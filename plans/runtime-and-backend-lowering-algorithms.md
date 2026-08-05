# Bingo Runtime 与 LLVM Backend Lowering 算法

本文规定 Bingo MIR 到 runtime ABI、LLVM IR、目标文件和最终二进制的实现细节。runtime 是 TypeScript 可观察语义的一部分，不是链接阶段的补丁；`.d.ts` 中存在某个 API，也不表示目标平台已经有实现。

runtime core 的实现语言、crate 边界、panic/unsafe 规则、原生静态库产物和 LLD 链接算法以 [rust-runtime-and-linking.md](rust-runtime-and-linking.md) 为准。本文中的 ABI/ObjectHeader/GC/状态机是跨语言语义契约，不表示用 C 或 Go 实现 runtime。

## 1. 目标与实现边界

计划中的首个可抛异常产品 profile 如下；Phase 2A 的 number-only 首切暂用 `exceptions=none`，不得接受任何可抛路径：

```text
semantics = static
gc = tracing-nonmoving
exceptions = status-code
strings = utf16
number = ieee754-f64
modules = static-graph
dynamic = disabled
```

强制边界：

1. HIR 负责 TypeScript 语义和求值顺序，MIR 负责显式 CFG、布局、检查、cleanup、状态机和 runtime 调用。
2. LLVM backend 只翻译已验证 MIR，不重新决定 overload、方差、对象 shape、异常语义或 capability。
3. runtime ABI 只接受明确 RepType/descriptor，不能以裸 `i8*` 绕过 GC、alignment 和类型检查。
4. 所有可能分配、抛出、挂起或进入外部代码的位置必须在 effect 和 safepoint 表中可见。
5. `BuildPlan` 只是 `canonical`、未解析的 backend request；Phase 2A 必须先用锁定 toolchain/runtime manifests 和 LLVM `TargetMachine` 解析不可变 `TargetContext`，再开始 RepresentationPlan 或 MIR。
6. LLVM verifier 成功只是结构正确的必要条件；仍需 runtime differential、sanitizer 和目标机测试。
7. Rust runtime 只暴露版本化 `extern "C"` ABI；Rust panic、引用、trait object 和标准库容器不得跨边界，普通失败以 status/exception handle 回到 MIR。

## 2. Runtime ABI 清单

### 2.1 CapabilityManifest

每个 runtime/host 能力由机器可读清单定义：

```text
Capability {
  logicalName       rt.array.push
  symbolName        __bingo_rt_array_push_v1
  layer             core | object | collection | async | eh | gc | host
  abiVersion        semver
  signature         AbiSignature
  effects           EffectSet
  requiredFeatures  []FeatureId
  targets           []TargetConstraint
  implementationHash Hash
}
```

resolver 输出的 `AvailableCapabilityCatalog` 是所选 runtime manifest 声明的可用实现索引、manifest hash 和约束集合；它不等于某个程序实际使用的 capability 闭包。structural MIR 之后，`BindRuntimeCapabilities` 才从 intrinsic 引用递归计算 `BoundCapabilityClosure`，并冻结实际 symbol、ABI hash 与 effect。source/HIR lowering 只能记录 logical capability requirements，不能提前宣称 exact effects。

binding 算法：

1. HIR/MIR intrinsic 使用 logical name，不直接拼接链接符号。
2. capability binding pass 只在 `TargetContext` 选定的 runtime manifest 和 `AvailableCapabilityCatalog` 中解析 profile、target 下唯一实现，并产出 `BoundCapabilityClosure`。
3. 比较 RepType signature、calling convention、ownership、exception 和 GC contract。
4. 递归闭合 `requiredFeatures`，检测环和版本冲突。
5. 把解析后的 symbol 与 ABI hash 固化到 MIR artifact。
6. 链接前再次读取目标 runtime manifest 并比较完整闭包；不得重新解析 `TargetContext`。

缺失能力必须在 backend 前诊断，不能等 undefined symbol。

### 2.2 ABI 类型

ABI schema 只允许有稳定布局的类型：

```text
Bool8, I32, U32, I64, U64, F64, USize
GcRef(typeDescriptor), ExternRef(abiId)
Utf16View(ptr, length), ByteView(ptr, length)
TaggedValue(tag, payload), StatusCode
```

public runtime ABI 中的 boolean 用 `i8`，避免不同 C ABI 对 `i1` 的分歧。string 默认传 GC-owned `StringRef`；只读无逃逸调用可传 `Utf16View`，其 lifetime 写入签名。

这里的 C ABI 指调用约定和固定布局，不限定实现语言为 C。Rust 侧所有公共结构使用 `#[repr(C)]`，所有导出函数使用带 ABI major 的 `extern "C"` symbol；Rust 内部随即转换到 safe implementation。`bingo-abi` schema 是 Rust header、Go backend ABI 描述和 layout cross-check manifest 的单一生成来源；具体 target DataLayout 仍以 LLVM `TargetMachine` 查询值为权威，不能由 ABI schema 覆盖。

## 3. TargetContext 解析

`ResolveBuildPlan` 只做默认值解析、canonicalization、前端 hash 绑定和请求校验，不探测本机，也不证明 target/runtime 可用。Phase 2A 使用唯一入口：

```text
ResolveTargetContext(BuildPlan, ToolchainManifest, RuntimeManifest)
    -> immutable TargetContext + authoritative DataLayout
       + AvailableCapabilityCatalog
       | target/toolchain/runtime diagnostic
```

解析必须验证 target triple、CPU/features、LLVM major、object format、data layout、runtime/ABI 版本、GC/EH profile 和所请求 feature 的兼容性；不得从 host 默认路径或临时探测结果静默补全。构建 `TargetContext` 时固定：

```text
TargetContext {
  triple
  cpu
  features
  llvmDataLayout
  pointerWidth
  endian
  cCallingConvention
  exceptionModel
  objectFormat
  tlsModel
  relocationModel
  codeModel
  optLevel
  sanitizerSet
  toolchainManifestHash
  runtimeManifestHash
  abiLayoutManifestHash
}
```

LLVM `TargetMachine` 查询的 DataLayout 字符串和结构化布局值是唯一权威来源。`ToolchainManifest` 记录 expected DataLayout/hash，ABI layout manifest 只做交叉校验；任一 mismatch 都 fail closed，不能用 manifest 值覆盖 LLVM 返回值。所有 size/alignment/offset 通过该 DataLayout 计算，禁止手写假定 64 位。raw frontend snapshot cache 与 target 无关；`BuildPlan` 冻结请求，`TargetContext` 冻结已解析实现。`RepresentationPlan`、RepType layout、MIR、LLVM 和 object emission 只能读取同一个 `TargetContext`/DataLayout，其 cache 必须包含 TargetContext hash；解析失败时不得生成占位 layout 或 MIR。

缓存键分层且不可互换：

```text
FrontendSnapshotKey = hash(frontend semantic config, canonical sources,
                           typescriptGoCommit, stdlib declaration hash,
                           snapshot schema)
BuildArtifactKey = hash(FrontendSnapshotKey, BuildPlan, TargetContext,
                        runtime/ABI/layout/lowering hashes)
```

因此换 target、CPU/features、GC、异常 profile、runtime capability、优化或 emit 选项只能失效下游 artifact，不能错误复用另一个 target 的布局或对象。

## 4. 核心内存布局

### 4.1 GC 对象头

首版非移动 mark-sweep 对象头：

```text
ObjectHeader {
  descriptor   *TypeDescriptor
  gcBits        u32
  flags         u16
  reserved      u16
  payloadSize   usize
}
```

`descriptor` 提供 kind、alignment、fixed size、pointer bitmap/trace callback、class identity、shape metadata 和可选 finalizer。对象头字段顺序属于 runtime ABI；backend 只能通过 layout manifest 获取 offset。

### 4.2 String

```text
StringObject {
  header
  lengthCodeUnits usize
  hashCache       u32
  flags           u32
  data            [length]u16
}
```

规则：

- length、index、slice 基于 UTF-16 code unit，不按 UTF-8 字节或 Unicode scalar。
- literal 以精确 code unit 序列进入只读常量池；需要 GC identity 时使用 immortal object descriptor。
- 拼接先做长度溢出检查，再一次分配并复制。
- string equality 比较长度和 code units，可使用缓存 hash fast reject。
- JS 可观察的 surrogate 行为不得被 Unicode normalization 改写。
- C/host UTF-8 转换只能出现在显式 ABI adapter，转换失败策略由 capability 定义。

### 4.3 固定 shape object

```text
ObjectObject {
  header
  shapeOrClass *ShapeDescriptor
  presenceBits [N]usize
  fields       layout-defined
}
```

data field 使用固定 offset；optional property 单独使用 presence bit。读取缺失 property 返回 `undefined`，不能读取未初始化 payload。写引用字段执行 write barrier。getter/setter 不占 data field，访问 lower 为绑定 receiver 的调用。

ShapeDescriptor 至少记录 property key、kind、offset/presence bit、mutability、method/accessor slot 和 enumeration order。字段 offset 可以按稳定 layout 规则安排，但可观察的 property enumeration 必须单独遵守 ECMAScript 顺序：整数 index key 升序、其他 string key 按插入顺序、symbol key 按插入顺序。static shape 冻结后不允许增删字段；dynamic shape 是单独 runtime 类型。

结构化对象跨布局使用显式 `ObjectView` RepType 或拒绝：

```text
ObjectView {
  source       GcRef<ObjectObject>
  viewDesc     *ObjectViewDescriptor   # frozen, non-GC metadata
}
```

`viewDesc` 保存 source/target property 的 offset、presence、accessor 和 read/write mapping；trace 只追踪 `source`，不追踪 descriptor。只读 view 可以协变。可写 view 只有在读写类型、store RepType 和 aliasing 均等价时才允许；任何隐式复制都会产生新 object identity，不能作为 identity conversion。`ObjectView` 的 identity/equality 必须比较 source object，getter/setter 仍按绑定 source receiver 调用。

### 4.4 Class、vtable 与 private field

```text
ClassDescriptor {
  typeDescriptor
  classIdentity
  baseClass
  instanceLayout
  vtable
  privateSlotTable
  staticObject
  initState
}
```

- base instance payload 位于派生 payload 前部，以保证合法 upcast offset。
- override 复用经类型和 ABI 验证的 vtable slot；需要 variance adapter 时 slot 指向 thunk。
- `#private` key 使用 class-scoped identity/slot，不使用字符串查找。
- base constructor 分配 receiver 并初始化 base fields；derived constructor 在 `super()` 前保持 `this` 未初始化，以 base constructor 返回的合法 receiver 建立 `this`，随后初始化 derived fields 并继续 body。失败时未发布对象仍由 GC 管理。
- static field/block 在 class init 函数按 source order 运行。

普通 structural object 不因 shape 相同就拥有 class identity；`instanceof` 使用 class descriptor chain，而不是字段集合。

### 4.5 Array 与 tuple

```text
ArrayObject {
  header
  length       usize
  capacity     usize
  elementDesc  *TypeDescriptor
  storage      *BufferObject
}
```

首版 static array 为 dense array。所有 index 在 `f64 -> valid integer index -> usize` 规范化后检查 bounds。扩容遵循确定增长策略，但增长率不是语言 ABI。reference element store 检查 element descriptor 并执行 write barrier。

稀疏 array、任意字符串 property、动态 `length` 删除元素等完整 JS 行为仅 dynamic array runtime 支持。fixed tuple 可内联为独立 layout；一旦经 array API 逃逸，必须显式 box/copy 成 ArrayObject。

### 4.6 Closure

```text
ClosureObject {
  header
  codePtr       function pointer
  envPtr        GcRef<Environment>
  abiSignature  *AbiSignatureDescriptor
}
```

capture 计划：

- immutable scalar 且不跨 suspend：可按值捕获。
- 可变绑定或多个 closure 共享：提升为 GC `Cell<T>`。
- object/reference：环境保存 GC ref，并进入 pointer map。
- lexical `this`、`super`、`new.target` 使用显式隐藏 capture。
- closure 不逃逸的情况可由后续 escape analysis 栈分配，但语义基线仍按 heap closure 验证。

间接调用先验证静态 AbiSignatureId；dynamic/FFI callable 使用独立 checked adapter，禁止任意函数指针 bitcast。

### 4.7 Tagged union 与 DynamicValue

static tagged union：

```text
TaggedUnion {
  tag       u32
  payload   aligned max-inline payload or GcRef
}
```

tag table 属于 public ABI。payload 的 GC pointer map 可按 tag trace，或统一使用 boxed payload。

`DynamicValue` 仅 interop/dynamic profile：

```text
DynamicValue { tag u32, flags u32, payload [16]byte }
```

其 box/unbox/property/call 全部经过 runtime capability。static MIR 中除标注的 boundary block 外不得出现 DynamicValue。

## 5. Tracing GC 算法

### 5.1 首版选择

GC v1 使用 single-mutator、stop-the-world、非移动、精确 mark-sweep：

1. 分配器从 size class/free list 获取对齐块并写 ObjectHeader。
2. 到达阈值或显式 safepoint 时，由唯一 mutator 停在已发布 roots 的状态。
3. 从 globals、TLS、shadow stack、async/generator frames 和 runtime handles 枚举 roots。
4. 按 TypeDescriptor pointer map/trace callback 标记。
5. 处理 weak reference 和 finalization queue。
6. sweep 未标记对象，清 mark bit，恢复 mutator。

非移动策略简化首版本机指针和 FFI，但不允许丢失 root。首版每个 runtime instance 只能注册一个拥有 Bingo heap 的 mutator thread；runtime service thread 只能投递消息或处理不触碰 Bingo heap 的 host 数据，不能并发读写 heap、直接执行 TypeScript callback 或自行触发 collection。跨线程 host callback 必须排队回到 owning mutator；`SharedArrayBuffer`/`Atomics` 和第二 mutator 在该 profile 中稳定拒绝。后续引入第二 mutator、移动/并发/增量 GC 都属于新的 ABI、effect 和 verifier profile。

Rust runtime 内部以不透明 `Gc<T>` 表示 Bingo heap handle，但 `Gc<T>` 本身不是 root，也不得提供可跨 safepoint 保存的无约束 Rust 引用。跨 MayAllocate/MaySuspend/MayBlock/host call 的值必须进入编译器生成的 root slot 或 runtime `Root<T>`；Bingo heap object 不由 Rust `Drop` 释放。Rust `Box`/`Arc` 只用于非 GC runtime 元数据。

### 5.2 Shadow stack root

第一阶段优先显式 shadow stack，避免一开始依赖目标相关 LLVM statepoint：

```text
GcFrame {
  previous    *GcFrame
  map         *GcFrameMap
  activeBits  []usize
  slots       []*ObjectHeader
}
```

`GcFrameMap` 是静态 slot 类型/trace schema，`activeBits` 是当前 safepoint 的精确活跃集合。函数 prologue 注册 frame，所有普通返回、status cleanup 和可选 unwind cleanup 都必须注销。MIR root placement pass 在每个 safepoint 前计算活跃 GcRef，将其 store 到 slot，再发布 active bitmap；死亡 slot 必须清为 null，或在发布前由 active bitmap 排除。collector 只扫描已发布的 active slot，不能把旧指针当作保守 root。safepoint 后 reload；phi/SSA 中的引用也必须 materialize，不能只存在寄存器。

root slot store、dead-slot clear、active bitmap publication 和 frame link/unlink 是优化器可见且有序的 `RootPublication` effect。LLVM emission 必须让 frame 地址真实逃逸到 runtime，并以带 side effect 的 ABI call/intrinsic 建立 compiler barrier；不得依赖注释、debug metadata 或仅在优化前存在的 store。任何 pass 都不得把 root store 移到 safepoint 后、把 dead-slot clear 移到 publication 前，或 DCE 掉 collector 可观察的 frame 更新。

优化后可增加 LLVM `gc.statepoint`/stack map backend，但必须与 shadow-stack 实现做 differential，且不可改变语言语义。

### 5.3 Safepoint

强制 safepoint：

- runtime allocation 和可能触发 GC 的 helper。
- 可能分配的 direct/indirect/extern call。
- loop backedge 的 profile-controlled poll。
- await/yield suspend 前。
- throw/status 传播以及可选 unwind shim 进入 runtime 前。
- blocking host call 前后。

MIR effect 系统必须标记 `MayAllocate`。backend 若发现可能分配的 call 前活跃 GcRef 未 root，直接 verifier error。

root audit 同时作用于最终 MIR 和优化后的 LLVM：每个 safepoint 都要能反查实际 slot store、active bit、reload 和 cleanup。GC 测试在 O0/O2 下强制每个可分配点触发 collection，并覆盖 live/dead slot 交替、phi、loop、status return、throw、callback 和 suspend；只验证优化前 root map 不构成发布门禁。

### 5.4 Write barrier

首版 STW mark-sweep 可使用无操作 fast path，但 MIR 仍生成语义级 `gc_write_barrier(owner, slot, value)`。这样未来并发/增量 collector 不需要重写前端。初始化未发布对象可由 verifier 证明并省略 barrier；对象发布后所有引用写入都保留。

### 5.5 WeakRef 与 finalizer

weak reference 不作为 mark root。标记完成后先清不可达 target，再把 FinalizationRegistry job 加入 microtask queue；callback 时序和“一定执行”不能作保证。未实现 weak/finalization lowerer 时 source subset gate 拒绝值使用；若 lowerer 已存在但所选 runtime 缺 capability，则由 ResolveTargetContext 后的 target capability gate 拒绝。

## 6. Module graph 与初始化

### 6.1 编译时图算法

使用 tsgo 已解析的 module identity 和 resolution mode 建图，不重新解析 import 文本。边分为 type-only、eager value、deferred、dynamic/host。type-only 边不进入 runtime init graph。

对 eager value graph 使用 Tarjan SCC：

1. 以入口和每个 module 源码中的 requested-module/import 声明顺序遍历；canonical ModuleId 只用于重复边、生成边和同序 tie 的确定性处理，不能改变可观察初始化顺序。
2. 为每个 SCC 先运行 instantiate phase，分配 export cells、function/class declarations 和 module state。
3. 再按规范化 DFS order 运行 evaluate phase。
4. export cell 是 live binding；import 读取 cell，不复制初始化值。
5. 未初始化 lexical export 读取产生 TDZ 异常。
6. module state 使用 `Uninstantiated -> Instantiating -> Instantiated -> Evaluating -> Evaluated/Failed`。
7. 失败状态缓存同一 exception，后续访问不重复执行副作用。

### 6.2 Module ABI

```text
ModuleDescriptor {
  moduleId
  abiHash
  exportTable
  instantiateFn
  evaluateFn
  state
  failure
}
```

public export cell 的 RepType/descriptor 属于 module ABI。CommonJS、`export =`、dynamic require 只能通过单独 interop loader，不能混入 static ESM 的 live-binding 算法。

### 6.3 Top-level await 与 import defer

top-level await 把 SCC evaluate 结果提升为 Promise/Future 状态；依赖 SCC 等待其完成，必须检测异步循环依赖。`import defer` 需要 namespace 首次可观察读取触发 evaluate，属于独立 capability；没有实现时拒绝，不能退化为 eager import。

## 7. Property、prototype 与迭代协议

### 7.1 静态 property access

固定字段 lower 为：receiver 单次求值 -> null check -> optional presence check -> GEP/load。accessor lower 为 direct/vtable call。method extraction 产生绑定 receiver closure 或显式 receiver pair，不能丢失 `this`。

### 7.2 Dynamic property access

computed key 只有在 checker/constant folder 得到固定 string/number/symbol 时可用 static shape。其他 key 需要 `rt.object.get/set/has/delete`，并且对象必须是 dynamic object。static object 不因为一次 computed access 自动升级为 dynamic，否则 layout、identity 和优化边界会悄悄改变。

### 7.3 Prototype

class descriptor chain 只实现受控继承和 `instanceof`。任意 `Object.setPrototypeOf`、`__proto__` 写入、prototype monkey patch 和 Proxy trap 属于 dynamic profile；static profile 拒绝。

### 7.4 Iterator lowering

for-of/array spread 等协议统一为：

```text
iterator = GetIterator(value)
try:
  loop:
    result = iterator.next()
    if result.done: break
    consume(result.value)
finally on abrupt completion:
  IteratorClose(iterator)
```

已知 dense array 可优化成 index loop，但只在证明 iterator method 未覆写、没有 Proxy/dynamic boundary 且 close 无可观察行为时进行。通用 iterator 使用 well-known symbol slot capability。

## 8. Cleanup、异常与资源管理

### 8.1 Cleanup IR

HIR 的 `try/finally`、`using`、scope-owned runtime handle 先变成 cleanup region：

```text
CleanupRegion {
  id
  parent
  actions in reverse-execution order
  exits: normal | return | break | continue | throw | suspend-failure
}
```

MIR cleanup expansion 为每个离开 region 的边生成共享 cleanup block，携带 `ExitReason` 和 payload。不得为 return/throw 分别复制一套可能漂移的 finally 逻辑。

`finally` 若再次 return/throw，会覆盖原 exit payload；`using` dispose 失败按 SuppressedError 规则与已有 exception 合并。

### 8.2 Exception object

所有抛出值规范化为 runtime exception carrier：

```text
ExceptionCarrier {
  thrownValue   TaggedValue or DynamicValue
  typeInfo      runtime RTTI
  sourceInfo    optional file/line/column
  stackToken    optional lazy stack capture
}
```

TypeScript 允许 throw 任意值；static profile 的可抛值必须可装入封闭 TaggedValue，其他需要 dynamic exception capability。catch variable 默认 `unknown`，使用前必须收窄。

### 8.3 Status-code 基线与可选 Native Unwind

MIR 只表示平台无关的 normal/exception successor、cleanup region 和 exception carrier ownership。第一个可执行 profile 固定为全链 status-code/result lowering：MayThrow 函数通过 `StatusCode` 加 out-result/exception handle 返回；调用点按 status 分支到 normal 或 exception successor；cleanup dispatcher 显式执行 `finally`、resource dispose、root frame 注销和 handle release。该 profile 的生成函数和 Rust helper 都是 `nounwind`，LLVM module 不需要 personality、landingpad 或 funclet。

native-unwind 是后续 target-specific profile，只有 bridge contract 通过目标机门禁后才启用：

- Itanium/DWARF EH（Linux/macOS 等）使用已锁定 personality、`invoke`、`landingpad`、`resume` 和 throw/rethrow shim。
- Windows MSVC EH 使用已锁定 personality、`invoke`、`catchswitch`、`catchpad`、`cleanuppad`、`cleanupret` 和对应 throw/rethrow shim。
- 只有极薄平台 shim 可以把已 root 的 Bingo `ExceptionCarrier` 转移给 native unwind；普通 Rust frame/helper 仍保持 `nounwind` status ABI。
- profile 必须定义 carrier 分配/释放和 rethrow ownership、foreign exception 拒绝或转换策略、uncaught boundary、shadow-stack cleanup 以及必需的平台链接库。

status-code 与 native-unwind 的 function ABI、object note、umbrella runtime 和 startup object 必须全链一致，不能混链。不得使用 `setjmp/longjmp`：它会绕过 cleanup、root 生命周期和 LLVM 优化约束。无 native unwind 的 target 继续使用同一 status-code 基线，而不是另造隐式异常语义。

### 8.4 noexcept 与 effect

只有 MIR effect 证明 `NoThrow` 的 call 才能省略 exception successor。status-code profile 中 MayThrow helper 必须检查显式 status；native-unwind profile 中可启动 unwind 的平台 shim 必须使用 `invoke`。优化不得把有可观察 cleanup 的 throw path 当作 unreachable。

## 9. Promise 与 microtask runtime

### 9.1 Promise 状态

```text
PromiseObject {
  state      Pending | Fulfilled | Rejected
  result     TaggedValue
  reactions ordered list
  handled    bool
}
```

resolve 执行 thenable assimilation，需要 self-resolution 检查和 once guard。reaction 总是进入 microtask queue，不能因 promise 已完成就同步调用。queue 由 host/runtime pump 驱动，模块/CLI entry 退出前的 drain 策略写入 host capability。

### 9.2 Async 状态机

对每个 async function：

1. 创建 frame layout：state、parameters、live locals、pending exception、cleanup cursor、promise capability。
2. 以 entry block 执行同步前缀，直到首个 await。
3. `await x` 调用 PromiseResolve/awaitable adapter，保存所有跨 suspend 活跃值和 GC roots。
4. 注册 fulfill/reject continuation，并返回 outer Promise。
5. continuation 根据 state 跳回 resume block；fulfill 产生 await value，reject 走 throw edge。
6. return resolve outer Promise；未捕获 throw reject outer Promise。
7. finally/using 状态跨 suspend 保存，恢复时继续正确 cleanup。

状态编号按 source order 稳定生成，frame descriptor 进入 debug metadata 和 GC trace map。不能把 async 简化为线程阻塞等待。

### 9.3 Async iteration

`for await` 先获取 async iterator；允许 sync iterator adapter 时显式 capability 包装。每次 next、value await、body、IteratorClose 都有 reject/exception 边。break/return/throw 必须 await async `return()` 完成后再离开。

## 10. Generator 状态机

Generator frame 保存 `SuspendedStart/Executing/SuspendedYield/Completed`、locals、operand temporaries、exception/cleanup state。入口返回 GeneratorObject，不执行 body。`next(value)`、`throw(error)`、`return(value)` 分别产生 resume reason；重入 Executing 状态必须报错。

`yield` 保存 continuation 后返回 `{value, done:false}`；自然 return 返回 `{value, done:true}`。`yield*` 驱动 delegate 的 next/throw/return 并在 abrupt completion 执行 close。async generator 在此基础上串行处理 request queue 并通过 Promise 返回结果。

## 11. `using` / `await using`

资源绑定时立即查找并缓存 dispose method，避免 cleanup 时再次动态解析：

1. 求值 initializer 一次。
2. null/undefined 按规范决定是否无操作。
3. 获取 `Symbol.dispose` 或 `Symbol.asyncDispose` method 并验证 callable。
4. push `{resource, method, asyncFlag}` 到当前 cleanup region。
5. scope 所有 exit 逆序调用。
6. `await using` 的 dispose 结果进入 async 状态机。
7. 多重失败构造 SuppressedError 链，保持原异常顺序。

缺少 symbol/disposable/async 的 source lowerer 或 semantic proof 时 subset gate 拒绝；lowerer 已存在但所选 runtime/ABI capability 不可用时，由 ResolveTargetContext 后的 target capability gate 拒绝。

## 12. 标准库调用选择

调用 standard API 时按优先级选择：

1. 语义完全等价的 MIR/LLVM intrinsic，例如严格数值运算。
2. 已知 layout 的专用 runtime helper，例如 dense array push。
3. protocol capability，例如 iterator、promise、dispose。
4. generic runtime helper + TypeDescriptor。
5. 显式 host/interop adapter。

选择 intrinsic 前必须证明边界语义：NaN、负零、溢出、UTF-16、SameValueZero、property enumeration order、异常和 callback effect。证明不足就调用 runtime，不以性能为由改变行为。

具体实现可落在三类 artifact：LLVM/MIR intrinsic、Rust native runtime capability、self-hosted TypeScript stdlib function。self-hosted 函数进入普通 HIR/MIR verifier；泛型函数按 InstantiationKey 单态化或使用 descriptor-shared ABI，不能要求 umbrella runtime archive 穷举用户类型。

## 13. Host FFI

FFI manifest 明确：symbol/library、C/native signature、Bingo signature、string encoding、ownership、nullability、threading、blocking、throw/status、callback lifetime 和 GC pin/handle 规则。

边界算法：

1. 验证 capability 和 target。
2. 执行 checked marshalling；任何临时 buffer 建立 cleanup action。
3. GC object 不直接把内部地址长期交给 host；使用 pin 或 stable handle。
4. blocking call 前保存 roots并通知 runtime。
5. native error 按 manifest 转 exception/Result。
6. callback 建 trampoline + closure handle，释放策略必须明确。

仅有 `.d.ts`、C header 或同名系统函数不足以生成 FFI。

## 14. MIR 到 LLVM 类型映射

| MIR | LLVM | 说明 |
| --- | --- | --- |
| `I1` | `i1` | 仅内部布尔 |
| `I8/I32/U32/USize` | 对应整数 | USize 跟随 DataLayout |
| `F64` | `double` | JS number 基线 |
| `GcRef<T>` | target address-space pointer | 不得与 ExternRef 随意 bitcast |
| `FuncRef` | closure object pointer | direct function 可另有 LLVM function pointer |
| fixed struct | named LLVM struct | layout freeze 后创建 body |
| tagged union | named struct `{tag,payload}` | public tag/offset 进入 ABI hash |
| `VoidRep` | `void` | 只用于无值返回 |
| `NeverRep` | 无 LLVM value | block 以 unreachable/throw 终止 |

LLVM opaque pointer 模式下仍由 MIR RepType verifier 保证 pointee 语义，不能把类型责任交给 LLVM pointer type。

## 15. 指令 Lowering

### 15.1 SSA 与 CFG

- 每个 MIR block 先创建 LLVM BasicBlock，再填指令，支持前向边。
- block parameters/phi 在所有 predecessor 已知后补全；incoming 顺序按 stable BlockId。
- `br/switch/return/throw/unreachable` 后禁止追加指令。
- critical edge 是否拆分由 cleanup/root/debug 需求决定，并保留 source provenance。

### 15.2 Memory

- `alloc_local` 只在 entry block 创建 alloca，或经明确 stack-slot pass 放置。
- load/store alignment 来自 layout；volatile/atomic 只由 MIR 显式标记。
- field GEP 使用 LayoutId offset proof；optional field 先检查 presence bit。
- array access 先检查 index conversion、负数/NaN/非整数和 bounds，再计算地址。
- 引用 store 在需要时调用/inline write barrier。

### 15.3 Number 与位运算

普通 `+ - * / %` 使用 f64 语义，并为 JS `%`、幂、rounding 特例选择正确 intrinsic/runtime。位运算显式实现 ToInt32/ToUint32：处理 NaN/Infinity/负零、truncate modulo 2^32，再执行 i32 op，结果按 TS number 转回 f64。shift count mask 为 5 bit。

禁止给可能溢出的 JS number 运算错误添加 LLVM `nsw/nuw`；禁止使用 fast-math 破坏 NaN、Infinity、signed zero，除非独立非 JS 数值 profile 明确开启。

### 15.4 Comparison

strict equality 按类型分派：f64 遵循 NaN/zero，string 比 code units，symbol/object 比 identity。relational string 使用 UTF-16 lexicographic；异构 coercion 在 static profile 不可达，dynamic profile 调 runtime。`Object.is` 与 `===` 分开实现。

### 15.5 Call

direct call 使用冻结 LLVM FunctionType 和 calling convention。closure call 传隐藏 env；method call 传 receiver；descriptor-shared generic 传隐藏 descriptor。status-code profile 的 MayThrow call 返回 status 并显式分支；只有 native-unwind profile 的已审计平台 shim 使用 `invoke`。MayAllocate 前发布 roots。tail call 只有 cleanup stack 为空、ABI 相同且没有活跃 root frame 特殊要求时允许。

## 16. 检查与失败路径

null、bounds、tag、class cast、integer index、capability guard 统一 lower 为：condition -> likely success block / cold failure block。status-code 基线在 failure block 构造结构化 status/exception carrier 并跳到 exception successor；native-unwind profile 才可调用具名 throw shim 并以 `unreachable` 结束。真正 process-fatal 的 trap/OOM policy 必须使用不同 capability，不能冒充语言异常。

检查消除只能使用 MIR proof：支配范围内已检查、loop range proof、sealed layout、non-null flow。LLVM 优化推导不能反向改变 Bingo diagnostic 或异常种类。

## 17. Debug info 与 source map

- compile unit 保存 TypeScript source、tsgo commit、Bingo schema 和 target profile。
- function/lexical block/local 使用原 SourceSpan；synthetic thunk/state/cleanup 标记 artificial，并指向触发语法。
- 类型 debug metadata 展示 TsType 名称，同时关联实际 RepType/layout。
- async/generator frame locals需要逻辑变量映射，不能只显示 state struct field。
- optimization 后仍输出 line table；generated runtime helper 不冒充用户代码位置。

诊断与 crash dump 应能沿 `LLVM instruction -> MIR node -> HIR node -> snapshot NodeId -> source span` 回溯。

## 18. 优化流水线

固定顺序建议：

```text
source type normalization
-> typed HIR + semantic desugaring
-> specialization worklist to fixed point
-> variance/conversion validation
-> ResolveTargetContext(BuildPlan, toolchain/runtime manifests)
-> target representation/layout selection
-> MIR CFG/SSA + cleanup/exception/async lowering
-> structural MIR verifier
-> capability binding and exact effect freeze
-> checked local simplification / devirtualization
-> escape analysis (optional stack promotion)
-> bounds/null check elimination with proofs
-> root placement and cleanup freeze
-> final MIR verifier
-> LLVM emission
-> LLVM verifier
-> conservative LLVM optimization pipeline
-> post-opt LLVM verifier
-> post-opt safepoint/root publication audit
-> object emission
```

specialization 必须在 target layout 和 MIR 前达到 fixed point；`ResolveTargetContext` 必须在 RepresentationPlan/MIR 前成功，后续 target-dependent pass 不得回读未解析 `BuildPlan`。capability binding 必须在 MIR 优化前冻结准确 effect，否则优化器无法证明 safepoint 和 throw 边界。root placement 后不得运行会引入新 safepoint 或隐藏引用 lifetime 的自定义 MIR pass。LLVM pass pipeline 首版禁用不符合 JS number 语义的 fast-math，并必须保留 `RootPublication` 的 side effect/ordering；每次 LLVM 升级做 IR、root publication、object 和 differential 审计。

## 19. 目标文件与链接

1. 复用 ResolveTargetContext 已创建并绑定 hash 的 LLVM TargetMachine，核对 module triple/data layout；链接阶段不得重新选择 target 或创建第二个 authoritative layout。
2. 发射 object 而非把文本 IR 当最终产物。
3. 根据 bound MIR intrinsic 计算 capability 闭包，选择 target/profile/feature/ABI hash 匹配的唯一预构建 Rust umbrella `staticlib`；首版不把 Rust bitcode 或跨语言 LTO 当作发布契约。
4. 链接 startup object、module/self-hosted stdlib objects、该 umbrella archive、manifest 明确的可选外部引擎 archives 和显式 host libraries。
5. 启动 shim 初始化 GC、scheduler、module registry，再执行 entry module。
6. 通过确定性 response file 调用目标 LLD driver，并检查 capability symbol closure、ABI note/hash 和重复 runtime version。
7. 产物嵌入 build manifest：source hash、tsgo commit、IR schema、LLVM version、target、profile、rustc/Cargo features、umbrella/external artifact hashes 和 LLD version。
8. 可复现构建要求稳定 module/archive order、symbol naming、timestamp policy 和 debug path remap。

不支持的 native library、target feature 或 linker 行为必须在构建配置阶段报错。

## 20. Backend verifier

LLVM emission 前检查：

- 所有 MIR value 有确定 RepType，所有 LayoutId 已冻结。
- CFG、phi、dominance、cleanup 和平台无关的 exception edge 完整。
- 每个 MayAllocate safepoint 的活跃 GcRef 已 root。
- 每个引用 store 有合法 barrier 策略。
- indirect call 的 AbiSignatureId 已验证。
- runtime intrinsic 已绑定 capability，签名/effect/hash 匹配。
- static profile 没有未授权 DynamicValue。
- target 不支持的 EH/TLS/atomic/ABI 已拒绝。

LLVM emission 后检查：

- `LLVMVerifyModule` 在优化前后都成功。
- module triple/data layout 与 TargetMachine 一致。
- status-code profile 没有意外 personality/unwind edge；native-unwind profile 的 personality、landingpad/funclet 和 shim 结构符合 target contract。
- ABI/public struct layout 与 manifest 计算一致。
- 没有 unresolved runtime symbol、非法 address-space cast 或意外 external declaration。
- 唯一 Rust umbrella archive 的 target、panic、GC、exception、ABI major、capability 和 layout notes 与构建请求一致；外部引擎 archive 只能来自 manifest 闭包。

## 21. 失败原子性和编译并发

- 每个 module 先发到独立 LLVM Module/object 临时产物，完整验证后才进入 artifact cache。
- 并行 worker 不共享可变 LLVMContext；每 worker 使用独立 context，跨 module 只共享序列化 ABI schema。
- linking 使用稳定 ModuleId 排序。
- 某 module 失败时不发布半成品 object/cache entry。
- runtime manifest 和 target context immutable，可并发读取。
- compiler crash 时保留最小复现所需的 snapshot/MIR hash 和阶段，不自动发布包含绝对用户路径的 artifact。

## 22. 最低验证矩阵

| 层 | 必须验证 |
| --- | --- |
| layout | 32/64 位 size/alignment、optional bit、inheritance、private slot、tag table |
| object/view | cross-layout read、accessor receiver、identity/equality、mutable alias write、implicit-copy rejection |
| string | surrogate、空串、拼接溢出、index/slice、UTF-8 FFI roundtrip |
| array | bounds、扩容、reference barrier、readonly view、dense/sparse 拒绝 |
| closure | by-value/by-cell、recursive capture、receiver、escape、indirect ABI |
| GC | single-mutator/second-mutator rejection、deep graph、cycle、O0/O2 active-root audit、dead-slot、root across call/throw/await、weak ref、OOM path |
| module | SCC、live binding、TDZ、一次初始化、失败缓存、top-level await |
| EH/cleanup | status-code return/throw/finally、nested using、profile 混链拒绝；后续 Windows/Itanium native unwind |
| async | sync prefix、multiple await、reject、finally、microtask order |
| generator | next/throw/return、yield*、close、reentrancy、async queue |
| LLVM | pre/post verify、debug line、target object、link closure、ABI hash |
| determinism | 不同并发度和临时路径产生相同规范化 artifact |

runtime 行为使用 Node/规范 oracle 做 differential；不应依赖 Node 的对象地址、错误文本或调度器内部细节。所有 case 遵守 [test-authoring-standards.md](test-authoring-standards.md) 的独立性要求。

## 23. 实施顺序

1. Phase 2A 先用锁定 toolchain/runtime manifests 实现 `ResolveTargetContext`，并固定首切所需的最小 `bingo-abi`、唯一空 umbrella `staticlib` 和 deterministic response file。
2. 完成 `VERT-001`：`x86_64-unknown-linux-gnu` 的 `add(number, number)` 经过 validated target-independent snapshot、verified HIR、BuildPlan/manifest resolver、RepresentationPlan join、target-aware verified MIR、真实 go-llvm、LLVM verifier、object emission、空 startup/umbrella runtime、LLD 和 run harness；不引入对象、GC 或 EH。
3. 实现 MIR checks、`ObjectView`/fixed object/array/closure layout、single-mutator shadow-stack root 和最小 mark-sweep runtime，并通过 O0/O2 root audit。
4. 实现 self-hosted stdlib package、module SCC 初始化、generic specialization 与 iterator。
5. 实现全链 status-code cleanup、using 和 exception carrier；Rust helper 保持显式 status，panic 不表达语言异常。
6. 实现 Promise/microtask、async/generator frame。
7. Linux/Windows 各自 bridge contract 和目标机测试通过后，再提供可选 native-unwind profile。
8. 实现 host FFI、dynamic profile、weak/finalization 和高级标准库能力。
9. core 稳定后将 ABI/memory/core crates 收敛到 `no_std + alloc`。
10. 最后才开启高级 LLVM 优化、statepoint、并发 GC、跨模块优化、可选跨语言 LTO 和更多 target。

每一步的支持开关、拒绝策略和诊断必须先于 capability 对用户可见；详细规则见 [unsupported-semantics-and-diagnostics.md](unsupported-semantics-and-diagnostics.md)。
