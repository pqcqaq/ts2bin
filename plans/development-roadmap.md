# ts2bin 六阶段开发计划（含 Phase 1.5 与 Phase 2.5 门禁）

本计划把 `ast2bingo` 拆成六个可独立验收的阶段，在前端与 HIR 之间设置 Phase 1.5 lowering-readiness，并在对象阶段前设置 Phase 2.5 engineering-hardening 门禁。每阶段都必须增加源码样例、诊断 golden、HIR/MIR golden 和最少一组可运行测试；未通过上一阶段退出条件，不进入下一阶段扩展语法。

阶段的输入和产物必须分别对照 [tsgo-integration.md](tsgo-integration.md)、[bingo-ir-spec.md](bingo-ir-spec.md)、[stdlib-runtime-plan.md](stdlib-runtime-plan.md) 和 [testing-conformance-and-release.md](testing-conformance-and-release.md)。实际编码从 [implementation-specification.md](implementation-specification.md) 进入，并同时遵守逐语法 lowering、类型/方差、runtime/backend 和拒绝诊断四份细则。本文件只定义实施顺序，不重复定义这些契约；若路线图与 verifier、capability manifest 或 case manifest 冲突，以后者为准。当前状态和依赖以 [implementation-backlog.md](implementation-backlog.md) 为唯一事实来源；Phase 3 细化以 [phase3-entry-and-hardening.md](phase3-entry-and-hardening.md) 为准。

## 总体顺序

```text
阶段 1 前端锁定
  -> Phase 1.5 snapshot/lowering 契约闭合
  -> 阶段 2A number-only real-LLVM 纵切
  -> 阶段 2B primitive 控制流与静态核心
  -> Phase 2.5 output/registry/fuzz 工程加固
  -> 阶段 3 布局/函数/对象/闭包/variance
  -> 阶段 4 模块/泛型/集合/迭代/资源
  -> 阶段 5 runtime-heavy 语义
  -> 阶段 6 LLVM 产品化与兼容性
```

## 阶段 1：前端集成、类型快照与语法闸门

### 目标

把本地 `typescript-go` 变成可稳定调用的前端，定义 ts2bin 自己的编译 profile 和诊断协议。这个阶段不生成 LLVM，不尝试“先支持全部语法”。

### 工作项

1. 固定 `typescript-go` commit、Go toolchain、标准库声明和 tsconfig 默认值；fork 只增加 `cmd/ts2bin` 与内部包。
2. 构造 `compiler.Program`，读取 source files，依次检查 syntactic、bind、semantic、global diagnostics。
3. 为 `ast.Node` 建立只读 visitor，生成 `TypedSnapshot`：NodeId、Span、Kind、SymbolId、TypeId、SignatureId、flow facts、capture set、module id。
4. 把 checker 查询集中到 `internal/tsfrontend`；`internal/ast2bingo` 只能消费已冻结的 snapshot，不得直接调用 checker。
5. 根据 [typescript-support-matrix.md](typescript-support-matrix.md) 实现 subset gate：`any`、不可靠断言、dynamic object、未实现 async/EH 等输出 BINGO 诊断。
6. 建立 source span 到 HIR/MIR/LLVM metadata 的 ID 链，保证错误可以回到原始 TS 行列。
7. 实现 `internal/tsfrontend` facade 和 `ProgramSnapshot` schema；checker 按独占借用分组捕获，`done()` 后才允许并行 lowering。
8. 生成 AST Kind manifest、tsconfig/profile snapshot 和 module graph digest，并将 `typescriptGoCommit`、stdlib hash 写入 provenance。

### 交付物

- `cmd/ts2bin check`：只解析/类型检查/打印稳定诊断。
- `cmd/ts2bin dump-snapshot`：输出 JSON 或文本 snapshot。
- 语法节点覆盖报告：以 `Kind` 为全集，不能有未分类的源节点。
- 50 个以上正例和拒绝例，包含 `as any as`、unknown、variance、module、JSX、using。

### 验收门槛

- 同一 commit、同一配置下 snapshot 字节稳定。
- tsgo 报错的源程序绝不进入 HIR；tsgo 合法但矩阵 R 的程序有稳定 BINGO 诊断。
- 不修改 `typescript-go` parser/checker 行为；上游测试仍通过。
- snapshot 不保存长期有效的 AST 指针，不依赖生成文件中未承诺的私有布局。
- snapshot schema、AST Kind manifest、配置归一化结果和诊断排序均有稳定 golden；任何 checker 指针泄漏测试失败。

## Phase 1.5：snapshot lowering 契约闭合

### 目标

把 Phase 1 的“可审计前端快照”提升为“可供 HIR 使用的输入契约”。Phase 1.5 只负责 frontend DTO/semantic proof、target/cache 边界、独立 replay 依赖闭包和可执行 pass contract；真实 MIR、LLVM、runtime、artifact runner 与 Node differential 属于 Phase 2A 的纵切退出条件，不得反向扩大 Phase 1.5。入口通过后只启动 primitive IR，首条可执行纵切通过前不得扩展新的 HIR 语法组。

### 工作项

1. `FND-004`：现行交付已迁移到 `pqcqaq/typescript-go` 的固定 fork commit；lock 同时记录 fork remote、fork commit 和 reviewed upstream ancestor，parent gitlink/checkout 必须与 fork commit 一致。旧 patch/materialize/apply 机制已经退役；本地 doctor、隔离 fork smoke/full test/vet、frontend 九阶段、locked replay 双构建、远端 fork verification、committed parent HEAD clean-clone，以及 Go-LLVM 20.1.8 verifier 与 Rust staticlib + Clang/LLD 的 WSL smoke 已通过。
2. `FE-008`：实现 snapshot schema v2 的 tagged `SyntaxPayload`、具名 child roles、source blob、literal/operator/name/property/import-export/class-init/type payload；checker capture panic/error 必须 fail closed，validator 重算 digest 并验证引用、parent/root 和 acyclic 不变量。
3. `FE-009`：补齐 property read/write/optional/readonly/accessor/private identity、signature parameter optional/rest/effect、assertion chain/representation proof、non-null/flow proof kind、runtime capture 分类和 specifier-level type-only module edge。
4. `FE-011`：修复大小写敏感路径 identity，完整捕获影响语义的 TS options，拆分 target-independent `FrontendSnapshot` 与 target-dependent `BuildPlan`，并验证 profile override/cache key。
5. `FE-010`：在稳定的 frontend/build-plan 边界上建立首纵切 snapshot-only replay；释放 AST/checker 后，仅用序列化 snapshot 生成 `add(number, number)` 的 canonical HIR/lowering events，并以 readiness registry、manifest metadata 和 malformed negative cases 锁定边界。广泛 runner/fuzz 在 `REL-001/003` 收口。
6. `IR-000`：收敛 source type plan、typed HIR、specialization fixed point、target representation、CFG/SSA 和 effect verifier 的唯一 DAG。

当前状态按“代码存在”“Phase 3 准入”和“发布审计”分开记录。Phase 1.5、Phase 2A、scoped Phase 2B static-core implementation 与 Phase 2.5 本地门禁均已完成；Phase 3 已推进到 `VERT-013b` derived class self-audit 和 `OBJ-003b` private/protected access 的 production LLVM/runner/CLI 接线。`APP-001/CLI-001/VERT-009` 的 self-audit 证据已收口，但仍等待独立 A3 review；自动 CI 由项目负责人延期，因此该 application preview 不能据此进入 Integrated 或 release profile。当前最近门禁是补齐 class-access 的 LLVM 20 Linux authoritative runtime rebuild、ELF/Node differential 与 deterministic artifact evidence；本机 WSL/sysroot 不可用时必须保持 environment-blocked。

### 退出门槛

- clean clone 可获取并构建 Phase 1 源码，不能依赖 submodule dirty state。
- S0/S1 首批节点的 syntax payload 无未知项，snapshot-only replay 与 capture-time oracle 一致；capture helper 不得把 checker panic/error 静默降为空事实。
- snapshot validator 对悬空 semantic ID、篡改 flow/assertion proof、parent/root 不一致、cycle、digest/config/provenance 漂移全部 fail closed。
- named type-only import/export、runtime capture、non-null/flow、assertion chain 和 diagnostic stage/span/multiplicity 有精确 fixture。
- S0/S1 accept 必须来自实际 lowerer registry，不得把 manifest 中的未来 `LoweringPlan` 当作已实现 handler；bind diagnostics 保留独立 stage。
- `A.ts`/`a.ts`、Windows/WSL path、target 切换和 profile override 有独立 deterministic tests。
- `BaseURL`/`RootDirs`/`TypeRoots`/paths substitutions、source/module/diagnostic paths 中残留的盘符、UNC 或 POSIX rooted path 在 wire 边界 fail closed；同根外部路径只能以可搬迁的相对身份进入 hash。
- Phase 2A 的 BuildPlan 使用明确的 no-EH mode；`BuildPlan` 只是 canonical unresolved request，必须先经 manifest 驱动的 `ResolveTargetContext`；未实现的 `llvm-eh` 不得作为默认或已支持 provenance。
- IR schema ownership、pass/effect DAG、cache invalidation 和 provenance 已冻结并有 malformed/negative golden。
- parent `.gitmodules`/gitlink/lock 固定同一可获取 fork commit；reviewed upstream commit 是其祖先；fork checkout clean；关闭条件包括 doctor、远端 fork fetch/full test/vet、WSL smoke 与 committed parent HEAD clean-clone。当前 fork 机制已迁移，本地 doctor/full test/vet、replay/frontend 门禁、远端 fork verification、committed parent clean-clone，以及 Go-LLVM 20.1.8 verifier 与 Rust staticlib + Clang/LLD 的 WSL smoke 已通过。

## 阶段 2A：primitive 可执行纵切

### 目标

只闭合 `add(number, number)` 的可验证、可执行链：validated serialized snapshot -> target-independent typed HIR；BuildPlan + manifests -> ResolveTargetContext；二者经 RepresentationPlan join -> target-aware MIR -> real LLVM -> object -> LLD -> process output -> Node oracle。Phase 1.5 实现契约与 pinned-fork 交付验收（`FND-004a`）均已完成；纯 Go interpreter、伪 MIR 或文本 LLVM 只能提供局部反馈，不能替代本阶段的真实产物证据。

### 工作项

1. `[complete] IR-007a -> IR-001a -> IR-002a -> IR-003a` 已冻结 JavaScript `number=f64`、NaN payload、`-0`、RNE/no-fast-math `+`、number/void HIR schema major 2 和 C ABI IEEE-754 bit-observation contract；lock/replay/旧 major rejection 与 `CompilerBuildIdentity` 已同步，其余类型 fail closed。
2. `[complete] FE-012a` 已关闭 validated-input 边界：subset gate 与 production lowering 只消费完整验证后的 detached snapshot；primitive replay 仅支持参数读取、`number + number` 和单一 return，HIR/op 显式携带 canonical empty logical capability requirements。
3. `[complete] BE-001a + RT-002a`：Go-LLVM/TargetMachine/DataLayout 基座与 Rust workspace/empty startup/manifest scaffold 已完成；二者只提供 resolver 所需 manifests，不自行声称完成 capability binding。
4. `[complete] BE-001a + RT-002a + BuildPlan -> TC-001a ResolveTargetContext`，resolver 只语义读取 BuildPlan/toolchain/runtime manifests，以 typed multi-artifact envelope 绑定 immutable TargetContext、LLVM authoritative DataLayout 与 AvailableCapabilityCatalog，并原样保留 HIR；裸 `Facts []string` 只可排序，不可作为 proof。首切只接受显式 Linux x86-64、LLVM 20、generic CPU、no-EH 和锁定 runtime。
5. `[complete] IR-003a + TC-001a -> IR-004a/005a` 已用 RepresentationPlan join 核对 HIR/BuildPlan/context/compiler identity provenance，并完成 target-aware HIR -> MIR、structural verifier 与 `BoundCapabilityClosure`/exact effects；首切覆盖 non-empty available catalog 与 empty add bound closure 的分层测试。
6. `[complete] IR-008a` 为 canonical pass executor 增加显式 case manifest、verified first-slice HIR/MIR canonical JSON/text serialization、schema-aware diff 与 `emit-hir --verify` / `emit-mir --verify` CLI；不适用阶段仍由 verifier 证明为 no-op，未引入语法面扩张。
7. `[complete] RT-002b + BE-002a/004a` 已固定 `extern "C" double add(double,double)` 的 ABI/bit harness，把 final verified MIR 真实降为通过 verifier 的 LLVM/ELF object，并由确定性 LLD response file 链接运行；完整 IR/runtime/backend issue 的 Phase 2B 范围不作为首切前置。
8. `[complete] REL-001a + VERT-001 + REL-002a` 已由 `test --stage static-core` 执行完整 snapshot-to-process 真实产物、生成 canonical provenance report，并以锁定 Node 22.22.0 对普通值、`-0` 和 canonical qNaN 完成三方 binary64 差分。Phase 2A 退出，下一步进入 Phase 2B。

### 首批必须可运行样例

```ts
export function add(a: number, b: number): number { return a + b; }
```

### 验收门槛

- HIR/MIR verifier 对首切正例通过，对篡改 schema、ID、类型、effect、origin、terminator 和 pass dump 的 negative golden 全部拒绝。
- Linux x86-64 `add(number, number)` 必须由独立 replay 进程经 HIR/MIR verifier、real LLVM、object 和确定性 LLD 运行，并与 Node oracle 一致。
- backend 必须拒绝未经 `ResolveTargetContext` 的 BuildPlan；TargetContext、toolchain/runtime manifest hash、DataLayout 和 capability closure 必须进入 MIR/artifact provenance。
- first-slice harness 通过固定 C ABI 传递 `double`，以 IEEE-754 bit pattern 观测 NaN、`-0` 和普通结果，避免当前 TS 子集缺少 literal/call 入口而无法形成可观察闭环。
- case manifest 记录 source/snapshot/HIR/MIR/LLVM/object/executable/output 的 provenance；同一输入重复运行摘要稳定。
- 上述闭环已经关闭。对象、GC、EH、async、模块与 self-hosted stdlib 仍不得借 Phase 2A 首切越过后续阶段门禁；Phase 2B 只扩本节定义的 primitive 控制流与静态核心。

## 阶段 2B：primitive 控制流与静态核心扩展

### 目标

在 Phase 2A 的真实产物链上扩展 `bool`、变量、调用与基本 CFG，再按表示和 runtime 证据引入 string、null/undefined 和单次求值消糖。每增加一个语法组，必须同时增加 snapshot proof、HIR/MIR golden、malformed verifier case 和 Node observable differential。

### 工作项

1. 实现 literal、identifier、unary/binary、call、variable、return、if/while/for/switch/conditional 的 HIR builder 与 CFG lowering。
2. 将 flow narrowing、literal widening、`never`/unreachable 转成 HIR facts；不在 lowering 中重新猜测类型。
3. `[primitive contract complete]` 固定 bool、null/undefined 与 UTF-16 string 的表示和 ABI，再实现对应 conversion/operator table。boolean 已冻结 canonical `i1` MIR 与严格 `uint8_t` ABI；nullable-number 已冻结 distinct null/undefined tags、16-byte ABI 和 guarded unwrap；UTF-16 已冻结 borrowed immutable `{const uint16_t *data, uint64_t length}` ABI、孤立 surrogate 保真、空/非空 canonical view 和 `.length`。owned storage、分配、索引与 GC 不属于本条纵切。
4. `[scoped]` Phase 2B 已关闭 nullish coalesce 与 local logical assignment 的单次求值；`as`、`satisfies`、non-null 以及依赖 property/computed-key/getter 的 optional-chain/logical-assignment place evaluation 移入 Phase 3 object/place contract，不以本阶段局部变量证据冒充完整 `IR-006`。
5. 扩展 HIR/MIR verifier 的 dominance、phi、短路、cleanup/effect 规则；实现保序常量折叠，不做跨函数激进优化。
6. `[complete] APP-001 + CLI-001 + VERT-009`：static-core application entrypoint/startup 与进程退出契约已冻结；真实 source capture 经 snapshot/HIR v8/MIR v6/LLVM/object/LLD 生成 deterministic ELF 与相邻 provenance report，入口使用 `bingo_program_main_v1` 和 manifest-authenticated application startup，未复用 case harness 或函数名到机器码映射。

七条 fixture 纵切已关闭，application build 纵切已完成本地实现与证据但保持 review-blocked：前七者由 deterministic ELF 独立进程执行并与锁定 Node oracle 差分；VERT-009 从真实项目构建唯一 exported `main(): number`，边界 `0/1/255`、source/HIR/MIR/manifest/startup 负例、versioned LLVM symbol、确定性 ELF/report 和静默精确退出码均有本地证据。当前 HIR/MIR schema 为 v8/v6。Phase 2B 只本地关闭 scoped primitive/static-core implementation，不代表完整 `IR-001..008` 或 release-profile milestone；property place、owned string/GC、模块和完整 stdlib 仍在后续阶段。

### 验收门槛

- `classify` 等控制流样例经同一 real-LLVM runner 与 Node oracle 一致。
- `f64` number、bool、UTF-16 string、null/undefined 的表示固定并有 ABI 测试。
- 已交付的 nullish 与 local logical-assignment 纵切副作用次数与 TypeScript/JavaScript oracle 一致；property optional-chain/短路/条件 place evaluation 由 Phase 3 `OBJ-000/001/003/006` 关闭。
- 误用 dynamic、跨域隐式转换和 disjoint assertion 在 HIR 入口被拒绝；任何 malformed golden 都不能到达 LLVM backend。

## Phase 2.5：工程加固与 Phase 3 准入

Phase 2.5 不扩大语言面。`ENG-001` 已让 application ELF/report 通过共享 atomic no-clobber publisher 发布，并在 report 失败时成对回滚；`ENG-002` 已把 primitive lowerer、MIR verifier 和 LLVM emitter 收敛为显式 registry，拒绝 ambiguous lowerer，移除重复 backend admission whitelist，并把新 lowerer 文件纳入 compiler identity hash；`REL-003a` 已增加有固定负例和 256 KiB 上限的严格 snapshot/HIR/MIR decoder fuzz seed。完整 self-audit 见 [phase2b-a3-self-audit-2026-08-11.md](phase2b-a3-self-audit-2026-08-11.md)。自动 CI 保持项目负责人指定的延期状态，但延期期间不得声称 Integrated。`GOV-001` 的独立 A3 review 仍是 application preview 进入 release profile 的前置，不阻塞 Phase 3 implementation entry。

完整顺序、issue 拆分和退出证据见 [phase3-entry-and-hardening.md](phase3-entry-and-hardening.md)。

## 阶段 3：表示布局、函数、对象、类、闭包与 variance

### 目标

从“表达式可以算”扩展到“值可以安全存储、传递、调用和捕获”。这是协变/逆变、结构化类型和 runtime layout 的核心阶段。

### 工作项

1. `OBJ-000a` 已以 `SelfAudited` 冻结 reference identity、aliasing、equality、readonly/write、escape category 和 dynamic boundary；契约、strict decoder/fuzz 与正负例见 [phase3-obj-000a-design-2026-08-11.md](phase3-obj-000a-design-2026-08-11.md)。
2. `OBJ-000b + BE-004b` 已以 `SelfAudited` 用 Linux x86-64 与 compile-only Linux AArch64 同时冻结 header/shape/field/trace schema；Rust/C/LLVM offset 对照与独立 layout hash 见 [phase3-obj-000b-be-004b-design-2026-08-11.md](phase3-obj-000b-be-004b-design-2026-08-11.md)。
3. `GC-001a + BE-003b` 已以 `SelfAudited` 在任何 owned object 之前冻结 root liveness、safepoint、dead-slot clearing、write barrier 和双目标 O2 preservation；canonical plan、独立 liveness verifier 与自审证据见 [phase3-gc-001a-be-003b-design-2026-08-11.md](phase3-gc-001a-be-003b-design-2026-08-11.md)。
4. `RT-006a` 已以 `SelfAudited` 提供单 mutator、STW、precise、non-moving tracing heap、shadow-stack ABI、cycle 回收与 deterministic archive；设计与证据见 [phase3-rt-006a-design-2026-08-11.md](phase3-rt-006a-design-2026-08-11.md)。
5. `OBJ-001a + OBJ-006a + BE-003a + VERT-010` 已按 [设计/自审](phase3-vert-010-design-2026-08-11.md) 以 `SelfAudited` 关闭 object literal、静态 property read/write、identity 和 alias observable semantics，并经真实 ELF/Node 差分。
6. `IR-006b + OBJ-003a/006b + VERT-011` 已按 [设计/自审](phase3-vert-011-design-2026-08-11.md) 以 `SelfAudited` 关闭 computed key、getter、optional chain 与 property logical assignment 的 PlaceRef 单次求值。
7. `OBJ-002a + BE-003a + VERT-012` 已按 [设计/自审](phase3-vert-012-design-2026-08-11.md) 以 `SelfAudited` 关闭首个 escaping mutable capture、by-cell environment、capture root lifetime 与 indirect call；lexical `this`、递归、嵌套环境和 adapter 留给后续独立纵切。
8. `VERT-013a/013b` 已关闭 base/derived class、constructor/super、field initializer 与 receiver identity；`OBJ-003b` private/protected access 已完成 canonical authorization、HIR/MIR/layout/bound MIR、LLVM emitter、runner 和 CLI 接线，待 Linux authoritative runtime/ELF 证据后完成本地状态提升。`OBJ-004` 已以 `SelfAudited` 关闭 per-declaration proof、真实 checker-free interface replay、nested generic/SCC、cross-module type relation、layout equality 与 canonical HIR direct-reuse gate；`OBJ-005` 已进入 Implementing，首个 readonly ObjectView 已具备真实 frontend snapshot→proof/HIR/MIR/backend/LLVM/harness/Node 链，但 Linux native differential 与 accessor receiver 证据仍待关闭，checked cast、copy adapter 和可审计 `unsafeCast` 继续按独立增量推进。可写字段/数组保持不变，方法 bivariance 不穿过 ABI。

### 验收门槛

- `ReadonlyArray<Dog>` 到 `ReadonlyArray<Animal>` 可通过；`Array<Dog>` 到 `Array<Animal>` 默认拒绝或显式复制。
- `(Animal) => void` 与 `(Dog) => void` 的参数方向测试正确；方法 bivariance 不直接穿过静态 ABI。
- 闭包捕获变量、class private slot、getter 副作用、super 调用都有运行测试。
- 不能生成同一 `TypeScript` 类型却使用不兼容 LLVM 表示的函数签名。

## 阶段 4：模块、泛型、枚举、集合、迭代与资源清理

### 目标

形成可组织的大型程序：模块图、初始化顺序、跨模块符号、可控泛型实例化和常用集合协议。

### 工作项

1. 使用 Program 的模块解析结果建立 ModuleGraph、import/export slots、default export 和循环依赖初始化。
2. 擦除 `import type`、纯类型导出和声明文件；为外部实现建立 FFI declaration contract。
3. 实现按表示分组的泛型单态化；加入递归深度、实例数量和代码尺寸上限。
4. 支持 generic constraint、default/const type parameter、in/out variance、泛型函数/类/接口的 HIR 实例化。
5. `RT-003a` 在 `RT-006a` 后实现 owned UTF-16 string、array/tuple 和 readonly view；`RT-003b` 再实现 Map/Set，borrowed UTF-16 继续沿用 Phase 2 契约。
6. `RT-004a` 先关闭同步 `for...of`、iterator close、spread 和解构的 normal/break/continue/return；throw/finally 路径拆为依赖 EH 的 `RT-004b`。
7. `RT-005a` 只实现同步 `using` 的正常和结构化控制流 cleanup；throwing cleanup 为 `RT-005b`，`await using` 为依赖 async 的 `RT-005c`。
8. 为每个标准库调用查询 [stdlib-runtime-plan.md](stdlib-runtime-plan.md) 的 capability manifest；声明存在但 runtime 未实现时在编译期报错。
9. 建立 `RT-007a` self-hosted stdlib HIR/package 种子，只接入不分配、不抛出、不挂起且不依赖 owned storage 的算法；package format 不再反向依赖 owned collection runtime，普通 specialization、verifier、deterministic package hash 和 dead-strip 全部适用。

### 验收门槛

- 多文件 ESM 样例（含循环依赖）初始化顺序稳定，重复导入只执行一次。
- 泛型实例化不会把 unresolved type parameter 留到 MIR；超限有可定位诊断。
- Phase 4 退出只要求 `RT-004a/005a` 的同步 normal/break/continue/return 清理；throw/finally 由 `RT-004b/005b` 随 EH 纵切关闭，`await using` 由 `RT-005c` 随 async 纵切关闭。
- `const enum` 只在可证明常量和边界安全时内联。
- `core-es2020` 等 manifest 的 capability 闭包、ABI hash 和缺失项报告可在 `ts2bin doctor` 中复现。
- Phase 4 的 self-hosted 退出只证明 seed package；依赖分配、GC、异常或 async 的算法不得据此标记为 complete。

## 阶段 5：runtime-heavy 语义与兼容层

### 目标

处理需要运行时协议或状态机的语法，同时把 dynamic/interop 与 static 核心隔离。这个阶段不应因为“能调用 runtime”就放宽 static 的拒绝规则。

### 工作项

1. 先完成 `EH-001` 的全链 status/exception-carrier ownership 与 target bridge 契约，再由 `BE-003c + ADV-001 + RT-004b/005b` 同一纵切实现异常 ABI、invoke/unwind、IteratorClose 和 throwing cleanup；Rust panic 不表达语言异常。
2. 在独立 Rust crate 中实现 Promise/microtask 原语，并与 async/await 状态机、错误 continuation、top-level await（若模块 profile 开启）连接。
3. 实现 generator/`yield`/`yield*` frame；如果目标 runtime 不完整，保持默认 R。
4. 以独立 Rust crate/capability 实现 BigInt、RegExp、Symbol、动态属性、`instanceof`、abstract equality 等 runtime 模块；重型 engine 和数据版本必须锁定。
5. 标准 decorator 与 legacy decorator 分开，固定 metadata、initializer 和执行顺序。
6. JSX 先按 checker 解析 factory/fragment，再走普通调用；建立最小 JSX runtime。
7. dynamic profile：`DynamicValue`、属性字典、外部 JS/Node/FFI boundary、显式 checked cast 和诊断统计。
8. 在 Phase 3 `GC-001a/RT-006a` 最小 heap 基础上扩展完整 `GC-001/RT-006`：async frame、弱引用前置、压力预算和 FFI root 边界；`Gc<T>` 不等于 root。ARC/arena 只实现为带无环证明和 capability 限制的受限 profile。
9. 在 RT-006 与 ADV-001 闭合后完成 `RT-007b`：把需要 owned storage、分配、异常或清理的核心 self-hosted stdlib 算法接入同一 package/verifier，形成可发布闭包。

### 验收门槛

- 每个 runtime helper 都有明确 ABI、错误策略和版本号；没有隐式调用未声明 helper。
- async/exception/using 的所有退出边都有状态机/cleanup 测试。
- static 与 interop 的输出和诊断可区分；开启 dynamic 不改变静态模块中未触达代码的行为。
- `eval`、`with`、任意 Proxy、原型改写等仍按矩阵拒绝，除非专门实现并单独命名 profile。
- GC root、写屏障、异常、async frame 和 cleanup 的 ABI 都有 runtime contract 与行为测试，不能只通过链接检查。

## 阶段 6：生产 LLVM 后端、优化、目标平台与产品化

### 目标

把各阶段已经随纵切增长的 LLVM/object/link 能力产品化，建立优化、缓存、完整第二运行目标、差分测试、性能和发布流程。Phase 6 不再首次实现对象、GC 或 EH backend lowering；它们分别由 `BE-003a/003b/003c` 与对应语义纵切闭合。

### 工作项

1. 使用 `tinygo.org/x/go-llvm` 建立 backend context/module/builder wrapper；固定 LLVM 大版本，首版优先 LLVM 20。
2. 完成通用 MIR operation/type/effect emitter registry、global、debug/source metadata 与优化 pipeline；对象、GC、EH emitter 已由早期纵切提供并在此统一产品化。
3. 运行 `VerifyModule`、PassBuilder/`default<O2>`，再用 TargetMachine 输出 bitcode/object/assembly。
4. 用锁定 Cargo/rustc 构建 `bingo-rt` 原生 static archives，固定 `extern "C"` calling convention、data layout、allocator、GC/写屏障、panic/status、异常和线程模型。
5. 实现 incremental cache：source/config/frontend snapshot hash -> HIR/MIR/LLVM artifact；cache key 必须含 LLVM/runtime ABI 版本。
6. 做 TypeScript/JavaScript oracle 差分、LLVM verifier、fuzz、compile-fail、性能和二进制可复现测试。
7. 在 Phase 3 compile-only second DataLayout 证据上增加至少一个第二运行目标，并完善 Windows/WSL2、Linux、macOS 构建矩阵。自动 CI 的重新启用时间由项目负责人决定，但启用并通过前不得进入 Integrated/ReleaseCandidate。
8. 按 [testing-conformance-and-release.md](testing-conformance-and-release.md) 接入 case manifest、Node/规范差分、fuzz、cache provenance 和可复现构建门禁。

### 验收门槛

- 所有发布样例 LLVM verifier 通过，`opt`、`llc`、linker 产生可运行文件。
- 同一输入、工具链和 runtime commit 可复现相同 LLVM/目标文件摘要。
- 同一 Rust toolchain、Cargo.lock/features、target/profile 和 runtime source 可复现相同规范化 archive/layout/capability 摘要。
- 失败分类清晰：TS 诊断、Bingo 子集拒绝、runtime ABI 缺失、LLVM/backend bug。
- 至少覆盖 x86-64 Linux 和一个第二目标；平台差异不能改变 TypeScript observable semantics。
- 发布 profile 的 handbook 交叉覆盖、标准库声明/成员 manifest、LLVM verifier、runtime ABI hash 和 artifact digest 全部可由 CI 报告追溯。

## 跨阶段测试策略

### 测试层次

1. parser/checker oracle：确认输入与 tsgo 诊断一致。
2. snapshot golden：确认符号、类型、flow 和 selected overload 稳定。
3. HIR/MIR golden：确认消糖、CFG、布局、variance 和 cleanup。
4. interpreter/runtime：快速测试字符串、容器、异常、Promise 和 iterator。
5. LLVM verifier/backend：确认 IR 合法、passes 不破坏 ABI、目标代码可运行。
6. differential：与 Node/TypeScript 发射结果比较允许的语义子集。

### 质量门禁

- 每个 R 规则都要有反例测试，防止后续“为了通过样例”误放开。
- 每次更新 tsgo commit 先运行 snapshot compatibility；Kind 增加或字段变化必须更新适配层。
- golden 变化需要说明源语义变化、上游变化还是编译器 bug 修复。
- fuzz 输入只允许进入 parser/snapshot 和显式 dynamic harness；不把任意 fuzz 程序直接当作可执行产物。

## 风险与应对

| 风险 | 影响 | 应对 |
| --- | --- | --- |
| tsgo `internal` API 变动 | 适配层频繁破坏 | 薄 fork、snapshot DTO、单一 facade、固定 commit |
| TS 动态语义过宽 | LLVM 代码错误但难定位 | static 默认拒绝，dynamic 显式边界并计数 |
| LLVM 版本/opaque pointer 差异 | 构建或 verifier 失败 | 固定大版本，backend contract tests，CI 多平台 |
| TypeScript 类型与运行时脱节 | 不安全布局/调用 | TsType/RepType 分层、MIR verifier、checked cast |
| 泛型代码爆炸 | 编译时间/二进制膨胀 | 按表示单态化、实例上限、共享引用版本 |
| 异常/async/GC 跨平台差异 | 运行时崩溃 | runtime ABI versioning、平台 feature gate、阶段性 R |
| Rust ABI/panic/unsafe 泄漏 | 未定义行为或无法稳定链接 | 只暴露 `repr(C)`/`extern "C"`、panic=abort、status 异常、unsafe 审计和 layout 双向验证 |
| rustc/Cargo feature 漂移 | archive、布局或行为不可复现 | 锁定 toolchain/Cargo.lock/features/target，全部进入 runtime lock 和 cache provenance |
| 直接复用 JS emitter | 隐式 coercion 和动态对象泄漏 | emitter 只作 oracle，独立 HIR/MIR lowering |
