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
- 下一顺序固定为 `IR-008a -> RT-002b + BE-002a -> BE-004a -> REL-001a -> VERT-001 -> REL-002a`。`VERT-001` 是第一个 Linux x86-64 可执行文件；真实自举仍需 Phase 2B 的变量、调用、控制流、模块和最小 self-hosted stdlib contract。
