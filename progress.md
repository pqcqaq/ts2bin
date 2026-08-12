# 工作进度

## 2026-08-03

- 已读取 `planning-with-files-zh` 技能说明。
- 已确认当前目录不是 Git 仓库；不进行提交。
- 已建立计划、资料记录和进度日志。
- 已检查 Node/npm/TypeScript 环境，确认 npm 当前 TypeScript 版本为 `7.0.2`。
- 发现 `npx tsc` 的同名包陷阱，后续改用显式 `typescript@latest`。
- 已稀疏克隆微软官方 `TypeScript-Website` 仓库并记录参考提交。
- 已枚举 Handbook、Reference、Declaration Files 与发布说明的官方章节。
- 已从官方发布说明筛出 TypeScript 4.0 至 6.0 的主要语言/类型语法特性。
- 已完成阶段 1；当前阶段：文档结构设计。
- 已建立 `handbook/README.md` 导航、资料说明、严格模式配置和示例目录。
- 已完成阶段 2；当前阶段：核心语法与类型系统编写。
- 已完成 01–03：基础语法、基础类型、联合与收窄，并加入对应示例。
- 校验：`npm run check` 通过（TypeScript 7.0.2，严格模式）。
- 已完成 04–07：函数、对象类型、泛型、类型运算，并加入对应示例。
- 二次校验：全部 01–07 示例通过 TypeScript 7.0.2 严格检查。
- 用户追加 ECMAScript 标准库整理范围；已确认本地 `typescript-go` 完整仓库及其 ES5–ESNext 声明目录。
- 已在计划中新增独立的标准库阶段，并记录 DOM/WebWorker 与 ES 标准的边界。
- 已完成 08–09：类、模块与命名空间，并加入模块化示例。
- 三次校验：全部 01–09 示例通过 TypeScript 7.0.2 严格检查。
- 已完成阶段 3；当前阶段：工程与现代语法编写。
- 已核对 TypeScript 6.0 默认值、迁移项和 `typescript-go` 对 TypeScript 7 原生端的定位。
- 已完成 10–11：枚举/符号/迭代/资源管理与标准/旧式装饰器，并加入示例。
- 四次校验：全部 01–11 示例通过 TypeScript 7.0.2 严格检查。
- 已完成 12–14 与 16：声明文件/JSX、工具类型、现代语法版本表、编译配置。
- 五次校验：全部 01–14 示例通过 TypeScript 7.0.2 严格检查，包含 `import defer`。
- 已完成阶段 4；当前阶段：ECMAScript 标准库整理。
- 标准库声明检索第一次因 Windows glob 展开规则失败；已改为 `rg -g` 方案。
- 已枚举所有实际含声明的 `lib.es*.d.ts` 分项，并识别 ES2025/ESNext 新增接口。
- 已生成并复核 `stdlib/99-api-index.md`：314 个声明类型、103 个全局/命名空间值签名、2173 条成员签名。
- 已修正索引生成器，使声明标题保留泛型参数和继承信息。
- 已完成标准库入口、原始值/全局对象、数组/二进制数据两章，并列出完整方法分组。
- 六次校验：新增 ESNext Array/Uint8Array、ES2024 ArrayBuffer、Float16 示例通过。
- 已完成标准库 03：Map/Set/Weak*、Proxy、Reflect、属性描述符，并加入示例。
- 七次校验：标准库集合/反射示例通过 TypeScript 7.0.2 严格检查。
- 已完成标准库 04：Promise、Iterator/AsyncIterator、Iterator Helpers、DisposableStack，并加入示例。
- 八次校验：标准库异步/迭代/资源示例通过 TypeScript 7.0.2 严格检查。
- 已完成标准库 05：RegExp、Date、Intl 全部格式化器、Segmenter、DurationFormat，并加入示例。
- 九次校验：标准库正则/日期/Intl 示例通过 TypeScript 7.0.2 严格检查。
- 已完成标准库 06–07：Temporal 全部对象族与 ES5–ESNext 版本索引。
- 已更新主 README/SOURCES，加入标准库入口、typescript-go 提交和 AST 生成索引说明。
- 已完成阶段 5；当前阶段：组合示例与速查表。
- 已完成 15 组合用法及示例；首次新增 17 速查章的补丁格式失败，未产生部分文件。
- 已重新分批创建 17 语法速查，覆盖声明、类型运算、泛型、类、模块、环境声明、装饰器和资源管理。
- 十次校验：加入组合示例后，全部 TypeScript/TSX 示例通过严格检查。
- 已完成阶段 6；当前阶段：自动校验与收尾。
- 收尾统计：29 个 Markdown、23 个 TypeScript/TSX 示例，无 TODO/FIXME/占位内容。
- 类型严格检查通过；链接检查首次因 Windows `fd -x` 无法解析无后缀 `npx` 失败，已改用 `npx.cmd`。
- 链接检查第二次因并发 `npx` 竞争缓存失败；改为单任务串行 `npm exec` 与独立临时 cache。
- 补充 `examples/09-modules.ts`，各核心章节均有对应或组合示例。
- 最终校验：24 个 TS/TSX 示例通过 TypeScript 7.0.2 严格检查。
- 最终校验：29 个 Markdown 的本地链接全部通过 `markdown-link-check`。
- 最终校验：正文无 TODO/FIXME/占位内容；`typescript-go` 工作树保持干净。
- 标准库索引重生成哈希一致：`85f3b1a428106407fd3c63cda768b5f8c162305d`。
- 所有阶段完成。

## 2026-08-04

- 已切换到 ts2bin 编译链设计任务。
- 已读取 `planning-with-files-zh` 技能并恢复既有规划文件。
- 已建立六步文档编制计划，准备审计本地 `typescript-go` 源码。
- 已定位本地前端组件：`internal/ast`、`internal/parser`、`internal/checker`、`internal/compiler`、`internal/transformers`。
- 已确认解析/程序/检查器入口名称，并记录 AST 由手写与生成文件共同组成。
- 已确认 Go `internal` 导入限制和 tsgo “API not ready” 状态；项目结构将采用薄 fork + 内部适配层方案。
- 已确认 checker 具备 typed lowering 所需的主要语义查询接口。
- 已审计 AST 节点访问、Program 诊断入口、checker 类型标志与 variance 实现。
- 已识别 TS 可变数组协变的不健全兼容点，并决定 Bingo 默认采用可变容器不变、只读容器协变。
- 已枚举 tsgo 自带消糖 transformer，后续用作行为参照和差分测试来源。
- 语法清单检索首次使用 Windows 路径 glob 失败，已记录并改用 `rg -g`。
- 已创建 `plans/README.md`，定义文档导航、支持级别和核心方案。
- 已创建 `plans/architecture.md`，覆盖前端集成、typed snapshot、Bingo HIR/MIR、运行时 ABI、variance、泛型、消糖、模块/异常/异步和 LLVM 后端。
- 已创建 `plans/typescript-support-matrix.md`，按词法、类型节点、表达式、语句、模块、类、JSX/JSDoc 和动态语义建立完整支持/消糖/运行时/拒绝矩阵。
- 已创建 `plans/development-roadmap.md`，给出六阶段 ast2bingo 路线、交付物、验收门槛、测试策略和风险应对。
- 已补充 `import defer` 和按 `kind_generated.go` 分组的 AST Kind 覆盖账本。
- 一致性检查通过：4 个 Markdown、约 770 行；本地链接目标存在，代码围栏成对，无 TODO/FIXME/TBD 占位。
- 本轮规划文档任务全部完成。

## 2026-08-04 文档完善

- 用户要求结合 handbook、标准库索引和 tsgo 源码进一步完善规划。
- 已重新读取规划技能以及 `task_plan.md`、`findings.md`、`progress.md`。
- 已开始对照现有 plans、handbook 导航、tsgo transformer/tsoptions；发现需要增加可实现接口、IR 指令、stdlib/runtime 和工程化测试文档。
- 一次 Program 生命周期正则检索因括号转义失败，已记录并改用分段/固定字符串检索。
- 已核对 Program 诊断与 checker 获取接口，确认 checker 独占访问和 release 函数约束。
- 已核对 tsoptions target/lib/module/JSX/strict 配置与 handbook 标准库分组，确定需要增加配置兼容表和 runtime capability manifest。
- 已核对 tsconfig -> CompilerHost -> Program 构造链、SourceFile 绝对路径要求、module resolution API、Type/Signature 访问器和 flow graph 形态。
- 已新增 `plans/tsgo-integration.md`：固定薄 fork、Program 构造、checker 生命周期、snapshot schema、tsconfig 契约、AST manifest 和 ModuleGraph。
- 已新增 `plans/bingo-ir-spec.md`：定义 HIR/MIR v1 类型、指令、effect、unsafe provenance、normalization passes、verifier 和示例。
- 已新增 `plans/stdlib-runtime-plan.md`：将 handbook 的 ES5–ESNext 标准库映射到 capability manifest、runtime ABI、GC/字符串/集合/异步/Temporal 分层。
- 已新增 `plans/testing-conformance-and-release.md`：定义 case manifest、handbook/stdlib 交叉覆盖、差分/fuzz、CI、缓存和发布工程。
- 已更新 `plans/README.md` 和 `plans/architecture.md`：串联 tsgo、IR、runtime、测试发布规格并明确唯一事实来源。
- 已更新 `plans/development-roadmap.md`：六阶段补入 facade/checker release、HIR/MIR verifier、capability manifest、tracing GC/runtime ABI 和可复现发布门禁。
- 已修正 `bingoOptions.gc`：general static profile 默认从 ARC 改为非移动 tracing GC；ARC/arena 仅作为受限 profile。
- 已新增 `plans/implementation-backlog.md`：用稳定 issue ID、依赖 DAG、交付物、验收命令和第一条纵向实现路径将规划落到工程任务。
- 最终静态检查：9 个 plans Markdown、约 2,049 行；代码围栏全部成对，本地链接全部可解析，无 TODO/FIXME/TBD 占位。
- 已确认 `typescript-go` 工作树保持干净；项目根目录仍不是 Git 仓库，因此没有提交动作。
- 本轮完善阶段 A–E 全部完成。

## 2026-08-04 编译器开发流程规范

- 用户要求新增覆盖完整开发步骤和审计时机的编译器工程规范。
- 已新增 `plans/compiler-development-process.md`，定义 D0–D4 变更等级和 A0–A4 审计等级。
- 已建立 Proposed -> Scoped -> DesignAccepted -> Implementing -> LocalVerified -> SelfAudited -> ReviewAudit -> Integrated -> ReleaseCandidate/Released 状态机。
- 已明确设计审计、实现审计、里程碑审计、发布审计和 tsgo/stdlib/LLVM 上游升级审计的入口条件。
- 已补充 issue 分诊、证据收集、最小纵切、停线条件、验证命令、自审清单、返工/合并、阶段退出、故障回滚和标准记录模板。
- 已把流程规范接入 `plans/README.md`、`plans/implementation-backlog.md` 和 `plans/testing-conformance-and-release.md`。
- 最终检查：10 个 plans Markdown、约 2,441 行；本地链接全部存在，代码围栏成对，无 TODO/FIXME/TBD/占位和行尾空白。
- `typescript-go` 工作树保持干净；根目录不是 Git 仓库，未执行提交。
- 本轮流程规范阶段 F–H 全部完成。

## 2026-08-04 工程规范强化

- 用户要求强化代码可读性/可维护性、公共文档注释、核心流程注释、提交和完全独立测试规范。
- 已新增 `plans/coding-and-maintainability-standards.md`：核心流程保持线性，抽象必须证明语义/不变量/复用/边界价值，禁止无意义 wrapper、预判式接口和无归属 helpers。
- 已强制 Program/checker、snapshot、HIR/MIR pass、variance/dynamic、runtime/GC/EH 和 LLVM mapping 编写核心不变量、生命周期和失败策略注释。
- 已强制所有导出类型、函数、方法、配置、诊断、IR 节点、CLI 和 runtime ABI 编写契约型文档注释。
- 已新增 `plans/test-authoring-standards.md`：测试必须可单独、乱序、重复和安全并行/分片运行；每 case 独享 workspace、manifest、golden 和 runtime/LLVM context。
- 已设计 `internal/testkit` 的最小边界、Go testing/go-cmp 使用规则、fixture/golden、negative、differential、fuzz、flaky 和独立性审计要求。
- 已新增 `plans/git-and-commit-standards.md`：Conventional Commits、分支/scope、Test/Audit footer、submodule 更新、合并、标签和回滚规范。
- 已更新流程总规范、自审清单、测试发布规范和 README 导航，使三份规范成为合并门禁。
- 最终静态检查：13 个 plans Markdown、约 3,221 行；本地链接全部存在，围栏成对，无 TODO/FIXME/TBD/占位和行尾空白。
- 三份新增规范的 scoped `git diff --cached --check` 通过；全仓库首次导入检查仍会报告既有 handbook 的额外 EOF 空行，已记录为初始提交前的独立基线清理，不在本轮批量改写。
- 新增/修改文件已加入父仓库暂存区；未创建提交，`typescript-go` submodule 工作树保持干净。
- 本轮工程规范阶段 I–L 全部完成。

## 2026-08-04 Git 初始化与分批提交（历史记录）

- 已将父目录初始化为 Git `main` 分支，并把现有 `typescript-go` 规范化为 submodule/gitlink。
- `[历史]` submodule 远程曾为 `https://github.com/microsoft/typescript-go.git`，固定提交 `5b1047d10d32e7d5b446be4de56b126ff42f82bb`；现行交付已迁移到 `pqcqaq/typescript-go` pinned fork commit。
- 初始提交前按 `git diff --cached --check` 机械清理 53 个既有文件的额外 EOF 空行；未改正文语义。
- 第 1 批 `763f330 chore(repo): initialize repository and pin typescript-go`：仓库、ignore、submodule 基线。
- 第 2 批 `f030162 docs(handbook): add TypeScript and ECMAScript reference`：完整 handbook、示例、标准库索引和生成器。
- 第 3 批 `1a3d1d8 docs(plans): define ts2bin architecture and engineering standards`：架构、IR、runtime、路线图、流程、编码、测试和提交规范。
- handbook 的 `npm run check` 与 `npm run check:links` 通过；13 份 plans 的本地链接、围栏、占位和 whitespace 检查通过。
- 根目录研究、发现、任务和进度记录作为最后一批提交，形成从资料审计到工程落地的完整轨迹。

## 2026-08-04 实现级算法规格

- 新增 `plans/implementation-specification.md`，固定 Program/snapshot/subset gate/type plan/HIR/MIR/capability/LLVM 主算法、checker 生命周期和 pass 顺序。
- 新增 `plans/syntax-lowering-algorithms.md`，逐类规定表达式、PlaceRef、求值顺序、控制流、声明、class、module、async/generator、JSX/decorator 和 synthetic Kind 的 lowering。
- 新增 `plans/type-system-and-variance-algorithms.md`，规定 TsType/RepType、双层兼容性、union/intersection、递归方差 SCC 固定点、function adapter、泛型单态化和断言链算法。
- 新增 `plans/runtime-and-backend-lowering-algorithms.md`，规定对象/字符串/数组/闭包布局、shadow-stack tracing GC、module SCC、native EH、Promise/async/generator 和 MIR 到 LLVM/object/link 算法。
- 新增 `plans/unsupported-semantics-and-diagnostics.md`，规定 static/interop/unsafe 边界、必须拒绝的动态行为、capability/target 失败、稳定诊断和新能力准入门禁。
- 更新 plans 总导航、六阶段路线图和 lowering 细则交叉引用，使实现代码能够从总规格进入并定位唯一算法契约。
- 一致性审计修正旧 `setjmp` EH 建议、模块 import 顺序和 optional/indexed read-write 类型规则；18 份 plans 文档的本地链接、围栏、占位词、行尾空白和 `git diff --check` 均通过，typescript-go submodule 保持干净。

## 2026-08-04 Rust runtime 架构决策

- 用户决定使用 Rust 编写 `bingo-rt` core，并在编译末端静态链接；旧的 Go/C/LLVM runtime 泛化表述被正式收敛。
- 新增 `plans/rust-runtime-and-linking.md`，固定 Rust workspace、`repr(C)`/`extern "C"` ABI、safe/unsafe 边界、`Gc/Root`、panic/status、`std -> no_std + alloc` 路线、native static archives 和 LLD 链接算法。
- 更新总体架构、编译主算法、runtime/backend、stdlib、路线图、backlog、测试、开发流程、维护和 Git 规范，使 Rust toolchain、Cargo features、archive/layout/capability hash 进入门禁与 provenance。
- 标准库明确分成 Rust 原语、self-hosted TypeScript HIR/package 和可选 external engine 三层；泛型算法不要求 Rust archive 穷举用户实例。
- 当前只记录架构和执行契约，尚未创建 Cargo workspace、runtime 源码、archive 或 linker 实现。
- 最终静态复核：19 份 plans 文档、6,452 行；本地链接全部存在，Markdown 围栏成对，无实际 TODO/FIXME/TBD、行尾空白或旧 Go/C runtime 实现假设，`git diff --check` 通过。

## 2026-08-04 至 2026-08-05 Phase 1 Foundation 与前端实现

Phase 1 的实现已落在 `typescript-go/cmd/ts2bin` 与 `typescript-go/internal/tsfrontend`。下表记录的是 2026-08-05 方向审计前，按当时 `FND-001..003`、`FE-001..007` 验收契约得到的完成状态；它证明原前端门禁通过，不代表 snapshot 已经 lowering-ready。审计后的当前状态见下一节。

| ID | 状态 | 已实现内容 | 可复现验收命令（在 `typescript-go` 目录运行） |
| --- | --- | --- | --- |
| `FND-001` | complete | 建立 `cmd/ts2bin` 命令入口；锁定并输出 tsgo commit、TypeScript/Go、108 个 bundled lib 的哈希、LLVM 20.1.8 与 LLD 20.1.8 provenance | `go test ./internal/tsfrontend -run '^TestCanonicalBuildInfoJSONIsStableAndComplete$' -count=1`; `go test ./cmd/ts2bin -run '^TestVersionJSONContainsLockedProvenance$' -count=1`; `go run ./cmd/ts2bin version --json` |
| `FND-002` | complete | 规范化 `bingoOptions`，提供 static/interop/unsafe profile、稳定 canonical digest、严格 TypeScript 默认值，并拒绝 dynamic、非法值和未知 JSON 字段 | `go test ./internal/tsfrontend -run '^TestNormalizeOptions' -count=1`; `go test ./internal/tsfrontend -run '^TestCheckRejectsUnknownBingoOption$' -count=1` |
| `FND-003` | complete | 建立 TS/BINGO/BINGO-UNSAFE/LLVM 诊断 registry、pointer-free schema、稳定排序与去重 | `go test ./internal/tsfrontend -run '^TestDiagnostic' -count=1`; `go test ./internal/tsfrontend -run '^TestSortAndDeduplicateDiagnosticsUsesStableContract$' -count=1` |
| `FE-001` | complete | 封装 tsconfig、CompilerHost、Program 与诊断采集链；`check` 返回稳定结构化诊断且不暴露 live Program/checker | `go test ./internal/tsfrontend ./cmd/ts2bin -run '^TestCheck' -count=1` |
| `FE-002` | complete | 以 callback scope 独占借用 checker，并在正常返回、错误、panic、取消和并发路径上释放 | `go test -race ./internal/tsfrontend -run '^TestWithCheckerForFile' -count=1` |
| `FE-003` | complete | 定义 pointer-free `ProgramSnapshot`、稳定 ID、canonical hash/JSON、完整性校验与 CLI determinism 双构建检查 | `go test ./internal/tsfrontend -run 'Deterministic' -count=1`; `go test ./cmd/ts2bin -run '^TestSnapshotVerifiesDeterminismAndWritesJSON$' -count=1`; `go test ./internal/tsfrontend -run '^TestAsyncFunctionSnapshotIsDeterministic$' -count=50` |
| `FE-004` | complete | 捕获 node/type/signature/symbol、overload、泛型实例化、constant、flow narrowing 与 semantic digest；fixture runner 对 check/build/snapshot 期望做差分 | `go test ./internal/tsfrontend -run '^TestFrontendConformanceFixtures$' -count=1`; `go test ./internal/tsfrontend -run '^TestSnapshotCapturesGenericCallInstantiation$' -count=1` |
| `FE-005` | complete | 生成并校验 351-row AST Kind manifest schema v2；100 个 fixture 提供 194 条真实 evidence，另有 157 条逐 Kind 精确 exemption；JSDoc/JS/JSX 节点进入稳定 snapshot | `go test ./internal/tsfrontend/kind_manifest_gen ./internal/tsfrontend -run 'Kind' -count=1`; `go test ./internal/tsfrontend -run '^TestRunSubsetGate' -count=1` |
| `FE-006` | complete | 从 Program resolution cache 生成 canonical ModuleGraph，分类 ESM/CJS、type/value/side-effect edge、package exports 条件和 eager value SCC | `go test ./internal/tsfrontend -run 'ModuleGraph' -count=1` |
| `FE-007` | complete | 建立 351 Kind、4,893 API、108 stdlib、100 semantic 的兼容性基线；runner 审计 checkout lock、iota/build-tag API、路径链接与原子更新 | `go test ./internal/tsfrontend ./cmd/ts2bin -run 'Compatibility' -count=1`; `go run ./cmd/ts2bin compatibility --json` |

该轮最终验收在 FE-005/FE-007 冻结时执行，下列矩阵当时全部通过：

```powershell
go test ./...
go test -race ./internal/tsfrontend ./cmd/ts2bin
go test -shuffle=on ./...
go test -count=20 ./internal/tsfrontend ./cmd/ts2bin
go vet ./...
go run ./cmd/ts2bin version --json
go run ./cmd/ts2bin test --stage frontend --json
go run ./cmd/ts2bin doctor --json
go run ./cmd/ts2bin compatibility --json
git diff --check
git status --short
```

关键结果：targeted race 通过；全仓 shuffle 通过；`internal/tsfrontend` 与 `cmd/ts2bin` 连续 20 次通过；frontend stage 报告 `ok: true`；compatibility 报告 `compatible: true` 且 checkout expected/observed commit 闭合；doctor 的 Windows、WSL 和 revision closure 检查全部通过。该结论的准确表述是：Phase 1 原验收项 complete，lowering readiness 未审计。

## 2026-08-05 开发方向与 lowering-readiness 审计（历史检查点；旧 patch 机制已退役）

- 总体架构继续采用 `typescript-go -> immutable snapshot -> Bingo HIR/MIR -> LLVM -> Rust C ABI staticlib + LLD`；不改成 AST 直发 LLVM，也不引入完整 JS engine 作为 static profile 基础。
- 阶段结论调整为 `rework before Phase 2`：Phase 1 通过原门禁，但不能据此启动广泛 `IR-001`/HIR 语法开发。
- 新增 Phase 1.5：`FND-004`、`FE-008..011`、`IR-000`。前置工作覆盖可获取 fork/clean clone、lowering-complete snapshot v2、fail-closed checker capture、完整 snapshot verifier、property/signature/assertion/flow/capture/module proof、snapshot-only replay、路径/semantic-options/target cache 边界和唯一 pass DAG。
- 测试审计确认当前 fixture 主要比较 diagnostic code 集和 snapshot summary，`test --stage frontend` 只跑单一 conformance test；精确 DTO/diagnostic、fresh-instance determinism、独立 manifest、Unicode/path/fuzz 和完整阶段 runner 进入 `FE-010`。
- 新增后续设计门禁：`OBJ-000` structural object view/identity/alias/GC ABI、`GC-001` single-mutator root liveness/optimizer contract、`EH-001` status/native-unwind bridge。
- 把 real LLVM 反馈前移为 `RT-002` + `BE-001/002/004a` + `REL-001` + `VERT-001` + `REL-002a`：先由统一 case runner 在 Linux x86-64 编译并运行无对象/GC/EH/字符串的 `add(number, number)`，再扩展 runtime 和第二目标。
- 审计中已修复 CLI profile override 丢失其余 `bingoOptions`，并为 assertion snapshot 增加单步 target/assignability proof；相关定向测试通过。这些只是局部修复，不能替代 Phase 1.5。
- assertion proof 曾产生 3 个预期 semantic digest 差异；现已完成 schema v2 迁移、人工分类与 baseline 更新，`go test ./internal/tsfrontend -count=1` 通过。这只证明当前 baseline 一致，不代表 Phase 1.5 已闭合。
- 完整结论、证据和调整后的依赖链见 `plans/development-audit-2026-08-05.md` 与 `plans/implementation-backlog.md`。

## 2026-08-05 Phase 1.5 收口与计划重排（历史检查点；旧 patch 机制已退役）

- `FE-008` 实现进展：snapshot schema v2、tagged payload、source blob、named children、通用图/hash validator 和 fail-closed capture 已落地。反向审计仍发现 validator 接受 NumericLiteral 空 Text 与 BinaryExpression 全 generic `child[n]` roles，因此状态回调为 partial，下一步补 Kind shape registry。
- `FE-009` 实现进展：property/parameter/signature/effect、assertion/non-null/flow/capture/module facts 已进入 snapshot semantic hash。仍缺 per-specifier module binding、checker/callee-derived effect proof 与按 Kind/lowerer mandatory-fact validation，因此状态为 partial。
- `FE-010` 实现进展：真实序列化 `add(number, number)` replay、11-Kind readiness registry、多 return/未绑定 Kind/非 number/坏 symbol/type 拒绝已通过。consumer 仍位于 `internal/tsfrontend`，events 仍按 source position，尚无独立新进程/CFG evaluation-order 证明，因此仅为 primitive prototype。
- `FE-011` 实现进展：`FrontendSnapshot` wrapper 与 BuildPlan provenance split、投影后 hash、case-sensitive path/profile tests 已落地。raw ProgramSnapshot 仍随 target/CPU/emit 变化，BuildPlan 接受任意格式正确 digest，且遗漏三个 TS options，因此状态为 partial。
- compatibility 夹具读取器和 semantic digest domain 已迁移到 schema v2；执行 `go run ./cmd/ts2bin compatibility --update-baseline` 后，`go test ./internal/tsfrontend -count=1` 通过。
- `[历史，已退役机制]` `FND-004` 当时已生成 patch，lock 固定 upstream/base/path/SHA-256，doctor 报告 `materialized-exact`；一次隔离 remote apply/test/vet 通过，最新 shallow smoke/long-path cleanup 也 exit 0。但 parent HEAD 的 gitlink 仍是旧 commit，lock/scripts/patch 未进入 parent HEAD，因此 acceptance blocked。
- `IR-000` 审计结论为 metadata skeleton：已有不可变 13-stage pass metadata/sequence contract 与初步 HIR verifier；overlay 仍证明无返回自循环、非法 store/phi/sparse ID 和 MIR duplicate FunctionID 可被接受。
- 后续顺序调整为：FND clean-parent delivery -> FE Kind shape registry -> mandatory semantic facts/per-specifier/effect proof -> source-level target split/typed BuildPlan -> 独立 checker-free CFG replay -> pass executor -> primitive IR chain（含 HIR/MIR verifier closure） -> empty runtime/startup -> real LLVM/object/link -> case runner -> `VERT-001` -> Node differential。对象、GC、EH、async、模块和广泛语法继续延后。

反向 overlay 证据（2026-08-05）：frontend overlay 的 4 个漏洞断言全部 PASS，分别暴露 Kind payload/role、BuildPlan 伪 digest、TS option projection 和 raw target-dependent hash 问题；IR overlay 的 5 个 verifier 漏洞断言全部 PASS，暴露无 return CFG、非法 store/entry phi、sparse ID 与重复 MIR FunctionID。replay overlay 的 exactly-one-return 旧漏洞断言 FAIL（修复有效），raw backend-dependent hash 断言仍 PASS（FE-011 未闭合）。因此常规 `go test` 全绿既不能关闭 Phase 1.5 入口，也不能关闭其后的 primitive vertical slice；两道门按各自依赖验收。

本轮定向验证：

```powershell
go test ./internal/bingo -count=1
go test ./internal/tsfrontend -count=1
go test ./internal/tsfrontend -run 'Replay|LowererReadiness|VerifyHIR|CanonicalHash|Pass' -count=1
go test ./internal/tsfrontend -run 'TestSnapshotTypeScriptOptions|TestFrontendSnapshotKey|TestLogicalPath' -count=1
go run ./cmd/ts2bin compatibility --update-baseline
.\scripts\doctor.ps1 -Quiet
```

## 2026-08-05 二次方向审计与阶段拆分（历史检查点；旧 patch 机制已退役）

- 总体架构再次确认正确：`typescript-go checker -> immutable frontend snapshot -> typed HIR -> target-aware MIR -> LLVM/object -> Rust C ABI runtime + LLD`。不采用 AST 直发 LLVM，也不以完整 JS engine 作为 static profile 基础。
- 状态语义改为 `implemented`、`prototype`、`acceptance-blocked`、`complete`。`FE-008/009/011` 与 `IR-000` 已有实质生产实现，不再列为“缺失”；当前统一标记 `implemented / acceptance-blocked`。
- `FE-008` 已出现 Kind-driven payload/role/arity registry；`FE-009` 已出现 per-specifier module binding、fail-closed effect registry/call closure 和 lowerer required-fact registry；`FE-011` 已出现 source-level target split、三项 TS option projection和 validated FrontendSnapshot/BuildPlan binding；`IR-000` 已出现 executor、fixed-point budget、pre/post verifier、effect proof 与 deterministic dumps。
- `FE-010` 已拆成 `internal/frontendwire`、`internal/ast2bingo` 和 `cmd/ts2bin-replay`。`go list -deps ./cmd/ts2bin-replay` 不再包含 parser、binder、checker、AST 或 tsoptions，说明独立进程依赖方向正确。
- 初次联合测试暴露的 `KindImportType`/`KindTypeLiteral` wire effect 分类已修复；随后 `internal/ast2bingo`、`cmd/ts2bin-replay`、FE effect/shape/BuildPlan 定向测试和 `internal/bingo` 均通过。全量 frontend compatibility baseline、snapshot fixture 与 default-options golden 仍因 DTO/hash 变化漂移，因此 Phase 1.5 尚未 complete，需人工审查有意变化后再更新基线。
- 二次源码对比发现 `tsfrontend` 与 `frontendwire` 复制了完整 serialized validator；虽然 shape/validator 主体当前近似相同，effect helper 已在赋值、解构、for-of/in、property-name 和 type-context 规则上发生差异。后续不再手工同步两份实现，改为 `frontendwire` 单一 validator，`tsfrontend` 最终验证委托给 wire。
- `[历史，已退役机制]` `scripts/doctor.ps1 -Quiet` 二次复核失败：当时 submodule worktree 与 lock 中 patch 不一致，状态为 `divergent`。旧 materialized-exact/remote apply 日志只保留为历史证据；该处理路径现已被 pinned-fork 交付取代。
- 路线图把原阶段 2 拆成 Phase 2A 与 2B。2A 只闭合 `add(number, number)` 的 snapshot/HIR/MIR/real LLVM/object/LLD/process/Node 链；2B 才扩 bool、变量、调用、CFG、string/null/undefined 和单次求值语法。
- `REL-001` 拆出 `REL-001a` first-slice runner core，避免完整 release runner 与尚不存在的 backend/artifact oracle 形成验收依赖环。`VERT-001` 依赖 `REL-001a`，完整 handbook/diagnostic coverage 留给后续 `REL-001`。
- 调整后下一顺序：单一 wire validator -> target/cache 与 no-EH 配置 -> replay/frontend migration full regression -> `IR-000` contract infrastructure 全量验收 -> 最后 clean-parent delivery -> Phase 2A typed-HIR 后续 handlers + number-only HIR/MIR verifier -> empty startup -> real LLVM/object/LLD -> `REL-001a` -> `VERT-001` -> Node differential -> Phase 2B。

## 2026-08-05 审计收口增量（历史检查点；旧 patch 机制已退役）

- `FE-009a` 已同步 assignment/destructuring/for-of 相关 capture/wire helper并增加 round-trip tests；完整 `snapshot_validate.go` 仍在 `tsfrontend`/`frontendwire` 各有一份，因此只能记为 `implemented / acceptance-blocked`，下一步是删除 serialized validator 双写，而不是继续人工同步。
- `FE-010/IR-000` 已进一步闭合：独立 replay process 会真实执行 `validate-snapshot -> typed-hir` canonical production prefix；dependency closure、跨进程重复输出、显式 evaluation-order/single-block HIR、缺 handler和 HIR/event tamper 拒绝均有 checked-in tests。typed HIR 之后的 RepresentationPlan/MIR/backend handlers 仍属于 Phase 2A。
- `[历史，已退役机制]` 当时计划纠正了 FND 顺序：旧 patch 为 `divergent`，且 `FND-004a` 不能先于仍会修改工作树的 FE/IR 任务。该 patch 重生成流程现已由固定 fork commit、upstream merge、remote fork verification 和 clean-parent gate 取代。
- 新增 `FE-011b`：当前代码/default golden/lock 只接受未实现的 `llvm-eh`，与“首切无 EH、首个 throwing profile 为 status/result”的架构不一致。Phase 2A 前先引入 canonical no-EH mode；status-code/native-unwind 后续分别锁定，禁止把未实现 capability 写入 artifact provenance。
- Phase 2A 改用 first-slice 子任务 `IR-001a..005a/007a`、`RT-002a`、`BE-002a`，避免完整 IR/runtime/backend issue 中的变量、调用、general CFG、bool/string/null、phi/memory 和完整 registry 验收反向拉入 `add(number, number)` 纵切。Phase 2B 继续负责这些扩展。

## 2026-08-05 Phase 1.5 退出审计收口（历史检查点；旧 patch 机制已退役）

- `FE-008a/009a` 已关闭：删除 capture 侧完整 serialized validator 与 shape registry 副本；`tsfrontend.ValidateProgramSnapshot` 只委托 `frontendwire`，fixture 增加 capture -> wire encode/decode/re-encode byte parity。
- `FE-011b` 已关闭：默认、options golden、BuildPlan 和 `ts2bin.lock.json` 使用 `exceptions=none`；`llvm-eh` 只保留为未来常量并返回 `unavailable`。
- `FE-011a` 路径身份已闭合：项目内 semantic paths 相对化；Windows/WSL 同根 snapshot bytes、TypeScriptDigest、ContentHash 一致。wire validator 在任何 digest/hash 比对前拒绝 config/options/source/module/diagnostic 中残留的 Windows drive、UNC 和 POSIX rooted disk path，真实跨盘 `rootDirs` Build 回归 fail closed。
- UTF-8 baseline 已人工审查：Kind 351、API 4,893、stdlib 108 项零变化；100 个 semantic digest 中 28 个变化均来自 checker 合成符号名的有效 U+FFFD wire 规范化；snapshot contract golden 仅一处 U+FFFD 表达变化，config golden 不变。新增专门 canonical encode/decode/re-encode 测试。
- 当前验证全绿：核心六包、核心六包 race、`go vet ./...`、frontend 九阶段（package/validator/module/checker/CLI/compatibility/race/shuffle/repeat）、`go test ./... -count=1`。此前 Windows watcher 时序失败本轮未复现，不能作为项目阻塞。
- BuildPlan 语义已纠正：它是绑定 frontend hash 的 canonical unresolved request，不是 executable capability proof。此历史检查点中的 `CapabilitySet` 已由当前契约拆分为 resolver 的 `AvailableCapabilityCatalog` 与 structural MIR 后的 `BoundCapabilityClosure`；后续文档以二者为准。
- 后续计划重排：当前依赖为 `IR-007a -> IR-001a -> IR-002a -> IR-003a` 与 `BE-001a`、`RT-002a` 并行；三路汇合到 `TC-001a` 后再做 `IR-004a/005a`、`RT-002b`、`BE-002a/004a`、`REL-001a`、`VERT-001`、`REL-002a`。
- `[历史，已退役机制]` 最终 patch SHA-256 `759e0661a91c7b757a78106425618046dc0b8e348f2c1e31263f486c074a9c9f` 当时已生成；doctor materialized-exact、官方 remote shallow clean checkout apply/full test/vet/cleanup、WSL Go-LLVM verifier和 Rust staticlib/LLD smoke 全部通过。该证据不适用于现行 pinned-fork checkout。

## 2026-08-06 契约二次审计（历史检查点；旧 patch 机制已退役）

本节曾取代上一个“Phase 1.5 退出审计收口”；当前状态以后续“Phase 2A 入口复审”为准，更早段落仅保留历史证据。

- 总体架构不变：`FrontendSnapshot -> target-independent typed HIR`；`BuildPlan + manifests -> ResolveTargetContext`；两者在 `RepresentationPlan` 汇合后进入 `target-aware MIR -> LLVM/object -> Rust C ABI runtime + LLD`。
- canonical pass DAG 已新增不可绕过的 `ResolveTargetContext`，并显式区分 `AvailableCapabilityCatalog` 与 structural MIR 后的 `BoundCapabilityClosure`。
- typed HIR 已把 FrontendSnapshot schema/hash、source hash、tsgo commit、stdlib hash 与 Kind manifest hash 纳入 canonical provenance；replay/post-verifier 交叉校验来源 snapshot hash。
- BigInt/RegExp 的 snapshot-time 诊断已改为 target-independent `subset.lowerer_unavailable`；runtime capability availability 留到 TargetContext 后判断。
- Phase 2A 依赖改为并行的 `IR-007a -> IR-001a -> IR-002a -> IR-003a`、`BE-001a`、`RT-002a`，然后 `BE-001a + RT-002a + BuildPlan -> TC-001a -> IR-004a/005a`。LLVM TargetMachine 查询值是 DataLayout 权威源；link 只复验同一个 immutable TargetContext，不重新解析。
- `[历史，已退役机制]` 二次审计后的 patch SHA-256 曾为 `cc4c9ab435810a23d31a1c1c72b040ae9241fbbadf1c041c6815df7266339e95`；`b2dca40` 的 doctor、clean-clone frontend 九阶段、全仓 test/vet 与 isolated apply 验证当时通过。该交付机制已被 pinned fork commit 取代。
- Phase 2A 首切入口当时新增四项关闭条件：validated snapshot 才能作为 subset/lowering 输入；`IR-001a` 冻结 HIR schema major 2 并纳入 compiler build identity；`IR-002a` 传递 canonical logical capability requirements（纯 add 的 bound closure 可为空）；typed multi-artifact envelope 不能用 `PassState.Facts []string` 冒充 proof。随后复审把职责进一步纠正为 `TC-001a` 只解析 BuildPlan/manifests，HIR provenance join 留给 RepresentationPlan。

## 2026-08-06 Phase 2A 入口复审（当前状态）

- `typescript-go` 现行交付已迁移到 `https://github.com/pqcqaq/typescript-go.git` 的 pinned fork commit；lock 同时固定 reviewed upstream ancestor，upstream 更新只允许显式 merge。旧 patch/materialize/apply 机制不再活跃。本地 doctor、隔离 fork smoke/full test/vet、frontend 九阶段、locked replay 双构建、远端 fork verification 和 committed parent HEAD clean-clone 已通过。
- 总体方向继续采用两条语义支路：validated FrontendSnapshot -> target-independent HIR；BuildPlan + toolchain/runtime manifests -> TargetContext。执行器可以在 HIR 后调度 resolver并用 envelope 保留 HIR，但 resolver 不语义读取 HIR；首次 provenance join 固定在 RepresentationPlan。
- `FE-012a` 已关闭：`Frontend.Build` 返回 canonical 深拷贝 sealed snapshot，外部 diagnostics 与 snapshot 脱离；`RunSubsetGate` 自行完整验证，production replay 在 in-memory、serialized、frontend-wrapper 三条路径拒绝重哈希 using/async/decorator/any/unknown 篡改。
- `IR-007a` 已关闭：number contract v1 固定 binary64、canonical qNaN、保留 `-0`、round-to-nearest ties-to-even/no-fast-math 加法，以及固定 C ABI/bit observation；替代表示、policy、operator 或 ABI 均 fail closed。
- `IR-001a/002a/003a` 已关闭：HIR schema/lock 升为 major 2；CompilerBuildIdentity 覆盖 upstream commit、fork commit 与 lowering schema/hash；source-type-plan 保持 identity-free，不同 driver identity 生成不同 HIR provenance/hash；logical requirements、number-only lowering 和 malformed verifier matrix 已通过。
- `PassArtifactEnvelope` 只标为基础设施 complete：它提供 role/schema/payload-bound digest 与不可变 transition。`TC-001a` 仍 pending，必须等待真实 `BE-001a` LLVM TargetMachine/DataLayout 与 `RT-002a` runtime/toolchain manifests，不能用 fixture payload、MIR v1兼容 verifier 或 fact labels 冒充完成。
- 旧 patch checkout 下的核心回归只保留为历史证据；fork 迁移后的核心六包（普通与 race）、串行 `go vet -p 1 ./...`、`go test -p 1 ./... -count=1`、doctor、frontend 九阶段、locked replay 双构建、本地隔离和远端 fork verification 已通过。current committed HEAD clean-clone 是最后一项交付门禁。
- 调整后的下一顺序：`BE-001a || RT-002a -> TC-001a -> IR-004a/005a -> RT-002b + BE-002a/004a -> REL-001a -> VERT-001 -> REL-002a`。Phase 2B、对象、GC、EH、async 和第二目标继续 blocked。

## 2026-08-10 Phase 2A IR 关闭（当前状态）

- `BuildPlan` wire 已下沉到 checker-free `internal/buildplan`；`targetcontext` 与 `bingomir` 的依赖闭包不再包含 AST、parser、binder、checker、tsoptions 或 tsfrontend。
- `IR-004a` 已关闭：RepresentationPlan pre/post verifier 同时解码并交叉校验 typed HIR、BuildPlan、TargetContext、DataLayout、AvailableCapabilityCatalog、toolchain/runtime manifests，拒绝有效重哈希后的 HIR/BuildPlan substitution。
- `IR-005a` 已关闭：独立 first-slice target-aware MIR 使用 `RepF64`/`fadd`，固化全部上游 provenance；structural/final verifier 验证 dense IDs、representation、return/effect 和内容 hash；capability binding 从 structural MIR 生成显式空 `BoundCapabilityClosure`。
- canonical production pipeline 已真实执行全部 14 个 pass，两次相同输入的 final MIR 与逐 pass dump byte identity 稳定；现有 general MIR v1 verifier 保持独立，未被冒充为 first-slice target-aware verifier。
- 验证通过：Windows `go test -p=1 ./... -count=1`、`go vet ./...`、checker-free dependency audit；WSL/LLVM 20 `go test -tags=llvm20 ./internal/bingomir ./internal/targetcontext ./internal/llvmbackend -count=1`。
- 下一顺序固定为 `IR-008a -> RT-002b + BE-002a -> BE-004a -> REL-001a -> VERT-001 -> REL-002a`。`VERT-001` 是第一个 Linux x86-64 可执行文件；计划内的 self-hosted stdlib 仍需 Phase 2B 的变量、调用、控制流、模块和最小 stdlib contract。编译器主体是 Go，“编译器编译自身”不在当前路线中，不能与 stdlib self-hosting 混称。

## 2026-08-10 IR-008a 完成

- `internal/irartifact` 新增 checker-free first-slice case manifest loader、严格 HIR/MIR decode、canonical JSON/text rendering 和 schema/provenance-first structural diff；`emit-hir --verify` 与 `emit-mir --verify` 接入 `ts2bin`。
- `testdata/ts2bin/lowering` 固定 `add(number, number)` 的 serialized frontend snapshot、BuildPlan 与 runtime manifest。HIR replay 只读取 snapshot；MIR 才读取已验证 BuildPlan/runtime manifest 和真实 LLVM TargetMachine。
- Windows/no-LLVM 默认构建对 `emit-mir` 明确 fail closed；WSL LLVM 20 下 `emit-mir --verify` 与 bound MIR equal diff 通过。IR-008a 完成后下一顺序为 `RT-002b + BE-002a -> BE-004a -> REL-001a -> VERT-001 -> REL-002a`。

## 2026-08-10 RT-002b 与 BE-002a 完成

- runtime ABI schema 新增程序导出 `extern "C" double add(double,double)`；生成 C header、严格 16 位 IEEE-754 hex harness 与 `bingo_add_harness.o`，并把 harness 文件、大小和 SHA-256 纳入 strict runtime manifest。
- final verified bound MIR 真实降为 LLVM `double @add(double,double)`、`fadd` 与 `nounwind`，明确禁用 fast-math；LLVM VerifyModule、ELF object emission、artifact tamper rejection 和重复 emission identity 均通过。
- runtime source/ABI/target/manifest hashes 已同步 resolver fixture 与父仓库 lock；Windows 全仓 `go test -p=1 ./... -count=1`、`go vet ./...`、WSL LLVM 20 定向测试、Rust `cargo test --lib` 和重复 release build 通过。默认 Rust doctest 因当前 WSL 找不到 `rustdoc` 未执行，保留为环境项。
- 下一顺序为 `BE-004a -> REL-001a -> VERT-001 -> REL-002a`；`VERT-001` 仍是第一个完整 snapshot-to-process Linux 可执行文件门槛。

## 2026-08-10 BE-004a 完成

- 新增独立 `internal/firstslicelink` 边界，只消费 final verified LLVM emission 与 strict runtime manifest；复验 archive/startup/harness 的 basename、大小和 SHA-256 后才允许链接。
- linker response file 只含稳定 basename，固定 Linux x86-64、LLD、non-PIE、无 build-id、no-undefined、fatal-warnings 与 link map；临时工作目录不进入 artifact identity。
- harness 启动时调用 `bingo_rt_abi_version_v1()`，保证 umbrella archive 不会被 LLD 当作未使用输入丢弃；link map 必须证明唯一 archive token 与 runtime ABI symbol。
- WSL LLVM 20 下两次相同输入的 response/map/executable/content hash 完全一致，真实 executable 对 `1 + 2` 输出 `4008000000000000`；Windows contract tests、targeted test/vet 与 LLVM 五包回归通过。
- 下一顺序为 `REL-001a -> VERT-001 -> REL-002a`。

## 2026-08-10 REL-001a 与 VERT-001 完成

- first-slice case manifest 新增严格 `timeoutMs` 与 canonical binary64 execution vectors；空执行、重复名称、非 16 位或大写 hex 均 fail closed。
- 新增 `internal/firstslicerunner`：在单 case timeout 内执行 snapshot-only HIR、target-aware MIR、real LLVM/object、strict runtime/LLD link 和 process run，并按名称稳定排序 executions。
- canonical static-core report 绑定 CompilerBuildIdentity、snapshot/HIR/BuildPlan/runtime/MIR/LLVM/object/emission/response/map/executable/link/output 全部 digest；篡改输出或顺序会被独立 verifier 拒绝。
- `ts2bin test --stage static-core` 固定运行 checked-in case，不提供 runner/path override；WSL LLVM 20 下 `-0 + -0` 与 `1 + 2` 真实 executable 输出通过，Windows/no-LLVM 保持 fail closed。
- 下一项仅为 `REL-002a` Node oracle differential；通过后 Phase 2A 才退出并进入 Phase 2B。

## 2026-08-10 REL-002a 与 Phase 2A 完成

- 新增锁定 Node 22.22.0 的 first-slice oracle；binary64 bits 通过 DataView 显式转换，oracle script/version/output hashes 进入 canonical report schema 2。
- checked-in case 增加 canonical qNaN，与原有普通值、`-0` 一起执行 expected/native executable/Node 三方比较；冷启动总 case timeout 调整为 10 秒，仍受 60 秒 manifest 上限约束。
- 使用 fork commit `a77f97525c6a262e8c4dbb8c86fffd989d566c08` 构建真实 LLVM 20 CLI 后，`ts2bin test --stage static-core --json` 返回 `ok=true`，三个 execution 全部一致；真实 ELF executable SHA-256 为 `7fad9cb1bd23a3b8f9d797989c38ee96e0549a18bfa33c1e3257de633880a926`。
- Phase 2A 退出，Phase 2B 进入 ready。这里证明的是受限 `add(number, number)` 可执行纵切，不是通用 TypeScript 程序编译能力；self-hosted stdlib 仍依赖 Phase 2B 的变量/调用/控制流，以及 Phase 4 的模块、泛型、集合与 stdlib package contract。

## 2026-08-11 Phase 2B IR-007b 完成

- 新增 canonical boolean contract：source boolean 在 target MIR 使用 `i1`，C ABI 使用 `uint8_t` 且只接受 0/1，condition 直接按 i1 分支，禁止与 number 隐式互转。
- `PrimitiveRepresentationBinding` 成为 boolean/number 到 `i1`/`f64` 的唯一映射入口；现有 number-only RepresentationPlan 仍生成原有单一 binding，Phase 2A artifact bytes 未被扩张。
- alternative contract、非 canonical ABI byte 和 unsupported primitive representation 的 negative tests 已通过；HIR/MIR/backend/CLI 相关包 test/vet 回归全绿。
- 下一纵切固定为 `choose(flag: boolean, left: number, right: number): number`，依次关闭 snapshot/HIR/CFG verifier、target-aware MIR/LLVM 与 uint8 ABI/Node differential。

## 2026-08-11 Phase 2B IR-001b/002b/003b 完成

- fork commit `16feebd2cc266ecbdcbdb8420e2023d3caae1e5d` 新增独立 `VerifyPhase2HIR`/canonical entry，旧 Phase 2A number-add verifier 未放宽。
- validated serialized `choose(flag: boolean, left: number, right: number): number` snapshot 生成 boolean/number 参数、显式空 operation slices、三块 dense CFG、direct condbranch 和两条 number return；evaluation-order events 与 source origin/provenance 逐项复验。
- verifier 覆盖 dense ValueID/BlockID、successor、reachability、dominance、condition/return type，并拒绝重算 hash 后的 parameter/condition/successor/return/event 篡改；source `if` child-role/type 篡改在产生 HIR 前 fail closed。
- 修复 test-only snapshot clone 的嵌套 slice 浅拷贝，消除子测试共享 DTO 的顺序污染；定向、shuffle、race、相关 HIR/MIR/CLI 包 test/vet 与 `git diff --check` 通过。
- 下一项固定为 `IR-004b/005b + BE-002b`：RepresentationPlan 同时绑定 boolean/i1 与 number/f64，生成并验证三块 target-aware MIR 和真实 LLVM conditional branch。

## 2026-08-11 Phase 2B IR-004b/005b + BE-002b 完成

- fork commit `376f0b23e0b98f4a34d4c6ee48dbf8dee82f3386` 将 canonical HIR 的实际 primitive 类型绑定为 `[boolean/i1, number/f64]` RepresentationPlan；number-only plan 仍保持原 artifact bytes，未使用的额外 binding 会被 lowering 拒绝。
- `FirstSliceMIRArtifact` 在保持 add JSON 兼容的前提下增加可选 successors；choose 生成 dense 三块 MIR，参数为 `i1/f64/f64`，entry 为直接 `condbranch`，两条 return 均为 f64；rehashed CFG/representation tamper 全部 fail closed。
- WSL LLVM 20 真实 pipeline 两次执行的 MIR/LLVM/object identity 稳定；public `choose` ABI 为 `double choose(uint8_t flag, double left, double right)`，入口 `icmp ult flag, 2`，非法 byte 调用 `llvm.trap`，合法 byte `trunc` 为 i1 后分支；VerifyModule 与 ELF object 通过。
- 下一项为 `RT-002c + REL-001b/002b + VERT-002`：runtime C header/harness、true/false 进程执行、非 canonical byte 拒绝及 Node differential/report provenance。

## 2026-08-11 Phase 2B RT-002c + REL-001b/002b + VERT-002 完成

- fork commit `eb98a14d4b215a821a235fdb497471db0459d366` 扩展 ABI v1 生成器的 `u8 -> uint8_t`，保留 add harness 并新增独立 `bingo_choose_harness.o`；runtime manifest 同时认证两个 harness，重复构建 manifest byte identity 一致。
- `choose-boolean-number` 独立 case 显式绑定 entry point 和 boolean flag；linker 从已验证 LLVM entry point 选择 manifest-authenticated harness，true/false 两支与锁定 Node 22.22.0 oracle 一致。
- strict ABI negative 会以 `0x02` 调用真实 ELF；LLVM 入口 trap 使进程失败且无输出，arguments/output hash 和全部 snapshot/HIR/MIR/LLVM/object/link/executable hashes 进入 canonical report。
- Windows 串行全仓 `go test -p=1 ./... -count=1`、全仓 `go vet -p=1 ./...`、WSL LLVM 20 choose pipeline/runner、Rust workspace lib tests 和双 runtime build manifest identity 通过；WSL 缺少 `rustfmt`/`rustdoc`，format/doctest 未执行，保持为环境项。下一纵切为 local binding/assignment + direct call。

## 2026-08-11 Phase 2B IR-001c/002c/003c + BE-002c + REL-002c + VERT-003 完成

- HIR schema/primitive lowering 升为 v3；source-type plan 支持按源码位置排序的 1-2 个函数和唯一 exported entry。`calllocal` snapshot proof 接入 direct call 的 selected signature/effect proof；同模块 direct-call capture 允许只读函数 binding，其余 capture 仍 fail closed。
- HIR verifier 支持多函数 dense `FunctionID`、唯一 exported function、call 的 callee/参数/返回类型/effect 校验；local binding/assignment 以 SSA value alias 更新，不引入未证明内存 place。MIR 同步保留 `Callee`/visibility，helper 必须是较早函数且禁止递归。
- LLVM 20 生成 internal-linkage `add` helper 和 exported `compute`；runtime 新增并认证 `bingo_compute_harness.o`。runner/Node oracle 对 NaN、负零和普通值三组输入执行真实 ELF，全部与 Node 22.22.0 一致；runtime manifest/content hash 已同步到 lock 和 fixtures。
- 定向 Go packages 与 WSL LLVM 20 `ts2bin test --stage static-core --case testdata/ts2bin/calllocal --json` 通过。下一纵切为 loop/general CFG + SSA/phi。

## 2026-08-11 Phase 2B loop/general CFG + SSA/phi 完成

- fork commit `74546c56984e4afea7801d35d7fff38ed4f19497` 将 HIR 升为 v4、Phase 2B target-aware MIR 升为 v2，并为 phi 显式保存 incoming block identity；verifier 按每条入边验证 value 定义支配关系，正确接受 loop back edge。
- `testdata/ts2bin/loop` 从真实 validated snapshot 生成 `while (value < limit)` 的 header/body/exit CFG、loop-carried phi、`fcmp olt` 与 back edge；source/HIR/MIR tamper 和 malformed CFG/phi 在 backend 前拒绝。
- Windows 定向 Go 包、WSL LLVM 20 backend/MIR/runner tests 通过；真实 deterministic ELF 对多次 back edge、overshoot、`-0` 和 NaN-condition-false 四组 binary64 输入与 Node 22.22.0 一致。
- Phase 2B 仍为 in progress。下一纵切为 string/nullish representation 与 ABI，随后实现 optional/nullish/logical assignment 的单次求值消糖。编译器本体仍由 Go 实现，不属于现行 self-hosted stdlib 或 compiler-bootstrap 里程碑。

## 2026-08-11 Phase 2B nullable-number coalesce 完成

- fork commit `db79bea025937896843049558fd3eb99e9dfd68c` 新增受限 `coalesce(value: number | null | undefined, fallback: number): number` 纵切；HIR 升为 v5，target-aware MIR 升为 v3。
- ABI 固定为 16-byte `{i8 tag, [7 x i8] padding, f64 payload}`：tag `0/1/2` 分别表示 number/null/undefined；nullish payload 必须为零，未知 tag 在 LLVM ABI 入口 trap。HIR/MIR verifier 和 case manifest 都拒绝未证明 unwrap、非 canonical tag/payload。
- runtime manifest、C harness、LLVM 20、LLD、Linux ELF、Node 22 对拍均已通过；执行覆盖普通 number、`-0`、NaN、null、undefined 以及非法 tag `03`。
- Phase 2B 仍为 in progress。下一项是 optional/nullish/logical assignment 的单次求值消糖；string ownership/GC 和模块、完整 stdlib 仍在后续阶段。编译器主体是 Go，不把受限程序可执行误称为 compiler self-bootstrap。

## 2026-08-11 Phase 2B numeric literal/classify VERT-007 完成

- fork commit `89ca9be2cabfdbbc32c70c46e7cdc68c418fe34e` 将 HIR 升为 v6、Phase 2B target-aware MIR 升为 v4；`number.constant` 以 lowercase 16-digit binary64 bits 保存，prefix unary `-` 明确降为 `fneg`，无关操作携带 number bits 会被拒绝。
- `classify(value: number): number` 从真实 validated snapshot 生成两个有序 `<`、五块 CFG 和三条 return；source/HIR/MIR 复核覆盖 literal constant/type、负号 operator、condition binding、successor 和 return value tamper。
- runtime ABI 增加 `double classify(double)` 与一参数 bit harness，所有 runtime manifests 认证新对象；WSL LLVM 20/LLD 真实 ELF 对负数、`-0`、小数、`1` 与 canonical qNaN 均和 Node 22.22.0 一致。
- Windows 定向 replay/HIR/MIR/link/runner/target tests 与 WSL LLVM 20 backend/MIR/link/runner tests 通过。Phase 2B 仍为 in progress；下一纵切为 UTF-16 string representation/runtime，完整 property optional chain 继续依赖 Phase 3 object/place contract。

## 2026-08-11 Phase 2B UTF-16 string length VERT-008 完成

- fork commits `bd755bedf56622708ac61f9d1b082dc77c955009` 与 `2468bb1dcc771d05307738d3f144c2c833c862f4` 新增 borrowed immutable UTF-16 `{const uint16_t *data, uint64_t length}` ABI、`string.length`/`utf16.length` lowering、独立 harness、Node code-unit oracle 与 `stringlength` case；ASCII、空串、孤立 surrogate、混合 surrogate 和 surrogate pair 全部经过真实 ELF 验证，非法 `{NULL, 1}` trap。
- 审计发现通用 HIR preserving pass 与 LLVM admission 白名单未覆盖新纵切，已修正并把 `stringlength` 纳入 WSL LLVM runner 表。另按 reader-major 规则将 HIR/MIR 升为 v7/v5，更新 lowering identity、pass envelope/golden、lock 和旧 v6/v4 rejection；旧 Phase 2A add verifier 未放宽。
- Windows 定向 Go tests、WSL LLVM 20 backend/link/runner tests、ABI generator check 和 `git diff --check` 通过。WSL 基础环境仍会对不存在的 `/lib/libhook.so` 输出动态加载器警告；测试通过前显式清除 `LD_PRELOAD`，该噪声不属于编译器产物。
- 路线图新增 APP-001/CLI-001：Phase 2B 退出前实现明确受限的 application entrypoint/build preview。self-hosted stdlib 拆为 Phase 4 的无分配 seed `RT-007a` 与 Phase 5 依赖 GC/EH 的可发布闭包 `RT-007b`；Go 编译器本体仍不在 compiler self-bootstrap 范围。

## 2026-08-11 Phase 2B application build VERT-009 本地实现完成

- fork commit `9a53ae50f6da67c9b3948b239d8292967e42422b` 与父仓库提交 `8e6aff8` 新增受限 `ts2bin build`：唯一 exported parameterless `main(): number` 只能返回 `0..255` canonical integer literal，真实 source project 经 HIR v8/MIR v6、LLVM/object/LLD 生成 deterministic Linux x86-64 ELF 与相邻 provenance report。
- application startup 独占 C `main`，编译产物导出 `bingo_program_main_v1`；边界值、错误入口/返回、重哈希 HIR/MIR、旧 major、manifest/startup substitution、重复 ELF/report identity 和静默精确退出码均有本地证据。
- 该变更属于 D3/A3；独立 A3 review 尚未完成，因此准确状态是 local verified / self-audited / review-blocked，而不是 Integrated 或 release ready。自动 CI 由项目负责人明确延期。

## 2026-08-11 Phase 2.5 工程加固与 Phase 3 重排

- `ENG-001` 修复 application 输出事务：report 使用同目录 staging file 发布，report 编码或发布失败会回滚已生成 ELF；失败注入测试证明两个最终路径均不存在。
- `ENG-002` 把 primitive snapshot lowerer、MIR function-set verifier 与 Linux LLVM emitter 改为显式 registry；现有 schema、artifact bytes 和各纵切语义不变，新增语法不再继续扩张中心 dispatch switch。nullable unwrap guard 改为验证 CFG/type proof，不再依赖 fixture 函数名。
- `REL-003a` 新增 size-bounded `FrontendSnapshot`、`ProgramSnapshot`、Phase 2 HIR 与 structural MIR strict decoder fuzz seed，并验证任何被接受输入都能 canonical round trip。
- Phase 3 入口调整为 `OBJ-000a -> OBJ-000b/BE-004b -> GC-001a/BE-003b -> RT-006a -> VERT-010/011/012`；对象 owned allocation 前必须先关闭双 DataLayout、root/O2 和最小 tracing heap。同步/异常/异步 cleanup 分别拆为 RT-004a/005a、RT-004b/005b、RT-005c，避免跨阶段验收依赖环。

## 2026-08-11 Phase 3 准入收口

- `ENG-001` 进一步统一 ELF/report 的 filesystem boundary：共享 publisher 使用同目录 staging + hard-link 原子发布，预检后出现的并发 owner 不会被覆盖；成功、冲突、staging cleanup、report encode/publish rollback 均有固定测试。
- `ENG-002` 增加 primitive lowerer unique-match 拒绝，删除 LLVM 入口与 emitter registry 重复的函数名 whitelist，并把新 `primitive_lowerers.go` 纳入 `PrimitiveLoweringHash`，防止 registry 变化绕过 compiler identity/cache invalidation。
- `REL-003a` 为 Phase 2 HIR decoder 增加 unknown field、旧 schema、content-hash tamper 固定负例；FrontendSnapshot/ProgramSnapshot fuzz 上限收紧为 256 KiB，默认 16 worker smoke 分别完成 21k+ 次执行，不再出现资源放大超时。
- Windows project-owned tests/vet/race、四个 fuzz、WSL LLVM-tag tests、Go-LLVM/Rust smoke、runtime 两次 deterministic rebuild，以及真实 application 两次同路径构建/ELF 执行均通过。最终 ELF SHA-256 为 `2720cdba49f21cc2b57384601e55e8dddd84b9633c1dab383ae3327236e45076`，report 为 `1ca5f20a49b4b3e839c4c3b95791fd54ac6d335bb9e1f91806787f0142a2e7b8`。
- Phase 2B/2.5 对 Phase 3 implementation entry 已完成；独立 A3 继续只阻塞 application preview 的 Integrated/release-profile consumption，自动 CI 按项目负责人决定保持延期。

## 2026-08-11 Phase 3 `OBJ-000a` 对象语义契约

- `OBJ-000a` 已达到 `SelfAudited`：新增 schema v1 canonical object semantic contract、strict decoder/content hash、reference identity/equality、readonly/mutable view、显式 copy/dynamic boundary planner，以及 `Local < Caller < Heap < Dynamic` escape lattice；未引入布局、分配、GC、runtime ABI 或 LLVM lowering。
- 转换门禁拒绝缺失/不可靠 read proof、可写协变、optional write mismatch、private identity mismatch 和 data/accessor kind substitution；可写 alias 只能形成 `RequiresLayoutProof` 候选，等待 `OBJ-000b`，不会隐式 copy。
- 固定正负例、race、20 次 shuffle、3 秒有界 decoder fuzz（约 10 万次执行）、全仓 Go test/vet 均通过。前端自动适配留到后续集成：现有 `HasGetter/HasSetter` 同时描述普通数据字段的可读写性，必须结合 symbol declaration node kind 才能可靠区分 accessor。
- 自动 CI 继续保持项目负责人指定的关闭状态，因此只记录 `SelfAudited`，不声称 `Integrated`。下一开发项为 `OBJ-000b + BE-004b` 双 DataLayout 对象布局契约。

## 2026-08-11 Phase 3 `OBJ-000b + BE-004b` 双 DataLayout 对象 ABI

- `OBJ-000b + BE-004b` 已达到 `SelfAudited`：schema v1 固定 24-byte object header、48-byte shape descriptor、40-byte property descriptor、40-byte trace descriptor，以及 declaration-order closed-shape field/presence/trace layout；未开放 allocation、collector、root、barrier 或用户对象 lowering。
- Linux x86-64 与 compile-only Linux AArch64 由 Clang/LLVM 20.1.8 独立观测完整 DataLayout；即使 v1 固定结构 offset 相同，target/layout hash 仍相互独立。mutable alias proof 比较 physical layout hash，不以 size equality 或 semantic type key 冒充布局等价。
- 单一 `object-layout-v1.json` 生成 Go schema hash、Rust `repr(C)` 与 C header。Rust size/align/offset、C 双目标 `_Static_assert`、WSL LLVM `TargetData` 双目标测试、strict decoder/fuzz 和所有 hash/offset/presence/trace 篡改负例通过。
- runtime archive/object hash 因无可执行能力变化而保持不变；source hash 更新为 `bf3c1df858368617bba6b5d9a3b3f4d3fe383ba9a62bb7cb2886d52cc54ee111`，manifest hash 更新为 `d36e254dfd97525a43b7c652bdf042d5990992ac8fc654bc611e2a1be9f23010`，lock、compiler constants 和全部 fixture 已同步。
- 自动 CI 仍按项目负责人决定保持关闭，因此不声称 `Integrated`。当时的下一开发项为 `GC-001a + BE-003b` root liveness/safepoint/dead-slot/write-barrier/O2 preservation contract；该项的完成证据见下节。

## 2026-08-11 Phase 3 `GC-001a + BE-003b` root/barrier 安全契约

- `GC-001a + BE-003b` 已达到 `SelfAudited`：schema v1 canonical safety plan 固定单 mutator、STW、precise、non-moving profile，显式 shadow stack frame/root publication、safepoint reload、published-owner write barrier 与 frozen effect event contract；未实现 allocation、mark/sweep、heap traversal 或 runtime capability publication。
- verifier 独立重算 CFG/phi/loop fixed-point liveness，并 fail closed 拒绝不可达块、未知事件、重复 instruction/value、phi predecessor 错序、伪造 live set、孤立 root event、不精确/重复 active value、缺失 reload、frame cleanup 和 barrier 错误。
- Windows focused/full tests、vet、race、5 次 shuffle 与 3 秒 decoder fuzz（约 7.5 万次执行）通过；WSL LLVM 20 在 Linux x86-64 与 compile-only Linux AArch64 上均验证 O0 及 `default<O2>` 后 link/store-clear/publish/safepoint/reload/barrier/unlink 顺序保持。
- 自动 CI 继续保持项目负责人指定的关闭状态，因此只记录 `SelfAudited`，不声称 `Integrated`。当时的下一开发项为 `RT-006a` 最小非移动 tracing heap；完成证据见下节。

## 2026-08-11 Phase 3 `RT-006a` minimal tracing heap

- `RT-006a` 已达到 `SelfAudited`：新增独立 `bingo-memory` rlib 和唯一 umbrella runtime 的 generated ABI，完成 zeroed non-moving allocation、descriptor/trace validation、exact shadow-stack root traversal、single-mutator ownership、forced safepoint mark/sweep、cycle 回收和 no-op semantic barrier。
- C ABI 增加 13 个版本化 `rt.gc.*` capability；跨语言布局断言覆盖 `BingoGcFrameV1`/`BingoGcStatsV1`，runtime manifest、fixtures、Go resolver、lock 和 compiler identity 已同步。
- Rust locked fmt/test/clippy、4,096-object/8-cycle stress、C release ABI smoke（含跨线程拒绝、multi-frame、malformed frame/descriptor、inactive slot 和 LIFO cleanup）、x86-64 link/run、AArch64 compile-only layout、generator check 和双 target archive/manifest byte identity 均通过。Miri 未安装，未声称 Miri 证据。
- 自动 CI 继续保持项目负责人指定的关闭状态，因此只记录 `SelfAudited`，不声称 `Integrated`。下一开发项为 `VERT-010` 首个 owned object/property vertical slice。

## 2026-08-11 Phase 3 `VERT-010` owned object/property 纵切启动

- `OBJ-001a + OBJ-006a + BE-003a + VERT-010` 已达到 `DesignAccepted`：冻结 HIR v9/MIR v7、`object-ref`/`gc-ref`、closed shape/property symbol binding、精确 GC capability closure、shadow-stack root sequence、target layout join、LLVM/runtime ABI 和 tamper/determinism matrix；设计见 `plans/phase3-vert-010-design-2026-08-11.md`。
- 首批 HIR substrate 已实现：新增 target-independent object/property binding、五类 object operation shape verifier、精确 capability 集，以及 semantic hash/property symbol/capability/physical-offset-leakage 负例。新增字段保持 `omitempty`，在完整 reader/verifier 同步前不改变既有 primitive artifact bytes，也不提前提升 schema major。
- `go test ./internal/bingo -count=1`、`go vet ./internal/bingo` 与 `git diff --check` 通过。下一步接入 object literal/shorthand/property snapshot lowerer，并完成完整 HIR dominance、initialization、alias identity 和 operation-order verification。
- snapshot readiness registry 已显式加入 object literal 与 shorthand property；binary/property/variable handlers 精确覆盖 static `value` read/write、property-plus-literal 和 object initializer，同时保留旧 application negative 的稳定诊断。真实 `objectalias/frontend-snapshot.json` 驱动 handler 测试通过。
- subset type closure 通过 property declaration kind 区分 object-literal shape 与同为 object record 的函数/模块类型，只放行单个 required mutable public number shorthand data property。完整 VERT-010 HIR verifier 固定 alloc/init/alias/load/add/store/original-load 顺序和精确 capability closure，并拒绝 copied alias、错误 store owner、错误 final receiver、property substitution 与 spurious barrier capability。
- 本轮 `go test ./internal/bingo ./internal/ast2bingo -count=1`、对应 `go vet` 和 `git diff --check` 通过；完整 HIR v9 reader/hash 与 snapshot-to-HIR lowerer 仍在实现中，尚未进入 MIR/backend。
- HIR v9 reader/lowerer 已随后闭合：新增独立 `VERT010ReplayResult` 和 strict `DecodeVERT010ObjectHIR`，从真实 `objectalias` frontend snapshot逐节点证明四语句 source shape、同一 property symbol、const identity alias、canonical number field contract 和 effect proof，构造并重验 semantic contract hash 与 canonical HIR content hash。旧 HIR v8 primitive reader没有放宽。
- 两次真实 snapshot replay byte-identical；把一次 `.value` access 替换为另一个真实存在的 `value` symbol 并重哈希 snapshot 后会以 property identity mismatch 拒绝。`go test ./internal/bingo ./internal/ast2bingo -count=1` 与对应 race（约 63 秒）、vet、`git diff --check` 均通过。
- 当前进入 MIR v7：下一步将 `TypeObject -> RepGcRef` 与 x86-64/AArch64 object layout content hash、field offset、exact capability closure 和 canonical GC safety plan 绑定；production typed-HIR dispatch 暂不切换，直到 MIR consumer能够严格接收 v9。
- 独立 MIR v7 artifact 与 strict reader 已落地：`gc-ref`/`f64` 表示、完整 canonical `ObjectLayoutContract`、target/DataLayout、object extent、property symbol/offset 和 canonical `GCSafetyPlan` 全部进入 content hash。`LowerVERT010MIR` 只接受 canonical HIR v9 与同 type key 的 canonical layout，并自行派生 GC proof，调用方不能注入任意 root events。
- allocation 前先 clear inactive slot 并 publish empty set；allocation 后 store/publish active root，再经 forced safepoint exact reload 后使用，最后 unlink frame。精确 capability closure同步包含 `rt.gc.root.reload` 与 `rt.gc.safepoint`。layout/content hash、target hash、field offset、representation 和 reload proof substitution 负例通过。
- MIR 重复 lowering byte-identical并可 strict decode。`go test ./internal/bingo ./internal/ast2bingo -count=1`、VERT-010 race、对应 vet和 `git diff --check` 通过；下一步绑定 TargetContext 中的具体 runtime symbols/signature hashes，再接 LLVM emitter。
- `VERT-010` 状态推进为 `Implementing`：TargetContext binding 现在严格区分 object-layout 字符串摘要与 toolchain DataLayout artifact identity，并把 canonical MIR 的八个 logical GC capability 一对一绑定到 validated catalog 的 symbol/signature hash；target context、catalog 与 bound MIR content hash 全部进入封闭制品。
- bound MIR 已增加 canonical serialization、strict unknown-member decoder、deterministic round trip 和 capability substitution/content-hash tamper negative。`go test ./...`、`go vet ./...`、VERT-010/TargetContext race tests 与双层 `git diff --check` 通过。
- VERT-010 独立 LLVM20 emitter 已实现：只接受 canonical bound MIR，从 closure 选择八个 runtime symbol，生成 private shape/property/trace descriptors、完整 shadow-stack/root/safepoint/reload 序列、状态码 trap 和 verified field-offset f64 load/store；旧 primitive MIR reader major 保持不变。LLVM O0/O2 verifier、bound-symbol substitution negative 与真实 ELF object emission 通过。
- 新增 `bingo_object_alias_harness.o` runtime artifact 和锁定 Node object-alias oracle。真实 object 与 Rust umbrella archive 经 Clang/LLD 链接执行，并与 Node 22.22.0 对比 `+0`、`-0`、普通值、`+Infinity` 和 payload qNaN；alias 写入后 original 读取结果一致。runtime archive hash保持 `afe3be810f4559a483404b8f80004ef4e825f345ddd874162bba786da6bcff19`，新 source/target-manifest/runtime-manifest hashes 分别为 `c248eafd58116a38c7a70050ec740622b3823b9a5b4ba08c340585a025f62649`、`017808ef6e3c0c5636fa82fd7247ab208d6fa275b6b8e347b9c116b082a7f3e3`、`f127c1fd8fc6e3a46fc298e828596132d19386e1abc3d7da3f310cdb5ba7cd23`。
- 全仓 Go test/vet、相关 race、Rust fmt/test/clippy、完整 LLVM20 backend/link/runner suite、runtime build smoke 和 lock identity checks 通过；doctor 仅因正在开发的 `typescript-go` worktree 非 clean 报告预期失败。生产 pass/CLI 尚未把真实 source fixture 串成单一 canonical source-to-ELF chain，因此状态仍为 `Implementing`，不提升为 `LocalVerified` 或 `SelfAudited`。
- `ts2bin emit-vert010` 已接入 canonical production pipeline：读取 validated frontend snapshot 与 locked runtime manifest，构造 BuildPlan，执行 snapshot/HIR v9/MIR v7/TargetContext binding/LLVM，并 no-clobber 原子发布 `hir-v9.json`、`object-layout-v1.json`、`mir-v7.json`、`bound-mir-v1.json`、`module.ll`、`module.o`、`report.json`。CLI 在 LLVM20 + 注入 compiler identity 的真实命令端到端通过；report 具备 strict decoder、未知字段拒绝和 content hash 校验。
- `object_lowerer.go` 已纳入 compiler lowering identity embed/hash closure，确保 VERT-010 lowering 变化触发 provenance/cache identity 变化。
- unified case runner 已接入 `testdata/ts2bin/objectalias`，完整 source/snapshot/HIR v9/MIR v7/bound MIR/LLVM/object/LLD/ELF/Node 路径通过。CLI artifact publication、strict report decoder、unknown-member/content-hash rejection和重复报告 byte identity均关闭。
- 最终自审发现并修复 HIR semantic contract digest 仅做格式检查的问题：HIR property 现显式携带 canonical `sourceTypeKey`，reader 可重建 `ObjectSemanticContract` 并拒绝重哈希伪造。source negative matrix 同步补齐 computed/accessor/method/spread/optional/additional/copied-alias/unsupported-type，HIR/MIR schema、effect、initialization、layout、trace 与 capability tamper 均 fail closed。
- `OBJ-001a + OBJ-006a + BE-003a + VERT-010` 达到 `SelfAudited`。当前真实身份：HIR `fbfee40355541c3d8b43f08852de521b476abc1fe86d35e1a3616860d868f23f`、bound MIR `59ac3caf1162571bbb6fcb5e1a9772a110ec6c45fa46d666f574845f501b5c6e`、object `7e49631a37824a4825e453aa8e0defad6774f81ba98be4ca1c2e7d638d2169c9`、report `fa527cd274caf8e10f14526ca5f41f4897b14548ebaf5fe3d3563c722deb5f71`；两份完整报告 byte-identical，文件 SHA-256 为 `c584ff68d7a5888d469cf8675bfc5ab6ee2ed8eaecefada611c22e9fa616d9dd`。
- 全量 Go test/vet、focused race、shuffle、三个 VERT decoder fuzz、LLVM20 backend/link/runner/CLI、Rust fmt/test/clippy 与双层 `git diff --check` 通过。Miri 不可用且不声称相关证据；CI 继续按项目负责人要求保持关闭，因此不声称 `Integrated`。下一实现项为 `VERT-011`。

## 2026-08-11 Phase 3 `VERT-011` PlaceRef/property evaluation 纵切启动

- `IR-006b + OBJ-003a/006b + VERT-011` 达到 `DesignAccepted`：冻结 target-independent canonical PlaceRef、receiver/key 单次保存、static computed-key admission、accessor effect、optional CFG 与 property logical-assignment CFG；动态 key/Proxy/prototype/private/symbol/method extraction/optional call/closure/EH 均保持拒绝。设计见 `plans/phase3-vert-011-design-2026-08-11.md`。
- locked tsgo optional-chain/logical-assignment transformer 仅作为行为 oracle；Bingo 不消费 transformer 输出。primitive HIR v8/MIR v6 和 VERT-010 v9/v7 reader 保持严格不变，VERT-011 使用独立 HIR v10/MIR v8 迁移边界。下一步实现 canonical PlaceRef schema、strict verifier/decoder 和 tamper tests。
- `VERT-011` 状态推进为 `Implementing`：PlaceRef schema v1 已 canonical 保存 dense place ID、receiver/computed-key SSA、object/property/source-type identity、direct/computed syntax、static-data/accessor plan、mutability、getter/setter identity、load/store effect 与 origin，不携带 target offset、DataLayout 或 runtime symbol。
- strict decoder 拒绝 unknown member、old/unknown schema、stale hash 与超过 256 KiB 的输入；tamper matrix覆盖 ID/order/key/property/type/readonly/accessor/effect/physical-leakage，并保留跨不同 place 合法复用同一已求值 SSA receiver。focused test 与约 8.5 万次 `FuzzDecodePlaceRefContract` 执行通过；下一步为 HIR v10 source lowering/CFG verifier。
- PlaceRef v1 进一步内嵌 canonical object semantic contracts，并按 object/property key、data/accessor kind、read/write type、optional/readonly 逐项 join；object contract 强制 TypeKey canonical order，避免相同语义产生多种合法字节序列。
- 首个 HIR v10 computed-accessor `??=` CFG 已 canonical 冻结：entry 严格执行 receiver -> key -> place.make -> 单次 getter load -> nullish test；assign edge独占 RHS 与一次 setter store；skip edge只 unwrap 已加载值；phi 精确绑定 blocks 2/3。旧 HIR v8 与 VERT-010 v9 reader 显式拒绝 PlaceRef/module operation metadata。
- receiver/key 顺序、copied key、load/store PlaceID、wrong/reversed nullish branch、skip-edge RHS、double setter、phi predecessor/value 与 forged getter effect negative全部通过；HIR strict decode/content hash/unknown-member和 bounded fuzz 已加入。全量 Go test/vet、VERT-011 focused race 与 submodule `git diff --check` 通过。状态仍为 `Implementing`，下一步是真实 snapshot-to-HIR lowering，不以结构 HIR 证据冒充 source vertical slice。
- 真实 `propertynullishassign/frontend-snapshot.json` 已接入 checker-free VERT-011 replay：从 canonical snapshot property facts 和 declaration identity 重建 `backing` data property、`result` getter/setter、nullable read/number write、saved receiver/key PlaceRef，并生成包含 alloc/init 与四块 `??=` CFG 的 HIR v10。lowerer 已纳入 compiler lowering identity hash closure。
- 两次 replay 与 strict frontend decode byte-identical；重新哈希且通过通用 snapshot 结构校验的 dynamic/copied receiver/key、getter symbol、backing/result type、getter/setter body、RHS 和 accessor declaration substitution 均 fail closed。全量 Go test/vet、focused race 与最新 3 秒 PlaceRef/HIR fuzz（约 13.8 万/5.4 万次执行）通过。VERT-011 仍为 `Implementing`，下一步为 MIR v8，不声称 LLVM/ELF/Node 或 `SelfAudited` 证据。
- VERT-011 MIR v8 已独立闭合：新增 16-byte `nullable-f64` backing layout、storage-free accessor binding、saved receiver/key、四块 CFG/phi、getter/setter symbol 与固定 cdecl ABI、完整 layout contract 和 GC safety plan。strict reader 与约 4,700 次初始 bounded fuzz 通过，旧 MIR v6/v7 reader 明确拒绝；representation/offset/accessor ABI/receiver/key/branch/phi/effect/GC substitution 均 fail closed。
- TargetContext 将 MIR v8 一对一绑定到现有八项 GC capability；production `ExecuteVERT011` 已串起真实 snapshot→HIR v10→layout→MIR v8→bound MIR→LLVM→ELF object。LLVM 20 O0/default<O2> verifier、真实 Rust runtime archive 链接与 Node 差分通过 number、±0、Infinity、payload NaN、null、undefined，Node counters 为 receiver/key/getter 各一次且 setter/RHS 仅 nullish edge 一次。
- 本轮 Windows 全量 `go test ./...` 与 `go vet ./...` 通过，WSL LLVM-tagged bingomir/llvmbackend 测试通过。CI 按负责人要求保持关闭；Miri 仍不可用。VERT-011 尚缺 CLI 原子 artifact publisher、unified case runner 与最终完整自审，因此准确状态仍为 `Implementing`。
- VERT-011 的 CLI 与 unified runner 已闭合：`emit-vert011` 原子无覆盖发布 HIR v10/object-layout/MIR v8/bound-MIR/LLVM/object/report；manifest-owned harness 执行 `propertyNullishAssign(payload, tag)`，Node 差分覆盖 `+0/-0/1/Infinity/payload NaN/null/undefined`，并验证 receiver/key/getter 仅一次、RHS/setter 仅 nullish edge。非法 tag 非零且零输出拒绝，两次 runtime build 的 manifest/harness/archive hash 完全一致。
- `IR-006b + OBJ-003a/006b + VERT-011` 达到 `SelfAudited`。Windows 全量 Go test/vet、focused race、WSL LLVM20 backend/bingomir/runner/CLI、Rust 10 个 lib test/clippy/rustfmt、三个 decoder fuzz（约 221 万次执行）和双层 `git diff --check` 通过。WSL 缺少 rustdoc、Miri 不可用，因此不声称这两项证据；自动 CI 按负责人要求保持关闭，状态不提升为 `Integrated`。下一实现项为 `VERT-012` closures。

## 2026-08-11 Phase 3 `VERT-012` closure 纵切启动

- `OBJ-002a + BE-003a + VERT-012` 进入 `Implementing`。首切固定一个逃逸、零参数闭包通过共享 heap cell 修改 captured `number`，用于证明 closure identity、capture lifetime、间接调用和 exact GC tracing；lexical `this`、递归、嵌套环境、async/EH 和签名 adapter 保持拒绝。
- 新增 canonical closure contract v1 与 strict decoder/content hash，冻结 dense function/environment/capture ID、source symbol/signature、by-value/by-cell、stack/heap-environment、slot order、escape lifetime 和 trace count。mutable-by-value、stack escape、nondense slot、trace mismatch 与 unknown member negative 通过。设计见 `plans/phase3-vert-012-design-2026-08-11.md`；下一步为 decoder fuzz 和真实 snapshot capture proof，不声称 HIR/MIR/LLVM 或 `LocalVerified`。
- checked-in `closurecounter` 真实 fixture 已完成两次 deterministic frontend build。VERT-012 专用 replay 严格消费 snapshot capture proof：唯一箭头函数只捕获同模块 `count:number`，access=`readwrite`、mutable=true、零参数 number signature；导出函数对顶层 `makeCounter` 的模块绑定不会误装箱。rehashed readonly/immutable capture substitution 均拒绝，closure decoder 初始约 2.4 万次 bounded fuzz 通过。状态仍为 `Implementing`，下一步为独立 HIR major 与 capture/call CFG。
- VERT-012 HIR v11 已绑定真实 replay：显式 `environment.alloc -> cell.init -> closure.make -> call.indirect -> call.indirect`，closure body 显式 `cell.load -> +1 -> cell.store`；共享 closure value 和 heap environment 的 CFG/effect/capability 顺序由独立 verifier 固定。HIR round-trip、tamper matrix 与旧 v8/v9/v10 readers fail-closed 通过。下一步为独立 MIR v9、TargetContext capture layout 和 LLVM indirect-call lowering。
- VERT-012 MIR v9 已闭合 HIR-to-layout join：cell 使用非 trace `f64` layout，environment 使用 trace `gc-ref` cell field，两个 type key 均由 closure contract hash 派生。两 slot GC plan 证明 cell 在 environment allocation 前存活，cell/environment 在 forced collection 前精确重发布并重载；layout/root/offset/indirect-call/shared closure substitution 均拒绝。下一步为 TargetContext binding 与 LLVM indirect-call lowering。
- VERT-012 bound-MIR v1 已闭合：TargetContext 同时核验 cell/environment 两份 DataLayout identity，并从 runtime manifest 的 exact catalog 绑定全部 GC capability；catalog、context、任一 layout 或 binding substitution 均在 LLVM 前 fail closed。状态仍为 `Implementing`，下一步为 LLVM closure representation、runtime harness、ELF 和 Node differential。
- VERT-012 LLVM/object 链已闭合首轮：独立九项 capability closure 加入 `rt.gc.write_barrier`，cell/environment shape 与 pointer-offset trace descriptor 按冻结 C ABI 生成，双槽 shadow stack、两次 allocation、barrier、forced safepoint、`{code, environment}` closure aggregate 和两次真实 indirect call 通过 O0/O2 verifier。最初 trace descriptor 将 offset-array 模式的 `pointer_map_words` 错置为 1，runtime status trap 成功拦截；修正为 0 后，真实 object+Rust archive+LLD/ELF 与 Node 在 `+0/-0/1/Infinity/payload NaN` 上逐位一致。生产 `bingomir.ExecuteVERT012` 已接入唯一 snapshot-to-object 链。状态仍为 `Implementing`，尚缺 manifest-owned harness、CLI/unified runner 和最终自审。
- VERT-012 manifest/CLI/runner 链已闭合：runtime manifest 认证独立 closure harness，`emit-vert012` 原子发布 closure contract/HIR v11/cell+environment layouts/MIR v9/bound MIR/LLVM/object/report，unified runner 对五组 binary64 输入执行真实 ELF 与 Node bit differential，重复报告保持 deterministic。
- `OBJ-002a + BE-003a + VERT-012` 首个 escaping mutable closure 子切达到 `SelfAudited`。运行时重建 smoke/GC ABI、Windows 全量 Go test/vet、VERT-012 focused race、WSL LLVM20 backend/runner/CLI、既有 bounded fuzz 和双层 `git diff --check` 通过；CI 按负责人要求保持关闭，Miri 不声称，状态不提升为 `Integrated`。lexical `this`、递归、nested environment、capture adapters 仍保持拒绝并进入后续纵切。

## 2026-08-11 Phase 3 `VERT-013a` base class 纵切启动

- `OBJ-003b + BE-003a + VERT-013a` 从 `Implementing` 起步，现已达到 `SelfAudited`。首切固定一个无基类 `Counter`：public mutable number field、显式 unary constructor、receiver-bound zero-arg method 和 exported caller；extends/super、private/protected、static、accessor、computed key、decorator、abstract/generic、method extraction 与 adapter 保持拒绝。设计与自审证据见 `plans/phase3-vert-013a-design-2026-08-11.md`。
- canonical class contract v1 已冻结 nominal class/instance identity、constructor ABI、field/method dense ID、receiver requirement 与 `allocate -> field initializer -> constructor body` 顺序；64 KiB strict reader、unknown/stale/oversize 和 derived/private/static/ABI/order tamper matrix 通过，3 秒 fuzz 约 3,201 次执行。
- checked-in `classcounter` 真实 fixture 通过 deterministic frontend snapshot。checker-free lowerer 严格消费 class/type/property/signature/new/call facts，rehashed readonly field、method effect 与 optional constructor parameter substitution fail closed；lowerer/replay 已纳入 compiler identity。
- 独立 HIR v12 显式保存 nominal class contract、receiver allocation、field init/store/load、constructor call 和同一 receiver 的两次 method call；旧 v8/v9/v10/v11 readers fail closed，CFG/receiver/field/capability tamper matrix、focused test/race/vet 通过。下一步为 instance layout、MIR 与 TargetContext binding，不声称 LLVM/ELF/Node 或 `SelfAudited`。
- VERT-013a MIR v10 与 bound-MIR v1 已闭合首轮：instance layout 复用 object ABI，唯一 `value:f64` 字段无 trace offset；MIR 同时绑定完整 class contract、nominal instance type key、layout hash、field offset、constructor/method callee identity和单 receiver root lifetime。layout/contract/receiver/callee/root substitution fail closed，3 秒 MIR fuzz 约 2.6 万次执行。
- 生产 `bingomir.LowerVERT013a` 已串起 snapshot replay、TargetContext resolution、instance layout、MIR 和 exact capability binding；WSL LLVM20 TargetMachine 下 provenance chain 测试通过。该入口明确停在 bound-MIR，不以空 emission 冒充 backend；下一步为 LLVM class descriptor/constructor/method lowering、ELF 和 Node differential。
- VERT-013a LLVM/object/runtime 链已闭合：private constructor 和 receiver-bound method 复用 manifest-bound allocation/root ABI，forced safepoint 后精确 reload receiver；O0/O2 verifier、真实 object+Rust archive+LLD/ELF 与 Node 在 `+0/-0/1/Infinity/payload NaN` 上逐位一致。
- manifest-owned `bingo_class_counter_harness.o`、unified `classcounter` runner 和 `emit-vert013a` CLI 已接入。CLI 原子无覆盖发布 class contract v1、HIR v12、instance layout v1、MIR v10、bound MIR v1、LLVM IR、ELF object 和 strict content-hashed report；runner 两次报告 byte-identical。
- `OBJ-003b + BE-003a + VERT-013a` 达到 `SelfAudited`。Windows 全量 Go test/vet、focused race、class contract/MIR fuzz、WSL LLVM20 runner/CLI、runtime smoke/GC ABI 和双层 `git diff --check` 通过；CI 按负责人要求保持关闭，Miri 不声称，状态不提升为 `Integrated`。extends/super、private/protected、static、accessor、computed name、method extraction 与 adapters 仍保持拒绝并留给后续纵切。

## 2026-08-12 Phase 3 `VERT-013b` derived class 纵切设计

- 8b 已按“一条语义纵切一次闭合”规则拆分：`VERT-013b` 只处理一个直接 `super()` 的派生类和静态已知方法 dispatch；private/protected、static、variance 与 adapters 不再混入同一验收项。
- `plans/phase3-vert-013b-design-2026-08-12.md` 已冻结 class contract v2、HIR v13、base-prefix/derived-suffix layout、构造顺序和拒绝矩阵。真实 `derivedcounter` fixture 已通过两次 byte-identical snapshot build；strict contract v2、旧 v1 reader 隔离、constructor/super/identity/ABI tamper matrix 与 fuzz seed 已通过，状态推进为 `Implementing`。下一步是 checker-free derived replay 与独立 HIR v13。
- VERT-013b checker-free replay 与 HIR v13 已闭合首轮：heritage/base type、base/derived nominal symbol、constructor ABI、selected `super()` signature、override method symbol 和两次同 receiver 调用均从 snapshot facts 交叉验证；rehashed base relation、super target 与 method effect substitution fail closed。HIR 显式保存 complete-receiver allocation、direct `call.super`、base field prefix、derived field init/body、静态派生方法调用和 receiver identity，v8-v12 readers fail closed。focused full-package tests、VERT-013b race 与双层 `git diff --check` 通过；状态仍为 `Implementing`，下一步是 base-prefix/derived-suffix layout 与 MIR v11。
- HIR v13 verifier 已加强为从 canonical class contract 重建并逐字节比较完整四函数 CFG，provenance capability digest、签名、effects、返回值和操作顺序篡改均 fail closed。VERT-013b layout contract 已绑定 class-contract hash、base/derived type key 与 field symbol，证明 `value:f64` 偏移在 derived object 中保持为精确前缀、`step:f64` 只能作为后缀且两者无 trace offset；状态仍为 `Implementing`，下一步是 MIR v11 与 bound MIR。
- VERT-013b MIR v11/bound MIR 已实现并通过 round-trip、旧 reader 隔离及 super/receiver/layout/GC root/capability tamper 矩阵。派生构造路径只分配一次 complete receiver，基类构造在该 receiver 上初始化 base prefix；GC safety 对 super 与两次 method safepoint 均要求精确 root publish/reload。状态仍为 `Implementing`，下一步是 TargetContext binding 与生产 pipeline。
- VERT-013b 已接入 TargetContext 与生产 `bingomir` lowering/execute pipeline；base/derived 两个 layout 均与观测 triple/data-layout/hash 绑定。LLVM 20 O0/O2 验证、ELF 链接运行及 Node differential 已通过，覆盖 start/step、负零、无穷与 NaN payload；多属性 shape descriptor 按 base-prefix/derived-suffix 顺序发射。状态仍为 `Implementing`，下一步是 runtime harness manifest、unified runner 与 CLI artifacts。
- VERT-013b runtime/runner/CLI 已闭合：权威 runtime build 生成双参数 harness 与更新后的 locked manifest，unified runner 对五组 binary64 输入完成 native/Node 确定性双跑；`emit-vert013b` 原子发布 contract v2、HIR v13、layout、MIR v11、bound MIR、LLVM IR、ELF object 与 strict report，no-clobber 生效。设计验收项在本地证据下完成，状态提升为 `SelfAudited`；CI 按 owner 决定保持关闭，未声称 `Integrated`。

## 2026-08-12 Phase 3 `OBJ-003b` private/protected access 启动

- `8b-2` 已以独立的 [访问设计](plans/phase3-obj-003b-access-design-2026-08-12.md) 进入 `Implementing`，不修改已冻结的 VERT-013b class contract v2。canonical class-access contract 固定声明顺序、direct base relation、member owner、visibility 和 private identity；strict decoder 拒绝 unknown/stale schema/hash、forward inheritance、重复 symbol/identity 与 visibility/identity substitution，并有 fuzz seed。
- 真实 `classaccess` fixture 经两次 deterministic frontend snapshot 构建。checker-free replay 从 snapshot property facts、selected member symbol、receiver narrowed type 与 parent 链恢复 lexical class，并对 private identity、derived-private rejection 和 protected receiver compatibility 使用同一 access planner。对 private identity、visibility 与 protected receiver 的 rehashed tamper 均 fail closed。
- 编译器诊断回归固定 derived private access 的 `TS2341` 和 derived protected access through base receiver 的 `TS2446`。当前尚未生成新的 HIR/MIR 或 backend 制品，不能提升为 `LocalVerified`/`SelfAudited`；下一步是为被授权 member access 建立独立 HIR contract。
- 独立 HIR v14 已闭合首轮：四个 source-authorized member proofs 同时绑定 access contract、selected member symbol、lexical accessing class、receiver class、private identity、planner decision 与 source origin；verifier 从 canonical contract 重算 planner 而不信任 lowerer 的允许标记。v9-v13 reader 对新 class-access fields fail closed，lowering identity 也已覆盖 class-access sources 和 HIR v14 major。HIR strict decoder/fuzz seed、snapshot replay hash binding 与相关 full-package test 通过；下一步为 target-aware MIR authorization artifact，当前仍为 `Implementing`。
- Target-aware MIR v12 已闭合首轮：artifact 内嵌 canonical HIR v14，分别固定 `class.field.load.authorized` 与 `class.method.call.authorized`、`f64` representation、member owner/kind、request/decision/origin，并绑定 TargetContext hash、triple 与 DataLayout hash，不携带 field offset。TargetContext 层要求 HIR frontend provenance 与 resolved context 完全一致。MIR strict decoder/fuzz seed、旧 VERT-013b MIR reader isolation、完整相关包测试与 focused race 通过；下一步是 access authorization 与 canonical object layout/offset 的显式 join，状态仍为 `Implementing`。
- Access-aware layout join 已闭合首轮：class-access contract 绑定每个 nominal instance type hash，base layout 只含 declaration-order 的 private `secret` 与 protected `value` 两个 `f64` field，derived layout 必须保持同一双字段 prefix、相同 offsets、无 trace offsets；method members 不得产生物理 slot。MIR 同时区分 TargetContext artifact hash 与 LLVM layout-string hash，TargetContext canonical target 校验两者后才允许 layout planning。layout strict decoder/fuzz seed、type/symbol/offset/representation/target tamper、完整相关包测试与 focused race 通过；下一步是让现有 backend 消费该 authorization/layout join，状态仍为 `Implementing`。
- Backend consumption 已闭合 compile-only 首轮：strict backend plan 内嵌 canonical layout join，对 field authorization 按 receiver nominal class 选择 base/derived layout 并解析唯一 offset，对 method authorization 只保留 receiver-bound callee symbol且禁止 offset；authorization ID、member symbol、offset/callee substitution 均 fail closed。生产 `bingomir.LowerClassAccess` 串起 snapshot→HIR v14→TargetContext MIR v12→layout→backend plan，并明确不返回伪造的 LLVM/object。Windows 相关 full-package/focused race 通过；WSL 当前因 `wsl.exe` 系统拒绝访问未能执行 Linux LLVM-tagged pipeline test，且不声称该项证据。下一步是将完整 constructor/method/exported-entry CFG 纳入执行 MIR 后生成真实 LLVM，状态仍为 `Implementing`。
- MIR v12 已扩展为最小执行 CFG：`Vault.readSecret` private load、`DerivedVault.readValue` protected load、两个 authorized method call 与最终 `fadd` 的 function/instruction IDs、operands、effects 和 return value 均由 HIR v14 proofs 重建。backend plan 改为按 CFG 顺序消费 authorization，而非直接遍历授权表；调用交换、receiver/authorization/function/instruction substitution 均 fail closed。constructor/allocation/exported-entry 的完整 source semantics 和真实 LLVM 仍未完成。
- 本轮质量修复收紧 checker-free replay：固定 `Vault`/`DerivedVault` 的 class-child 形状与无显式 constructor 约束，字段 initializer 必须分别是 source literal `1`/`2`，唯一 `new DerivedVault()` 必须绑定默认构造 signature 和同一局部 receiver，两个导出方法调用必须保持 selected signature、receiver/argument identity 与各调用恰好一次。新增字段初值、构造选择、heritage 形状和 selected-call 的 rehashed tamper 回归；相关 Go 包、focused race 与 diff 检查通过。状态仍为 `Implementing`，CI 继续按负责人要求关闭。
- P3 执行链开始从授权 CFG 分离：新增 canonical `ClassAccessExecutionContract`，固定五个 source-level functions（基类构造、派生默认构造、两个方法和 exported `classAccess`）、一次 derived allocation、`secret=1`/`value=2` 初始化、direct super 和调用顺序；该制品已进入 replay schema v2，并有严格 decode/hash/tamper 回归。当前尚未把它提升为 HIR/MIR v15/v13，也未生成真实 LLVM/ELF，因此状态继续为 `Implementing`。
- Class-access HIR 已升级至 v15：其 canonical CFG 内嵌 execution contract，显式表示 base field initialization、derived allocation/direct super、private/protected authorized load、两个 receiver-bound public method call 与 exported `classAccess` return；逻辑 capability 闭包复用已审计的 owned-object/GC 需求。旧 HIR verifiers 对 execution 字段 fail closed；execution initializer、allocation、super target、field symbol、receiver 与 entry call-order substitution 均有回归。MIR 仍为 v12 最小执行 CFG，下一步升级为消费 HIR v15 的 v13，状态不提升。
- Class-access MIR 已升级至 v13：artifact 同时绑定 HIR v15 与 execution contract，五个 functions 按 source execution 顺序保存 base initializer、single derived allocation、direct `call.super`、authorized private/protected loads、authorized public calls 和 entry `fadd`；layout/backend plan 只对四个 authorization operation 选择 offset/callee，新增 initialization/allocation/super/execution-hash tamper 均 fail closed。GC root/capability closure 尚未形成 layout 后 bound MIR，真实 LLVM 仍未开始，状态保持 `Implementing`。
- Class-access bound MIR 已接入：post-layout artifact 独立绑定 structural MIR v13、base/derived layout hash、TargetContext、derived trace layout 的 GC safety plan 和完整 runtime capability closure；targetcontext production binding 校验 observed LLVM DataLayout、catalog provenance、exact logical names/signatures，bound round-trip、GC safepoint、target/layout/capability tamper 均 fail closed。真实 LLVM/ELF/Node 尚未开始，状态仍为 `Implementing`。
- Classaccess-specific LLVM 20 emitter 已实现并接入 `TargetMachine.EmitClassAccessObject`/production `ExecuteClassAccess`：直接消费 bound MIR，发射两字段 shape、单次 GC allocation、base initializer、direct super、两个 `(receiver, other)` 方法、root publish/reload/safepoint 和 exported zero-argument `classAccess(): f64`。Linux-tagged module/object 与 canonical source-to-object tests 已加入；当前 Windows 非 tagged tests/vet/diff 通过，但本机 WSL 仍不可启动，因此不声称 LLVM verifier/object test 已执行，更不声称 ELF/Node evidence。
- Node oracle 已加入 `ClassAccess()` 与独立 script hash，脚本显式复现 `private secret=1`、`protected value=2`、derived receiver 和两个调用；Node v22 本地直接执行得到 `4008000000000000`。这只是 oracle 证据，不替代 native ELF/runner 证据；runtime harness/manifest 仍待接入。
- Runtime-owned zero-argument `class_access_bits.c` harness 已加入，authoritative build script/target manifest/manifest writer 会生成并锁定 `bingo_class_access_harness.o`；Go runtime manifest schema、strict artifact validation、linker entry selection、zero-argument native invocation 和 runnable case-manifest validation 已接入。Python/C syntax 与相关 Go test/vet/diff 通过。由于 Linux authoritative runtime rebuild 仍不可执行，checked-in runtime manifest/source/target hashes 尚未更新，不能声称 harness 已构建或 ELF 已链接。
- Unified runner 现已接入 `classAccess`：production path 使用 `ExecuteClassAccess`、runtime-owned harness、zero-argument native run 与 `NodeOracle.ClassAccess`，并把 bound MIR/LLVM/object/link/native/Node identities 纳入 strict report。报告 verifier 固定 `classaccess` oracle script、零参数 ABI 和 expected/native/Node output hash；旧 runtime manifest 缺新 harness 会在 link 前 fail closed。runtime rebuild/ELF evidence 仍待 Linux 环境。
- CLI `emit-classaccess` 已接入原子 artifact publisher，输出 access contract v1、execution v1、replay v2、HIR v15、MIR v13、layout v1、bound MIR v1、backend plan v1、LLVM IR、object 与 strict report；existing directory no-clobber、unknown report member 和 stale hash 回归通过。命令的真实执行仍依赖重新锁定的 runtime manifest 与 Linux LLVM backend。
- Linux-tagged `emit-classaccess` integration test 已加入：从 checked-in snapshot 运行 production command，逐一 strict decode contract/execution/HIR/MIR/layout/bound/backend artifacts，检查 ELF magic、report 和二次发布 no-clobber。当前环境仍无法启动 WSL，故该测试尚无执行证据。
- 新增 execution contract 与 bound MIR decoder fuzz targets；3 秒 bounded runs 分别完成约 1,574 和 1,920 次执行，未发现 canonicalization/strict decode 问题。相关 seed、full package test、race/vet/diff 继续通过。
- Windows 主机已安装 locked Rust 1.97.1 的 `x86_64-unknown-linux-gnu` std target，并成功交叉构建 release `libbingo_runtime.a`。LLVM 20.1.8 clang 缺少 Linux libc sysroot，startup/harness C objects 因 `math.h`/`ctype.h`/`inttypes.h` 缺失无法构建；Zig 自带 sysroot但使用 clang 21.1.0，不符合 LLVM 20 lock，未采用。authoritative runtime manifest/ELF 门禁因此仍未关闭。

## 2026-08-12 Phase 3 `OBJ-004` variance proof 开始

- 按 [OBJ-004 设计](plans/phase3-obj-004-variance-design-2026-08-12.md) 进入 `Implementing`，不修改已冻结的 object/class/runtime ABI。首个 closed-generic、target-independent contract 已实现：声明顺序 parameter/occurrence IDs、readonly/writable/function parameter/return/mutable element polarity、显式 `in`/`out`/`in out` 规则、tsgo hint downgrade 和 direct-ABI admission 均由 verifier 重算。
- `DecodeVarianceContract` 使用 unknown-member、schema、content-hash、proof-substitution、non-canonical order、oversize fail-closed 门禁；正例覆盖 covariant/contravariant/invariant/unknown，负例覆盖 bivariant direct reuse、annotation conflict 和残余动态语义。递归 SCC、nested generic propagation、frontend snapshot extraction 与 cross-module proof 尚未实现，不以本 substrate 提升为 `LocalVerified`。
- `go test ./internal/bingo -run Variance -count=1`、focused race、全仓 `go test ./...`、全仓 `go vet ./...` 与双层 `git diff --check` 通过；3 秒 16-worker `FuzzDecodeVarianceContract` 完成 4,542 次执行并发现 24 个新增 interesting inputs，无失败。下一步为 checker-free occurrence capture、递归 SCC 和完整 `OBJ-004` HIR/source integration。
- checker-free source replay 已接入真实 `testdata/ts2bin/variance` snapshot：从 interface/type-parameter declaration、property read/write facts、method call signature 和 tsgo variance hint 重建 `ReadonlyBox<out T>`、`Consumer<in T>` 与 mutable `Cell<T>` 三份 contract。Bingo 不信任 tsgo 对 `Cell<T>` 的 `out` hint，依据 writable property 将其重算为 invariant；replay 本身纳入 compiler lowering identity。
- variance hint parser 覆盖 tsgo 的 `out`/`in`/`in out`、`[bivariant]`/`[independent]` 和 `(unmeasurable)/(unreliable)` 编码；多参数 occurrence 在构造 contract 前按 parameter/source/path 重新 canonical 排序。真实 snapshot 独立重建文件 SHA-256 均为 `16561cf3d95b2f277453ce3d59d9d5c43e842dd8a8a2960cbf2573c0e097e96f`；全仓 Go test/vet、variance replay race、tamper negative 与最新 3 秒 decoder fuzz（31,515 次执行）通过。递归 SCC、nested generic propagation 与 HIR consumer 仍待实现，状态保持 `Implementing`。
- recursive variance graph 独立 schema v1 已实现：嵌入 canonical declaration contracts，dense node 精确绑定 declaration parameter，dependency edge 固定 positive/negative/both/unknown transform 与 source path；Tarjan 重建 SCC，按 component 最小 node ID 分配稳定 SCC ID，并在有限 polarity lattice 上执行有界单调 fixed point。
- mutual positive/negative recursion 收敛为 `Both`，positive self recursion 保持 `Positive`，opaque edge 降级 `Unknown`；unknown member/hash、forged SCC/proof、noncanonical edge 和 oversized graph 均 fail closed。3 秒 16-worker `FuzzDecodeVarianceGraph` 完成 9,798 次执行并发现 60 个新增 interesting inputs，无失败。真实 nested generic edge extraction 与 HIR conversion consumer 当时仍待实现，随后已由以下两项闭合。
- `OBJ-004` 真实 nested-generic replay 已闭合：fixture 增加 self-recursive `Tree<T>` 与正/负互递归 producer/consumer；replay 从 frozen object symbol/type-argument/signature facts 重建三条 canonical graph edge，真实 SCC 收敛到预期极性。过程中修复 snapshot capture 的两个事实完整性缺陷：checker 返回的 property slice 在可重入 capture 前立即 clone，property read/write type 按所属 generic instance 查询，不再复用首次 symbol capture 的实例化类型。兼容性 semantic baseline 已经由受控命令重建；全仓 `go test ./...`、`go vet ./...`、variance/snapshot `-race` 与双层 `git diff --check` 通过。CI 继续按 owner-deferred 保持关闭。
- `OBJ-004` direct-reuse consumer 已闭合并提升为 `SelfAudited`：新增 canonical `TypeRelationGraph`，从真实两模块 `models.ts -> variance.ts` 的 base facts、declaration/argument binding 和相同 symbol/实参等价记录重建 `Dog -> Animal`；`HIRVarianceConversionProof` 同时消费最终 variance polarity、关系路径和两端 object layout，`HIRVarianceGate` 再绑定受支持 canonical HIR reader、函数与具体 object value。真实 `ReadonlyBox<Dog> -> ReadonlyBox<Animal>` 通过，反向、invariant/unknown、路径/类型/function/value/layout substitution 均 fail closed。新增 relation/conversion/gate decoder fuzz 的 3 秒运行分别完成约 2,471、3,148、6,190 次执行且无失败；全仓 test/vet、聚焦 race 与 diff 门禁通过。checked cast、adapter 与 thunk 保持在 `OBJ-005`，CI owner-deferred，因此不标记 `Integrated`。

## 2026-08-12 Phase 3 `OBJ-005` readonly ObjectView 开始

- 按 [OBJ-005 ObjectView 设计](plans/phase3-obj-005-object-view-design-2026-08-12.md) 进入 `Implementing`。首个 canonical `ObjectViewProof` 从 OBJ-004 `TypeRelationGraph` 重算每个 readonly target property 的 read relation path，并绑定 source/target `ObjectSemanticContract`、`ObjectLayoutContract`、source field offset/presence bit、identity preservation 与禁止写暴露；调用方不能再用未绑定 `Reliable=true` 放行。
- `ObjectViewHIRGate` 嵌入并验证受支持 canonical HIR reader，绑定函数和具体 object-producing source value。writable target、missing/kind/private/optional/read relation mismatch、semantic/layout type substitution、mapping offset/path、HIR function/value/type、unknown member、stale hash 和 oversize 均 fail closed；不生成 copy、bitcast、dynamic boundary 或 unsafe provenance。
- focused unit tests 通过；3 秒 16-worker `FuzzDecodeObjectViewProof` 和 `FuzzDecodeObjectViewHIRGate` 分别完成约 10,742 和 3,249 次执行且无失败。下一步是把 view mapping 作为显式 HIR operation 进入 MIR/LLVM/runtime 纵切，并证明 identity、accessor receiver 和无隐式复制。
- ObjectView operation/MIR/backend substrate 已接通：operation 分配 fresh result `ValueID`；独立 HIR artifact 防止修改历史 reader；MIR 固定 `view.bind` 为 `PreservesIdentity=true`、`Allocates=false`，data-property read 从 verified source offset/presence/representation 重建。backend plan 只接受一个 `f64` read、零 runtime call/零 allocation。operation、artifact、MIR、backend plan decoder 均有严格 canonical round-trip/tamper 覆盖；3 秒 fuzz 的 operation/artifact/MIR/backend runs 分别约 4,098、2,983、6,574、6,530 次执行，无失败。accessor mapping 在 MIR gate 显式拒绝，状态保持 `Implementing`。
- ObjectView LLVM 20 emitter、runtime C harness 与独立 Node identity-read oracle 已实现：emitter 绑定完整 backend plan hash，只发射一个 verified source-offset `f64` load，O0/O2 tagged tests 禁止 bitcast/call/alloca/malloc/GC runtime；Linux tagged differential test 生成 ELF、按 proof-derived offset 执行 harness，并对 `+0/-0/1/Infinity/payload NaN` 与 locked Node 逐位比较。当前 Windows 主机无法访问 `wsl.exe`，因此 tagged LLVM/ELF/native test 尚未执行，不声称 native runtime 证据或 `SelfAudited`。本轮全仓 `go test ./...`、`go vet ./...`、ObjectView/variance/type-relation focused race 与双层 `git diff --check` 通过，状态保持 `Implementing`。
- 真实 frontend ObjectView 纵切已接入：新增 deterministic `testdata/ts2bin/objectview` snapshot，源码把可写 `{ value:number }` 赋给 `ReadonlyValue`，再经 mutable alias 更新后从 readonly view 读取，以 observable mutation 固定 identity/no-copy 语义。checker-free replay 从 contextual type、distinct source/target property symbols 和 readonly/write facts重建两端 semantic/layout、relation、proof、HIR gate/artifact 与 MIR；production `bingomir.LowerObjectView/ExecuteObjectView` 再生成 backend plan/LLVM object。readonly、contextual assignment、return receiver、property identity 的 rehashed tamper、replay unknown/stale/oversize 和 artifact substitution 均 fail closed；replay decoder 3 秒 fuzz 完成 35 次深层 artifact 执行无失败。全仓 test/vet、相关五包 focused race 与双层 diff 门禁通过。Linux tagged source→ELF→native→Node 测试已加入但因 WSL 不可访问尚未执行，故状态保持 `Implementing`。
- ObjectView accessor receiver-aware MIR 首轮已完成：MIR schema 升至 v2，accessor mapping 必须从同一 canonical VERT-011 PlaceRef 重绑 source object/type/property、saved source receiver、getter symbol、固定 getter ABI、read representation 与 `call/read/throw` effects；实际调用 receiver 使用 fresh view SSA，并由 `PreservesIdentity` 证明与 source 相同。receiver/getter/ABI/effect substitution 均 fail closed，data-property LLVM backend 额外检查 read kind，accessor backend 继续显式拒绝。ObjectView MIR fuzz 新增 accessor seed，3 秒完成约 32,710 次执行并发现 71 个 interesting inputs，无失败；全仓 test/vet、四包 focused race 与双层 diff 通过。真实 accessor-view snapshot replay、getter code join、LLVM/ELF/Node 仍待后续，因此状态不提升。
- 真实 accessor-view frontend replay 已补齐：独立 `objectaccessorview` fixture 保存 getter-only `ReadonlyResult`、mutable source accessor 和 contextual structural assignment，专用 replay 在不改动已冻结 VERT-011 fixture 的前提下重建 canonical accessor HIR、ObjectView proof/artifact 和 receiver-aware MIR v2。fixture 发现并修复原 VERT-011 lowerer 对 getter/setter declaration slice 偶然顺序的依赖，现改为 exact declaration set 校验；contextual target 与 getter-only write surface 的 rehashed tamper 均拒绝。深层 replay fuzz 3 秒完成 40 次执行无失败；全仓 test/vet、四包 focused race 与双层 diff 通过。accessor backend getter code join/LLVM 仍未完成，状态保持 `Implementing`。
- accessor backend code join 已接通：plan v2 从 canonical PlaceRef/source layout 重算唯一 backing offset、getter symbol、nullable-f64 representation 和 `bingo_object_view_read_accessor_v1(ptr,payload*,tag*)` ABI；Linux-tagged emitter 生成私有 getter（payload/tag offset+8）与 receiver-preserving call，禁止 malloc/GC/bitcast。新增 accessor plan fuzz seed 3 秒完成约 69,282 次执行并发现 104 个 interesting inputs；新增 C harness 保留 tag/payload bits，Node oracle 覆盖 number/null/undefined。Windows 全仓 test/vet、五包 focused race 与双层 diff 通过；WSL 不可访问，故 ELF/native/Node tagged execution 尚无权威证据，状态保持 `Implementing`。

## 2026-08-12 Phase 3 `OBJ-005` checked cast 设计

- checked cast 子切已达到 `DesignAccepted`，尚未进入实现。它只接受显式 dynamic/FFI boundary，不把 TypeScript `as`、`satisfies` 或 non-null assertion 解释为运行时 cast；首切目标限定为 closed shape 的 required public data properties。
- 设计要求成功时保持原对象 identity 并只暴露 readonly surface；失败是显式 match=false，runtime contract failure 则使用独立非零 status。实现必须经 versioned capability/manifest、canonical semantic/layout/shape 绑定以及 strict decoder/tamper/fuzz 门禁，不允许 allocation、copy、用户 accessor 调用或未经验证的 header dereference。
- 设计记录见 [OBJ-005 checked-cast design](plans/phase3-obj-005-checked-cast-design-2026-08-12.md)。设计验收时尚未提升为 `Implementing`、`SelfAudited` 或 `Integrated`；以下实现记录随后将子切推进到 `Implementing`。
- 首个 checked-cast canonical contract 已实现：独立 dynamic/FFI boundary artifact（schema/content hash）、目标 semantic/layout 完整 provenance、required public data-only admission、readonly result 与 identity preservation 均由 verifier 重算；静态 source、assertion、optional/accessor/private/writable、layout/type/hash substitution 全部 fail closed。相关 decoder/tamper tests 与 `FuzzDecodeCheckedObjectCast` 3 秒 16-worker（2,977 次执行、23 个新增 interesting inputs）通过。runtime capability/manifest、真实 dynamic fixture 和 Linux ELF/native/Node differential 仍待后续，状态为 `Implementing`，CI 继续保持关闭。
- checked-cast runtime ABI 首轮已接入 schema/generator/Rust/header/target manifest：`rt.object.shape_matches` 使用 `bingo_shape_matches_v1(*object,*shape,*u8)->status`。runtime 在清零 result 后先验证对象仍属于 single-mutator heap，再对 allocator-authenticated source descriptor 与 target descriptor 做结构比较（shape/trace/property count、bounded key、kind/flags/offset/presence/slot/order/value descriptor）；null/foreign/stale/malformed object 返回 contract failure，不会先读取不可信 header。Rust workspace test/clippy 与 Go targetcontext/bingo/bingomir/llvmbackend package gates 通过；真实 dynamic fixture、bound lowering、Linux ELF/native/Node differential 仍待后续。
- checked-cast bound artifact 已加入：`CheckedObjectCastBoundContract` 同时封闭 cast、TargetContext hash、capability catalog hash 与唯一 `rt.object.shape_matches` / `bingo_shape_matches_v1` binding，symbol/logical name/signature/context/catalog/cast substitution 均 fail closed。decoder round-trip/tamper 与 3 秒 16-worker bound fuzz（67,188 次执行、127 个新增 interesting inputs）通过。锁定 runtime manifest 仍等待权威 Linux rebuild，因此 TargetContext 正向 binding 尚不开放，避免 source-only capability 被生产 lowering 错用。
- `targetcontext.BindCheckedObjectCast` 已接入：验证 canonical cast、TargetContext/catalog provenance、LLVM DataLayout identity，并从排序 catalog 解析唯一 capability；当前锁定 catalog 缺少新 capability 时按预期 fail closed。正向 binding 证据留待 runtime manifest 权威重建。
- checked-cast backend plan 已实现：内嵌完整 bound artifact，并独立重算 target semantic hash、layout content/physical hash、property count、唯一 shape-match symbol、status-checked 与 `0|1` match domain；成功值固定为原 source reference，allocation/copy/accessor/additional runtime call 均拒绝。round-trip/tamper tests 与 3 秒 16-worker backend fuzz（1,694 次执行、16 个新增 interesting inputs）通过；LLVM emission 继续由未锁定 capability 阻挡。
- checked-cast Linux LLVM20 emitter 与 tagged O0/O2 structural test 已加入：emitter 生成 plan-owned target shape，清零 outputs 后调用 `bingo_shape_matches_v1`，显式传播非零 status，拒绝非 `0|1` match，只有 match=1 写回原 source reference。Windows 非 tagged backend test 通过；WSL 仍被系统拒绝访问，故 tagged LLVM verifier/object/ELF 测试尚未执行，不能作为 LLVM/native evidence 声称。
- checked-cast Node oracle 已加入 locked script hash 与 `<0|1>:<binary64 bits>` 协议，区分 matching/missing/extra/accessor cases；目标 required data properties 允许 source 额外属性，但拒绝 missing/accessor。Node v22.22.0 直接执行 payload NaN `7ff8000000000042` 得到 matching=`1:7ff8000000000042`、accessor=`0:7ff8000000000042`。这是 oracle/bit-preservation 证据，不替代 native ELF differential。
- runtime shape-match source/target 语义已修正：source descriptor verifier 允许已验证 data/accessor shape，target verifier 才强制 required public data-only；accessor/optional source 对 canonical data target 返回 `match=0`，malformed kind 仍返回 contract failure。Rust workspace test/clippy 通过，避免把合法动态来源误报为 runtime ABI 错误。
- runtime-owned `checked_object_cast_bits.c` harness 已加入并接入 build script、target manifest、manifest writer 与 Go runtime artifact schema；输入 `<matching|extra|missing|accessor> <bits>`，输出 `<0|1>:<bits>`，并检查 runtime allocation、wrapper status、match domain、identity/null result。Windows LLVM20 clang C syntax、Python compile、Rust workspace 与 Go manifest/linker/full gates 通过；Linux harness object/locked manifest hash 尚未权威重建。
- runtime shape-match 已进一步修正为 target-property subset：source object 可更大、可带额外已验证属性；target required data property 必须在 source 中以相同 key/kind/flags/offset/presence/slot 出现，source/target trace 各自独立验证。新增 source extra-property 正例通过，accessor/optional source 仍返回 `match=0`，malformed descriptor 返回 status；Rust workspace/clippy、Go 全量 test/vet 与 C/Python 静态门禁通过。
- checked-cast 已接入 first-slice linker/run 协议边界：link request 对 `bingo_checked_object_cast_v1` 强制独立 `i32` status ABI，response file 只选择 manifest-authenticated checked-cast harness，缺 artifact 时在物化前 fail closed；执行 helper 只接受四个 canonical shape 与小写 16 位 payload，并严格拒绝非 `0|1`、大写、多行或缺换行输出。本轮同时修复 `classAccess` 已有 harness 路径未进入 linker request 白名单的问题。相关包、全仓 Go test/vet 与 diff 门禁通过；锁定 runtime manifest 未改，Linux ELF/native differential 仍待权威 rebuild，状态保持 `Implementing`，CI 保持关闭。
- checked-cast 真实 frontend provenance 已接入：新增 interop-profile `checkedobjectcast` fixture，经 snapshot 双构建确定性验证；fixture 只保存唯一 ambient `hostObject(): unknown` dynamic source 与 required-public-readonly `HostValue.value:number` 目标，不定义或借用 TypeScript `as` 作为运行时 cast。专用 checker-free replay 从 declaration-only/unknown-effect signature 和目标 property facts 重建 `ffi-import` boundary、semantic/layout 与 canonical cast，并显式拒绝任意 assertion node；rehashed host return/effect、target writable、assertion substitution、strict decoder/oversize/determinism 均 fail closed，3 秒 16-worker fuzz 完成 35 次深层执行无失败。全仓 Go test/vet、Rust workspace test/clippy 与双层 diff 通过；用户可见 boundary、positive TargetContext binding、ELF/native 仍待后续，状态保持 `Implementing`，CI 不变。
- checked-cast fixture/replay 已补齐真实 matching/nonmatching 输入：ambient boundary 现为 `hostObject(shape: "matching" | "missing"): unknown`，replay 从 canonical string-literal union 严格验证闭合 case 集合，同时继续拒绝任何 `AsExpression`。生产 `bingomir.LowerCheckedObjectCast/ExecuteCheckedObjectCast` 已串起 replay、BuildPlan frontend hash、TargetContext resolution、catalog binding、backend plan 与 LLVM emission gate；frontend substitution/nil TargetMachine fail closed，Linux tagged test 要求旧锁定 manifest 精确停在 `rt.object.shape_matches` unavailable，未伪造 catalog 或 emission。本轮 fuzz 49 次深层执行无失败，全仓 Go test/vet、Rust workspace test/clippy 与双层 diff 通过；Linux tagged test 本机未执行，权威 rebuild/positive binding/ELF/native 仍待后续，状态保持 `Implementing`，CI 不变。
- production profile 自审修复：checked-cast pipeline 现在先强制 interop BuildPlan，static profile 不再被允许越过 dynamic-boundary admission。真实 interop plan 面对当前 static-only first-slice TargetContext/runtime manifest 时会在 runtime-profile resolution 处 fail closed，尚不会到达 capability binding；Linux tagged test 已同步固定这一正确错误顺序。positive binding 因而需要同时发布 interop runtime profile 与 `rt.object.shape_matches` 的权威 manifest，不能只追加 capability 或伪造 catalog。定向 test/vet 通过；状态与 CI 均不变。
- checked-cast replay provenance 闭包已加固：artifact 显式绑定 host name symbol ID、host signature hash、source `unknown` type hash、target type hash 和 target property key；canonical decoder 交叉检查 boundary source ID 与 cast source/target/property 字段，host symbol/signature/source/target/property substitution 全部 fail closed。此前 declaration 节点没有可用 symbol，现改为精确读取 `name` identifier 的真实 symbol。3 秒 fuzz 完成 34 次深层执行无失败；全仓 Go test/vet、Rust workspace test/clippy 与双层 diff 通过。OBJ-005 继续 `Implementing`，CI、runtime manifest 和锁定哈希不变。
- checked-cast replay reader 升级为 schema v2：frontend evidence 现为独立 schema-v1 canonical artifact，包含 snapshot hash 与 host/signature/source/target/property facts；dynamic boundary `SourceID` 绑定 `frontend-evidence:<evidence hash>`。即使攻击者同时重哈希 evidence、boundary 和 cast，只要外层 frontend identity 未同步仍会 fail closed；旧 replay v1 与无 evidence hash 制品严格拒绝。3 秒 fuzz 完成 36 次深层执行无失败；全仓 Go test/vet、Rust workspace test/clippy 和双层 diff 通过。状态仍为 `Implementing`，CI 与锁定 runtime 不变。
- checked-cast replay provenance 再加固至 schema v3：frontend evidence 同时绑定 validated `CompilerBuildIdentity` 与 matching/missing case-union type hash，且两者进入 evidence content hash 并与 outer replay identity 交叉校验；合法但不同 compiler fork、case union、outer identity、旧 v1/v2 reader 和完整重哈希链全部 fail closed。3 秒 fuzz 完成 28 次深层执行无失败；全仓 Go test/vet、Rust workspace test/clippy 和双层 diff 通过。此项只强化 source provenance，不改变当前 interop runtime profile/positive binding/native evidence 的未完成状态，CI 保持关闭。
- checked-cast replay 升级至 schema v4 并内嵌完整 canonical `ProgramSnapshot`；构造与 decoder 共用唯一 checker-free derivation，decoder 会验证 snapshot 后独立重建 frontend evidence、boundary、target semantic/layout 与 cast，再逐一比较 content hash。rehashed embedded snapshot substitution 与旧 v3 reader fail closed，消除了只信任 opaque frontend digest 的最后缺口。3 秒 fuzz 完成 33 次完整 snapshot 深层执行无失败；全仓 Go test/vet、Rust workspace test/clippy 与双层 diff 通过。OBJ-005 仍为 `Implementing`，runtime/CI 状态不变。
- checked-cast target admission 已移除对 diagnostic-only `TypeSnapshot.DebugText` 的依赖：现从唯一 `KindInterfaceDeclaration` 的 name identifier 定位 `HostValue`，验证 symbol declaration reverse edge，并要求 object type 的 symbol/payload scalar 绑定同一 identity。仅修改 DebugText 并重哈希 snapshot 不改变 semantic/layout cast；interface name、symbol declaration、type symbol substitution 均 fail closed。测试 clone helper 同时补齐 Symbols.Declarations 深拷贝，消除执行顺序污染。3 秒 fuzz 完成 44 次完整 snapshot 深层执行无失败；全仓 Go test/vet、Rust workspace test/clippy 与双层 diff 通过。状态、CI 和锁定 runtime 均不变。
- checked-cast canonical fact 审计继续收紧：matching/missing case 现从结构化 literal payload 的值段解析，不再把当前 TypeScript string-literal flags 数字当作 admission 常量；目标属性新增独立 provenance gate，绑定 object property list/fact、property symbol parent/type、唯一 `PropertySignature` declaration/valueDeclaration reverse edge、所属 `HostValue` interface、readonly getter-only data 形态及 canonical `number` read type。setter、property parent/declaration/read-type 重哈希替换均 fail closed；全仓 Go test/vet、Rust workspace test/clippy 与 diff 门禁通过。`OBJ-005` 仍为 `Implementing`，CI、锁定 runtime manifest 与 Linux/native evidence 状态均不变。
- checked-cast 首个用户可见 artifact boundary 已加入：`emit-checked-cast-replay --output FILE SNAPSHOT` 只接受 canonical frontend snapshot，以注入的 compiler identity 生成 self-contained replay v4，并通过 atomic no-clobber publisher 发布；双次独立生成逐字节一致，严格 decoder 可复验，已有目标、缺 identity 和非 checked-cast fixture 均 fail closed。审计同时修复 compiler provenance 闭包遗漏：`checked_object_cast_replay.go` 现进入 `PrimitiveLoweringHash` 的嵌入源码集合，reader 变化会使实现哈希变化。该命令不接收 runtime manifest、不发射 LLVM，也不赋予 `as`/`satisfies`/non-null 或新 intrinsic 运行时语义；ambient FFI declaration + artifact command 已是验收后的显式源码 provenance/用户边界，不再另造 TypeScript cast syntax。权威 interop runtime rebuild、positive binding 与 native evidence 仍待后续。全仓 Go test/vet、Rust test/clippy 与 diff 门禁通过，状态保持 `Implementing`，CI 不变。
- checked-cast artifact 现已接入 production consumer：`LowerCheckedObjectCastReplay`/`ExecuteCheckedObjectCastReplay` 严格解码 replay，绑定当前 compiler identity 和 BuildPlan frontend hash，再复用 snapshot lowering 的唯一 TargetContext/capability/backend 链；snapshot 与 artifact 在 Linux-tagged test 中都固定停在当前 static-only locked runtime profile gap，未伪造 positive binding。聚焦与全仓门禁通过，权威 interop manifest、positive binding 与 LLVM/ELF/native differential 仍待后续，`OBJ-005` 保持 `Implementing`，CI 不变。
- `OBJ-005` FunctionThunk 首个 target-independent substrate 已加入：canonical v1 contract 以嵌入 TypeRelationGraph 重算 target→source 的参数逆变路径和 source→target 的返回协变路径，冻结 `bingo.funcref.object.v1` calling convention、closure environment ABI 与 source-effects ⊆ target-effects；allocation/copy/runtime check/suspend/host entry 与 bivariant/不可靠捷径均不获准。方向、relation、effect、ABI/environment、隐式行为、unknown/stale/oversize substitution 全部 fail closed；3 秒 16-worker decoder fuzz 完成 40 次执行无失败。它尚未 materialize 为 frontend/HIR/MIR/LLVM thunk，因此不提升 `OBJ-005` 状态；全仓 Go test/vet、Rust test/clippy 与双层 diff 门禁通过，CI 保持关闭。
- FunctionThunk frontend provenance 已接通：新增 deterministic `functionthunk` fixture（body-resolved exported `source`/`target` 与 `adapted: typeof target = source`），replay v1 内嵌完整 snapshot，精确绑定 source/target signature declaration、Animal/Dog interface symbol/type、assignment contextual target 和 Dog→Animal base edge；ambient unknown/incomplete effect 方案明确拒绝。参数/返回/上下文/effect/base-edge 重哈希替换均 fail closed，3 秒 replay fuzz 完成 27 次完整 snapshot 执行无失败；全仓 Go test/vet、Rust test/clippy 与双层 diff 门禁通过。真实 thunk HIR/MIR/LLVM/differential 仍待后续，`OBJ-005` 与 CI 状态不变。
- FunctionThunk additive HIR v1 已 materialize 显式 wrapper：dense SSA 固定 `parameter.convert(Target→Source) -> source.call -> return.convert(Source→Target)`，两次转换携带 replay relation path 且无 effect，call 精确继承 source signature hash/effects，environment identity 保持。HIR reader 重建 ID/operand/type direction/path/callee/effect/return，self-contained replay join负责 frontend provenance；篡改矩阵与 3 秒 HIR decoder fuzz（22 次深层执行）通过。尚未选择 target-dependent FuncRef/MIR ABI 或发射 LLVM，故状态仍为 `Implementing`；全仓 Go test/vet、Rust test/clippy 与双层 diff 门禁通过，CI 不变。
- FunctionThunk target-dependent additive MIR v1 已加入：artifact 内嵌并验证 canonical HIR，content-bound target triple/DataLayout，冻结 object=`gc-ref` 与 FuncRef=`{code-ptr,gc-ref-or-null}`（code/environment index 0/1）；参数和返回 upcast 均为 relation-backed reference identity，不允许 bitcast/copy/allocation/runtime check，source call 绑定 exact signature/effects，当前 `read` fixture 明确无 safepoint，`allocate` effect 则进入 safepoint 标记。ABI、操作顺序、operand、callee、effect、representation、stale target identity、unknown/oversize substitution 均 fail closed；全仓 Go test/vet、Rust workspace test/clippy 与双层 diff 通过。LLVM wrapper、ELF/native differential 仍待完成，`OBJ-005` 保持 `Implementing`，CI 与 locked runtime manifest 均未改动。
- FunctionThunk backend 纵切已实现但 native evidence 尚待执行：canonical backend plan 固定 `bingo_function_thunk_object_v1`、零 runtime call/零 allocation，并在缺少 GC root plan 时拒绝任何 safepointing source call；LLVM20 Linux emitter 从 FuncRef 精确 extract code/environment，以 `(environment, target-object)` indirect call source 并原样返回 source object。Linux-tagged tests 已覆盖 O0/O2 verifier、ELF、C ABI harness、environment/object identity 与 Node differential，IR 明确禁止 bitcast/alloca/GC/malloc；当前 Windows host 启动 `wsl.exe` 返回系统无法访问，故这些 tagged tests 未在本机执行，不能记作 native 证据。backend decoder fuzz 3 秒完成 25 次深层执行无失败，CI 与 locked runtime manifest 未改，`OBJ-005` 保持 `Implementing`。
- `OBJ-006` 首个 admission substrate 已加入：独立 `PropertyAccessAdmission` schema v1 从 canonical object identity/key domain/profile 重算 direct/literal→PlaceRef、literal-union→finite dispatch、unknown+static→稳定拒绝、unknown+interop→显式 DynamicBoundary；dynamic result 绑定 source ID/effects，static 路径不允许 dynamic boundary。decision/effect/profile/key/boundary/unknown/oversize substitution 全部 fail closed，3 秒 decoder fuzz 完成 32 次执行无失败。尚未进入真实 frontend replay/HIR/MIR，状态保持下一增量，CI 与 locked runtime manifest 不变。
- `OBJ-006` 真实 frontend replay 已接通：新增 deterministic interop fixture，分别保存 `pair.left`、`pair["right"]`、`pair[key: "left"|"right"]` 与 `hostRecord()[key: string]`；checker-free replay v1 内嵌完整 snapshot，绑定四个 exported function/access node、receiver/key canonical type hash，并从 literal payload、union members和 declaration-only ambient `hostRecord` signature 重建四类 admission。dynamic 只允许 exact ambient host call receiver，普通宽 string key不获准；function/node/receiver/key/decision/order/unknown/oversize substitution均 fail closed，reader进入 `PrimitiveLoweringHash`。3 秒 deep replay fuzz完成44次无失败；HIR finite dispatch、DynamicValue/runtime/MIR仍待后续，`OBJ-006` 为 `Implementing`，CI与locked runtime manifest不变。
- `OBJ-006` additive HIR v1 已 materialize：direct/literal 固定 `receiver.eval→place.make→place.load`；literal-union 固定 `receiver.eval→key.eval→key.dispatch→two place.load.case→phi`；dynamic 固定 `host.call→key.eval→dynamic.boundary.enter→dynamic.property.load`，每步绑定 admission/boundary hash、keys、operands和effects。standalone HIR reader重建结构/content identity，replay→HIR join负责完整frontend provenance；operation/operand/key/boundary/effect/return/stale provenance/unknown/oversize均fail closed。3秒HIR decoder fuzz执行11,976次并发现13个new interesting inputs，无失败。DynamicValue/runtime ABI、target representation与MIR仍待后续，`OBJ-006`保持`Implementing`，CI与locked runtime manifest不变。
- `OBJ-006` target/runtime contract 首切已冻结但未发布 capability：独立 DynamicValue ABI v1固定16-byte/8-align `{tag:u32,reserved:u32,payload:u64}`，object payload是opaque host handle（不伪装GC ref），number保持binary64 bits，key为UTF-16 view；`bingo_dynamic_property_load_v1`契约为status-checked、可accessor/throw、不可隐式allocation。target-dependent MIR v1内嵌canonical HIR/ABI，绑定target/DataLayout并精确声明唯一`rt.dynamic.property_load`；bound MIR/context/catalog/symbol/signature gate已实现。审计决定在runtime worker完成前不把symbol写入generated `abi-v1.json`，防止authoritative rebuild误发布空能力；当前interop TargetContext/profile与catalog均应fail closed。ABI/MIR decoder fuzz 3秒分别23/28次无失败，`OBJ-006`保持`Implementing`，CI、locked runtime manifest/hash不变。
- `OBJ-006` runtime/backend 增量已落地：generated ABI schema现在真实包含16-byte DynamicValue、UTF-16 view和`bingo_dynamic_property_load_v1`，Rust worker使用单调不复用的authenticated host handle registry，reset使旧handle失效；data/accessor、missing key、forged/stale handle、reserved/tag、key length/null、wrong thread、out-param清零、NaN/-0 bits与status `6` accessor exception均有单测。Go ABI contract同步冻结exception status、canonical undefined result和v1无exception carrier；真实 interop replay已进入production replay→HIR→target-dependent unbound MIR，严格backend plan固定LLVM表示、唯一symbol/status contract，LLVM20 wrapper emitter已接入TargetMachine。现行locked static catalog的负例明确拒绝`rt.dynamic.property_load`，未修改CI、locked manifest/hash，也不声称positive binding或Linux native evidence；`OBJ-006`保持`Implementing`。
- `OBJ-006` interop handoff surface继续闭合：`ts2bin emit-property-access-replay` 以完整 frontend snapshot 生成可重读的canonical replay，确定性/no-clobber/missing identity/wrong-profile负例已覆盖；runtime新增仅供宿主适配的`bingo_host_number_record_register_v1`，批量复制UTF-16 key与number bits后才发布authenticated object handle，duplicate/null/oversize输入失败不消费token且清零输出。该注册入口不是编译产物的MIR capability；production dynamic load仍只声明`rt.dynamic.property_load`。新增Linux build脚本C smoke验证record注册、NaN/-0、missing key、duplicate与reset-stale handle，本机仅完成C11 header syntax check；未更新locked manifest/hash或CI，仍不声称Linux native evidence。
- `OBJ-006` binding/backend审计继续收紧：DynamicValue ABI现在携带按runtime-manifest同一canonical JSON算法重算的property-load signature hash，unbound MIR嵌入该身份，TargetContext binding要求catalog hash精确相等，bound MIR reader再次证明binding/hash一致并新增size-bounded strict decoder/fuzz；正确symbol配错误signature不再可能进入backend。LLVM20 wrapper的status检查改为具有可观察语义：成功原样保留runtime result，任意非零status再次写canonical undefined后返回原status，backend plan显式声明`clearsFailureResult`；Linux-tag O0/O2/ELF测试已编写但本机不声称执行证据。
- FunctionThunk production consumer 与 artifact boundary 已接通：`emit-function-thunk-replay --output FILE SNAPSHOT` 用 injected compiler identity 从唯一 canonical fixture snapshot 发布自包含 replay，双次生成确定且 no-clobber；`Lower/ExecuteFunctionThunk[Replay]` 严格 join replay/current compiler identity/canonical static BuildPlan frontend hash/observed TargetMachine，并产生 HIR→target-dependent MIR→backend plan→emission。错误 replay、compiler identity、BuildPlan、profile 和 nil machine 均 fail closed；Linux-tagged production test 覆盖 target/DataLayout/ELF/hash join，但本机 WSL 不可访问，未执行。纯 static thunk 不引入 runtime manifest/capability binding，CI 与 locked runtime manifest 未改，`OBJ-005` 继续 `Implementing`。
- `OBJ-006` 本机质量收尾补齐 C11 ABI 编译期断言：DynamicValue 固定 size=16/align=8 与 0/4/8 offsets，64-bit host 上 UTF-16 view 固定 size=16/align=8 与 0/8 offsets，host number property 固定 size=24/align=8 与 0/8/16 offsets；Linux LLVM tagged test新增合法 plan 的 DataLayout substitution 负例，要求 `TargetMachine` 在 object emission 前 fail closed。四个 strict decoder 各完成 3 秒 bounded fuzz，无崩溃或失败样本；全仓 Go test/vet、Rust workspace test/clippy、generator check、C syntax 与双层 diff 门禁通过。总体路线不调整：下一门槛是 authoritative Linux interop profile/runtime rebuild、真实 capability/hash catalog、positive binding、LLVM O0/O2/ELF/link/native/Node differential；在这些证据完成前 `OBJ-006` 保持 `Implementing`，CI 按负责人决定继续关闭且不提供 `Integrated` 证据。
- `OBJ-006` interop TargetContext 契约已接通：first-slice resolver 的 codegen domain 现显式允许 `static|interop`，但 runtime manifest、TargetContext 与 catalog 必须按 profile 绑定已发布的独立 authoritative manifest identity；当前身份表仍只有 static，完整重哈希的 interop manifest会稳定报“无 authoritative identity”，interop BuildPlan 配现有 static manifest则在 capability binding 前因 profile mismatch fail closed。production 新增 `ResolveAndBindPropertyAccess`，强制 unbound MIR 经 BuildPlan/frontend hash、observed TargetMachine、runtime manifest、TargetContext/catalog 的唯一 join 后才能生成 backend plan，不能以手写 context/catalog 绕过。profile/hash substitution、static rejection 和 Linux-tagged错误顺序回归已加入；Windows 全仓 Go test/vet、Rust workspace test/clippy/fmt、generator/C11/diff 门禁通过，Linux tagged测试仍待权威环境执行，状态与CI不变。
- `OBJ-006` deterministic unbound publication boundary 已加入：`emit-property-access-unbound --output-dir DIR SNAPSHOT` 要求真实 observed TargetMachine，从 canonical interop snapshot 生成固定四文件 `replay-v1.json`、`hir-v1.json`、`unbound-mir-v1.json`、`report.json`。strict report 重算 frontend/BuildPlan/replay/HIR/MIR/target/DataLayout identity，拒绝未知字段、stale hash、非十六进制 digest 和 artifact provenance substitution；publisher验证完整闭合文件集、existing-directory no-clobber并回滚部分发布。schema和文件集合刻意不存在 bound MIR、catalog/backend plan、LLVM IR或object字段，缺 authoritative interop manifest时不能用该命令冒充成功binding。Windows report/publisher/CLI package tests与vet通过，Linux-tagged真实命令测试已加入但尚未执行；状态与CI不变。
- `OBJ-006` runtime authoritative build 前置链已补齐：`write_runtime_manifest.py --profile static|interop` 以 static `first-slice-target.json` 为不可变基线，interop 仅通过 `first-slice-interop-overlay.json` 增加唯一 `rt.dynamic.property_load`（精确 symbol/signature/effects），并按 logical name 排序；interop 的 `targetManifestHash` 使用合并 profile manifest canonical hash，static 仍保持原始 target hash。`build-first-slice.sh` 在 dynamic C smoke 成功后用同一真实 archive/objects 分别写出 static 与 `runtime-manifest-interop.json`，不手工写入任何 hash。Python profile/unit、Rust、Go focused、C11 与 diff 门禁通过；Windows 无 bash/Linux，故 authoritative rebuild、manifest hashes、positive binding、ELF/native/Node 仍未声称，CI保持关闭。
- `OBJ-006` interop manifest consumer contract 已闭合到未发布身份门槛：Go validator按profile选择唯一 capability closure与target-manifest identity，static保持现有集合，interop在排序后的精确位置增加`rt.dynamic.property_load`/`bingo_dynamic_property_load_v1`/canonical DynamicValue signature/`call,read,throw` effects；runtime manifest与AvailableCapabilityCatalog共用同一closure定义，避免双白名单漂移。测试以真实locked static fixture构造完整重哈希的interop候选，证明正确结构通过所有source/schema/artifact/toolchain/capability检查后只因“无authoritative manifest identity”失败；missing/extra/symbol/signature/effect/order substitution均在此前拒绝。该项未填入archive/source/runtime hash，也未开放catalog positive binding；状态与CI不变。
- `OBJ-006` interop target identity 增加跨语言防漂移门禁：Go test直接读取runtime build实际使用的static baseline与interop overlay，按Python writer相同的profile替换、capability合并/排序与canonical JSON SHA-256规则重算，并锁定`InteropTargetManifestHash`；overlay、baseline或consumer常量任一侧漂移都会失败。Windows全仓Go test/vet、Rust workspace test/clippy/fmt、Python writer tests、ABI generator、C11 syntax与双层diff门禁通过；authoritative Linux runtime identity仍未发布，CI继续关闭，`OBJ-006`保持`Implementing`。
- `OBJ-005` explicit layout copy adapter 首个target-independent contract已实现：schema v1要求现有semantic planner独立给出`explicit-copy→copy-new-identity`，随后绑定source/target semantic contract、同一target的两份layout、canonical type-relation graph，并为每个target property冻结source load与target store的offset/representation和关系路径。首切只允许required public data，显式拒绝identity preservation、无allocation、accessor invocation、optional/private/protected、mixed target及mapping替换；strict decoder、unknown/oversize/stale hash、tamper matrix和fuzz entry已加入。该证据不包含HIR allocation/load/store顺序、GC roots、MIR/backend/native，`OBJ-005`保持`Implementing`，CI不变。
- `OBJ-005` layout copy additive HIR/GC increment已落地：HIR v1从canonical copy contract重建固定`object.copy.target.alloc→object.copy.source.load→object.copy.target.store`序列，目标分配结果为新identity；内嵌GCSafetyPlan证明source root在allocation safepoint前publish、后reload，引用representation在barrier-aware lowering前明确拒绝。HIR/GC strict decoder、operation/operand/offset/representation/effect/root/safepoint/trace substitution negatives、unknown/stale/oversize与3秒 fuzz已通过；尚未实现MIR、TargetContext/backend/LLVM/native，`OBJ-005`仍为`Implementing`，CI与locked runtime不变。
- `OBJ-005` layout copy target-dependent MIR/binding已闭合首轮：MIR v1从canonical HIR重建`gc.alloc.target(gc-ref,safepoint)→field.load.source(f64)→field.store.target(f64)`，绑定copy layout的triple/DataLayout和新target identity；bound artifact只闭合实际使用的`rt.gc.alloc`，同时绑定MIR、TargetContext、catalog及精确symbol/signature hash。TargetContext测试以真实locked static manifest/catalog完成正向`bingo_gc_alloc_v1` binding，并拒绝DataLayout替换；MIR/bound strict decoder、operation/binding替换和fuzz已加入。backend/LLVM/runtime harness/Node仍未实现，reference field仍在barrier lowering前拒绝，`OBJ-005`保持`Implementing`，CI与locked runtime不变。
- `OBJ-005` layout copy backend审计修复并推进LLVM接线：发现内嵌GC proof要求的frame/root runtime calls未进入原单一alloc binding，现bound closure按实际事件精确扩展为`alloc + frame.link/unlink + root.store/publish/reload`六项，禁止backend调用未绑定symbol。backend plan冻结target shape/layout、f64两侧offset、new identity、status-check与六call顺序；LLVM20 Linux emitter经TargetMachine接入，发布source root→alloc→reload source→load/store→unlink，禁止bitcast和冗余`rt.gc.safepoint`。默认构建focused test/vet通过，Linux tagged O0/ELF测试已加入但本机未执行，runtime harness/Node differential仍待完成；`OBJ-005`保持`Implementing`，CI不变。
- `OBJ-005` layout copy真实frontend与生产artifact边界已接通：新增static fixture以`source`与独立readonly `copy`对象字面量、复制后source mutation和`copy.value`返回证明observable new identity；checker-free replay内嵌完整canonical snapshot，绑定exact function/node/symbol/contextual readonly facts，并在strict decode时重建copy contract、HIR与MIR。`emit-object-layout-copy-replay --output FILE SNAPSHOT`按current compiler identity原子no-clobber发布确定性制品；production `LowerObjectLayoutCopy[Replay]`继续严格join exact static BuildPlan frontend hash、observed TargetMachine、locked TargetContext/catalog、bound MIR与backend plan。CLI双次byte-identical、已有输出、缺identity、错误fixture和tamper均fail closed；全仓Go test/vet与双层diff门禁通过。runtime harness、Node differential和Linux authoritative LLVM/ELF/native证据仍待完成，故`OBJ-005`保持`Implementing`，CI继续关闭且不提供`Integrated`证据。
- `OBJ-005` layout copy native boundary 已补齐：新增 C11 harness 通过 `bingo_gc_alloc_v1` 分配 source，调用 `bingo_object_layout_copy_v1` 后修改 source 并验证 target identity 与 payload bits；Node oracle 新增同语义 `copy !== source` 脚本及输入校验/脚本 hash。Linux-tagged LLVM test 会把 emitted ELF object、harness 与现有 runtime archive 链接，覆盖 zero、negative-zero、normal、infinity 和 NaN bits 的 native/Node differential；本机 Windows 仅完成 C syntax、Go test/vet，未执行 Linux tagged native 证据，CI 与 locked manifest/hash 不变。
- `OBJ-005` layout copy artifact/pipeline quality gate 收紧：strict replay reader 现重新执行完整 frontend snapshot validator 与 compiler provenance join，evidence 字段使用显式稳定 JSON 名称，并拒绝 unknown、oversize、frontend-hash 与深层 snapshot/artifact substitution；3 秒 16-worker decoder fuzz 完成 33 次完整 replay 执行无失败。production consumer 将 current compiler identity、BuildPlan frontend hash、static profile 与 nil TargetMachine 拆为独立 fail-closed gate，负例矩阵全部通过；状态、CI、runtime manifest/hash 均不变。
- `OBJ-005` layout copy O2 preservation gate 已补到真实 emitter 模块：Linux-tagged test 在原始 IR 与 `default<O2>` 后分别 verify，要求六个 bound GC call 按 `frame.link→root.store→root.publish→alloc→root.reload→frame.unlink` 执行顺序保留，且 f64 load/store 数据路径仍存在；bitcast 与冗余显式 safepoint 继续禁止。该测试不是通用 GC litmus 的替代证明，但当前 Windows host 仍无法执行 Linux+cgo+LLVM tagged suite，故只记录测试接线，不记录 O2/native 实测通过。

## 2026-08-12 Phase 3 Linux migration handoff

- Windows 阶段已按三批提交：`typescript-go` `2ef21cd2f`、runtime `c0364eb`、父仓库文档/lock/gitlink `d7229db`；父仓库与子模块 clean，gitlink、submodule HEAD 与 lockfile 一致。
- 新增 [Phase 3 Linux development handoff](plans/phase3-linux-handoff-2026-08-12.md)，冻结工具链、bootstrap、baseline gates、producer-driven authoritative rebuild、`OBJ-003b -> OBJ-005 -> OBJ-006` 关闭顺序、RT-003a/MOD/EH 后续路线和分批提交纪律。
- 不再在 Windows 启动新的 RT-003a 代码纵切。Linux 首项必须运行真实 runtime producer，禁止手工更新 manifest/hash；CI 仍关闭，迁移与本地 Linux 证据不构成 `Integrated`。
