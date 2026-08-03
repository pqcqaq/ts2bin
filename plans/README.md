# ts2bin 设计文档

本目录定义 `TypeScript -> Bingo -> LLVM` 编译链的目标、边界和实施顺序。它不是 TypeScript 语法手册的重复版本；`handbook/` 负责解释语法，本目录负责回答“哪些语法能编译、如何保留语义、何时拒绝、如何验证”。

## 推荐阅读顺序

1. [architecture.md](architecture.md)：总体架构、编译边界、Bingo IR、运行时与类型语义。
2. [tsgo-integration.md](tsgo-integration.md)：本地 `typescript-go` 的版本锁定、Program/checker 生命周期、快照和模块图契约。
3. [typescript-support-matrix.md](typescript-support-matrix.md)：按 AST Kind、语义行为和 profile 划分支持、消糖、运行时和拒绝规则。
4. [bingo-ir-spec.md](bingo-ir-spec.md)：Typed Snapshot 之后的 HIR/MIR 类型、指令、effect、unsafe provenance 与 verifier。
5. [stdlib-runtime-plan.md](stdlib-runtime-plan.md)：`handbook/stdlib` 与 `typescript-go` 内置 `.d.ts` 到 capability manifest、runtime ABI 和 GC 的映射。
6. [development-roadmap.md](development-roadmap.md)：六阶段实施顺序、依赖、交付物、验收门槛和 issue 分组。
7. [testing-conformance-and-release.md](testing-conformance-and-release.md)：测试资产、差分/fuzz、标准库覆盖、CI、缓存和发布门禁。
8. [implementation-backlog.md](implementation-backlog.md)：可直接创建 issue 的编号、依赖、验收命令和第一条纵向实现路径。
9. [compiler-development-process.md](compiler-development-process.md)：从 issue 分诊、设计、实现、自审、审计到合并和发布的强制流程。
10. [coding-and-maintainability-standards.md](coding-and-maintainability-standards.md)：抽象准入、核心流程注释、公共 API 文档、错误和生命周期规范。
11. [test-authoring-standards.md](test-authoring-standards.md)：测试库、fixture、golden、独立性、乱序/并发/重复运行规范。
12. [git-and-commit-standards.md](git-and-commit-standards.md)：父仓库/submodule、分支、提交消息、合并和发布标签规范。

建议的阅读方式是先读架构确定边界，再读 tsgo 集成和支持矩阵锁定输入；实现 HIR/MIR 时以 IR 规格为唯一约束；进入 runtime 或 LLVM 阶段前，必须同时满足标准库 capability 和测试发布文档的门禁。

## 一句话方案

```text
TypeScript source
  -> typescript-go Program + Checker
  -> immutable typed AST snapshot
  -> subset gate and diagnostics
  -> Bingo HIR (TypeScript semantics preserved)
  -> Bingo MIR (explicit control flow, layout, conversions, cleanup)
  -> LLVM IR
  -> LLVM verifier / passes / target machine / linker
```

关键决策：

- 不把 `typescript-go` AST 直接当作 Bingo IR。AST 是语法树，Bingo HIR 必须包含解析后的符号、类型、重载选择、控制流和运行时表示。
- 不在 HIR 阶段过早执行 LLVM 化。联合类型、泛型、闭包、异常、异步和资源清理需要先完成语义 lowering。
- 默认编译一个“静态可验证 TypeScript 子集”；`any`、动态对象和 JavaScript 反射通过显式 `dynamic` 配置隔离，不能悄悄扩大语义。
- 生产后端优先使用 `tinygo.org/x/go-llvm` 绑定真实 LLVM；`github.com/llir/llvm` 仅作为无 LLVM 环境下的 IR 文本测试或离线工具。
- 当前 `typescript-go` 的公开 API 尚未就绪，且核心包位于 `internal/`。第一阶段应维护一个薄 fork，将 `cmd/ts2bin` 和适配层放在 `github.com/microsoft/typescript-go` 模块内部。
- checker 只能在独占借用期间访问，并且每次借用都必须调用 release；snapshot 不得持有 checker、Type 或 Signature 指针。
- `.d.ts` 只提供编译期声明，不等于目标产物存在实现；所有运行时调用必须通过版本化 capability manifest 和 ABI 闭包检查。
- 普通 TypeScript 对象允许循环引用，general static profile 默认使用非移动 tracing GC；ARC/arena 只能作为有额外可证明约束的受限 profile。
- `Array<T>` 的可变元素默认不变，`ReadonlyArray<T>` 和只读字段才允许协变；tsgo 的历史兼容性结果不能直接当作 Bingo 布局安全证明。

## 交付物与唯一事实来源

| 工程问题 | 唯一事实来源 | 生成/验证产物 |
| --- | --- | --- |
| tsgo 解析、类型和模块结果 | `tsgo-integration.md` + 锁定 commit | `ProgramSnapshot`、AST Kind manifest、snapshot golden |
| 哪些 TS 语法可以进入编译链 | `typescript-support-matrix.md` | subset gate、BINGO 诊断和语法覆盖报告 |
| HIR/MIR 的类型和控制流不变量 | `bingo-ir-spec.md` | IR schema、verifier、HIR/MIR golden |
| ES 标准库和宿主 API 是否可链接 | `stdlib-runtime-plan.md` | capability manifest、ABI hash、runtime tests |
| 何时算完成、如何回归和发布 | `testing-conformance-and-release.md` | case manifest、差分报告、CI/reproducibility 报告 |
| 如何拆 issue 并安排第一条纵切 | `implementation-backlog.md` | 稳定 issue ID、依赖 DAG、阶段退出命令 |
| 如何执行开发、审计和发布 | `compiler-development-process.md` | 状态机、变更/审计等级、审计记录和回滚规则 |
| 如何保证代码可读和可维护 | `coding-and-maintainability-standards.md` | 抽象准入、注释/API 文档、依赖方向、可读性审计 |
| 如何编写完全独立的测试 | `test-authoring-standards.md` | case manifest、隔离 workspace、golden、乱序/race/重复门禁 |
| 如何组织 Git 历史和 submodule | `git-and-commit-standards.md` | 分支/提交格式、gitlink、合并、标签和回滚 |

如果不同文档出现冲突，以更低层且可执行的契约为准：IR verifier 高于架构叙述，capability manifest 高于 `.d.ts` 声明，锁定的 tsgo snapshot schema 高于上游私有对象布局。

## 源码审计基线

- 前端模块：`typescript-go/internal/parser`、`internal/ast`、`internal/compiler`、`internal/checker`。
- 解析入口：`parser.ParseSourceFile`。
- 程序/文件/诊断入口：`compiler.NewProgram`、`Program.GetSourceFiles`、各类 syntactic/bind/semantic diagnostics。
- 语义查询：`Checker.GetTypeAtLocation`、`GetSymbolAtLocation`、`GetResolvedSignature`、`GetPropertiesOfType`、`GetTypeArguments`、`IsTypeAssignableTo` 等。
- 节点基线：`typescript-go/internal/ast/kind_generated.go`；它覆盖 JS/TS、JSX、JSDoc 和合成节点。
- 既有 transformer（async、class fields、decorator、for-await、optional chain、object spread、using、JSX、module 等）只作为语义差分测试的 oracle，不作为 Bingo IR 生成器。

## 文档中的支持级别

| 标记 | 含义 |
| --- | --- |
| S0 | 第一版静态子集直接支持，必须有 golden IR 和运行测试 |
| S1 | 前端消糖后进入 S0，源语法本身不保留到 HIR |
| S2 | 需要 Bingo runtime ABI 或专门状态机，按路线图阶段加入 |
| C | 仅编译期语义，检查后擦除，不产生运行时值 |
| P | 设计已确定但暂缓实现，必须有 feature gate |
| R | 默认编译期拒绝；只有明确的动态/不安全配置才可另行实现 |
