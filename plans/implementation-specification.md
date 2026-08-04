# ts2bin 实现总规格

本文是 ts2bin 实现级文档的总入口。它把现有架构、语法支持矩阵和 IR 约束收敛成可以直接编写代码的算法契约，回答以下问题：

- 一个 TypeScript 文件如何从 tsgo Program/Checker 进入 Bingo。
- 每种语法由哪一层处理、生成什么 HIR/MIR、何时调用 runtime。
- 类型如何规范化、选择表示、验证方差并决定转换或拒绝。
- 对象、模块、异常、异步、GC 和 LLVM backend 如何协作。
- 哪些行为在任何普通 profile 中都不能静默支持。

详细算法分为四份：

1. [syntax-lowering-algorithms.md](syntax-lowering-algorithms.md)：全部 AST/语法的 AST → Snapshot → HIR/MIR 转换。
2. [type-system-and-variance-algorithms.md](type-system-and-variance-algorithms.md)：类型规范化、表示选择、泛型、协变/逆变和转换计划。
3. [runtime-and-backend-lowering-algorithms.md](runtime-and-backend-lowering-algorithms.md)：对象/runtime/GC/异常/异步/LLVM 的实现算法。
4. [unsupported-semantics-and-diagnostics.md](unsupported-semantics-and-diagnostics.md)：必须拒绝、profile 边界和诊断规则。

本文和四份细则均受 [bingo-ir-spec.md](bingo-ir-spec.md) 的 verifier 约束；若叙述和 verifier 冲突，以 verifier 为准。

## 1. 实现范围和版本基线

第一版实现锁定：

| 项目 | 基线 |
| --- | --- |
| tsgo | submodule gitlink 与 ts2bin.lock.json 中的完整 commit |
| TypeScript 语义 | tsgo 对应的 TS 6.0 语义基线及本地实测现代语法 |
| Bingo Snapshot/HIR/MIR | schema major 1 |
| runtime ABI | major 1 |
| LLVM | major 20 |
| 默认 profile | static |
| 默认 GC | non-moving tracing mark-sweep |
| 默认数值 | JavaScript number = IEEE-754 binary64 |
| 默认字符串 | UTF-16 code unit |
| 默认方差 | 函数参数逆变、返回协变、可写位置不变 |

禁止以“tsgo parser 能解析”代替“Bingo 可以生成安全本机代码”。支持级别仍使用 S0/S1/S2/C/P/R。

## 2. 编译主算法

~~~text
Compile(BuildRequest req):
  config = NormalizeConfig(req)
  program = Frontend.BuildProgram(config)
  diagnostics = CollectTSDiagnostics(program)
  if diagnostics.hasError:
      return TS diagnostics

  capabilitySet = LoadAndValidateCapabilities(config)
  snapshot = CaptureProgramSnapshot(program, capabilitySet)
  diagnostics += RunSubsetGate(snapshot, config)
  if diagnostics.hasError:
      return TS/BINGO diagnostics + optional snapshot

  typePlan = BuildTypeAndRepresentationPlan(snapshot)
  if typePlan.hasUnresolvedOrUnsafe:
      return BINGO type/representation diagnostics

  hir = LowerSnapshotToHIR(snapshot, typePlan)
  VerifyHIR(hir)

  for pass in FixedHIRPassOrder:
      hir = pass.Run(hir)
      VerifyPassPostconditions(pass, hir)

  mir = LowerHIRToMIR(hir, typePlan, capabilitySet)
  VerifyMIR(mir)

  bound = BindRuntimeCapabilities(mir, capabilitySet)
  if bound.hasMissingSymbolOrABIMismatch:
      return BINGO capability diagnostics

  llvmModule = EmitLLVM(bound, target)
  VerifyLLVM(llvmModule)
  OptimizeWithLockedPipeline(llvmModule)
  VerifyLLVM(llvmModule)

  artifact = EmitObjectAndLink(llvmModule, runtime, target)
  return artifact + provenance
~~~

任何失败都必须归属一个明确层：

| 层 | 失败类别 | 是否属于用户错误 |
| --- | --- | --- |
| tsgo config/parser/binder/checker | TS diagnostic | 是 |
| subset gate | BINGO unsupported/unsafe | 是 |
| type/representation plan | BINGO unrepresentable/variance | 是 |
| HIR/MIR verifier | compiler bug | 否 |
| capability binding | BINGO runtime/host capability | 是 |
| LLVM verifier | backend bug | 否 |
| linker/target environment | environment/ABI diagnostic | 可能 |
| runtime conformance | runtime bug | 否 |

## 3. 每文件 snapshot 捕获算法

~~~text
CaptureProgramSnapshot(program):
  files = program.GetSourceFiles() in canonical deterministic order
  for file in files:
      checker, release = program.GetTypeCheckerForFile(ctx, file)
      try:
          fileSnapshot = CaptureFile(checker, file)
          append fileSnapshot
      finally:
          release()

  sort type/symbol/signature tables by stable canonical keys
  assign persistent IDs
  hash config, sources, tsgo commit and stdlib manifest
  freeze all tables
  return immutable ProgramSnapshot
~~~

CaptureFile 必须完成：

- 为源节点分配 NodeId、OriginId 和 source span。
- 复制 symbol、resolved symbol、Type、contextual/narrowed Type、Signature 和 selected overload 信息。
- 复制常量值、module resolution、module format、usage mode、capture set 和 checker 已求出的 flow facts。
- 把 tsgo Type/Signature 的进程内 ID 映射为本 build 的 dense ID，再计算可持久化 canonical hash。
- 不复制 checker 内部 FlowNode 图；MIR CFG 由 Bingo 自己构造。
- 不保存 AST、Checker、Type、Signature、Symbol 指针。
- release 之后不调用 TypeToString 或任何 checker API。

snapshot 是并发边界。只有 snapshot 冻结并且所有 checker 已 release，才允许按模块或函数并行 lowering。

## 4. Subset Gate 算法

对每个源节点执行：

~~~text
Gate(node):
  entry = SyntaxKindManifest[node.kind]
  if entry missing:
      compiler bug: unclassified AST Kind

  if node is parser recovery/synthetic source artifact:
      reject unless explicitly produced by trusted frontend adaptation

  switch entry.level:
    S0: require lowering handler and representable type
    S1: require desugaring algorithm and side-effect test
    S2: require enabled runtime capability and ABI
    C:  require compile-time normalization; forbid runtime value
    P:  reject unless named experimental feature is enabled
    R:  emit stable rejection diagnostic

  run cross-node policies:
    unsafe assertion chain
    unresolved generic
    dynamic escape
    variance/mutability
    module/host binding
    cleanup/exception support
~~~

Gate 不能只看 AST Kind；同一个 CallExpression 可能是 S0 direct call、S2 runtime call、interop FFI 或 R dynamic call。最终决定依赖 resolved signature、source/target type、effect、profile 和 capability。

## 5. Lowering Context

每个 AST handler 接收显式 LoweringContext：

~~~text
LoweringContext:
  ModuleId, FunctionId, CurrentBlock
  ScopeStack, CleanupStack, LoopStack, LabelStack
  ThisBinding, SuperBinding, NewTarget
  ExpectedTsType, ExpectedRepType
  EvaluationMode
  ExceptionRegion, SuspendRegion
  Profile, CapabilitySet
  Origin
~~~

EvaluationMode 只有以下几类：

| mode | 含义 |
| --- | --- |
| Value | 产生 SSA/value |
| Place | 产生可读写地址/属性引用，不能重复求值 |
| Condition | 产生 true/false CFG edge 并携带 narrowing facts |
| Discard | 保留 effect，丢弃纯值 |
| TypeOnly | 只读取类型事实，禁止产生 runtime op |

禁止使用多个布尔参数表达这些模式。

## 6. 表达式通用算法

~~~text
LowerExpr(node, mode, expected):
  info = snapshot.NodeInfo(node)
  require info.TypeId and OriginId

  if mode == TypeOnly:
      return CompileTimeTypeResult(info.TypeId)

  plan = TypePlanner.PlanExpression(info.TypeId, expected)
  raw = DispatchByKind(node.Kind, mode, plan)
  converted = ApplyConversionPlan(raw, plan.conversion)
  attach OriginId and effects
  return converted
~~~

所有表达式必须遵守：

1. 先按 ECMAScript/TypeScript 顺序求值子表达式。
2. 可能有副作用的 receiver、key、callee、argument 只求值一次。
3. operator/call 必须使用 checker 解析后的 type/signature，不在 MIR 猜测。
4. Place 模式返回 PlaceRef，不立即 load；复合赋值先保存 PlaceRef，再 load/operate/store。
5. Condition 模式优先生成控制流而非 materialize bool，以保留短路和 flow facts。
6. 每条 HIR/MIR op 保存 OriginId 与 effect。

## 7. 固定 HIR Pass 顺序

实现不得自行交换以下顺序：

1. ResolveCompileOnlyTypes
2. SpecializeGenerics
3. ValidateVarianceAndMutability
4. LowerAssertionsAndConversions
5. LowerOptionalAndLogical
6. LowerPatternsAndSpread
7. LowerClassesAndClosures
8. LowerIteratorsAndResources
9. LowerExceptionsAsyncGenerators
10. SelectLayoutsAndCallingConventions
11. BuildCFGAndSSA
12. VerifyMIR

每个 pass 必须声明：

- 允许输入的 HIR node。
- 必须消除或新增的 node。
- 保持的求值顺序和 effect。
- 可能产生的诊断。
- 前置/后置 verifier。
- golden dump 规范。

## 8. 转换计划结果

类型层不能只返回 true/false；必须返回以下之一：

| 结果 | 含义 |
| --- | --- |
| Identity | 类型和表示均兼容，无 runtime op |
| WidenLiteral | 只丢失 literal freshness，表示不变 |
| ReadonlyView | 只读协变 view，禁止通过目标写入 |
| NumericConvert | 明确 f64/i32/u32/float16 转换规则 |
| TagUnion/RetagUnion | 构造或调整 tagged union |
| CheckedCast | runtime 验证后转换 |
| CopyAdapter | 复制到新布局/可变容器 |
| FunctionThunk | 参数/返回/this 调整 thunk |
| InterfaceAdapter | 构造 shape/vtable adapter |
| DynamicBoundary | 只允许 interop，记录 provenance |
| Reject | 产生稳定诊断 |

LLVM bitcast 不属于源类型转换计划，只允许 MIR verifier 已证明的等表示底层操作。

## 9. 求值顺序和 effect 不变量

以下行为属于发布级不变量：

- optional chain 的 receiver、element key、callee 只求值一次。
- logical assignment 的左值地址只计算一次。
- object/array spread 按源顺序执行 getter 和 iterator。
- call 先求 callee/receiver，再按左到右求参数。
- new 先解析构造器，再求参数，再分配/初始化 receiver。
- class extends 表达式、computed key、decorator、static field/block 按规范顺序执行。
- return/throw/break/continue 必须穿过所有活跃 finally/cleanup。
- using/await using 按逆序释放，异常合并产生 SuppressedError 语义。
- module export slot 先分配，再执行初始化，支持循环依赖。
- async/generator suspend 前保存所有活跃 local、cleanup 和 exception state。

effect 集至少包含 pure/read/write/alloc/throw/suspend/dynamic/ffi/nondeterministic。优化器不能跨越未证明可交换的 effect。

## 10. 并发模型

- Program/checker 和 snapshot 捕获遵守 tsgo CheckerPool 独占规则。
- HIR lowering 只读 snapshot，可以按函数并行，但模块 init 和 specialization registry 通过确定性调度。
- 泛型实例化使用并发安全 memo table，最终输出按 canonical key 排序。
- LLVM Context 默认每编译任务独享；不能跨并发任务共享可变 Module/Builder。
- runtime capability/ABI registry 加载后冻结，编译期间只读。
- 并行结果的诊断、类型表、函数表和 artifact 必须稳定排序。

## 11. 模块和包布局建议

~~~text
internal/tsfrontend/
  program.go
  diagnostics.go
  snapshot.go
  snapshot_types.go
  module_graph.go

internal/ast2bingo/
  lower.go
  expressions.go
  statements.go
  declarations.go
  patterns.go
  classes.go
  modules.go
  assertions.go

internal/bingo/types/
  normalize.go
  representation.go
  variance.go
  assignability.go
  specialize.go

internal/bingo/hir/
internal/bingo/mir/
internal/bingo/verify/

internal/runtimeabi/
  capabilities.go
  layouts.go
  signatures.go

internal/llvmbackend/
  module.go
  types.go
  instructions.go
  exceptions.go
  debug.go
  target.go
~~~

这些文件按语义阶段划分，不为每个 AST Kind 创建一个函数或文件。相近语法共享同一线性 lowering 流程，只有独立语义、不变量或复用才抽取 helper。

## 12. 实现顺序

第一条纵切：

~~~text
number literal/parameter
  -> add function
  -> return
  -> snapshot
  -> HIR/MIR
  -> LLVM
  -> object/link/run
~~~

之后依次：

1. primitive、local、branch、loop、direct call。
2. union narrowing、nullish、optional/logical、patterns。
3. object/class/closure/layout/variance。
4. modules/generics/array/map/set/iterator/using。
5. exception/Promise/async/generator/decorator/JSX。
6. dynamic/FFI/ESNext 和多目标产品化。

任何阶段都先实现正例、拒绝例和 verifier，再扩大语法面。

## 13. 实现完成门禁

一个语法或类型功能只有同时具备以下内容才算完成：

- SyntaxKind/support matrix 行。
- snapshot 捕获字段和 stable ID。
- subset gate 规则。
- 类型/表示/方差转换计划。
- HIR lowering 和固定 pass 行为。
- MIR/ABI/LLVM mapping。
- 正例、拒绝例、side-effect、golden、differential。
- capability/target/profile 条件。
- 核心流程注释、公共 API 文档和诊断。
- verifier 规则和可复现 artifact。

只完成 AST switch case 不算实现完成。
