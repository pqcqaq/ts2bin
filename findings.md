# 资料与发现

## 环境

- 工作目录：`D:\Develop\git\ts2bin`。
- 当前父仓库位于 `main`，审计时 HEAD 为 `5f44799d9f6c1fa0770f26dcd811180f9afa721b`，已有 5 个提交且与 `origin/main` 对齐。
- Node.js：`v22.22.0`；Go：`1.26.0`；Rust：`1.97.1`。
- npm registry 当前 TypeScript 稳定版：`7.0.2`（查询日期：2026-08-03）。
- `typescript-go/` 已作为 Git submodule 纳入父仓库；当前 parent gitlink 指向上游 `12318e599d21f516defea3b20e5d44b9369da723`，内部版本为 `7.1.0-dev`。二次审计后的 dirty/untracked 实现已重新生成 binary patch，lock hash 与 doctor materialized-exact 一致，official remote isolated full test/vet/cleanup 已通过；只有从包含这些交付物的 parent HEAD clean clone 复验后，`FND-004` 才能关闭。
- 直接执行 `npx tsc` 会命中 npm 上名为 `tsc` 的占位包，校验应使用 `npx -p typescript@latest tsc` 或项目本地依赖。

## 官方资料

- 官方仓库：`microsoft/TypeScript-Website`，稀疏浅克隆到系统临时目录。
- 参考提交：`c8170c35bda4811c9516cbb69c39241ae4beb6d9`，提交时间 `2026-07-06T18:03:25Z`。
- 核心来源目录：Handbook v2、Reference、Declaration Files、Release Notes、TSConfig Reference。
- 官方发布说明当前收录至 TypeScript 6.0；npm registry 的 `typescript` 最新稳定包为 7.0.2。语言手册需明确资料基线，并对编译器可接受的现代语法额外实测。

## 覆盖清单

- Handbook 主线：基础、日常类型、收窄、函数、对象、类型构造、类、模块。
- Reference 补充：变量声明、枚举、符号、迭代器/生成器、JSX、命名空间、声明合并、类型兼容/推断、工具类型、三斜线指令。
- 声明文件：模块/全局声明、发布与使用、常见模板。
- 发布说明：筛出现代语法与类型系统特性，避免把纯编辑器或性能更新混入语法手册。
- 现代语法重点：可变/具名元组、模板字面量类型、映射类型键重映射、`override`、类静态块、`satisfies`、标准装饰器、`const` 类型参数、`using`/`await using`、导入属性、`NoInfer`、任意模块标识符、`import defer`。
- TypeScript 6.0 主要涉及默认值、弃用项和运行库类型变化；官方发布说明另有“Preparing for TypeScript 7.0”。
- 旧版实验性装饰器与 TypeScript 5.0 起的标准装饰器语义不同，文档必须分开说明。
- TypeScript 5.8 的 `erasableSyntaxOnly` 会限制会生成运行时代码的 TS 专属语法，适合单独提示。

## typescript-go 标准库

- ECMAScript 库声明位于 `typescript-go/internal/bundled/libs/`。
- 当前库集合覆盖 ES5、ES2015–ES2025 与 ESNext，并包含 decorators、disposable、Temporal、Float16、iterator helpers 等分项声明。
- `lib.dom*`、`lib.webworker*`、`lib.scripthost.d.ts` 是宿主环境 API，不属于 ECMAScript 语言标准；本任务的“ES 内置类型”不把它们混入标准库清单。
- `_submodules/TypeScript` 当前未初始化（`git submodule status` 前缀为 `-`），但 `internal/bundled/libs/` 已包含编译器实际捆绑的完整声明，可直接作为基线。
- 当前锁定的 `typescript-go 7.1.0-dev` README 表示 program/parsing/type checking 的兼容目标仍是 TypeScript 6.0；因此不能从原生端版本号推断新的 7.x 语言语法。项目基线同时锁定 commit、stdlib hash 和 `FE-007` semantic fixtures，不能只依赖这句 README 声明。
- TypeScript 6.0 默认值：`strict: true`、`module: esnext`、`target` 浮动到最新受支持 ES（当时为 ES2025）、`noUncheckedSideEffectImports: true`、`libReplacement: false`。
- TypeScript 6.0 中 `rootDir` 默认改为配置文件目录，`types` 默认改为 `[]`；7.0 原生端会移除 6.0 已弃用的旧选项。
- 实际 `lib.es*` 功能声明共覆盖 ES5、ES2015–ES2025 和 ESNext 分项；聚合 `lib.es20xx.d.ts`/`full` 文件主要用三斜线引用，不应重复统计。
- ES2025 分项包含 Set 组合方法、`Float16Array`/DataView float16、Iterator Helpers、Promise 新方法、RegExp 新能力和 Intl；ESNext 还包含集合 upsert、Array `fromAsync`、Disposable、Temporal、共享内存/TypedArray/Date/Error/Intl 前沿声明。
- 系统可直接调用 `tsc`，但结构化索引仍以 `typescript-go` 的声明文件为输入，避免 npm 包与本地仓库漂移。
- ES2025 Iterator Helpers：`map`、`filter`、`take`、`drop`、`flatMap`、`reduce`、`toArray`、`forEach`、`some`、`every`、`find`，以及 `Iterator.from`。
- ES2025 Set 组合：`union`、`intersection`、`difference`、`symmetricDifference`、`isSubsetOf`、`isSupersetOf`、`isDisjointFrom`。
- ES2025 还包含 `Promise.try`、`RegExp.escape`、`Float16Array`、`Math.f16round`、DataView float16 读写与 `Intl.DurationFormat`。
- ESNext 前沿声明包含 `Array.fromAsync`、Map/WeakMap `getOrInsert*`、`Date#toTemporalInstant`、`Error.isError`、`Atomics.pause`、Uint8Array Base64/Hex 编解码，以及完整 `Temporal` 对象族。
- API 索引核对：`Math` 当前含 ES5 基础函数、ES2015 双曲/整数/对数扩展和 ES2025 `f16round`；`ObjectConstructor` 含 `groupBy`、`hasOwn` 等现代静态方法；`String` 含 `matchAll`、`replaceAll`、`at`、`isWellFormed`/`toWellFormed`。
- `Temporal` 声明包含 `Now.timeZoneId/instant/plainDateTimeISO/zonedDateTimeISO/plainDateISO/plainTimeISO`，以及 PlainDate、PlainTime、PlainDateTime、ZonedDateTime、Duration、Instant、PlainYearMonth、PlainMonthDay 八类对象和对应 `from/compare` 构造器。

## 最终交付

- 17 个 TypeScript 语法/工程章节。
- 7 个 ECMAScript 标准库分组章节 + 1 个入口 + 1 个 AST 生成的完整 API 索引。
- 24 个严格模式 TypeScript/TSX 示例。
- 完整索引统计：81 个实际声明分项、314 个声明类型、103 个全局/命名空间值签名、2173 条成员签名。

## ts2bin 编译链设计任务（2026-08-04）

- 用户目标管线：`TypeScript -> tsgo AST -> Bingo IR -> LLVM IR -> LLVM toolchain`。
- 本轮需要审计完整 TypeScript 语法/语义并给出六阶段 `ast2bingo` 实现路线。
- 必须显式区分：直接降低、前端消糖、运行时库支持、暂缓支持、编译期拒绝。
- 重点语义包括不可靠类型断言、结构化类型、泛型实例化策略、协变/逆变、闭包、异常、异步、模块与 JavaScript 动态对象模型。
- 本地仓库位于 `typescript-go/`，当前包含 `internal/ast`、`internal/parser`、`internal/checker`、`internal/compiler`、`internal/transformers` 等完整前端组件。
- 解析入口为 `internal/parser.ParseSourceFile`；程序入口通过 `internal/compiler.NewProgram`，类型检查器通过 `internal/checker.NewChecker`。
- AST 主要由 `internal/ast/ast.go` 与生成文件 `ast_generated.go`/`kind_generated.go` 定义；不能假设它与 TypeScript npm 编译器的对象布局相同，应通过稳定的适配层访问。
- `typescript-go` 内置 transformer/emitter 主要服务 TypeScript 的 JavaScript 发射，不应直接作为 Bingo IR；需要独立的语义 lowering，避免把 JS emitter 的运行时假设泄漏到 Bingo。
- `typescript-go/go.mod` 的模块路径是 `github.com/microsoft/typescript-go`，且 README 明确标注公开 API “not ready”；独立 sibling module 无法合法导入其 `internal/*`。
- 推荐集成方式是维护一个薄 fork：将 `cmd/ts2bin`、`internal/bingo` 和 `internal/ast2bingo` 放在该模块内部；尽量不修改 parser/checker 核心，并以小型适配层隔离上游变动。
- `cmd/tsgo api` 当前是内部 JSON-RPC/MessagePack 服务，但公开状态仍未就绪，且现有协议主要面向编译/语言服务，不足以稳定输出完整 typed AST；不宜把它作为第一版后端接口。
- checker 已提供大量包内可调用的语义查询：`GetTypeAtLocation`、`GetSymbolAtLocation`、`GetResolvedSignature`、`GetTypeOfSymbol`、`GetPropertiesOfType`、`GetBaseTypes`、`GetTypeArguments`、`IsTypeAssignableTo` 等，可支持 typed lowering。
- AST `Kind` 覆盖完整 JS/TS token、type node、expression、statement、declaration 和 JSX/JSDoc 节点；支持矩阵可以以 `kind_generated.go` 为审计基线。
- AST `Node` 提供 `Kind`、位置、父节点和 `IterChildren`/`ForEachChild`，适合只读遍历；typed lowering 应建立自己的 visitor/context，不应复用会改写 TS AST 的 emitter visitor 作为 IR builder。
- `compiler.Program` 可获取源文件与全部语法/绑定/语义诊断，也能按文件获取 checker；正确入口是“全部 TS 诊断通过 + ts2bin 子集诊断通过”后才 lower。
- checker 内部已实现 `Invariant/Covariant/Contravariant/Bivariant/Independent`，并标记 `Unmeasurable/Unreliable`；可以作为源语言兼容信息，但 Bingo 必须再做一次布局与可调用性安全验证。
- tsgo 当前把 `Array<T>` 按协变处理，源码注释明确称其为“pretend array is covariant”。静态本机编译不能照搬这一不健全行为：可变数组应在 Bingo 中不变，`ReadonlyArray<T>` 才可协变；兼容赋值需要复制/适配或拒绝。
- 现有 transformer 已覆盖 async、class fields、decorators、for-await、logical assignment、nullish、object rest/spread、optional chain、tagged template、using、JSX、module、const enum 等，可作为消糖语义的测试 oracle，但不直接复用其 JS 输出 AST。

## ts2bin 文档完善任务（2026-08-04）

- 现有 `handbook/` 已有 17 个语法/工程章节、组合用法、tsconfig、标准库 7 个分组和 `stdlib/99-api-index.md` 完整成员索引；新设计应引用其章节作为输入契约，而不是重新抄语法。
- `typescript-go/internal/compiler/emitter.go` 的 transformer 顺序包含 type erasure、import elision、runtime syntax、legacy decorators、JSX、ES downlevel、module 和 const enum；这可以成为 lowering 行为的分层 oracle。
- `typescript-go` 当前 README 将 API 标为 not ready，因此必须补充具体的 fork 内 facade、版本锁定和上游变更检测计划。
- `compiler.Program` 提供 `GetSourceFiles`、syntactic/bind/semantic/global diagnostics 和按文件 `GetTypeCheckerForFile`；snapshot builder 可按文件组织，但必须遵守 checker pool 生命周期。
- `CheckerPool.GetChecker` 返回 release 函数且 checker 不允许并发访问；每次获取都具有独占性。ast2bingo 必须 `defer done()`，不能把 checker 指针塞入并行 HIR 任务。
- 默认 checker pool 为 4 个（受 `Checkers`、单线程和文件数约束），文件会稳定关联到 checker；适配层可以按 checker 分组构建 snapshot，再脱离 checker 并行 lower。
- `tsoptions` 已定义 target -> 默认 lib 映射、ES5–ES2025/ESNext target、ESM/CommonJS/Node/Preserve module、JSX 与 strict/isolated/useDefineForClassFields 等选项。ts2bin 需区分“影响前端语义的 TS 选项”和“只影响 JS emit、应由 Bingo profile 接管的选项”。
- `handbook/stdlib` 明确指出 `.d.ts lib` 只描述 API，不提供 polyfill；ts2bin 必须引入 runtime capability manifest，不能因为类型声明存在就假定 runtime 已实现。
- tsgo 配置/Program 的具体构造链可用 `ParseConfigFileTextToJson` -> `ParseJsonSourceFileConfigFileContent`/`ParseJsonConfigFileContent` -> `NewCompilerHost` -> `NewProgram(ProgramOptions)`；设计文档应把这条链固化在 facade 内。
- `SourceFile.FileName()` 要求规范化绝对路径；快照的 FileId/ModuleId 必须基于 canonical path，而不是原始 import 文本。
- `Program` 可提供每个文件的实际 module format、usage resolution mode 和 resolved module；ModuleGraph 应复用这些结果，不能另写一套 Node/ESM 解析器。
- checker `Type` 有稳定的 `Id/Flags/ObjectFlags/Symbol/Alias` 访问器，Signature 有 `Id/Flags/TypeParameters/Parameters/ThisParameter/MinArgumentCount`；snapshot 应复制这些公开信息并给自己的稳定 ID，避免持有内部 type data。
- binder/checker 的 flow graph 包含 assignment、call、condition、switch、branch、loop、array mutation、reduce/start/unreachable 等节点；Bingo 不应序列化内部 FlowNode 图，而应在表达式位置记录 checker 已求出的 narrowed TypeId，并自行构建 MIR CFG。
- 文档执行层需要独立于架构叙述：采用 `FND/FE/IR/OBJ/MOD/RT/ADV/BE/REL` 稳定 issue ID，每个 issue 绑定矩阵行、AST Kind、artifact、诊断和验收命令。
- 第一条实现纵切应保持最小语义面，但不能绕过真实边界：`add(number, number)` 仍需经过 Program/checker release、typed snapshot、HIR/MIR verifier、LLVM verifier/link 和 Node differential。
- 规格冲突优先级固定为：IR verifier 高于架构叙述，capability manifest 高于 `.d.ts` 可见性，锁定 snapshot schema 高于 tsgo 私有对象布局。
- 可维护性规范采用“抽象必须证明价值”：核心流程优先保持线性；只有语义单元、稳定不变量、真实复用或外部边界才允许抽取，禁止一行 wrapper、预判式接口和无归属 `utils/helpers`。
- Program/checker、snapshot、HIR/MIR pass、variance/dynamic、runtime/GC/EH 和 LLVM mapping 属于强制核心注释区域；所有导出 API、配置、诊断、IR 节点和 runtime ABI 必须有契约型文档注释。
- 所有测试必须可单独、乱序、重复和按安全条件并行/分片运行；fixture 只读、workspace 每 case 独享，禁止共享可变状态、固定端口、真实网络和前序测试产物。
- 父仓库提交采用 Conventional Commits 风格并记录 issue、Test、Audit；submodule 更新必须独立提交并同步 lock、stdlib manifest 和兼容性审计。
- tsgo `getVariancesWorker` 通过把单个类型参数分别替换为已知 super/sub marker，双向调用 assignability 推导 covariant/contravariant/bivariant/invariant；若 bivariant 再用 unrelated marker 验证 independent，并传播 `Unmeasurable`/`Unreliable`。
- tsgo 对显式 `out`、`in` 直接采用声明方差；类型参数关系比较按 covariant 正向、contravariant 反向、bivariant 任一方向、invariant 双向执行，unmeasurable 只接受 identity/完全相同。
- tsgo 将 `Array`、`ReadonlyArray` 和 tuple 统一走预置 covariance 快路径，且源码明确承认“pretend array is covariant”；Bingo 必须在可写位置重新计算 layout variance，把 mutable Array/tuple 视为 invariant。
- tsgo emitter 顺序为 metadata（可选）→ type erasure → import elision → enum/namespace/parameter-property runtime syntax → legacy decorators → JSX → ES downlevel → use strict → module → const-enum inline；该顺序只用于行为 oracle，Bingo 使用独立 typed HIR/MIR pass。

## Rust runtime 与链接决策（2026-08-04）

- `bingo-rt` 的目标实现语言固定为 Rust；Go 继续负责 tsgo facade、Bingo compiler 和 LLVM backend，不进入最终用户进程的 runtime core。
- Rust runtime 按 target/profile 预编译为原生 `.a`/`.lib`，LLVM 生成代码只调用版本化 `extern "C"` ABI，最终由 LLD 链接 startup、用户/stdlib objects、所需 Rust archives 和显式 host libraries。
- 首版不发布 Rust bitcode ABI，不启用跨语言 LTO；rustc 与内部 LLVM metadata 不是稳定的跨版本 runtime 契约。
- Rust panic 不表示 TypeScript exception。release runtime 使用 `panic=abort`，导出 helper 以 status/exception handle 返回失败，再由 Bingo MIR 进入 throw/finally/cleanup 边。
- Bingo 继续拥有独立的非移动 tracing GC。Rust `Gc<T>` 不是 root，跨 MayAllocate/MaySuspend/host call 必须使用编译器 root slot 或 runtime `Root<T>`；Bingo heap object 不由 Rust `Drop` 释放。
- 标准库实现采用三层：Rust native primitives、受限 TypeScript self-hosted algorithms、BigInt/RegExp/ICU/Temporal 等可选 engine adapters。泛型 self-hosted 代码以锁定的 verified HIR/package 分发并按需实例化。
- Rust `unsafe` 只允许集中在 ABI、GC、layout、原子、TLS、平台和外部 engine FFI 边界；公共 ABI 禁止暴露 Rust 引用、容器、trait object、future 或默认布局 enum。
- 正式发布随 CLI 携带锁定 Rust toolchain/Cargo.lock/features/target 构建的 archive、capability/layout manifest 和 runtime lock；开发模式本地 runtime build 必须以完整 hash 隔离缓存。
