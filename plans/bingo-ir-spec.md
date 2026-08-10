# Bingo IR 初始规格

本文定义 Bingo HIR/MIR 的通用目标契约。当前已交付 schema 是 HIR v5 与 Phase 2B target-aware MIR v3：HIR v2 冻结 number-only first-slice provenance，HIR v3 增加多函数/direct-call，HIR v4 与 MIR v2 为 CFG phi 显式保存 incoming block identity，HIR v5 与 MIR v3 增加 nullable-number representation、distinct null/undefined tags 和 guarded unwrap，使 verifier 能按入边验证 loop back edge 与 nullish proof。旧 Phase 2A verifier 继续冻结，扩展语法由独立 Phase 2B verifier 验证。它不是 LLVM IR 的别名，也不是 TypeScript AST 的序列化版本。

## 1. 分层职责

| 层 | 保留 | 禁止进入 |
| --- | --- | --- |
| Typed Snapshot | tsgo Kind、symbol/type/signature、module resolution | 可变 checker/AST 指针 |
| Bingo HIR | TypeScript 求值顺序、TsType、收窄、结构化控制流、effect | LLVM pointer/data layout |
| Bingo MIR | RepType、CFG/SSA、内存、cleanup、调用约定、runtime op | conditional/mapped 等纯类型节点 |
| LLVM IR | 目标 data layout、ABI、具体指令、metadata | TypeScript assignability 决策 |

任何 lowering 都遵循：`source semantic -> target-independent HIR op -> ResolveTargetContext -> RepresentationPlan -> target-aware MIR op -> LLVM op/runtime call`。不允许 HIR 绕过 resolver/representation 边界直接进入 MIR，也不允许从 AST handler 直接调用 LLVM builder。

## 2. 通用实体

```text
IrVersion, ModuleId, FileId, OriginId
TypeId, RepTypeId, FuncId, GlobalId
BlockId, ValueId, LocalId, FieldId, ShapeId
RuntimeCapabilityId, UnsafeProvenanceId
```

所有实体使用 dense id + table，避免 Go 指针成为 identity。每条 HIR/MIR 指令保存 `OriginId`，可追到 NodeId/source span；编译器生成的 cleanup/thunk 使用 synthetic origin，并记录产生它的源节点。

## 3. 类型系统

### 3.1 TsType

```text
Primitive(bool, number, bigint, string, symbol, null, undefined, void, never)
Literal(base, value)
Object(shape/nominal identity)
Class(instance type, constructor type)
Interface(structural contract)
Function(params, return, this, effects, variance)
Array(element, mutability)
Tuple(elements, optional/rest, readonly)
Union(members, discriminant plan)
Intersection(members, merged contract)
TypeParameter(constraint, default, variance)
Dynamic(any/unknown boundary with provenance)
CompileOnly(indexed, conditional, mapped, template, keyof, type query)
```

`CompileOnly` 必须在 HIR specialization/normalization 后消失；否则 MIR verifier 报错。

### 3.2 RepType

```text
Unit, I1, I8, I32, U32, I64, U64, F32, F64
RawPtr(addrspace), Ref(layoutId), NullableRef(layoutId)
Utf16String, BigIntRef, SymbolRef
ArrayRef(elementRep, mutability), Slice(elementRep)
Struct(layoutId), TaggedUnion(layoutId)
FuncRef(signatureRep), DynamicValue
```

TsType 与 RepType 是多对一关系。例如多个字符串 literal 都映射 `Utf16String`；`Dog | null` 可映射 `NullableRef(Dog)`；`string | number` 通常映射 `TaggedUnion`，不能裸用 LLVM union bitcast。

### 3.3 类型与表示规划

类型规划不得把 source type normalization、generic specialization 和 target representation 合成一次前置扫描。唯一顺序为：

1. 从 snapshot 建立 target-independent `SourceTypePlan`：展开 alias 并保留 provenance，规范化 checker 已求值的 conditional/mapped/indexed type，保留尚未实例化的 generic work item。
2. 消除 literal freshness但保留 discriminant 常量，计算 union/intersection canonical member set、source variance 和 mutability proof。
3. 用 `SourceTypePlan` 生成 typed HIR，完成求值顺序和语义消糖。
4. 运行 specialization worklist 到 fixed point；每个新实例重新进入同一 canonical registry，直到没有新 work item 或触发预算诊断。
5. 对 specialized HIR 验证 variance、aliasing 和 conversion，生成 adapter/checked cast 或拒绝。
6. Phase 2A 调用 `ResolveTargetContext(BuildPlan, toolchain manifest, runtime manifest)`，把 canonical unresolved backend request 解析为不可变 `TargetContext`、LLVM `TargetMachine` 的权威 `DataLayout` 和 `AvailableCapabilityCatalog`；缺失或不兼容项在此 fail closed。
7. 结合已解析 `TargetContext` 与 available catalog 建立 `RepresentationPlan`，选择 RepType、layout、calling convention 和 GC pointer map。
8. 由冻结的 representation contract 进入 MIR CFG/SSA，structural verifier 通过后再从实际 intrinsic 计算 `BoundCapabilityClosure` 并冻结精确 effect，最后进入优化、root placement 与 final verifier。

target、layout 或 GC strategy 不得进入 raw frontend snapshot/`SourceTypePlan` hash。`BuildPlan` 只记录规范化请求，不拥有 `TargetContext`；source/HIR lowering 只能记录 logical capability requirements，不能把可用目录当成程序实际使用的闭包。target-dependent `RepresentationPlan`、MIR 和 artifact cache key 必须绑定 `TargetContext` 及其 toolchain/runtime manifest hashes。

## 4. HIR 模块与定义

```text
hir.module @app [profile=static, runtime_abi=1] {
  import @math.add
  export @main

  hir.func @main(%args: Array<string>) -> number effects [alloc, throw] {
    ...
  }
}
```

定义类别：

- `hir.func`：普通/async/generator/constructor/static-init/thunk。
- `hir.global`：常量或模块初始化槽。
- `hir.class`：instance fields、static fields、method slots、base class。
- `hir.shape`：结构化对象/接口布局描述。
- `hir.enum`：常量表和可选 runtime object。
- `hir.module_init`：模块初始化和 export slot 填充。
- `hir.extern`：由 runtime/FFI manifest 提供的实现。

## 5. HIR 表达式和语句

### 5.1 值与访问

```text
const, local.get, local.set
global.get, global.set
object.new, array.new, tuple.new
field.get, field.set, element.get, element.set
property.get, property.set              # 可能调用 getter/runtime
closure.new, capture.get, this.get, super.get
```

### 5.2 运算与转换

```text
num.add/sub/mul/div/rem/pow
int.bit_and/or/xor/shl/shr/ushr
bool.not, cmp.strict_eq/ne/lt/le/gt/ge
string.concat, string.compare
convert.numeric, convert.to_string
cast.noop, cast.checked, dynamic.box, dynamic.unbox
is.nullish, is.instance, is.type_tag
```

每个 operator handler 必须从 checker 类型选择 opcode。`+` 不允许到 MIR 后才猜是数值还是字符串。

### 5.3 调用

```text
call.direct, call.closure, call.virtual, call.interface
construct, runtime.call, ffi.call
```

调用保存 selected SignatureId、实例化类型参数、receiver 求值方式和 argument evaluation order。overload 只在 HIR metadata 存在，MIR 只能看到唯一调用签名。

### 5.4 结构化控制流

```text
hir.if, hir.loop, hir.switch
hir.try, hir.catch, hir.finally
hir.return, hir.throw
hir.await, hir.yield
hir.cleanup_scope
```

optional chain、nullish、logical assignment、destructuring、spread、for-of、using 等在 HIR normalization 展开；展开前后都要保持单次求值和 source origin。

## 6. MIR 指令集

### 6.1 常量与 SSA

```text
const.i1/i32/u32/i64/u64/f64
const.null, const.undefined, const.string, const.symbol
copy, select, phi
```

### 6.2 内存

```text
alloca.local, alloc.object, alloc.array, alloc.env
load, store
field.addr, element.addr
bounds.check, null.check
retain, release, gc.write_barrier
```

内存管理指令由 `gc` profile 选择 ARC/GC/arena 实现。HIR 不直接插入 LLVM `malloc/free`。

### 6.3 数值与比较

```text
fadd/fsub/fmul/fdiv/frem
iadd/isub/imul/sdiv/udiv/srem/urem
and/or/xor/shl/ashr/lshr
fcmp/icmp
f64.to_i32_js, f64.to_u32_js
checked.trunc/ext, bitcast.repr
```

`bitcast.repr` 只允许 verifier 已证明等尺寸、等 provenance 的底层表示转换；TypeScript `as` 不能直接生成它。

### 6.4 调用与异常

```text
call, call.indirect, invoke
landingpad/catchpad abstraction
throw, resume, unreachable
```

MIR 使用平台无关 exception region，LLVM backend 再选择 Itanium/Windows EH 结构。

### 6.5 控制流终结符

```text
br, cond_br, switch, return, throw, resume, suspend, unreachable
```

每个 block 恰好一个 terminator。phi incoming 必须与 predecessor 一一对应。

### 6.6 runtime 高层指令

```text
rt.string.*, rt.bigint.*, rt.regexp.*
rt.object.*, rt.array.*, rt.map.*, rt.set.*
rt.iterator.*, rt.promise.*, rt.generator.*
rt.module.*, rt.decorator.*, rt.jsx.*
rt.dispose.*, rt.dynamic.*
```

这些不是任意字符串调用，而是带 logical `RuntimeCapabilityId` 和版本化签名的 intrinsic。HIR artifact/op 必须 canonical 保存 logical requirement，但不能提前写入 resolved symbol、available catalog 或 bound closure；backend 只在 `ResolveTargetContext` 和 structural MIR binding 后由 manifest 映射到符号。纯 number add 的 logical requirement 列表为空也必须进入 canonical hash。

## 7. Effect 系统

每个 HIR function/instruction记录 effect 集：

```text
pure, read_local, write_local, read_global, write_global
alloc, retain_release, throw, suspend, io, dynamic, ffi, nondeterministic
```

用途：

- 防止消糖重复执行 getter、computed key、call。
- 确定 `finally`/cleanup 边。
- 控制常量折叠和 dead-code elimination。
- 标记 dynamic/FFI 安全边界。
- 验证声明为 pure 的 runtime intrinsic。

## 8. Unsafe provenance

所有不安全或动态转换保存 provenance：

```text
kind: explicit_unsafe_cast | ffi | dynamic_import | external_any | runtime_check
sourceType, targetType, sourceSpan
reason, requiredCapability
```

`as any as T` 没有显式 provenance 入口，因此 static/unsafe profile 都不能悄悄放行。只有 `unsafeCast<T>` intrinsic 或 FFI manifest 能创建 `explicit_unsafe_cast`。

## 9. 唯一 pass/effect DAG

固定顺序与 [implementation-specification.md](implementation-specification.md) 一致：

1. `ValidateSnapshotAndBuildSourceTypePlan`
2. `LowerSnapshotToTypedHIR`
3. `LowerEvaluationOrderAndSemanticSugar`
4. `ResolveCompileOnlyTypesAndSpecializeToFixedPoint`
5. `ValidateVarianceAliasingAndConversions`
6. `ResolveTargetContext`
7. `BuildTargetRepresentationPlan`
8. `LowerHIRToMIRCFGAndSSA`
9. `LowerCleanupExceptionAndAsyncState`
10. `VerifyStructuralMIR`
11. `BindCapabilitiesAndFreezeExactEffects`
12. `OptimizeProvenMIR`
13. `PlaceGCRootsAndFreezeCleanup`
14. `VerifyFinalMIR`

`ResolveTargetContext` 是 Phase 2A 的 target-dependent 门，不是普通 HIR rewrite；它消费 canonical unresolved `BuildPlan`、锁定 toolchain/runtime manifests 和 LLVM `TargetMachine`，产出 `target-context`、`data-layout` 与 `available-capability-catalog` facts。它可以与 target-independent HIR 链并行。后续 `RepresentationPlan` 的 join pre-verifier 同时消费 verified HIR、BuildPlan 与 resolver output，交叉核对 frontend/provenance hashes 后才允许进入 target-aware MIR。后续表示/MIR pass 只消费这些已验证 inputs，不得从 executor 初始状态注入原始 `target` 或 `capability-manifest` 冒充 resolver 结果。`BindCapabilitiesAndFreezeExactEffects` 在 structural MIR 之后从实际 intrinsic 产出 `bound-capability-closure` 和 frozen exact effects；available catalog 与程序实际绑定闭包不得使用同一个名称或 hash。每个 pass 都声明输入 schema、输出 schema、读取/新增的 fact 和是否会引入 call/safepoint/throw/suspend。pass 不得改变可观察求值顺序；effect freeze 后不得引入新 capability/safepoint/throw，root placement 后不得运行会隐藏引用 lifetime 或引入新 safepoint 的 MIR pass。每步可独立 dump/diff，且有正常、malformed 和循环 specialization golden。

Phase 2A 的 executable pass state 必须把 resolver 输入/输出保存为带 schema、canonical bytes 和 digest 的 typed envelope/fact store，并在 resolver 之后同时保留 HIR、BuildPlan、TargetContext、DataLayout 与 available catalog。resolver 只语义读取 BuildPlan/toolchain/runtime manifests；HIR 由 envelope 不可变保留，`RepresentationPlan` 才是首次 provenance join。仅保存 `[]string` fact 标签不能作为 capability 或 provenance proof；resolver post-verifier 独立重算 digest/manifest binding，RepresentationPlan pre-verifier 独立重算 join invariant。

## 10. Verifier 规则

### HIR verifier

- NodeId/OriginId 有效且定义唯一。
- symbol/type/signature 引用存在。
- operator 与 checker 解析类型一致。
- call 的参数数、rest、this、selected overload 一致。
- C 类型节点不产生 runtime value。
- 缺失 source lowerer 或 semantic proof 时不生成 HIR；S2 的 runtime/ABI availability 在 `ResolveTargetContext` 后验证，HIR 只保留 logical capability requirement。
- unsafe/dynamic op 有 provenance。

### MIR verifier

- 所有 TsType 已得到 RepType；不存在 conditional/mapped/unresolved type parameter。
- SSA 定义支配使用；phi 与 predecessor 完整一致。
- block 有唯一 terminator，无悬空 edge。
- load/store/address 的 layout、alignment、mutability 正确。
- 可变容器没有未经 adapter 的协变转换。
- call/invoke calling convention 和 signature 完全一致。
- throw/suspend/return 前 cleanup 集完整，资源只释放一次。
- GC ref store 具有必要 write barrier；ARC 路径 retain/release 平衡。
- runtime intrinsic 在 capability manifest 中存在且版本匹配。

### LLVM verifier 前置条件

MIR verifier 通过是调用 go-llvm 的必要条件；LLVM `VerifyModule` 失败统一视为 backend bug，并保存 MIR/LLVM repro，不向用户伪装成普通 BINGO 子集错误。

## 11. 示例：可选链

源代码：

```ts
function nameOf(user: User | undefined): string {
  return user?.profile.name ?? "anonymous";
}
```

规范化 HIR：

```text
%u = local.get @user
%is_null = is.nullish %u
%name = if %is_null {
  yield undefined
} else {
  %p = field.get %u, @User.profile
  yield field.get %p, @Profile.name
}
%fallback = is.nullish %name
return if %fallback { yield const.string "anonymous" } else { yield %name }
```

MIR 形成显式 `cond_br`、两个 merge block 和 phi；`user` 只读取一次。

## 12. 示例：variance adapter

```ts
interface Animal { name: string }
interface Dog extends Animal { bark(): void }
declare const dogs: ReadonlyArray<Dog>;
const animals: ReadonlyArray<Animal> = dogs;
```

只读 array 共享同一引用表示并允许协变 view；若目标为 `Array<Animal>`，HIR verifier 要求 `array.copy_upcast` 或报不变性诊断，不能直接复用可写引用。

## 13. 序列化与兼容性

HIR 与 MIR 使用分层 provenance；这些字段都属于 canonical content hash，不能只放在日志或外部 sidecar：

```text
HIR: schema version, FrontendSnapshot schema/hash, canonical source hashes,
     CompilerBuildIdentity(upstream commit + fork commit + lowering schema/hash),
     standard-library hash, Kind-manifest hash + logical-capability-requirement digest
MIR: HIR provenance + BuildPlan digest + TargetContext hash
     + toolchain/runtime/ABI/layout/available-capability manifest digests
     + resolved target triple + authoritative LLVM DataLayout/hash
     + BoundCapabilityClosure digest + exact-effect digest
```

HIR canonical hash 必须覆盖全部 provenance；缺失、未知 schema major 或格式错误均由 verifier 拒绝。`RepresentationPlan` join pre-verifier 必须验证 HIR 的 `FrontendSnapshotHash` 与 `BuildPlan.FrontendHash` 相同，并验证 resolver output 与 BuildPlan 请求一致；replay/post-verifier 也必须交叉核对来源 plan，不能只在篡改后重新计算 HIR hash。MIR 构造把 available catalog 与后续 bound closure 分别哈希。

reader 只保证读取同一 major IR version。mandatory provenance 在 pre-release v1 期间变化后已由 `IR-001a` 协调更新 `HIRSchemaVersion`、replay、lock 的 `bingoIR` 和旧 major 拒绝测试；Phase 2B 多函数/direct-call contract 将 reader 升为 HIR v3，loop/general CFG 的 edge-aware phi contract 再升为 HIR v4/MIR v2，nullable-number coalesce contract 再升为 HIR v5/MIR v3，并同步 pass envelope、golden、lock 和旧 major rejection。缓存命中必须比较全部 digest；不能只比较源文件时间戳。
