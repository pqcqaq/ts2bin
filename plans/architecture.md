# ts2bin 项目设计

## 1. 目标与非目标

### 目标

ts2bin 将经过 TypeScript 类型检查的程序编译成可验证、可优化、可链接的 LLVM 目标代码。第一目标不是兼容所有 JavaScript 的动态行为，而是得到一个可解释、可测试、可逐步扩展的静态编译子集。

首版必须具备：

- TypeScript 语法解析和完整前端诊断复用 `typescript-go`。
- 符号、类型、重载、控制流收窄、模块依赖的稳定快照。
- 明确的 Bingo HIR 和 Bingo MIR，以及各自的 verifier。
- 基本值类型、函数、闭包、结构化对象、数组、类、模块、异常和资源清理。
- LLVM IR 输出、`VerifyModule`、优化流水线和目标文件生成。
- 编译期拒绝不可靠断言和未实现的动态语义，而不是生成“看似能跑”的错误代码。

### 非目标

以下能力不作为第一版隐式承诺：`eval`、`new Function`、`with`、任意 `Proxy`/反射改布局、运行时改变原型、完全兼容 JavaScript 抽象相等和隐式数值转换、跨模块热替换、任意 npm 原生扩展 ABI、浏览器 DOM、Node 内置模块和任意宿主 API。

## 2. 仓库与集成边界

`pqcqaq/typescript-go` fork 保留模块路径 `github.com/microsoft/typescript-go`；AST/checker 位于 `internal/`，因此外部 sibling module 不能合法导入这些包。推荐结构如下：

```text
typescript-go/                         # 维护中的薄 fork
  cmd/ts2bin/                           # CLI、配置、诊断输出
  internal/ast2bingo/                   # tsgo AST + Checker -> Bingo HIR
  internal/bingo/hir/                   # 高层类型和语义 IR
  internal/bingo/mir/                   # 显式 CFG、布局、调用约定、清理
  internal/bingo/verify/                # HIR/MIR verifier
  internal/llvmbackend/                 # Bingo MIR -> go-llvm
  internal/runtimeabi/                  # runtime 函数签名与布局契约
  runtime/bingo-rt/                     # Rust workspace and umbrella staticlib
  testdata/ts2bin/                      # source、diagnostics、HIR/MIR/LLVM golden
```

适配层只依赖 `ast.Node` 的只读访问、`Program`、`Checker` 的稳定查询；不得让 Bingo 包到处 type-switch `ast.Node` 的私有实现。上游更新时只修改适配层和快照测试。

本架构的可执行细节分散在四份规格中，实施时不能只依据本文件的叙述：

| 边界 | 详细规格 | 进入下一层的门槛 |
| --- | --- | --- |
| tsgo -> snapshot | [tsgo-integration.md](tsgo-integration.md) | 诊断通过、ID 稳定、checker 已 release |
| snapshot -> typed HIR；BuildPlan + manifests -> TargetContext；RepresentationPlan join -> MIR | [bingo-ir-spec.md](bingo-ir-spec.md) | snapshot/HIR 与 typed resolver envelope 分别验证，join provenance 一致，类型、布局、CFG 和 effect 通过 verifier |
| `.d.ts` -> runtime | [stdlib-runtime-plan.md](stdlib-runtime-plan.md) | capability manifest 有实现且 ABI hash 匹配 |
| 源码 -> 发布物 | [testing-conformance-and-release.md](testing-conformance-and-release.md) | conformance、差分、LLVM verifier、可复现构建通过 |
| 规格 -> 开发任务 | [implementation-backlog.md](implementation-backlog.md) | issue 依赖、artifact 和验收命令齐全 |

这四条边界分别解决“输入是否可信、IR 是否自洽、调用是否可链接、产物是否可发布”。任何一层失败都必须保留自己的诊断分类，不能把错误延迟到链接器或运行时。

备用方案是启动 `tsgo api` 进程并通过 JSON-RPC/MessagePack 交互，但当前 README 将 API 标为未就绪，且协议不是完整 typed AST 导出接口，只适合作为未来跨进程边界，不适合作为第一版核心依赖。

## 3. 编译流水线

```mermaid
flowchart LR
  A[TS source + tsconfig] --> B[typescript-go Program]
  B --> C[parse / bind / type check]
  C --> D[target-independent typed snapshot]
  D --> E[subset gate + canonical BuildPlan]
  E --> F[source type plan]
  F --> G[typed HIR + semantic desugaring]
  G --> H[specialization fixed point]
  H --> I[variance / conversion]
  I --> J[Phase 2A ResolveTargetContext]
  T[toolchain and runtime manifests] --> J
  J --> K[target representation / layout]
  K --> L[MIR CFG/SSA + cleanup/EH/async]
  L --> M[structural MIR verify]
  M --> N[capability binding + effect freeze]
  N --> O[proven MIR optimization]
  O --> P[root placement + cleanup freeze]
  P --> Q[final MIR verify]
  Q --> R[LLVM IR / verifier / object]
  R --> S[target machine / linker]
  U[bingo-rt umbrella] --> S
```

`BuildPlan` 是绑定 `FrontendSnapshot` 的 canonical、不可变但尚未解析的 backend request；其中的 target、CPU/features、runtime、GC、异常和 LLVM 版本只表达用户请求，不证明本机或发布工具链可执行。`ResolveBuildPlan(FrontendSnapshot, buildConfig)` 只负责默认值、规范化、校验和哈希。Phase 2A 必须调用 `ResolveTargetContext(BuildPlan, toolchain manifest, runtime manifest)`，验证请求并冻结 immutable TargetContext、LLVM TargetMachine 的权威 DataLayout、ABI、调用约定、异常/GC profile、manifest hash 与 `AvailableCapabilityCatalog`；失败时在表示规划前 fail closed。`RepresentationPlan`、MIR 和 LLVM backend 只能消费这些 resolver 结果，不能直接把 `BuildPlan` 当作已解析目标。structural MIR 后 capability binding 才生成程序实际使用的 `BoundCapabilityClosure`。

`bingo-rt` 使用 Rust 实现，并为每个 target/profile/feature set 预编译一个 umbrella `staticlib`（`.a`/`.lib`）。workspace 内部 crate 使用 Rust `rlib` 依赖关系，不把多个各自携带 Rust 传递依赖的 `staticlib` 混链；BigInt、RegExp、ICU 等独立外部引擎可由 capability 闭包额外选择。LLVM 生成代码只通过版本化 `extern "C"` ABI 调用 runtime；用户对象、self-hosted stdlib object、startup object、唯一 umbrella runtime 和显式外部引擎 archive 最终由 LLD 链接。Rust ABI、trait object、panic 和 Rust 标准库容器不得进入 Bingo public ABI；详细契约见 [rust-runtime-and-linking.md](rust-runtime-and-linking.md)。

每一步的输入输出都可序列化：失败时打印源位置、Bingo 节点 ID、源类型和目标 LLVM 类型。这样可以定位“TypeScript 类型正确但 lowering 错误”和“LLVM verifier 错误”两种完全不同的问题。

### 3.1 前端快照

快照是不可变的内部 DTO，而不是 `ast.Node` 指针的长期缓存。建议字段：

```text
NodeId, SourceSpan, SyntaxKind, SyntaxPayload, NamedChildEdges
SymbolId, ResolvedSymbolId, DeclarationId
TypeId, ContextualTypeId, NarrowedTypeId
SignatureId, SelectedOverload, TypeArguments
FlowFacts, CaptureSet, ModuleId
ConstantValue, SourceTypePayload
```

快照阶段要保存“类型查询结果”而不是只保存语法类型节点：`T[K]`、条件类型、映射类型和重载需要 checker 已解析的结果。`SyntaxPayload` 和具名 child edge 必须足以在不重新打开 AST、checker 或未校验源文件的前提下完成 lowering；不能把 `IterChildren` 的无名顺序当作持久化语法契约。若类型仍是未实例化 type parameter 或不可测量 variance，快照应保留可诊断的 source type 状态，交给 subset gate 或后续 specialization 决定是否拒绝。

快照是整个编译链的并行边界：同一 checker 借用期间按文件捕获，release 后才允许 HIR lowering 并行。raw `ProgramSnapshot` 是 `FrontendSnapshot` artifact 的序列化根对象，只包含会改变 tsgo 前端语义的配置、规范化源码身份/内容、`typescriptGoCommit`、stdlib declaration hash 和 snapshot schema version；它不得包含 target triple、CPU/features、GC、异常模型、runtime capability、优化级别或 emit 选择。

profile、target、runtime capability 和输出选项在 subset gate/build planning 阶段进入 canonical `BuildPlan`，但此时仍是未解析请求。缓存键分层为 `FrontendSnapshotKey = hash(frontend semantic inputs)` 与 `BuildArtifactKey = hash(FrontendSnapshotKey, BuildPlan, TargetContext, runtime/ABI/layout/lowering hashes)`，因此同一 typed snapshot 可以安全复用于多个 target，而 target-dependent 诊断和产物不会错误共享。

### 3.2 Bingo HIR

HIR 保留 TypeScript 的语义结构，允许后续决定布局。核心对象：

```text
Module       imports, exports, init order, top-level await capability
TypeDef      nominal/structural identity, fields, methods, variance
FuncDef      params, result, generic params, effects, captures
Block        source order and structured statements
Expr         typed expression with conversion and narrowing facts
Pattern      binding/destructuring pattern
ConstValue   literal/enum/const-foldable value
```

HIR 类型分为两层：

1. `TsType`：`Any`、`Unknown`、`Never`、literal、union、intersection、conditional、mapped、type parameter、interface/class 等源语言类型。
2. `RepType`：实际值表示，如 `F64`、`I32`、`Bool`、`Utf16String`、`BigIntRef`、`ObjectRef`、`ArrayRef`、`FuncRef`、`NullableRef`、`DynamicValue`。

`TsType` 可在 HIR 中存在而不产生运行时实体；`RepType` 必须在进入 MIR 前确定。二者不可混用。

### 3.3 Bingo MIR

MIR 是 LLVM 的前一层，必须显式表示：

- 基本块、跳转、phi/SSA 值和不可达块。
- `alloc_local`、`load`、`store`、字段/元素访问、边界检查和空值检查。
- `call_direct`、`call_indirect`、闭包环境、方法 dispatch，以及平台无关的 normal/exception successor。
- `convert`、`checked_cast`、`dynamic_box` 和 `dynamic_unbox`。
- `cleanup_push`、`cleanup_pop`、`defer`、异常边和函数返回边。
- `await`/`yield` 的状态机保存点。
- 模块初始化、TLS、全局变量和 runtime ABI 调用。

MIR verifier 应拒绝：未定义值、支配关系错误、phi 入边不完整、类型不匹配、错误的异常边、重复释放和未处理 cleanup。

HIR 到最终 MIR 使用唯一的分层 pass DAG，而不是把 HIR、CFG、target layout 和 GC pass 混成一个线性列表：

```text
source type normalization
  -> typed HIR construction and semantic desugaring
  -> generic specialization worklist to fixed point
  -> variance/conversion validation
  -> ResolveTargetContext(BuildPlan, toolchain/runtime manifests)
  -> target representation, layout and calling convention selection
  -> HIR-to-MIR evaluation order + CFG/SSA lowering
  -> cleanup / exception-profile / async-state lowering
  -> structural MIR verification
  -> runtime capability binding and exact effect freeze
  -> proven MIR simplification / escape analysis
  -> GC root placement and cleanup freeze
  -> final MIR verification
  -> LLVM emission
```

HIR verifier 负责 source types、结构化控制流、求值顺序和 effect；MIR verifier 负责 RepType、dominance/phi、布局、cleanup、已绑定 capability 和 safepoint root。specialization 是可重复 worklist：后续 desugaring 若产生新实例，必须回到 fixed point，不能把未实例化 type parameter 留给 MIR。target-dependent pass 必须读取已解析 `TargetContext`，任何 pass 都不能重新调用 checker 猜测源类型；完整规则见 [bingo-ir-spec.md](bingo-ir-spec.md) 和 [implementation-specification.md](implementation-specification.md)。

## 4. 运行时表示与 ABI

### 4.1 静态 profile（默认）

默认 profile 追求可验证和可优化，不模拟所有 JavaScript 隐式规则。

| TypeScript 类型 | Bingo 表示 | 规则 |
| --- | --- | --- |
| `boolean` | `i1` 或 ABI `i8` | 只接受布尔运算，禁止数字隐式转换 |
| `number` | `f64` | 保留 JS IEEE-754；整数 API 需显式转换 |
| `bigint` | `BigIntRef` | 由 runtime 提供任意精度；禁止与 `number` 混算 |
| `string` | `{ptr: i16*, len: usize}` | UTF-16 code unit 语义，避免把 UTF-8 当作 JS 字符串 |
| `null`/`undefined` | 独立零大小标签或 nullable bit | 两者不混同，严格空值检查 |
| `symbol` | `SymbolRef` | 身份比较交给 runtime |
| `object`/class/interface | `ObjectRef` | 已知布局优先，动态属性需显式 profile |
| `Array<T>` | `ArrayRef<T>` | 可变容器默认不变；访问可插入边界检查 |
| `ReadonlyArray<T>` | `ArrayRef<T>` 只读 view | 元素类型可协变 |
| 函数类型 | `FuncRef{code, env, signature}` | 闭包环境不可丢失 |

静态 profile 的默认运行时组合为 `gc=single-mutator-tracing-nonmoving`、显式边界检查、严格函数参数逆变和版本化 runtime ABI。`gc=arc`、`gc=arena`、`dynamic`、`Proxy` 和宿主 FFI 都必须由 profile 明确开启，并在 `BuildPlan`、MIR artifact 和最终产物 provenance 中记录；它们不得污染 raw frontend snapshot。

`number` 采用 `f64` 是语义选择，不是 LLVM 默认选择；不要把所有 TS `number` 直接降成 `i32`。位运算、数组索引、移位和整数 API 必须生成明确的 `f64 -> i32/u32` 转换及溢出/截断策略。

### 4.2 dynamic profile（显式开启）

dynamic profile 提供 `DynamicValue`（tag + payload）、属性字典、原型链、JavaScript coercion 和运行时 cast。它是兼容层，不得让静态 profile 偷偷使用。所有进入 dynamic profile 的边界必须在 HIR 记录 `DynamicBoundary`，以便审计和性能统计。

### 4.3 对象与类布局

- interface、type alias、泛型约束默认只在编译期存在。
- class 产生稳定的实例布局、方法表和 class identity；`private/protected` 保留类型检查语义。
- 普通对象字面量按 shape 分配；shape 不稳定时进入 dynamic profile。
- `#private` 字段使用隐藏 slot 或 class-private descriptor，不能退化为公开字符串属性。
- `static {}` 降为类初始化函数，按模块初始化顺序执行。

结构化对象跨布局默认生成显式 `ObjectView` 或拒绝。`ObjectView` 保存 source object identity 与 frozen property/accessor/offset mapping；只读 view 可以协变，可写 view 只有在 source/target 的读写类型、store representation 和 aliasing 全部等价时允许。identity/equality 始终落到原对象；隐式字段复制不能伪装成 identity conversion，显式 copy adapter 必须声明会产生新 identity。

### 4.4 Runtime 实现与链接

runtime core 使用 Rust，而不是由 Go 或 C 实现。目标不是假设 Rust 自动解决 GC 或 ABI 安全，而是把原始指针、layout、root、write barrier、原子和平台 FFI 限制在可审计的 `unsafe` 边界内；字符串、集合、Promise 状态和大部分算法保持 safe Rust。

发布物按 target/profile 携带：

```text
startup object
+ one Rust umbrella staticlib
+ optional external-engine archives
capability manifest
ABI/layout manifest
runtime lock and artifact hashes
```

Rust 导出函数使用带 ABI major 的 `extern "C"` symbol，普通失败通过 status/exception handle 回到 MIR 异常边；release runtime 使用 `panic=abort`，panic 不得表达 TypeScript `throw` 或穿越 ABI。首个可执行异常契约是全链 status-code/result lowering；native unwind 是后续 target-specific profile，Rust helper 仍保持 `nounwind`，由已审计的平台 shim 把 exception carrier 转为 unwind。不同异常 profile 的 object/runtime 不得混链。

Bingo 使用自有 tracing GC；GC v1 明确为 single-mutator、stop-the-world、非移动 collector，不承诺并发 mutator、`Atomics` 或跨线程直接回调。`Gc<T>` 不等于 root，跨 MayAllocate/MaySuspend/host call 的活跃引用必须由编译器 root map 或 runtime `Root<T>` 保护。引入第二 mutator、并发/增量 GC 或 LLVM statepoint 都属于新的 ABI/verifier profile。

首版只把唯一 Rust umbrella native archive 作为稳定 runtime 发布边界，不发布 Rust bitcode ABI，也不启用跨语言 LTO。高层 Array/String/Iterator/Promise 等规范算法优先以受限 TypeScript 自举并作为已验证 HIR/package 分发；底层 storage、内部槽、GC、hash/equality 和调度器由 Rust 提供。

## 5. TypeScript 类型语义

### 5.1 类型分层

类型检查器的 `TypeFlags` 包含 primitive、literal、union、intersection、type parameter、object、conditional、indexed access、template literal 等。Bingo 不能试图为每个 TypeScript 类型都创建 LLVM 类型：

- primitive/literal：可直接得到 `RepType`。
- union：若可由稳定 runtime tag 区分，使用 tagged union；否则必须先收窄或使用 `DynamicValue`。
- intersection：合并已知字段/接口契约；冲突布局必须通过适配器或拒绝。
- conditional/mapped/template literal type：通常是 C，先由 checker 求值，再落为具体类型；无法求值时 R/P。
- generic type parameter：在 specialization 前只保留约束和 variance，不能假设所有实例都同一 LLVM 表示。

### 5.2 协变、逆变与不变

tsgo 已实现 `Invariant/Covariant/Contravariant/Bivariant/Independent` 及 unreliable/unmeasurable 标记。Bingo 采用下面的独立规则：

| 位置 | Bingo 默认方差 |
| --- | --- |
| 函数返回值、`readonly` 字段、只读集合元素 | 协变 |
| 函数参数、`in` 类型参数 | 逆变 |
| 可写字段、可变数组元素、读写属性 | 不变 |
| 同时出现在输入和输出 | 不变 |
| 未使用的参数 | independent |
| TS 历史 method bivariance | 仅兼容模式；静态 ABI 不直接接受 |

实现要求：

1. 先使用 checker 的 assignability 和 inference 结果，保留 TypeScript 诊断兼容性。
2. 再在 Bingo 计算布局方差；如果 checker 说可赋值但 Bingo 发现可写位置不变，生成复制/适配 thunk 或报 `BINGO_INVARIANT_VIOLATION`。
3. `out T` 只能出现在协变位置，`in T` 只能出现在逆变位置；标注与实际使用冲突时拒绝。
4. 函数参数始终按 strict contravariance 生成。TypeScript 为方法回调保留的 bivariance 只允许生成带检查的适配器，不允许直接复用函数指针。
5. `Array<T>` 不照搬 TypeScript 的历史协变；`ReadonlyArray<T>`、只读 tuple 可以协变。用户若要把 `Dog[]` 当 `Animal[]` 使用，必须显式复制成 `Animal[]` 或接受 dynamic 边界。
6. variance 为 `unmeasurable` 或 `unreliable` 时，不得作为零成本泛型转换的证明；默认拒绝跨 ABI 赋值。

### 5.3 泛型策略

首选“按表示分组的单态化”：

- `number`、`boolean`、固定对象布局等实例直接生成专门版本。
- 引用类型可共享传指针版本，但必须保留字段布局和析构/写屏障信息。
- 无法统一表示的类型参数使用类型描述符 + runtime helper，不能用裸 `i8*` 冒充所有类型。
- 递归泛型、巨大实例化和无法终止的条件类型设置深度/数量上限，超限报告可定位诊断。

## 6. 语义消糖策略

消糖必须发生在有类型和控制流事实的 HIR，而不是凭 AST 形状猜测：

| 源语法 | HIR/MIR 处理 |
| --- | --- |
| `a?.b`, `a?.[k]`, `a?.()` | 保存一次 receiver，生成 nullish branch，再访问/调用 |
| `x ?? y` | 只判断 `null`/`undefined`，不使用 truthy 判断 |
| `x ||= y`, `&&=`, `??=` | 保存一次左值地址/receiver，按对应短路条件读写 |
| 解构、默认值、rest | 先生成临时值和 presence 检查，再绑定局部；有副作用的 key 只求值一次 |
| spread object/array | 静态 shape 用字段复制；动态对象调用 runtime spread helper |
| `for...of` | 选择数组快路径或 iterator protocol；`for await...of` 进入异步状态机 |
| 箭头函数 | 捕获 lexical `this`/变量，生成闭包环境 |
| 参数属性 | 构造函数入口插入字段赋值 |
| overload | 只保留一个实现体，checker 选中的签名写入调用点 |
| `as`/`satisfies`/类型谓词 | 检查后擦除；需要表示变化时转成显式 checked conversion |
| `using`/`await using` | 作用域退出边和异常边都插入 cleanup；多个资源按逆序释放 |
| `async`/`await` | Promise/Future ABI + 状态机；不把 await 当普通 call |
| generator/`yield` | 生成可恢复 frame、next/return/throw 协议；首版可 R |
| JSX | 先按 JSX factory/runtime 规则转成普通调用，再走普通 call lowering |
| `const enum` | checker 常量值可用时内联；跨模块/动态值不内联 |

## 7. 模块、异常和并发

### 模块

静态 `import`/`export` 由 Program 的模块图决定，生成模块对象、导出槽和确定的初始化拓扑。`import type`、纯类型导出擦除。循环依赖必须用“分配导出槽 -> 执行初始化”的两阶段协议，而不是简单按文件顺序调用。`import()` 需要 Promise + loader，首版建议 P/R。

### 异常

MIR 保留平台无关的 exception edge 和 cleanup region，但具体 lowering 分两步交付。基线 status-code profile 把 `throw`、MayThrow call 和 cleanup dispatch 编成显式 CFG/result 传播；所有可达函数、runtime 和 object 必须使用同一 profile。native-unwind profile 只在 target personality、throw/rethrow shim、exception carrier ownership、foreign-exception policy 和 shadow-stack cleanup 均通过目标机测试后启用，再把相同 MIR edge 映射为 `invoke`/unwind。Rust helper 始终以 `nounwind` status 返回，只有平台 shim 可以启动 Bingo unwind。两种 profile 都不能遗漏 `finally`，也不得使用 `setjmp/longjmp` 绕过 cleanup、GC root 生命周期和 LLVM 优化约束。

### async/await

`async` 函数返回 `Promise<T>`；状态机 frame 至少包含 program counter、活跃局部、异常状态和 cleanup 状态。await 的成功/失败都进入显式 continuation。禁止把同步函数中的 blocking 调用伪装成 await。

## 8. LLVM 后端

生产后端使用 `tinygo.org/x/go-llvm`：它能创建 module/builder、验证模块、执行 passes、创建 target machine、输出 bitcode/目标文件并提供 JIT。Go 代码通过一层 `llvmbackend` helper 访问，不在 ast2bingo 中散落 LLVM C API。

建议固定 LLVM 大版本（首版优先 LLVM 20），在 CI 中运行：

```text
go test ./...
go test -tags=llvm20 ./internal/llvmbackend/...
llvm-as generated.ll
opt -verify -passes='default<O2>' generated.ll
llc -filetype=obj generated.ll
```

Windows 开发优先使用 WSL2/Linux 或容器；TinyGo bindings 的预置 cgo 配置主要覆盖 Linux/macOS/FreeBSD，原生 Windows 需要 `byollvm` 和手动 CFLAGS/LDFLAGS。

LLVM 生成 `app.o`/`app.obj` 后，backend 根据 bound MIR intrinsic 计算 runtime capability 闭包，选择 target/profile/ABI hash 完全一致的唯一 Rust umbrella staticlib 和显式外部引擎 archives，并生成确定性 linker response file。ELF 使用 `ld.lld`，COFF 使用 `lld-link`，Mach-O 使用锁定的 LLD 兼容 driver。链接器不得从系统默认路径偶然选择另一个 runtime；最终产物必须记录 rustc build ID、Cargo lock/features、umbrella archive hash、LLD 和 ABI/layout/capability hash。

真实后端不能等到高级 runtime 全部完成才验证。`VERT-001` 在对象、GC、异常和异步之前锁定一条 `x86_64-unknown-linux-gnu` primitive 纵切：`add(number, number)` 必须经过 validated target-independent snapshot、typed HIR verifier、BuildPlan/manifest `ResolveTargetContext`、RepresentationPlan join、target-aware MIR verifier、真实 go-llvm、LLVM verifier、object emission、空 startup/umbrella runtime 与 LLD，并由运行 harness 验证结果。该纵切不承诺完整 runtime 或第二目标，但它是后续 pass、ABI 和工具链变更的强制回归门禁。

## 9. 诊断模型

诊断分四层：

1. `TSxxx`：typescript-go 语法、绑定和语义错误。
2. `BINGOxxx`：TypeScript 合法但不在静态编译子集内。
3. `BINGO-UNSAFE`：不可靠断言、dynamic boundary、方差适配和显式不安全操作。
4. `LLVMxxx`：MIR/LLVM 类型或 verifier 错误，视为编译器 bug，不应变成用户普通诊断。

每条诊断都包含 source span、语法节点、源类型、目标表示、配置 profile 和建议修复。错误输出必须稳定，供 golden 测试锁定。

诊断生成顺序也属于接口契约：先输出 tsgo 的配置/语法/绑定/语义错误，再输出 capability 和 Bingo subset 错误；前一层有 error 时后一层不执行会产生误导的 lowering。`ts2bin doctor`、case manifest 和 release CI 必须使用同一套诊断 code 表，具体门禁见 [testing-conformance-and-release.md](testing-conformance-and-release.md)。
