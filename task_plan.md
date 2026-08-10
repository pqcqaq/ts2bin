# ts2bin 编译链规划文档编制计划

## 目标

审计本地 `typescript-go` 的语法树、解析器、类型检查器和标准库基线，设计 `TypeScript -> tsgo AST/语义 -> Bingo IR -> LLVM IR -> LLVM toolchain` 编译链，并在 `plans/` 交付可执行的开发计划与项目设计文档。

## 当前任务阶段

| 阶段 | 状态 | 说明 |
| --- | --- | --- |
| 1. 仓库与编译器能力审计 | complete | 定位本地源码，核对 parser/checker/AST/type APIs 与版本基线 |
| 2. TypeScript 语法与语义分级 | complete | 建立支持、消糖、运行时实现、诊断拒绝四类矩阵 |
| 3. Bingo IR 与流水线设计 | complete | 设计前端语义层、HIR/MIR 边界、ABI、GC/异常/异步策略 |
| 4. 六阶段 ast2bingo 路线图 | complete | 拆分实现顺序、依赖、里程碑、验收测试和退出条件 |
| 5. 文档落盘 | complete | 创建 `plans/` 并写入开发计划、项目设计和语法支持矩阵 |
| 6. 一致性复核 | complete | 检查覆盖范围、内部链接、术语、风险与可执行性 |

## 交付物

- `plans/README.md`：文档导航与关键决策摘要。
- `plans/architecture.md`：完整项目设计与编译管线。
- `plans/development-roadmap.md`：六阶段实施计划与验收标准。
- `plans/typescript-support-matrix.md`：TypeScript 全语法/语义支持、消糖、拒绝矩阵。
- `plans/tsgo-integration.md`：薄 fork、Program/checker 生命周期、snapshot schema 与 ModuleGraph 契约。
- `plans/bingo-ir-spec.md`：Bingo HIR/MIR 类型、指令、effect、unsafe provenance 与 verifier。
- `plans/stdlib-runtime-plan.md`：ES5–ESNext capability、runtime ABI、宿主边界与 GC 规划。
- `plans/testing-conformance-and-release.md`：分层测试、差分/fuzz、CI、缓存和发布门禁。
- `plans/implementation-backlog.md`：稳定 issue ID、依赖 DAG、阶段退出命令和第一条纵向实现路径。
- `plans/compiler-development-process.md`：编译器变更分级、开发状态机、审计触发条件、记录模板和发布/回滚流程。
- `plans/coding-and-maintainability-standards.md`：抽象准入、核心流程注释、公共 API 文档和可读性审计。
- `plans/test-authoring-standards.md`：独立测试、测试库、fixture、golden、乱序/race/重复运行规范。
- `plans/git-and-commit-standards.md`：父仓库/submodule、分支、提交消息、合并和发布标签规范。

## 设计约束

- `typescript-go` 是前端语法与类型语义事实来源；采用薄 fork 解决 Go `internal` 导入限制，但不修改 parser/checker 核心行为。
- 类型擦除不能掩盖不可靠的断言；运行时表示变化必须有可验证的转换。
- Bingo IR 不直接复制 TypeScript AST；应区分高层语义 IR 与接近 LLVM 的低层 IR。
- 先支持可闭合、可验证的 TypeScript 子集，再分阶段扩展动态 JavaScript 语义。
- 每阶段必须有 golden IR、诊断、差分行为和 LLVM verifier 测试。

## 本轮完善阶段（2026-08-04）

| 阶段 | 状态 | 说明 |
| --- | --- | --- |
| A. 既有资料与 tsgo 对照 | complete | 将 handbook、stdlib 索引、tsgo Program/checker/transformer 事实写入设计 |
| B. 可实现接口与 IR 规格 | complete | 增加 snapshot schema、HIR/MIR 指令、verifier 和 ABI 契约 |
| C. 标准库与 runtime 分层 | complete | 把 ES5–ESNext 声明映射成可编译级别、宿主边界和版本策略 |
| D. 工程化测试与发布 | complete | 增加 conformance、差分、fuzz、缓存、CI 和 issue 拆分 |
| E. 文档一致性复核 | complete | 完成导航、交叉引用、GC 默认值、链接、围栏和源码工作树复核 |

## 遇到的错误

| 错误 | 尝试次数 | 解决方案 |
| --- | ---: | --- |
| `eza` 在当前环境未显示目录内容 | 1 | 使用 `fd`/`rg --files` 进行可重复枚举 |
| Windows 下 `rg` 不展开 `handbook\\*.md` 路径 glob | 1 | 改用目录参数配合 `-g '*.md'` |
| `fd -x wc` 找不到 `wc` | 1 | 改用 `rg -c '^'` 统计 Markdown 行数 |
| 本轮复用的 Program 查询正则括号未闭合 | 1 | 后续改用固定字符串检索，避免在 PowerShell/rg 双重转义中丢括号 |
| 全仓库首次暂存的 `git diff --cached --check` 报既有 handbook 多余 EOF 空行 | 1 | 不批量改写范围外文档；修正本轮新文档并使用 scoped diff check，初始提交前另行做基线格式清理 |

## 开发流程规范阶段（2026-08-04）

| 阶段 | 状态 | 说明 |
| --- | --- | --- |
| F. 流程与审计模型设计 | complete | 定义变更分级、状态机、审计触发条件、角色和必需产物 |
| G. 流程文档落盘与导航 | complete | 新增编译器开发流程规范并接入 README/backlog |
| H. 一致性与链接复核 | complete | 检查流程和现有架构、测试、发布门禁无冲突 |

## 工程规范强化阶段（2026-08-04）

| 阶段 | 状态 | 说明 |
| --- | --- | --- |
| I. 可读性与维护性规范 | complete | 限制无意义封装，强制核心流程注释和公共 API 文档 |
| J. 独立测试规范 | complete | 设计测试库、fixture/golden 和单独/乱序/race/重复门禁 |
| K. Git 与提交规范 | complete | 定义 submodule、分支、提交格式、合并和标签规则 |
| L. 导航、流程与一致性复核 | complete | 接入流程总规范并检查链接、术语和可执行性 |

## 仓库初始化与提交阶段（2026-08-04）

| 阶段 | 状态 | 说明 |
| --- | --- | --- |
| M. Git 与 submodule 初始化 | complete | 初始化 `main`，将 tsgo 规范化为 gitlink/submodule |
| N. 初始格式基线 | complete | 只移除 `git diff --check` 报告的多余 EOF 空行 |
| O. 原子提交拆分 | complete | 按仓库、handbook、plans、项目记录四批构建本地历史 |
| P. 历史与工作树复核 | complete | 检查提交顺序、内容、测试、submodule 和最终状态 |

## 实现级算法规格阶段（2026-08-04）

| 阶段 | 状态 | 说明 |
| --- | --- | --- |
| Q. tsgo 与既有规格算法审计 | complete | 核对 AST Kind、transform 顺序、variance worker 和 IR 不变量 |
| R. 全语法 lowering 规格 | complete | 按表达式、语句、声明、类、模块和现代语法给出 AST→HIR/MIR 算法 |
| S. 类型、泛型与方差算法 | complete | 完成规范化、表示选择、assignability、variance SCC、adapter 和单态化算法 |
| T. runtime/backend 与拒绝策略 | complete | 完成对象布局、异常、async、GC、LLVM lowering、能力边界和诊断算法 |
| U. 总入口、交叉引用与静态复核 | complete | 串联实现文档并通过覆盖、链接、围栏、格式和术语一致性检查 |

## Rust runtime 架构固化阶段（2026-08-04）

| 阶段 | 状态 | 说明 |
| --- | --- | --- |
| V. Runtime 实现语言决策 | complete | 固定 Rust native staticlib、versioned C ABI、panic/status 和 Bingo tracing GC 边界 |
| W. 标准库实现分层 | complete | 固定 Rust primitives、self-hosted TypeScript 和 external engine 三层 |
| X. 构建与链接契约 | complete | 固定 target/profile archives、runtime lock、capability closure、deterministic LLD response/link |
| Y. 路线图与门禁同步 | complete | 更新 architecture/spec/backlog/testing/process/maintenance/git 文档 |
| Z. 静态一致性复核 | complete | 链接、围栏、格式、旧假设和 diff 检查通过；未实现 runtime 代码 |

## Phase 1 Foundation 与前端实现（2026-08-04 至 2026-08-05）

以下表格保留 Phase 1 在方向审计前、按原验收契约得到的历史状态；`complete` 只表示 `FND-001..003`、`FE-001..007` 原门禁通过，不表示 snapshot 已可在 AST/checker release 后直接 lower。

| ID | 状态 | 实现范围 | 独立验收（在 `typescript-go` 目录运行） |
| --- | --- | --- | --- |
| `FND-001` | complete | CLI 骨架与完整 toolchain/schema provenance | `go test ./internal/tsfrontend -run '^TestCanonicalBuildInfoJSONIsStableAndComplete$' -count=1`; `go test ./cmd/ts2bin -run '^TestVersionJSONContainsLockedProvenance$' -count=1` |
| `FND-002` | complete | `bingoOptions` 默认值、profile、canonical digest、严格校验与未知字段拒绝 | `go test ./internal/tsfrontend -run '^TestNormalizeOptions' -count=1`; `go test ./internal/tsfrontend -run '^TestCheckRejectsUnknownBingoOption$' -count=1` |
| `FND-003` | complete | 稳定诊断 registry、分类、排序和去重 | `go test ./internal/tsfrontend -run '^TestDiagnostic' -count=1`; `go test ./internal/tsfrontend -run '^TestSortAndDeduplicateDiagnosticsUsesStableContract$' -count=1` |
| `FE-001` | complete | tsconfig -> CompilerHost -> Program -> canonical diagnostic facade | `go test ./internal/tsfrontend ./cmd/ts2bin -run '^TestCheck' -count=1` |
| `FE-002` | complete | checker 独占借用与 panic-safe release | `go test -race ./internal/tsfrontend -run '^TestWithCheckerForFile' -count=1` |
| `FE-003` | complete | pointer-free snapshot、稳定 ID/hash、校验与 determinism CLI | `go test ./internal/tsfrontend -run 'Deterministic' -count=1`; `go test ./cmd/ts2bin -run '^TestSnapshotVerifiesDeterminismAndWritesJSON$' -count=1` |
| `FE-004` | complete | type/signature/symbol/overload/narrowing/generic semantic facts 与 fixture semantic digest | `go test ./internal/tsfrontend -run '^TestFrontendConformanceFixtures$' -count=1`; `go test ./internal/tsfrontend -run '^TestSnapshotCapturesGenericCallInstantiation$' -count=1` |
| `FE-005` | complete | 351-row Kind inventory、真实 gate handler registry、subset gate、194 evidence 与 157 exemption | `go test ./internal/tsfrontend/kind_manifest_gen ./internal/tsfrontend -run 'Kind' -count=1`; `go test ./internal/tsfrontend -run '^TestRunSubsetGate' -count=1` |
| `FE-006` | complete | Program-resolution ModuleGraph、canonical path、edge 分类与 eager SCC | `go test ./internal/tsfrontend -run 'ModuleGraph' -count=1` |
| `FE-007` | complete | 351/4,893/108/100 compatibility baseline、lock drift、API variant 与安全原子更新 | `go test ./internal/tsfrontend ./cmd/ts2bin -run 'Compatibility' -count=1` |

该轮冻结时的门禁矩阵：`go test ./...`、`go test -race ./internal/tsfrontend ./cmd/ts2bin`、`go test -shuffle=on ./...`、`go test -count=20 ./internal/tsfrontend ./cmd/ts2bin`、`go vet ./...`，以及 `version --json`、`test --stage frontend --json`、`doctor --json`、`compatibility --json` 四个 CLI smoke 当时全部通过。2026-08-05 审计后，阶段退出状态改为 `conditional pass`。

## Phase 1.5 与调整后主链（2026-08-06）

`FE-012a` 与 `IR-007a -> IR-001a -> IR-002a -> IR-003a` 已关闭；下一步并行推进 `BE-001a` 和 `RT-002a`，二者与 BuildPlan 汇合到 `TC-001a` 后才进入 target-aware `IR-004a/005a`。`BuildPlan` 只表示绑定 frontend hash 的 canonical unresolved request；resolver 只语义消费 BuildPlan/toolchain/runtime manifests，产出 immutable `TargetContext`、LLVM TargetMachine 的权威 `DataLayout` 和 `AvailableCapabilityCatalog`。typed envelope 原样保留 HIR，首次 HIR/target provenance join 发生在 `RepresentationPlan`；structural MIR 之后再由 capability binding 产出 `BoundCapabilityClosure`。完整 `IR-001..007` 与广泛 HIR/语法开发继续等待 real-LLVM 纵切反馈，MIR/backend 不得直接消费未解析 BuildPlan。

| ID | 当前状态 | 结果/退出条件 |
| --- | --- | --- |
| Direction audit | complete | 保留总体架构；Phase 1.5 实现契约已完成、Phase 2A 可启动；当前 pinned-fork 交付迁移已落盘但 FND-004 验收待执行，阻断证据和调整后的依赖已写入审计报告/backlog |
| CLI/profile fix | complete | 未显式 override 时保留完整 `bingoOptions`；显式 `--profile` 只改变 profile；定向测试通过 |
| Assertion proof bridge | complete | assertion chain、non-null、representation/flow proof 已进入 snapshot，并由 wire 独立重算、corruption negative 和 round-trip regression 闭合 |
| `FND-004` | complete | 现行 submodule/lock 已迁移到 `pqcqaq/typescript-go` 的固定 fork commit，并以 reviewed upstream ancestor + fork commit 作为 compiler identity；旧 patch/materialize/apply 机制已退役。本地 doctor、frontend 九阶段、隔离 fork smoke/full test/vet、locked replay 双构建、远端 fork fetch/full test/vet，以及 committed parent HEAD clean-clone 的 identity/clean-worktree/doctor 验收均已通过 |
| `FE-008` | complete | Kind-driven payload/role/arity registry、单一 `frontendwire` serialized validator、rooted-path fail-closed 门禁与原 overlay 负例已实现；核心、race、shuffle/repeat、全仓 regression 通过 |
| `FE-009` | complete | per-specifier binding、callee effect closure、exhaustive registry、lowerer facts、ownership/redirect 负例和 wire round-trip 已实现；serialized validator 双写已移除，核心与全仓 regression 通过 |
| `FE-010` | complete | checker-free dependency closure、独立进程重复输出、显式 evaluation-order/single-block HIR 与 tamper post-verifier 已通过；migration baseline/golden regression 已闭合 |
| `FE-011` | complete | source-level target split、三项 TS options、Windows/WSL identity、跨盘/UNC/POSIX rooted path fail-closed、profile/cache regression 和 validated FrontendSnapshot binding 已通过 |
| `FE-011b` | complete | canonical `exceptions=none` 已迁移 default options、lock、BuildPlan 与 golden；`llvm-eh` 只保留为未来 capability 并 fail closed，status-code/native-unwind 后续独立锁定 |
| `IR-000` | complete | executor/fixed-point/budget/pre-post/effect/dump golden 与 validate-snapshot -> typed-HIR production prefix 已通过核心、race、frontend stage 和全仓 regression；typed HIR 之后的 TargetContext/handlers 与真正 MIR verifier属于 Phase 2A |
| `FE-012a` | complete | `Frontend.Build` 返回 canonical 深拷贝 sealed snapshot；返回 diagnostics 与 snapshot 脱离；公共 subset gate 自行完整验证，production replay 对 in-memory/serialized/frontend-wrapper 的重哈希 flags/modifiers/type-closure 篡改全部 fail closed |
| `IR-007a` | complete | number contract v1 固定 binary64、canonical qNaN、保留 `-0`、RNE/no-fast-math `+`、`extern "C" double add(double,double)` 与 ABI bits observation；alternative contract fail closed |
| `IR-001a/002a/003a` | complete | HIR major 2、完整 `CompilerBuildIdentity`、identity-free source plan、logical requirements、number-only canonical lowering 与 schema/ID/type/effect/origin/terminator/provenance/capability/CFG negative tests已闭合；lock 的 `bingoIR` 已升为 2 |
| Typed artifact envelope substrate | complete | `PassArtifactEnvelope` 已提供 role/schema/payload-bound canonical digest、immutability 与 executor transition checks；resolver 不把 HIR误列为语义输入，RepresentationPlan 才声明首次 join；这只是 `TC-001a` 基础设施 |
| `BE-001a`, `RT-002a` | ready | 并行建立真实 Go-LLVM TargetMachine/DataLayout 与 Rust empty startup/toolchain-runtime manifests；不得以 fixture envelope 冒充完成 |
| `TC-001a`, `IR-004a/005a` | blocked | 等待 `BE-001a + RT-002a` 的真实 manifests/DataLayout；随后实现 resolver、RepresentationPlan join、target-aware MIR provenance/verifier 与 BoundCapabilityClosure |
| `RT-002b`, `BE-002a/004a`, `REL-001a`, `VERT-001`, `REL-002a` | blocked | 等待 verified target-aware MIR，再完成固定 C ABI、real LLVM/object/LLD、最小 runner 与 Node differential |
| Phase 2B: primitive control flow | blocked | Phase 2A 通过后再扩 bool、变量、调用、CFG、string/null/undefined 和单次求值消糖 |
| `OBJ-000`, `GC-001`, `EH-001` | pending | 分别在对象、GC、异常实现前冻结 alias/identity/ABI、root liveness/O2 和 status/unwind bridge |
| Broad Phase 2+ | blocked | 第一真实纵切通过后再扩对象/runtime/modules/generics/EH/async/第二目标 |

当前验证备注：`go list -deps ./cmd/ts2bin-replay` 已证明 production replay 不携带 parser/checker/AST；现行交付已迁移为 `pqcqaq/typescript-go` 固定 fork commit，旧 patch/materialize/apply 机制不再是活跃路径。doctor、frontend 九阶段、核心/全仓 test/vet、locked replay 双构建、本地和远端隔离 fork verification，以及 committed parent HEAD clean-clone 已通过；可按既定依赖进入 Phase 2A。不要重复开发已存在的 registry/executor/envelope，也不要在首切 real-LLVM 纵切通过前进入 Phase 2B。
