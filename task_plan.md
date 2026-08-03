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
