# 测试、兼容性与发布工程

ts2bin 的风险不是“某条 AST 没写 handler”这么简单，还包括 TypeScript 类型语义、JavaScript 求值顺序、runtime ABI、GC、LLVM verifier 和目标平台差异。本文件将现有 `handbook/` 与标准库索引转成可自动执行的测试体系。

测试结果何时进入设计、实现、里程碑或发布审计，以及审计未通过时如何返工，统一遵守 [compiler-development-process.md](compiler-development-process.md)。本文件定义证据内容，流程文档定义证据在哪个门禁必须出现。

每个测试的隔离、fixture、golden、helper 和独立运行要求以 [test-authoring-standards.md](test-authoring-standards.md) 为准。任何依赖测试顺序、共享可变状态或上一个测试产物的 case 都不能计入覆盖率和发布证据。

## 1. 测试资产目录

建议放在薄 fork 的 `testdata/ts2bin/`：

```text
testdata/ts2bin/
  syntax/                         # 对应 handbook 01–17 和 AST Kind group
  type-system/                    # union, narrowing, generic, variance
  lowering/                       # 消糖副作用和 source origin
  modules/                        # ESM/CJS/Node resolution/cycles
  classes/                        # layout, private, decorators, fields
  runtime/es5/                    # core globals and primitives
  runtime/es2015-es2025/          # collections, promise, iterator, typedarray
  runtime/esnext/                 # Temporal, fromAsync, upsert, base64/hex
  negative/                       # BINGO diagnostics and capability failures
  dynamic/                        # explicit interop only
  golden/snapshot|hir|mir|llvm/   # normalized artifacts
  manifests/                      # case and capability manifests
```

每个 case 使用同名文件：

```text
foo.ts
foo.tsconfig.json
foo.case.json
foo.expect.diag
foo.expect.hir
foo.expect.mir
foo.expect.out
```

## 2. Case manifest

```json
{
  "id": "variance/readonly-array-covariant-001",
  "source": "variance/readonly-array-covariant-001.ts",
  "handbook": ["06-generics", "07-type-operators"],
  "astGroups": ["TypeReference", "ArrayType", "PropertyAccessExpression"],
  "profile": "static",
  "target": "x86_64-unknown-linux-gnu",
  "runtime": "core-es2020",
  "expected": "run",
  "diagnostics": [],
  "artifacts": ["snapshot", "hir", "mir", "llvm", "obj"],
  "oracle": "node",
  "timeoutMs": 2000
}
```

`expected`：`check-only`、`hir`、`mir`、`run`、`reject`、`link-fail`。负例必须写预期 BINGO code，不能只断言命令退出非零。

## 3. 分层测试门禁

### 3.1 Frontend

- parser/scanner：与 tsgo 语法诊断一致。
- binder：symbol、scope、hoist、module indicator、private name。
- checker：TypeId/SignatureId、narrowed type、selected overload、type predicate、variance。
- module resolution：Program 的 canonical path、resolution mode、ESM/CJS、package exports/imports。
- snapshot：同一源码/frontend config/commit 字节稳定，绝不带 checker 指针；换 target/CPU/GC/EH/emit 不改变 frontend hash。golden 必须精确覆盖 Symbol/Signature/Flow/Assertion/CaptureSet/named child/payload，不得只比较 table count、Kind 集和 hash 长度。
- platform identity：大小写敏感 host 上 `A.ts`/`a.ts` 不碰撞，Windows/WSL/symlink/盘符按 host identity contract 产生稳定结果。
- config merge：未显式 override 时完整保留 `tsconfig.bingoOptions`，显式 CLI override 只改变被点名字段。

### 3.2 Snapshot-to-lowering readiness

- schema v2 的每个首批 S0/S1 node 都有已知 tagged syntax payload 和 named child role；删除或篡改 payload 必须稳定拒绝。
- property 保存 read/write/optional/readonly/accessor/private proof，signature 保存 optional/rest/effect，assertion 保存 chain/assignability/representation proof。
- capture 完成后主动 release AST/checker，序列化到 JSON 并由新 consumer process 重新加载；该进程只能读取 snapshot DTO。
- replay consumer 为 `add(number, number)` 生成 canonical lowering events/typed HIR，并与 capture-time oracle 差分。
- snapshot-only gate 是 Phase 2A `IR-001a` 的强制前置条件；仅比较 semantic digest 不算 lowering readiness。
- first-slice determinism 使用全新 Frontend/VFS、fresh serialization、独立进程重复输出和显式 evaluation-order proof；在同一实例上重复 Build 不是充分证据。
- canonical pass prefix、pre/post verifier 和 tamper cases 必须证明 snapshot/source-plan/HIR 不能跳步或伪造完成状态。

精确 diagnostic oracle、完整 handbook/AST case manifest 和 artifact/oracle execution 在 `REL-001` 闭合；更广泛的并发度/Unicode/跨平台组合与 fuzz 在 `REL-003`/`REL-004` 闭合。它们不能被省略，但不反向扩大 Phase 1.5 的 frontend-to-lowering contract。

### 3.3 HIR/MIR

- AST Kind manifest 无漏项。
- operator table 与 checker 类型匹配。
- 消糖保持单次求值：getter、computed key、iterator、call 和 spread 都有计数 oracle。
- HIR/MIR verifier 对人为篡改的 malformed IR 失败。
- generic specialization、variance adapter、cleanup/exception/suspend 边都有 golden。

### 3.4 Runtime

- primitive：NaN、Infinity、-0、UTF-16 code unit、BigInt/number 分离。
- object/class：shape、getter/setter、private、super、static init、prototype identity。
- collection：Map/Set 顺序、SameValueZero、weak reference、iterator close。
- async：Promise resolution、thenable assimilation、microtask、错误传播。
- resource：using/await using 正常、return、throw、break、continue、nested cleanup。
- GC：single-mutator v1、每 safepoint active root、dead-slot clear、root publication optimizer barrier、write barrier 和环；weak/finalization/async frame 在对应 capability 开启后测试。

### 3.5 LLVM/backend

- MIR verifier 通过后 `VerifyModule` 必须通过。
- `opt`/PassBuilder 只允许配置中的 passes；优化前后运行结果一致。
- `llc`/TargetMachine 输出 object，linker 能解析所有 capability symbols。
- debug/source map 能回到原 TS span。
- LLVM 版本、target triple、data layout、runtime ABI hash 进入 golden header。
- `VERT-001` 在对象/GC/EH 前独立跑 Linux x86-64 real LLVM -> object -> deterministic LLD -> executable，并与 Node oracle 比较 `add` 结果。

## 4. Handbook 交叉覆盖

现有 [handbook/README.md](../handbook/README.md) 的 17 个章节映射如下：

| Handbook | 测试主题 |
| --- | --- |
| 01–03 | 声明、primitive、union/narrowing、strict null |
| 04–05 | 函数 variance、对象 shape、index/call signature |
| 06–07 | generic inference、conditional/mapped/indexed access、utility types |
| 08 | class layout、private/protected、override、static block、accessor |
| 09 | ESM/CJS、namespace、declaration merging、triple-slash resolution |
| 10 | enum、symbol、iterator/generator、mixin、dispose |
| 11 | 标准/legacy decorators、metadata、initializer order |
| 12 | `.d.ts`、ambient、JSX、JSDoc、host boundary |
| 13 | compile-only utility type normalization |
| 14 | version gates：satisfies、using、import attributes、import defer 等 |
| 15 | API/event/state/config/plugin 组合场景 |
| 16 | tsconfig profile and option compatibility |
| 17 | token/operator/declaration parser smoke |

每章至少有一个 S0、S1、S2 和 R case；章节中无法静态编译的 dynamic 例子必须标出 interop profile。

## 5. 标准库交叉覆盖

基于 [stdlib/README.md](../handbook/stdlib/README.md) 和 [stdlib/99-api-index.md](../handbook/stdlib/99-api-index.md)：

1. 脚本读取 `typescript-go/internal/bundled/libs/lib.es*.d.ts`，为每个真实声明类型/值成员生成 capability candidate。
2. 聚合 `lib.es20xx.d.ts` 只做引用展开，不重复生成测试。
3. 对每个 candidate 计算 `signatureHash`，与 runtime manifest 对照。
4. 缺实现时生成 `planned/unsupported` case，而不是跳过。
5. DOM/WebWorker/ScriptHost 单独统计为 host API，不混入 ECMAScript coverage。

覆盖分层：

```text
declaration-index coverage    100% of 81 lib sections
type/member manifest coverage 100% of 314 types / 2173 members
static implementation         explicit S0/S2 subset
dynamic/external               explicit capability and negative case
```

“索引覆盖 100%”不等于“runtime 已实现 100%”；报告必须同时展示两列。

## 6. Differential oracle

### 6.1 Node/TypeScript

对 static subset，运行 Node 参考实现和 Bingo binary，比较：

- stdout/stderr、exit code、return serialization。
- number 特殊值、string UTF-16 长度/索引、BigInt 字符串化。
- object/array JSON snapshot（规定 key 顺序和不可序列化值处理）。
- error class/name/message；stack 只比较规范化前缀。

不比较编译器私有布局、GC 时间、错误 stack 行号和优化后指令数。

### 6.2 Runtime specification

Promise、iterator、dispose、Temporal、Intl 等使用标准测试向量或独立规范 fixture；不能把 Node 某一版本的扩展行为当作 ECMAScript 规范。

### 6.3 Compile-time oracle

将 TypeScript checker 结果保存为 snapshot：类型兼容、overload 选择、narrowing 和 variance 不比较内部 TypeId 数值。semantic digest 用于兼容性分类；进入 lowering 的语法、property/signature/assertion proof 还必须由 snapshot-only replay 消费，不能只比较 digest。

## 7. Property/fuzz 测试

- scanner/parser fuzz：输入大小、嵌套深度和超时有上限，保证无 panic/死循环。
- snapshot fuzz：随机 AST Kind 组合只能得到稳定诊断或合法 snapshot。
- snapshot validator fuzz：随机破坏 semantic reference、parent/root graph、assertion/flow proof、config/provenance digest 和 canonical JSON，只能稳定拒绝，不能 panic 或接受假证明。
- path/manifest fuzz：拒绝 `..` escape、大小写别名碰撞和非法 Unicode/path encoding；覆盖 Windows drive/backslash、WSL、case-sensitive/insensitive VFS。
- lowering fuzz：HIR/MIR verifier 是第一道安全边界；非法 IR 不交给 LLVM。
- differential fuzz：只执行 capability-safe、无 FFI、无 dynamic 的程序；运行在隔离进程。
- metamorphic：括号、冗余 `as`、等价短路重写、类型别名展开不应改变运行结果或 semantic digest。
- cleanup fuzz：随机嵌套 using/try/finally/return/throw，验证资源释放次数恰为一次。

## 8. 性能与资源预算

每个阶段记录：

```text
parse_ms, bind_ms, check_ms, snapshot_ms
hir_ms, mir_ms, llvm_ms, link_ms
peak_memory, checker_count, snapshot_bytes
hir_nodes, mir_instructions, generic_instances
runtime_allocs, gc_pause, binary_size
```

预算默认值（可在 CI 调整）：

- 单文件 10k 行 static case：前端 2s、snapshot 512 MiB 内。
- 泛型实例化超过 10,000 或 HIR/MIR 指令超过配置上限：报可定位诊断。
- fuzz case 2s 无结果：记录 timeout，不阻塞后续 case。

## 9. Cache 与可复现构建

cache 分两级。target-independent frontend cache key 至少包含：

```text
source content hashes
frontend-semantic tsconfig digest + source profile
typescript-go commit
stdlib manifest hash
snapshot schema
filesystem identity policy
```

target-dependent artifact cache key 再组合：

```text
frontend snapshot hash
bingo HIR/MIR schema + pass/effect DAG version
runtime ABI/capability hash
Rust toolchain + Cargo.lock/features + runtime archive hashes
LLVM major + target triple + cpu/features
runtime/gc/exceptions/overflow/bounds/emit options
```

缓存产物保存 provenance header；任何 key 缺失都视为 cache miss。release 构建禁止读取开发机全局 runtime 或未锁定 LLVM。

## 10. CI 矩阵

| Job | 环境 | 重点 |
| --- | --- | --- |
| clean-clone | fresh checkout + recorded fork remote | gitlink/fork/lock 可获取；无 dirty/untracked 依赖；Phase 1 全门禁 |
| frontend-linux | Go + tsgo fork | Program/checker/snapshot/full diagnostics |
| frontend-windows | Go 原生 | CLI、路径、诊断、无 LLVM 模式 |
| snapshot-replay | isolated consumer process | JSON round-trip 后无 AST/checker 的 `add` lowering readiness |
| runtime-rust | locked Rust targets | crate tests、ABI/layout、panic/status、Miri/sanitizer、archive manifests |
| vertical-linux | LLVM 20 + go-llvm + LLD | primitive `VERT-001` real LLVM/object/link/run + Node differential |
| llvm-linux | LLVM 20 + go-llvm | 完整 VerifyModule、opt、llc、runtime link/run |
| llvm-macos | LLVM 20 + Rust runtime | target/data layout、runtime ABI、LLD archive link |
| wsl-windows | WSL2 Ubuntu + Rust target | Windows 开发推荐 LLVM 环境、COFF runtime archive/link smoke |
| stdlib-manifest | typescript-go libs | declaration/runtime capability diff |
| fuzz-nightly | sandbox | parser/lowering/differential/cleanup |
| reproducible | clean container | artifact digest、source map、cache |

原生 Windows 的 LLVM job 如果无法稳定提供 cgo/libLLVM，应明确标记为 `frontend-windows`，不能伪装成完整 backend 支持。

## 11. CLI 与发布物

固定命令：

```text
ts2bin check       # tsgo + Bingo diagnostics only
ts2bin snapshot    # typed snapshot
ts2bin emit-hir    # HIR text/binary
ts2bin emit-mir    # MIR + verifier
ts2bin emit-llvm   # LLVM textual/bitcode
ts2bin build       # object/executable
ts2bin test        # case manifest runner
ts2bin doctor      # tsgo/LLVM/runtime capability audit
```

`doctor` 必须显示：tsgo commit、Go、LLVM/llvm-config、LLD、target triple、Rust runtime build ID/Cargo features、runtime archive/manifest、可用 capability 和缺失项。

`ts2bin test --stage frontend` 必须执行完整 frontend gate registry，而不是只运行一个 conformance test：snapshot validator、ModuleGraph、checker borrow/race、compatibility、CLI、shuffle 和选定重复次数都必须在报告中列出实际命令与结果。快速本地子集应使用另一个显式命令名，不能冒充阶段退出门禁。

发布物包含 CLI、按 target/profile 构建的 Rust native static archives、startup object、capability/layout/runtime lock、self-hosted stdlib package、标准库 manifest、第三方许可证、IR schema 版本和 reproducibility metadata。只有 clean-clone、snapshot-only replay、real-LLVM 纵切和对应完整 conformance 都通过的 profile 才能发布；experimental ESNext/dynamic 单独标注。

## 12. Issue 拆分建议

本节只保留优先级视图；稳定 issue ID、依赖和退出命令以 [implementation-backlog.md](implementation-backlog.md) 为准：

```text
P0  [complete] Phase 1.5: FE-008a/009a/010a/011a/011b/012a, IR-000a/007a/001a/002a/003a, FND-004a
P0  [complete] Phase 2A: FE-012a + IR-007a/001a/002a/003a
    || [complete] BE-001a || RT-002a
    -> TC-001a -> IR-004a/005a
    -> RT-002b + BE-002a/004a -> REL-001a -> VERT-001 -> REL-002a
P1  [ready] Phase 2B: full IR-001..008 primitive/control-flow contracts
P2  OBJ/MOD/RT/GC/EH/ADV feature groups in backlog dependency order
P3  full BE/REL productization, second target, broad fuzz/performance/release matrices
```

每个 issue 必须引用：矩阵行、capability、golden、diagnostic code、验收命令和预计影响的 schema/ABI 版本。新增 issue 不应绕开 backlog 的依赖图；若需要改变阶段顺序，先更新路线图和变更控制记录。
