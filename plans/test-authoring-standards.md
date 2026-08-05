# ts2bin 测试编写与独立性规范

本文规定 ts2bin 的测试分层、测试库、fixture、golden、差分、fuzz 和独立性要求。所有测试都必须能够独立运行；“在完整测试套件中偶然通过”不算有效测试。

本文件补充 [testing-conformance-and-release.md](testing-conformance-and-release.md)：该文件定义测试覆盖面和发布门禁，本文定义每一个测试如何编写、隔离、命名、运行和审查。

## 1. 独立测试的硬性定义

一个测试只有同时满足以下条件才算独立：

1. 单独运行时通过，不依赖其他测试先创建文件、缓存、模块、环境变量或全局对象。
2. 任意顺序运行时结果不变，不能依赖文件名排序、注册顺序或 map 遍历顺序。
3. 重复运行时结果不变，不能依赖残留临时目录、固定端口、系统时间或随机种子。
4. 与其他测试并行运行时不会争用目录、端口、环境、LLVM context、runtime registry 或 checker。
5. 在不同工作目录、用户名、机器路径和 CI shard 中结果一致。
6. 失败后仍能清理资源，不影响同一进程中的其他测试。
7. 所有输入、期望结果和外部工具版本都由本测试或 case manifest 明确声明。

禁止以下测试依赖：

- 测试 B 读取测试 A 写出的 snapshot、HIR、MIR、LLVM 或 object。
- 多个测试共同修改一个 golden、全局 cache、固定临时目录或 package-level map。
- 依赖真实网络、公共服务、用户主目录、系统安装的 Node 包或未锁定 LLVM。
- 依赖本地时区、locale、当前时间、CPU 数量、随机端口常量或 goroutine 调度顺序。
- 使用名称 01/02/03 暗示执行顺序。
- 失败后通过 retry 隐藏竞态、超时或未清理状态。

## 2. 测试技术栈

### 2.1 Go 测试

- 默认使用 Go 标准 testing、testing/fstest、httptest 和内置 fuzz/benchmark。
- 结构化值 diff 允许使用 github.com/google/go-cmp/cmp；必须显式配置忽略项，禁止忽略所有未导出字段来掩盖差异。
- 不引入依赖全局 suite、反射注册或隐式生命周期的重量级测试框架。
- 错误断言检查稳定的 error type/code 和关键字段，不依赖完整英文文案，除非测试对象就是诊断格式。
- panic 只用于验证明确声明的 programmer error；普通用户输入必须返回诊断或 error。

### 2.2 Rust Runtime 测试

- 默认使用 Rust 内置 test harness；跨 ABI 测试必须从生成的 C header 或 LLVM caller 调用导出符号，不能只覆盖 crate 私有 API。
- `cargo fmt --check`、锁定 clippy/lint、crate tests 和 target staticlib smoke link 属于 runtime 基线门禁。
- `unsafe`、GC handle 和 layout 测试按 [rust-runtime-and-linking.md](rust-runtime-and-linking.md) 使用 Miri、sanitizer、fuzz 和真实目标机的组合，不能用某一个工具的通过代替全部安全契约。
- 每个测试使用独立 heap/root stack/scheduler 和临时 Cargo target dir；禁止依赖另一个测试留下的 archive、incremental cache 或全局 allocator 状态。
- Rust panic 只用于 runtime 内部不变量测试；导出 ABI 对用户输入必须返回 status/exception，release `panic=abort` 路径不得用 `catch_unwind` 掩盖。

### 2.3 测试工具包

共享测试工具放在 internal/testkit 下，但只有满足 [coding-and-maintainability-standards.md](coding-and-maintainability-standards.md) 的抽象条件才创建。建议边界：

~~~text
internal/testkit/
  casefs/      copy immutable fixtures into t.TempDir
  golden/      normalize, compare, explicit update
  process/     context-bound subprocess with captured output
  oracle/      Node/specification result normalization
  llvm/        tool discovery and version/capability checks
~~~

规则：

- 只有跨两个以上测试包复用，或能够集中保证隔离/清理不变量时才创建 testkit helper。
- 单包内使用的 setup 和断言留在同一 _test.go 文件附近，不建立通用 helpers 包。
- helper 必须调用 t.Helper()，返回明确值或 error，不能在深层 helper 中随意 Fatal 使调用流程不可见。
- helper 不得隐藏核心断言、测试步骤或 artifact；审查者应从测试函数看出 Arrange、Act、Assert。
- 禁止 catch-all TestContext、TestWorld 或巨型 fixture builder。

## 3. 测试目录和文件契约

~~~text
testdata/ts2bin/
  syntax/
  type-system/
  lowering/
  modules/
  classes/
  runtime/
  negative/
  dynamic/
  golden/
  manifests/
~~~

一个 case 的输入和期望使用同一稳定前缀：

~~~text
optional-chain-single-eval.ts
optional-chain-single-eval.tsconfig.json
optional-chain-single-eval.case.json
optional-chain-single-eval.expect.diag
optional-chain-single-eval.expect.snapshot
optional-chain-single-eval.expect.hir
optional-chain-single-eval.expect.mir
optional-chain-single-eval.expect.llvm
optional-chain-single-eval.expect.out
~~~

规则：

- 每个 case 自包含，不能 import 其他 case 的临时输出；多文件程序放在该 case 独立子目录。
- fixture 是只读输入。测试必须先复制到 t.TempDir 或 runner 专属 workspace，再执行会写文件的命令。
- golden 属于单个 case；禁止多个测试共同更新同一个期望文件。
- 大型共享规范数据必须版本化且只读，case 通过 manifest 选择子集，不能在运行时修改。
- 文件名描述行为，不描述实现函数名；重构内部函数不应迫使大面积重命名 fixture。

## 4. Case manifest 规范

每个编译器行为 case 都必须有 manifest，至少包含：

~~~json
{
  "id": "lowering/optional-chain-single-eval",
  "source": "lowering/optional-chain-single-eval.ts",
  "handbook": ["03-unions-and-narrowing"],
  "astGroups": ["PropertyAccessExpression", "CallExpression"],
  "profile": "static",
  "target": "x86_64-unknown-linux-gnu",
  "runtime": "core-es2020",
  "expected": "run",
  "diagnostics": [],
  "artifacts": ["snapshot", "hir", "mir", "llvm", "out"],
  "oracle": "node",
  "timeoutMs": 2000,
  "requires": []
}
~~~

manifest 规则：

- id 全局唯一且稳定；移动目录时保留 id 或记录迁移。
- expected 必须是 check-only、hir、mir、run、reject、link-fail 等明确状态。
- 负例必须写 diagnostic code、source span 类别和关键字段，不只检查退出码。
- target/runtime/profile/requires 必须显式；不能读取开发机默认值。
- timeout 是单 case 上限，超时必须失败并保留诊断，不自动重试。
- oracle、工具版本和允许差异必须写入 manifest 或锁文件。

## 5. Arrange、Act、Assert 结构

测试函数应当直接展现三个阶段，可以使用空行或简短注释分隔，不为每个阶段再封装一层函数：

~~~go
func TestSnapshotRejectsEscapedCheckerPointers(t *testing.T) {
    workspace := copyCaseToTemp(t, "snapshot/no-checker-pointers")
    frontend := newFrontendForTest(t, workspace)

    snapshot, diagnostics := frontend.Build(context.Background(), requestFor(workspace))

    requireNoDiagnostics(t, diagnostics)
    assertSnapshotContainsNoInternalPointers(t, snapshot)
}
~~~

这里的 helper 只负责隔离 workspace、构造稳定前端和表达一个完整断言。不要把整个测试塞进 runSnapshotCase(t, name, flags...) 后只剩一行，除非它是 manifest 驱动的统一 conformance runner，且失败能定位到每个阶段和 artifact。

## 6. Go 测试独立性规则

### 6.1 文件系统

- 使用 t.TempDir()；禁止硬编码 ./tmp、C:\temp、/tmp/ts2bin 或仓库内输出目录。
- 测试只读 testdata，写操作一律进入测试私有 temp。
- 路径断言使用规范化相对路径或 FileId，不比较用户主目录和盘符大小写。
- t.Cleanup() 注册清理；即使 Fatal、panic 或 context cancel 也必须关闭文件、进程和 runtime handle。

### 6.2 环境变量和工作目录

- 使用 t.Setenv() 设置本测试需要的变量，并声明默认值。
- 调用 t.Setenv 或修改进程级 cwd 的测试不得 t.Parallel；优先让被测 API 接受显式 cwd/config。
- 禁止永久修改 PATH、HOME、locale、timezone 或 LLVM 配置。
- 子进程环境从最小白名单构造，不直接继承开发机全部环境。

### 6.3 时间、随机数和端口

- 时间通过注入 Clock 或固定 fixture 提供；不直接断言 time.Now() 的精确值。
- 随机测试记录 seed；普通单测使用固定 seed，fuzz 由测试框架管理 corpus。
- 网络服务使用 httptest 或监听 127.0.0.1:0 获取系统分配端口；禁止固定端口。
- 无网络需求的测试禁止访问外部网络；CI 应能在断网环境运行核心测试。

### 6.4 并发与全局状态

- 禁止可变 package-level registry/cache；必须通过实例或测试专用对象注入。
- t.Parallel() 只用于已经证明不修改进程级环境、cwd、全局 LLVM state 或共享 fixture 的测试。
- 子测试闭包必须捕获当前 case 值；不得引用循环迭代变量的共享地址。
- goroutine 必须受 context 管理并在测试结束前 join；禁止测试返回后仍有后台任务。
- LLVM context/module、checker borrow、runtime VM 和 cache 目录一律每测试独享。

## 7. 分层测试编写规则

### 7.1 Frontend

- parser/checker 结果以锁定 tsgo 为 oracle。
- 每个测试自己构造 Program 和获取/release checker，不复用其他测试的 Program。
- snapshot determinism 测试在全新实例和不同并发顺序下构建两次，比较规范化字节。
- module resolution fixture 自带 package.json/tsconfig，不读取父仓库 node_modules。

### 7.2 HIR/MIR

- HIR 测试只消费本 case 新生成的 snapshot，或读取该 case 的只读 snapshot fixture。
- MIR 测试不能依赖另一个 HIR 测试先写 golden；本测试自行验证 HIR，构造 BuildPlan/toolchain/runtime manifests，执行 ResolveTargetContext 与 RepresentationPlan join 后再生成 MIR。
- verifier 必须有正例和人工构造的 malformed IR 负例。
- 消糖测试必须用计数 getter、computed key、iterator 或 call 验证单次求值。

### 7.3 Runtime

- 每个测试创建独立 runtime/heap/scheduler；禁止共享 GC heap 或 microtask queue。
- GC 测试显式注册 root，结束时验证无悬挂任务和预期对象可达性。
- Promise/async 测试使用确定性 scheduler，不能依赖 sleep 等待。
- Map/Set/string/TypedArray 测试固定 locale、timezone、encoding 和数据版本。
- Rust 导出 ABI 测试必须检查 symbol、signature、`repr(C)` size/alignment/offset、null/invalid handle 和 status 转换；不得只从 Rust 内部调用 safe worker。
- Rust `unsafe` 核心在可用范围内运行 Miri；GC raw heap、外部 engine 和平台 shim 使用 sanitizer/目标机测试补足 Miri 无法覆盖的路径。
- release `panic=abort` 构建必须证明普通输入和负例返回 status/exception；测试不得用 `catch_unwind` 把 ABI panic 当作合法错误策略。
- 每个 runtime archive 测试独占临时 target dir，不能共享 Cargo output 后再用时间戳判断产物；可复现测试比较规范化 archive/member/manifest digest。
- self-hosted stdlib 测试从锁定 HIR/package 独立实例化，不能读取上一个 case 生成的 specialization cache。

### 7.4 LLVM/backend

- 每个测试创建独立 LLVM context/module/builder；不要复用全局 module。
- 输出进入 t.TempDir，target triple/data layout/LLVM major 写入 artifact header。
- VerifyModule 失败视为测试失败和编译器 bug，不能转成普通用户诊断。
- 缺少 LLVM 工具时只允许 capability-aware skip；发布 CI 的必需 job 不得 skip。
- link 测试必须使用锁定 LLD 和显式 response file，验证 Rust archive target/ABI/Cargo feature/capability 不匹配会在链接前产生结构化诊断。

### 7.5 Differential

- Node/TypeScript 和 Bingo binary 使用相同的显式输入、环境和 timeout。
- 比较 stdout/stderr、exit code 和规范化结果；允许差异必须列在 case manifest。
- oracle 进程每 case 独立启动或显式重置，不共享 module cache。
- 不把单一 Node 版本的扩展行为当作 ECMAScript 规范；规范 fixture 单独版本化。

## 8. Golden 测试规范

- golden 只保存稳定语义：ID、类型、指令、诊断、ABI 和 source origin；移除地址、时间戳、绝对路径和随机顺序。
- 更新 golden 必须使用显式 --update-golden 标志或专用命令，默认测试绝不自动改文件。
- 更新操作逐 case 执行并审查 diff；禁止无解释地批量接受所有变化。
- golden header 记录 schema、tsgo commit、stdlib/runtime hash、LLVM major 和 target。
- 序列化格式变更与语义变更分开提交，避免审查者无法判断真实差异。
- 一个 case 的某层 golden 缺失时应失败或明确 expected 不包含该层，不能静默跳过。

## 9. 负例和诊断测试

每个拒绝规则至少有一个独立负例：

- as any as 到不相容类型。
- 可变 Array 的不安全协变。
- unresolved generic representation。
- 缺失 runtime capability、host FFI 或 target support。
- malformed HIR/MIR、错误 cleanup、非法 LLVM mapping。
- eval、with、Proxy、原型改写等未支持动态语义。

负例断言必须检查：diagnostic code、阶段、source span、profile 和关键类型/capability。多个诊断按稳定排序比较；不得只断言 contains("error")。

## 10. Fuzz、属性和变形测试

- fuzz target 自包含 corpus 和资源上限；不读写共享 golden。
- 每个崩溃保存最小化 seed、config、lock 和目标层 artifact。
- lowering fuzz 先过 HIR/MIR verifier；非法 IR 不能交给 LLVM。
- differential fuzz 只执行 capability-safe、无 FFI、无 dynamic 的隔离程序。
- 变形测试验证括号、等价短路、类型别名展开和无效类型注释不改变 observable behavior。
- cleanup fuzz 随机组合 using/try/finally/return/throw，验证每个资源恰好释放一次。

## 11. Mock、Stub 和 Fake 规则

- 优先使用真实纯组件和内存文件系统；只在外部边界使用 test double。
- mock 必须对应稳定接口，不为测试一个私有调用顺序而制造接口。
- 不验证“某 helper 被调用一次”来替代语义结果；应验证 snapshot、IR、诊断、ABI 或 observable behavior。
- fake filesystem、clock、scheduler、runtime capability registry 必须每测试新建实例。
- 测试 double 的行为要比生产实现更简单，不能重新实现一套 TypeScript/LLVM 语义作为 oracle。

## 12. 断言和失败信息

- 一个测试可以有多个相关断言，但只验证一个行为主题。
- 失败信息包含 case ID、stage、artifact、expected/actual 和重现命令。
- 对大对象使用结构化 diff，避免成百上千条逐字段 Fatal。
- 不吞掉 subprocess stderr、LLVM verifier message 或 diagnostic origin。
- helper 的 Fatal 必须位于明确的 setup/contract 失败；语义比较尽量返回 diff 给测试函数。

## 13. 独立性验证命令

最低本地门禁：

~~~text
go test ./... -count=1
go test ./... -shuffle=on -count=1
go test ./... -race -count=1
go test ./... -count=20
~~~

针对单测必须可执行：

~~~text
go test ./internal/bingo/... -run '^TestMIRVerifierRejectsBrokenPhi$' -count=1
~~~

CI 追加：

- 按 package 和 case manifest 分片运行。
- 随机顺序和并发度运行。
- 选择历史 flaky/并发测试重复运行。
- 在干净临时目录、无网络和最小环境变量下运行核心测试。
- 检查测试结束后无残留进程、文件锁、端口监听和 goroutine。
- 对支持的 target 运行 LLVM/link/runtime 独立 job。

## 14. Flaky 测试处理

- 第一次出现不稳定即登记 issue，保存 seed、shard、环境和日志。
- 不允许用 retry、增加 sleep、放宽 timeout 或跳过断言作为最终修复。
- 暂时隔离必须标明 owner、影响阶段和解除条件；release 必需测试不能长期隔离。
- 修复后至少乱序重复 100 次或使用专门压力配置验证，且补充竞态/清理回归。
- 无法复现不等于关闭；保留失败证据并降低不确定外部依赖。

## 15. 测试审计清单

- [ ] 测试可以单独、乱序、重复、并行/分片运行。
- [ ] 没有共享可变 fixture、固定目录、固定端口、真实网络或未锁定环境。
- [ ] 每个 case 拥有独立 manifest、输入、golden 和 temp workspace。
- [ ] helper 数量受控，测试函数仍能直接读出 Arrange、Act、Assert。
- [ ] 正例、拒绝例、边界例、单次求值和 cleanup 路径齐全。
- [ ] diagnostic、snapshot、HIR/MIR、runtime 和 LLVM 层的责任没有混淆。
- [ ] golden 更新显式且 diff 可解释。
- [ ] fuzz/差分/子进程有 seed、timeout、资源上限和清理。
- [ ] 失败信息足够独立复现，不依赖 CI 上下文。
- [ ] 对应测试命令写入提交消息和审计记录。

## 16. 测试完成定义

测试只有同时满足以下条件才可作为合并或发布证据：

1. 测试行为独立、确定、可重复，没有顺序和共享状态依赖。
2. fixture、manifest、golden 和外部工具版本完整锁定。
3. 测试覆盖预期成功、预期拒绝和关键边界，不只覆盖 happy path。
4. 单测、乱序、race、重复和相应分层门禁通过。
5. 审计者能够从失败信息和记录命令在干净环境独立复现。
