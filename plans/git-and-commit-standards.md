# ts2bin Git 与提交规范

本文规定父仓库、typescript-go submodule、Rust runtime、分支、提交、变更集和发布标签的使用方式。目标是让每个提交可审查、可回滚、可二分，并能准确还原 tsgo、标准库、Bingo schema、Rust runtime、runtime ABI 和 LLVM 版本组合。

当前父仓库刚初始化，尚无历史提交可供模仿；在首个提交建立后，后续提交必须先检查历史风格，再遵循本文件和仓库已有约定。`typescript-go` 是独立 fork 仓库，不在父仓库内直接提交其源码修改；上游变化通过 fork 内的显式 merge 纳入。

## 1. 仓库关系

~~~text
ts2bin (parent repository)
  .gitmodules
  typescript-go -> github.com/pqcqaq/typescript-go.git (gitlink)
  handbook/
  plans/
  task_plan.md / findings.md / progress.md
~~~

规则：

- 父仓库提交的是 typescript-go 的 gitlink SHA，不提交其文件内容。
- tsgo 源码修改必须在 `pqcqaq/typescript-go` fork 的独立分支中完成；父仓库只更新 submodule 指针，并在提交正文记录 fork SHA、reviewed upstream SHA、原因和兼容性结果。
- 更新 submodule 前必须确认子仓库工作树干净；禁止用 git add -f 把子仓库文件提升到父仓库。
- git submodule status、git diff --submodule=log 和子仓库 git status 是 submodule 变更的必查证据。
- 构建和发布必须使用 lock 文件、submodule SHA 和 stdlib manifest hash，不能依赖开发机当前 checkout 的模糊分支。
- Rust runtime 必须锁定 `rust-toolchain.toml`、`Cargo.lock`、Cargo features、target 和 archive digests；runtime source、生成 header/layout/capability 和锁文件应作为一个可审计变更闭包。

## 2. 分支规范

分支名称使用小写、短横线和 issue ID：

~~~text
feat/FE-003-program-snapshot
fix/IR-005-mir-verifier
test/REL-003-cleanup-fuzz
docs/process-and-commit-standards
deps/UP-001-tsgo-12318e5
release/v0.1.0
hotfix/runtime-abi-1
~~~

规则：

- 一条分支只服务一个主 issue；跨阶段依赖必须在 issue 中声明。
- main 只接受通过相应审计和 CI 的变更，不直接在 main 上开发。
- deps/*、release/*、hotfix/* 需要额外记录 lock、ABI、回滚和发布影响。
- 分支合并前同步最新 main，解决冲突后重新运行受影响的全部门禁；不能只重跑失败的单测。
- 分支名不能包含机器名、日期随机串或个人缩写，避免无法追溯。

## 3. 提交消息格式

采用 Conventional Commits 风格，首行使用英文、现在时态、无句号：

~~~text
<type>(<scope>): <imperative summary>

<body>

Refs: <issue-id>
Test: <commands or manifest>
Audit: <audit-level and record>
~~~

允许的 type：

| type | 用途 |
| --- | --- |
| feat | 新增编译能力、runtime capability 或 CLI 能力 |
| fix | 修复已确认的编译器、runtime、测试或工具 bug |
| refactor | 不改变 observable behavior 的结构调整 |
| test | 新增或修正测试、fixture、fuzz、oracle |
| docs | 设计、开发、API、审计或用户文档 |
| build | Go/Node/LLVM 构建依赖和生成流程 |
| ci | CI、缓存、平台矩阵和发布自动化 |
| perf | 有基准证据的性能改进 |
| chore | 不改变语义的维护工作 |
| revert | 回滚已有提交 |

推荐 scope：frontend、snapshot、ast2bingo、hir、mir、verify、runtime、stdlib、llvm、cli、test、docs、release、deps。

合格示例：

~~~text
feat(frontend): capture stable type snapshots

Keep checker pointers inside the exclusive borrow and release them before
parallel lowering. Add deterministic IDs and snapshot golden coverage.

Refs: FE-003
Test: go test ./internal/tsfrontend/...; ts2bin snapshot --verify-determinism ...
Audit: A2 implementation audit
~~~

不合格示例：

~~~text
update
fix stuff
refactor everything
随便改改
~~~

### 3.1 提交正文要求

- 首行只说明一个主变化；不要把“新增功能 + 升级 tsgo + 格式化全仓库”放在一个提交中。
- 正文说明为什么改、保持了什么语义、拒绝了什么方案、有哪些兼容性影响。
- 必须列出实际测试命令；不能写“测试通过”而没有命令或 case manifest。
- D2 以上写 schema/diagnostic/capability/golden 影响；D3/D4 额外写 ABI、target、GC、异常、LLVM 或 lock 影响。
- BREAKING CHANGE: 只用于明确的不兼容行为，并附迁移方案；不能用普通正文掩盖破坏性变化。
- 不在提交消息中写未经验证的性能或安全承诺。

### 3.2 提交粒度

一个提交应当能够独立构建、测试或被明确标记为文档/基础设施提交。推荐顺序：

~~~text
docs/design -> test/fixtures -> implementation -> verifier/runtime -> integration
~~~

允许测试和实现同一提交，尤其是修复 bug 时；但 generated manifest、golden 和代码必须在同一语义变更提交中同步。不要提交“先破坏 main、下一提交再修”的半成品，除非 issue 明确是分阶段迁移且每一步有兼容门禁。

## 4. 提交前检查

提交前必须按顺序执行：

~~~text
git status --short --branch
git diff --stat
git diff --check
git diff -- <scoped-files>
git submodule status
git -C typescript-go status --short --branch
go test ./...
ts2bin test --stage <affected-stage>
~~~

涉及 LLVM、runtime、schema 或 lock 时追加 doctor、verifier、差分、跨平台或 reproducibility 命令。提交前检查：

- 只包含 issue 范围内文件；无临时日志、二进制、个人配置、未审计生成物。
- submodule 指针确实是预期 SHA；子仓库没有未提交修改。
- 没有误把 submodule 内容当成父仓库普通文件。
- 文档、代码注释、manifest、golden 和版本号保持一致。
- 提交前检查历史风格：若已有历史，运行 git log -10 --oneline 和 git log -10 --format=fuller；首个提交建立风格后，后续必须对齐。

## 5. Submodule 更新流程

### 5.1 合并上游提交到 fork

~~~powershell
.\scripts\merge-typescript-go-upstream.ps1
git -C typescript-go status --short --branch
git submodule status
git diff --submodule=log
~~~

合并必须发生在 clean fork branch，保留可审计的 upstream merge ancestry。解决冲突并提交 fork 后，运行 [compiler-development-process.md](compiler-development-process.md) 的上游升级审计，更新 `ts2bin.lock.json` 的 reviewed upstream/fork commits、stdlib manifest 和相关 snapshot/conformance 报告；`verify-typescript-go-fork.ps1` 通过后再在父仓库提交 gitlink。

### 5.2 需要修改 tsgo 源码

1. 在 `pqcqaq/typescript-go` fork 分支记录修改和上游 issue。
2. 先运行 tsgo 自身测试和 API/Kind/snapshot 兼容性检查。
3. 父仓库只引用该 fork 的明确 commit，并在提交正文写明 fork 变更范围与 reviewed upstream ancestor。
4. 禁止直接在父仓库 submodule 目录内留下未提交改动作为“本地依赖”。
5. 禁止恢复已退役的 patch/materialize/apply 交付路径；需要修改时必须先形成可获取的 fork commit。

### 5.3 回滚 submodule

回滚必须同时恢复：submodule SHA、stdlib manifest、snapshot schema、runtime ABI、LLVM/cache provenance。只回退 gitlink 而不回退其他版本输入，会产生无法解释的构建结果。

## 6. 合并策略

- 代码审查前先通过作者自审和对应 A 等级审计。
- 小而完整的提交优先 fast-forward/rebase 合并，确保 git bisect 的每个候选点可解释。
- 工作分支中的临时修复在合并前应整理；若保留多个提交，必须每个提交有清晰类型和测试。
- 不使用无意义的“大合并提交”掩盖上游升级、生成文件变化或行为差异。
- squash 只有在维护者确认不会损失审计证据、回滚边界和 issue 追踪时才使用。
- 合并过程中若有额外修改，必须重新运行门禁，不能沿用过期测试结论。

## 7. 版本标签与发布提交

发布提交必须包含：

- ts2bin 版本、submodule SHA、stdlib manifest hash、Bingo schema、runtime ABI 和 LLVM major。
- Rust toolchain、Cargo.lock/features、每个 target/profile runtime archive digest 和 LLD version。
- static/dynamic/experimental profile 列表及能力差异。
- conformance、differential、LLVM verifier、目标平台和 reproducible build 报告。
- 已知限制、迁移说明、回滚版本和安全公告（如适用）。

标签建议：

~~~text
v0.1.0-alpha.1
v0.1.0-beta.1
v0.1.0
~~~

发布标签只指向通过 A4 release audit 的提交；不能在未提交的工作树或浮动 submodule 分支上打标签。

## 8. 违规处理

- 提交混入无关文件：拆分或重做提交，不用审查者手工猜测范围。
- 测试命令缺失：退回 SelfAudited，补齐命令和结果。
- submodule 未锁定或有本地改动：阻断合并。
- 提交消息无法说明 ABI/schema/lock 影响：D2 以上退回补写。
- 发现历史提交已含错误事实：追加修复提交并在 issue 中说明，不重写公共历史，除非仓库维护者明确批准。

## 9. 提交完成定义

提交只有在以下条件全部满足时才算完成：

1. 分支、issue、scope 和变更等级明确。
2. 提交消息符合格式，正文包含原因、测试、审计和兼容性信息。
3. git diff --check、相关测试、verifier、manifest 和文档检查通过。
4. submodule SHA、父仓库 gitlink 和 lock/provenance 一致。
5. 提交可独立解释、可定位、可回滚，并且没有将临时实现伪装成稳定 API。
