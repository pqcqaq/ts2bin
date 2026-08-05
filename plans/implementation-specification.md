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
| TypeScript 语义 | 以 `ts2bin.lock.json` 锁定的 typescript-go checkout、stdlib hash 和 `FE-007` semantic baseline 为准；版本字符串本身不证明支持 |
| Bingo Snapshot | schema major 2，作为 Phase 1.5 snapshot-only lowering 门禁 |
| Bingo HIR/MIR | schema major 1 |
| runtime ABI | major 1 |
| runtime core | 每个 target/profile/feature set 唯一 Rust umbrella `staticlib` + versioned `extern "C"` ABI；内部 crate 使用 `rlib` |
| LLVM | major 20 |
| 默认 profile | static |
| 默认 GC | single-mutator stop-the-world non-moving tracing mark-sweep |
| Phase 2A 首切异常模式 | `none`；任何可抛路径 fail closed |
| 首个可抛异常 profile | status-code/result；native-unwind 为后续 target-specific profile |
| 默认数值 | JavaScript number = IEEE-754 binary64 |
| 默认字符串 | UTF-16 code unit |
| 默认方差 | 函数参数逆变、返回协变、可写位置不变 |

当前 `ts2bin.lock.json` 已记录 snapshot schema 2、no-EH 默认值和最终 patch SHA-256；compatibility/snapshot/options baseline 的有意 UTF-8 wire 变化已审查并通过回归。doctor materialized-exact、官方 remote shallow clean checkout apply/full test/vet/cleanup 与 WSL smoke 已通过；只剩获授权 parent commit/HEAD clean-clone 证明，不能用未提交工作树代替。第一条纵切使用 `exceptions=none`；`ResolveBuildPlan` 对 `llvm-eh` 的早期拒绝只表示当前 no-EH lowering/schema 边界，不是工具链可用性探测。status/native-unwind 契约须在进入异常实现前单独冻结，其他 target/runtime availability 统一留给 `TC-001a`。

禁止以“tsgo parser 能解析”代替“Bingo 可以生成安全本机代码”。支持级别仍使用 S0/S1/S2/C/P/R。

## 2. 编译主算法

~~~text
Compile(BuildRequest req):
  frontendConfig = NormalizeFrontendConfig(req)
  program = Frontend.BuildProgram(frontendConfig)
  diagnostics = CollectTSDiagnostics(program)
  if diagnostics.hasError:
      return TS diagnostics

  snapshot = CaptureProgramSnapshot(program, frontendConfig)
  frontendSnapshotKey = HashFrontendSnapshot(snapshot)

  buildConfig = NormalizeBuildConfig(req)
  buildPlan = ResolveBuildPlan(snapshot, buildConfig) // canonical unresolved request only
  diagnostics += RunSourceSubsetGate(snapshot)
  if diagnostics.hasError:
      return TS/BINGO diagnostics + optional snapshot

  sourceTypePlan = BuildSourceTypePlan(snapshot)
  if sourceTypePlan.hasUnresolvedOrUnsafe:
      return BINGO source-type diagnostics

  hir = LowerSnapshotToTypedHIR(snapshot, sourceTypePlan)
  hir = RunSemanticDesugaring(hir)
  VerifyHIR(hir)

  hir = SpecializeToFixedPoint(hir)
  ValidateVarianceAndConversions(hir)
  VerifyHIR(hir)

  targetContext, dataLayout, availableCapabilityCatalog = ResolveTargetContext(
      buildPlan, LoadToolchainManifest(), LoadRuntimeManifest())
  if targetContext.hasUnavailableOrIncompatibleRequest:
      return target/toolchain/runtime diagnostics
  diagnostics += RunTargetCapabilityGate(
      hir, targetContext, availableCapabilityCatalog)
  if diagnostics.hasError:
      return BINGO capability diagnostics

  verifiedJoin = VerifyRepresentationJoin(
      hir, buildPlan, targetContext, dataLayout, availableCapabilityCatalog)
  if verifiedJoin.hasProvenanceOrBindingMismatch:
      return BINGO internal/provenance diagnostic

  representationPlan = BuildTargetRepresentationPlan(
      verifiedJoin, targetContext, dataLayout, availableCapabilityCatalog)
  if representationPlan.hasUnrepresentableLayoutOrABI:
      return BINGO representation diagnostics

  mir = LowerHIRToCFGAndSSA(hir, representationPlan)
  mir = LowerCleanupExceptionAndAsyncState(mir, targetContext.exceptionProfile)
  VerifyStructuralMIR(mir)

  bound = BindRuntimeCapabilities(mir, availableCapabilityCatalog)
  if bound.hasMissingSymbolOrABIMismatch:
      return BINGO capability diagnostics
  bound = FreezeExactEffects(bound) // produces BoundCapabilityClosure and exact effects

  optimized = OptimizeProvenMIR(bound)
  rooted = PlaceGCRootsAndFreezeCleanup(optimized, targetContext.gcProfile)
  VerifyFinalMIR(rooted)

  llvmModule = EmitLLVM(rooted, targetContext)
  VerifyLLVM(llvmModule)
  OptimizeWithLockedPipeline(llvmModule)
  VerifyLLVM(llvmModule)

  appObject = EmitObject(llvmModule, targetContext)
  umbrellaRuntime, externalEngineArchives = SelectLockedRuntimeArtifacts(
      rooted.capabilities, targetContext)
  buildArtifactKey = HashBuildArtifact(
      frontendSnapshotKey, buildPlan, targetContext, rooted.capabilities,
      umbrellaRuntime.manifestHashes, externalEngineArchives,
      loweringSchema)
  artifact = LinkWithLLD(
      appObject, selfHostedStdlibObjects, umbrellaRuntime,
      externalEngineArchives, targetContext)
  return artifact + provenance(frontendSnapshotKey, buildArtifactKey)
~~~

`RunSourceSubsetGate` 只能判断 snapshot 是否具备当前 lowerer 所需的 target-independent 语义事实。BigInt、RegExp 等尚无 source lowerer 时在此报告 `subset.lowerer_unavailable`；“所选 runtime 不提供 capability”只能由 `ResolveTargetContext` 之后的 target capability gate 报告。`ResolveTargetContext` 可以与 HIR 链并行，返回的 `AvailableCapabilityCatalog` 是 manifest 声明的可用实现目录，不是程序实际使用能力的精确闭包；`VerifyRepresentationJoin` 才交叉核对 HIR `FrontendSnapshotHash`、`BuildPlan.FrontendHash` 与 resolver request/context hashes，后者只有在 structural MIR 完成后才能由 `BindRuntimeCapabilities` 计算为 `BoundCapabilityClosure`。

`targetContext.llvmDataLayout` 必须来自为已解析 target 创建的 LLVM `TargetMachine` 查询结果。toolchain manifest 记录预期 DataLayout 文本/hash，ABI layout manifest 做独立交叉校验；任一不一致都 fail closed，manifest 或 ABI schema 均不得覆盖 LLVM 返回值。Phase 2A pass state 必须使用带 canonical bytes/digest 的 typed resolver envelope/fact store，同时保留 HIR、BuildPlan、manifests、TargetContext、DataLayout 和 catalog；裸 fact 名称没有证明力。`LinkWithLLD` 接收同一个不可变 `TargetContext` 及其 hash，只重新校验 manifests/artifacts，不得再次解析或选择 target。

任何失败都必须归属一个明确层：

| 层 | 失败类别 | 是否属于用户错误 |
| --- | --- | --- |
| tsgo config/parser/binder/checker | TS diagnostic | 是 |
| subset gate | BINGO unsupported/unsafe | 是 |
| source type / variance plan | BINGO unresolved or unsafe type/variance | 是 |
| target context resolution | target/toolchain/runtime unavailable or incompatible | 可能 |
| target representation plan | BINGO unrepresentable layout/ABI | 是 |
| HIR/MIR verifier | compiler bug | 否 |
| capability binding | BINGO runtime/host capability | 是 |
| LLVM verifier | backend bug | 否 |
| linker/target environment | environment/ABI diagnostic | 可能 |
| runtime conformance | runtime bug | 否 |

## 3. 每文件 snapshot 捕获算法

~~~text
CaptureProgramSnapshot(program, frontendConfig):
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
  hash frontend semantic config, canonical sources, tsgo commit,
       stdlib declaration manifest and snapshot schema
  freeze all tables
  return immutable ProgramSnapshot
~~~

CaptureFile 必须完成：

- 为源节点分配 NodeId、OriginId 和 source span，并捕获 tagged `SyntaxPayload` 与具名 child edge。
- 复制 symbol、resolved symbol、Type、contextual/narrowed Type、Signature 和 selected overload 信息。
- 复制常量值、module resolution、module format、usage mode、capture set 和 checker 已求出的 flow facts。
- 把 tsgo Type/Signature 的进程内 ID 映射为本 build 的 dense ID，再计算可持久化 canonical hash。
- 不复制 checker 内部 FlowNode 图；MIR CFG 由 Bingo 自己构造。
- 不保存 AST、Checker、Type、Signature、Symbol 指针。
- release 之后不调用 TypeToString 或任何 checker API。
- checker query 的 panic/error 必须传播到 `CaptureFile` 边界并产生不可抑制的 internal diagnostic；禁止 helper `recover` 后以 nil/false/空切片冒充“没有 type/signature/symbol/property”。
- 捕获完成后重算 frontend config/provenance/table digest，并验证所有 semantic reference、assertion/flow proof、parent-child/root 双向关系和 node graph acyclic；任何缺失或不一致都 fail closed。
- runtime capture set 只包含真正的 free runtime binding，并区分 read/write、mutable、`this`/`super`；type-only name 和 property key/symbol 不得污染 closure layout。

snapshot 是并发边界。只有 snapshot 冻结并且所有 checker 已 release，才允许按模块或函数并行 lowering。本文的 `FrontendSnapshot` 指冻结后的完整 artifact，`ProgramSnapshot` 是它的序列化根对象；两者不是两级语义缓存，也不得拥有不同配置边界。

raw `ProgramSnapshot` 只保存影响前端语义的输入和 checker 已证明的事实。target triple、CPU/features、GC、异常 profile、runtime capability、优化级别和 emit 请求不得进入 snapshot；这些字段只进入 canonical、不可变但未解析的 `BuildPlan`。`ResolveBuildPlan` 只解析默认值并规范化请求，不能据此声称目标工具链或 runtime 可用。缓存键固定为：

~~~text
FrontendSnapshotKey = hash(frontend semantic config, canonical sources,
                           typescriptGoCommit, stdlib declaration hash,
                           snapshot schema)
BuildArtifactKey = hash(FrontendSnapshotKey, BuildPlan, TargetContext,
                        lowering schema,
                        runtime/ABI/layout hashes)
~~~

因此同一 snapshot 可以安全复用于多个 target，但任何 target、profile、layout、runtime 或 emit 变化都必须使下游 artifact cache 失效。

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
    S0: require registered executable lowering handler and representable type
    S1: require registered executable desugaring handler and side-effect test
    S2: require a registered logical-capability lowering handler and record
        the requirement; defer runtime/ABI availability to target resolution
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

Gate 不能只看 AST Kind；同一个 CallExpression 可能是 S0 direct call、S2 runtime call、interop FFI 或 R dynamic call。`RunSourceSubsetGate(snapshot)` 只依据 resolved signature、source type、前端 profile、lowerer readiness 和 snapshot semantic proof 作 target-independent 判断；它不得读取 runtime manifest，也不得把 target capability 失败写入 `FrontendSnapshot`。target type、runtime profile 和 capability availability 由 `ResolveTargetContext` 之后的 target capability gate 判断。

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
  SourceProfile, LogicalCapabilityRequirements
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

## 7. 唯一 Pass DAG 与阶段合同

实现只能使用下面这条分层 DAG；语法 desugaring 内部可以按已声明依赖组成子图，但不得跨越阶段边界交换 specialization、target layout、capability binding、优化或 root placement：

~~~text
FrontendSnapshot
  -> source type normalization / SourceTypePlan
  -> typed HIR construction and semantic desugaring
  -> generic specialization worklist to fixed point
  -> variance/conversion validation
  -> Phase 2A ResolveTargetContext(BuildPlan, toolchain/runtime manifests)
  -> immutable TargetContext + authoritative LLVM TargetMachine DataLayout
     + AvailableCapabilityCatalog
  -> target RepresentationPlan: layout + calling convention
  -> HIR-to-MIR evaluation order + CFG/SSA lowering
  -> cleanup / exception-profile / async-state lowering
  -> structural MIR verification
  -> runtime capability binding
     -> BoundCapabilityClosure + exact effect freeze
  -> proven MIR simplification / devirtualization / escape analysis
  -> GC root placement and cleanup freeze
  -> final MIR verification
  -> LLVM emission
~~~

Kind manifest 中的未来 `LoweringPlan` 文本不是 handler readiness 证明。S0/S1 只有在当前 compiler build 的 lowerer registry 已绑定 handler、声明 snapshot payload/schema 版本且存在对应 golden 时才可 accept；缺失 semantic reference 或 checker proof 是 `BINGO9000` 级内部失败，不能由 gate 跳过。

specialization 使用确定性 worklist；任何 desugaring 或实例化产生的新 `InstantiationKey` 都必须继续迭代到 fixed point。`BuildPlan` 不能直接供表示规划读取；Phase 2A 必须先用锁定的 toolchain/runtime manifests 与 LLVM `TargetMachine` 解析出不可变 `TargetContext`、权威 `DataLayout` 和 `AvailableCapabilityCatalog`。进入 target RepresentationPlan 前不得选择对象 offset、tag payload、pointer width 或 calling convention；进入 MIR 后不得残留未实例化 type parameter。structural verifier 先证明 CFG/SSA、RepType、layout 和 cleanup 结构；capability binding 再从实际 MIR intrinsic 计算 `BoundCapabilityClosure` 与精确 effect；final verifier 最后证明 closure、effect、safepoint root 和冻结后的 cleanup。

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
| ObjectView | 保留 source object identity 的 shape/accessor/offset mapping；只读 view 可协变，可写 view 仅在读写类型、store RepType 和 aliasing 均等价时允许 |
| NumericConvert | 明确 f64/i32/u32/float16 转换规则 |
| TagUnion/RetagUnion | 构造或调整 tagged union |
| CheckedCast | runtime 验证后转换 |
| CopyAdapter | 显式复制到新布局/容器并产生新 identity；不得伪装成 mutable structural identity conversion |
| FunctionThunk | 参数/返回/this 调整 thunk |
| InterfaceAdapter | 构造不改变 object identity 的 interface dispatch descriptor/thunk；字段布局适配仍使用 ObjectView |
| DynamicBoundary | 只允许 interop，记录 provenance |
| Reject | 产生稳定诊断 |

LLVM bitcast 不属于源类型转换计划，只允许 MIR verifier 已证明的等表示底层操作。

structural object conversion 默认使用 `ObjectView` 或拒绝。读取通过 frozen mapping 访问原对象；写入只有在 source/target 的读类型、写类型、底层 store representation 和别名语义完全等价时才合法；identity/equality 始终比较原 source object。任何会复制字段的 adapter 都必须在源语义允许新 identity 时显式出现，不能为满足目标 layout 静默复制可变对象。

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

source/HIR effect 集至少包含 pure/read/write/alloc/throw/suspend/dynamic/ffi/block/nondeterministic。capability binding 冻结精确的 MayAllocate/MayThrow/MaySuspend/MayBlock/MayEnterHost；root placement 随后引入不可交换的 `RootPublication` effect。优化器不能跨越未证明可交换的 effect，LLVM 也不得删除或重排 collector 可观察的 root store、active bitmap 和 frame link/unlink。

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

`VERT-001` 是第一条真实后端纵切：

~~~text
x86_64-unknown-linux-gnu add(number, number)
  -> target-independent serialized snapshot
  -> SourceTypePlan + typed HIR
  -> canonical unresolved BuildPlan
  -> ResolveTargetContext
     -> immutable TargetContext + authoritative LLVM TargetMachine DataLayout
        + AvailableCapabilityCatalog
  -> target RepresentationPlan + verified MIR
  -> real tinygo.org/x/go-llvm + LLVM verifier
  -> object emission
  -> empty startup object + one empty umbrella runtime staticlib
  -> ld.lld + run harness + Node oracle comparison
~~~

该纵切不依赖对象、GC、EH、self-hosted stdlib、async 或第二 target。实现顺序调整为：

1. 完成 lowering-complete snapshot、snapshot-only HIR readiness 和本节 pass DAG 门禁。
2. Phase 2A 让 target-independent `number` typed-HIR 链与 `BE-001a` LLVM TargetMachine/DataLayout、`RT-002a` empty runtime scaffold 并行推进；三路输入齐备后实现最小 `ResolveTargetContext`，再接入 RepresentationPlan、单 block MIR、structural/final verifier 和真实后端，最后完成 `VERT-001`。
3. 在 Phase 2B 实现 local、direct call、branch/general CFG/SSA、loop、union narrowing、nullish、optional/logical 和 patterns。
4. 冻结 `ObjectView`、object/class/closure layout 与 variance adapter，再引入 single-mutator GC v1。
5. 实现 modules、generics、array/map/set/iterator 和 self-hosted stdlib。
6. 先实现全链 status-code cleanup/exception，再实现 Promise/async/generator/using。
7. 目标机桥接门禁通过后再提供可选 native-unwind profile，随后扩展第二 target。
8. 最后推进 dynamic/FFI/ESNext、并发 GC、statepoint 和跨语言 LTO。

任何阶段都先实现正例、拒绝例和 verifier，再扩大语法面。

## 13. 实现完成门禁

一个语法或类型功能只有同时具备以下内容才算完成：

- SyntaxKind/support matrix 行。
- snapshot 捕获字段和 stable ID。
- subset gate 规则。
- source type、variance/conversion 和 target representation 计划。
- HIR lowering 和唯一 pass DAG 的阶段行为。
- MIR/ABI/LLVM mapping。
- 正例、拒绝例、side-effect、golden、differential。
- capability/target/profile 条件。
- 核心流程注释、公共 API 文档和诊断。
- verifier 规则和可复现 artifact。

只完成 AST switch case 不算实现完成。
