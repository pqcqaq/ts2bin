# 2026-08-05 开发方向审计与后续计划调整

> Historical audit checkpoint. Its “current/next” wording records the 2026-08-05 state and is superseded by [implementation-backlog.md](implementation-backlog.md) and [phase3-entry-and-hardening.md](phase3-entry-and-hardening.md).

## 1. 结论

总体技术方向正确，继续采用：

```text
typescript-go Program/Checker
  -> immutable frontend snapshot
  -> Bingo typed HIR
BuildPlan + toolchain/runtime manifests
  -> ResolveTargetContext
typed HIR + TargetContext
  -> RepresentationPlan -> Bingo target-aware MIR
  -> LLVM IR/object
  -> Rust runtime C ABI + LLD
```

不需要改成从 AST 直接生成 LLVM，也不需要引入完整 JavaScript engine 作为 static profile 的基础。在本审计检查点，下一步是并行的 LLVM TargetMachine/DataLayout 与 Rust runtime-manifest scaffold；该历史顺序后来已经完成。现行状态和下一步不再由本审计文档维护，以 backlog 与 Phase 3 entry plan 为准。

## 2. 审计证据

本次审计对照了 [architecture.md](architecture.md)、[implementation-specification.md](implementation-specification.md)、[implementation-backlog.md](implementation-backlog.md)、[tsgo-integration.md](tsgo-integration.md)、当前 `ts2bin.lock.json`、父仓库 gitlink，以及 `typescript-go/internal/tsfrontend`、`internal/frontendwire`、`internal/ast2bingo`、`internal/bingo`、`cmd/ts2bin` 和 `cmd/ts2bin-replay` 的实际代码与测试。

关键事实：

- 父仓库 `.gitmodules` 与 root lock 现指向 `https://github.com/pqcqaq/typescript-go.git`；lock/gitlink/checkout 固定同一 fork commit，并单独记录 reviewed Microsoft upstream ancestor。上游同步采用显式 merge，不再使用 patch/materialize/apply 交付。
- `ts2bin.lock.json` 使用 lock schema 2、snapshot schema 2 和 `reproducibilityStatus: pinned-fork-commit`；fork remote/commit、upstream ancestor、108 个 bundled lib、Go/LLVM/LLD 版本和 semantic baseline 均由锁与生成物约束。本地、远端 fork 与 committed-parent clean-clone 迁移验收命令均已通过。
- `NodeSnapshot` 的 Kind-driven payload/role/arity shape registry、checker capture fail-closed、semantic proof、module/effect/lowerer registries 与 ownership/redirect 负例均已进入实现；`frontendwire.ValidateProgramSnapshot` 是 serialized validator 单一真源，`tsfrontend` 只保留委托 API，capture analyzer 只产出 proof。
- `ReplayFrontendSnapshot` 已改为消费 `frontendwire` DTO；`go list -deps ./cmd/ts2bin-replay` 当前只保留 replay/IR 侧依赖，不再包含 parser、binder、checker、AST 或 tsoptions。独立进程重复运行、显式 primitive evaluation-order events、单 block return HIR、tamper post-verifier 与 migration full regression 均已进入 checked-in tests 并通过。
- `FrontendSnapshot` capture 已在源头剥离 backend fields，三项遗漏 TypeScript options 已投影，`ResolveBuildPlan` 绑定 validated snapshot；target/path/profile/cache regression、rooted-path 门禁与 no-EH 默认值均已闭合。`ResolveBuildPlan` 只产生 canonical unresolved request，Phase 2A capability 真值由 `ResolveTargetContext` 负责。
- Bingo 已加入 canonical `PassExecutor`、specialization budget/fixed-point、pre/post verifier、独立 effect proof、deterministic dump/golden；primitive replay 已绑定真实 validate-snapshot -> typed-HIR production handlers，并拒绝缺 handler、篡改 HIR 与错误求值顺序。`IR-000` complete；typed HIR 之后的 production handlers 与真正 target-aware MIR verifier属于 Phase 2A。
- Phase 1.5 的 wire/option/pass 实现门与 Phase 2A 的 number-only HIR schema hardening/typed envelope substrate 已关闭；fork 交付迁移的本地、远端和 committed-parent clean-delivery 证据均已通过。剩余编译器差距是实际 TargetMachine/DataLayout、空 runtime/toolchain manifests、TargetContext resolver、target-aware MIR、real LLVM/object/LLD、case runner 和 Node differential；不能只凭 happy-path `go test` 或 fixture envelope 关闭。

### 2.1 二次复核状态（以本节为准）

| 项目 | 当前状态 | 证据 | 关闭条件 |
| --- | --- | --- | --- |
| `FND-004` | `complete` | 现行 `.gitmodules`/lock/gitlink 已迁移到 `pqcqaq/typescript-go` 固定 fork commit，reviewed upstream ancestor 与 fork verification/merge scripts 已定义；本地 doctor、frontend/全仓门禁、隔离 test/vet、replay 双构建、远端 fetch/full test/vet 及 committed parent HEAD clean-clone 均已通过，旧 patch 路径已退役 | 进入 Phase 2A |
| `FE-008` | `complete` | Kind shape registry、payload/role negative tests、wire 单一 serialized validator 与 full regression 通过 | 保持 wire 为唯一规则源；schema 变化继续走 migration gate |
| `FE-009` | `complete` | module binding/effect registry/fixed-point/lowerer readiness、ownership/redirect 负例与 wire round-trip 通过 | 新 proof 必须同时有 capture 正例和 wire corruption 负例 |
| `FE-010` | `complete` | checker-free wire/replay、依赖闭包、重复运行、evaluation-order/single-block HIR、篡改拒绝及 migration regression 通过 | 纳入最终 fork/clean delivery |
| `FE-011` | `complete` | target split、option projection、Windows/WSL identity、rooted-path fail closed、profile/cache 和 no-EH regression 全绿 | BuildPlan 保持 unresolved；Phase 2A 由 TargetContext resolver 绑定 capability |
| `IR-000` | `complete` | canonical executor、fixed-point、hooks、effect proof、dump/golden，以及 validate-snapshot -> typed-HIR production prefix 已通过核心、race、frontend stage 和全仓 regression | typed HIR 之后的 TargetContext/production handlers 留在 Phase 2A |
| `FE-012a`, `IR-007a/001a/002a/003a` | `complete` | sealed snapshot、三路径 tamper rejection、number contract v1、HIR v2/compiler identity/logical requirements、identity/hash 与 malformed verifier tests通过 | 保持 target-independent；扩类型必须等待 Phase 2B |
| Typed envelope substrate | `complete` | typed artifact role/schema/payload digests 与 executor immutability已通过 | 不冒充 TargetContext/DataLayout/manifests resolver |
| Phase 2A | `in progress` | 入口 HIR 契约已关闭；real LLVM/runtime/TargetContext/MIR/object/LLD 尚未形成闭环 | `BE-001a || RT-002a -> TC-001a -> IR-004a/005a` 后让 `add(number, number)` 经真实 verifier/LLVM/LLD 运行并与 Node 差分 |

状态词含义与 [implementation-backlog.md](implementation-backlog.md) 一致：`implemented` 表示代码存在，`acceptance-blocked` 表示仍有明确证据缺口，`ready` 表示前置门已关闭但本阶段尚未完成，`complete` 才表示阶段门禁关闭。

## 3. 收口前阻断项（历史）

本节记录当时采用的 upstream+patch/materialize/apply 方案；该交付机制现已退役，不得从这些历史命令恢复为活跃流程。

| 严重度 | Issue | 问题 | 必须完成的结果 |
| --- | --- | --- | --- |
| P0 | `FND-004` | `[历史，已退役机制]` 旧 patch 曾可独立重建，但当时工作树继续演进并被 `doctor` 判定 divergent；若先封 patch 再修 frontend，会立即再次失配 | `[历史，已退役机制]` 当时需把本项移到 Phase 1.5 最后并重生成 patch/hash；现行结果改为固定 fork commit、显式 upstream merge 和 fork verification |
| P0 | `FE-008/011` | 主要缺口已实现，但 wire 拆分改变了 hash/config DTO 且复制了完整 validator；当前 compatibility/fixture/options golden 尚未闭合 | `frontendwire` 成为 serialized validator 单一真源，旧 overlay 负例与 target/path/profile/cache 全套 regression 通过 |
| P0 | `FE-009` | effect/module/mandatory-fact 与 overload ownership/redirect 负例已实现，关键 helper 已同步，但完整 serialized validator 仍被复制 | checker-time analyzer 只产出 proof；wire 独立重算并成为唯一 serialized effect validator，禁止人工双写 |
| P0 | `FE-010` | 独立依赖闭包、新进程 replay、显式 evaluation-order/single-block HIR 与 tamper tests 已通过，但全量 golden/baseline 仍漂移 | 人工分类 DTO/hash 变化，更新有意 baseline/golden 后让所有 migration regression 全绿 |
| P0 | `FE-011b` | 代码、default golden 和 lock 只接受 `llvm-eh`，但 native EH 没有实现，且首切宣称无 EH | Phase 2A 前引入 canonical `none` 首切模式并迁移默认/lock/BuildPlan；status-code 与 native-unwind 作为后续独立、不可混链的 profile |
| P1 | Phase 2A pass integration | 前两段 production handlers 与真实 typed HIR 已存在；typed HIR 之后仍没有 RepresentationPlan/MIR/最终 verifier handlers | 与 number-only IR 同步实现剩余 production registry；不适用的阶段由 verifier 证明 no-op，不能伪造 effect/fixed-point 完成状态 |
| P0 | `IR-004/005` | `VerifyMIR` 主要把 MIR 映射回 HIR shape，未验证 target RepType、layout、phi/memory、cleanup、GC roots 或 capability binding | 建立真正 MIR schema/lowering/verifier；malformed MIR 在进入 LLVM 前全部拒绝 |
| P1 | `IR-001/007` scope | 通用 `TypeKind`/`VerifyHIR` 已接受 boolean/string，但 Phase 2A 尚无对应 RepType、runtime 或 backend | first-slice production schema/verifier 只接受 number/void；boolean/string/null/undefined 在 Phase 2B 各自连同 representation、ABI 和 Node differential 一起放开 |
| P1 | `REL-001` dependency | 原计划让完整 release runner 阻塞首纵切，但其 artifact/oracle 验收反过来依赖真实 backend | 拆出 `REL-001a` first-slice runner core；`VERT-001` 只依赖 core，完整 `REL-001` 在 `BE-004`/`IR-008` 后关闭 |
| P1 | `VERT-001` | 可运行 LLVM 反馈链已前移并理顺依赖，但 executable 纵切仍未实现 | Linux x86-64、无对象/GC/EH的 `add` 经统一 case runner、real LLVM、object、LLD 后运行，并由 `REL-002a` 与 Node oracle 对照 |
| P1 | `OBJ-000` | structural object view 的 aliasing/identity/GC ABI 未冻结 | ObjectView RepType、layout、trace、读写和 equality 规则；mutable object 禁止隐式 copy adapter |
| P1 | `GC-001` | shadow stack 缺 safepoint 活跃性和优化器约束 | single-mutator v1、active bitmap/dead-slot clear、root store barrier、O2 前后 root audit |
| P1 | `EH-001` | Rust status ABI 与 native unwind 缺桥接契约 | 先冻结全链 status profile；Linux/Windows native EH 分开定义 shim、personality、ownership、rethrow 和链接库 |

### 3.1 测试证据限制

当前 frontend tests 已证明第一 replay happy path 和部分 fail-closed 行为，但尚未证明 lowering readiness：

- fixture 主要把 diagnostics 折叠为 code 集，遗漏 stage/span/profile/capability/type/multiplicity；binding 与 semantic 分类错误可能仍通过。
- snapshot semantic tests 已精确覆盖首批 Symbol/Signature/Flow/Assertion/CaptureSet/property/parameter/effect facts，但广泛 syntax group 仍没有同等精度的 replay/HIR golden。
- 100 个 fixture 已具备 profile/target/runtime/artifact/oracle/timeout/requirements metadata；runner 仍需把每个 case 的隔离、乱序、超时和 artifact/oracle 执行变成持续门禁。
- determinism 已覆盖 fresh serialization replay、独立进程重复输出、显式 first-slice evaluation order、target split 和 case-sensitive identity；并发度、Unicode 与跨 Windows/WSL 的完整组合矩阵仍可加强。
- `test --stage frontend` 当前只运行 `TestFrontendConformanceFixtures`，不会持续执行 validator、ModuleGraph、checker borrow/race、compatibility、CLI、shuffle/repeat 的完整阶段门禁。
- frontend/cmd 尚无 fuzz target；golden 更新由全局环境变量批量控制；checker borrow 的部分 timeout 路径可能遗留不可取消 goroutine。

因此 `FE-010` 标记为 `implemented / acceptance-blocked`：checker-free package/process boundary、显式 first-slice evaluation order、single-block HIR 和 canonical pass prefix 已有证据；单一 wire validator与全量 golden/baseline migration 仍阻断 Phase 1.5。更广泛 runner/fuzz/诊断 DTO 继续作为 `REL-001/003` 和 [testing-conformance-and-release.md](testing-conformance-and-release.md) 的发布门禁。

## 4. 首轮审计中已修复（历史检查点）

本节保留收口过程中的当时状态；现行完成度以 2.1 为准，Phase 2A 职责与顺序以 10.6 为准。

- 建立 snapshot schema v2、source blob、tagged payload、named children、Kind-specific shape registry、legacy decode 与 fail-closed validation；`FE-008a` 现在只剩 capture/wire 一致性和完整 regression。
- checker capture panic/error 不再降为空事实；property/parameter/signature/effect、assertion/non-null/flow/capture/module、per-specifier bindings、lowerer mandatory facts 与 overload ownership/redirect 负例进入 canonical proof；`FE-009a` 剩 wire 单一真源和独立重算证据。
- 建立序列化 snapshot-only `add(number, number)` replay、lowerer readiness registry、canonical HIR、独立 replay 命令和 checker-free wire DTO；显式 primitive evaluation-order/single-block CFG proof 与跨进程重复输出已纳入测试，`FE-010a` 只剩 migration full regression/clean delivery。
- CLI profile merge、case-sensitive logical identity、source-level target-independent FrontendSnapshot、三项 option projection和 typed BuildPlan binding 已落地；`FE-011a` 剩完整回归/clean-clone evidence。
- canonical PassExecutor、specialization fixed point/budget、pre/post verifier、effect proof 与 deterministic dumps 已落地；validate-snapshot -> typed-HIR production prefix 已接入 replay。`IR-000a` 剩全量/clean-delivery 验收，typed HIR 之后的 production handlers/真正 MIR 仍在 Phase 2A。
- compatibility fixture loader/摘要域已迁移到 schema v2；当前 100 个 semantic baseline 和 snapshot/options golden 因后续 DTO/proof 变化再次漂移，必须人工分类后才能更新。
- `[历史，已退役机制]` FND 脚本当时增加 patch metadata/hash/worktree exactness、remote shallow-fetch clean apply 和 Windows long-path cleanup。

这些结果已超过 prototype，但仍不足以关闭 `FE-008..011/IR-000`。baseline 一致只说明当前实现稳定，不证明遗漏事实已经完整；原 overlay、overload redirect、wire dependency closure 和 production prefix binding 已逐步变成 checked-in evidence，剩余双 validator、full regression、exception mode 与 clean delivery 必须继续逐项关闭。

## 5. 首轮调整后的主链（历史检查点）

以下依赖链记录首次调整，不再表示当前待办；现行链见 10.6。

```text
[complete] FE-008/009 single wire validation
  -> [complete] FE-011a target/path/profile/cache regression
  -> [complete] FE-011b truthful no-EH first-slice BuildPlan/default
  -> [complete] FE-010 full migration regression
  -> [complete] IR-000 executable contract infrastructure
  -> [complete] FND-004 authorized parent commit + HEAD clean-clone proof
  -> Phase 2A: remaining production handlers + IR-001a..005a/007a number-only HIR/MIR/verifier
  -> RT-002a empty runtime/startup + BE-001/002a/004a real LLVM/object/link
  -> REL-001a first-slice runner core
  -> VERT-001 Linux real-LLVM executable
  -> REL-002a Node differential
  -> Phase 2B: bool/control flow/calls/more primitive semantics
  -> OBJ-000 + object/closure/layout
  -> GC-001 + core runtime/modules/generics
  -> EH-001 + exception/async
  -> second target + release gates
```

Phase 2A 不按“实现更多 AST Kind”启动，而按“第一条 snapshot-only 可执行纵切”启动；Phase 2B 才允许扩展控制流和更多 primitive semantics。每扩大一个语法组，都必须同时增加 syntax payload、semantic proof、subset rule、HIR/MIR golden、malformed verifier case 和可观察行为差分。

## 6. 架构收敛决定

### Snapshot 与 target

`FrontendSnapshot` 只包含由 source、tsconfig 前端语义、锁定 tsgo/stdlib 和 source profile 决定的事实。target triple、CPU/features、GC、EH、runtime archive 和 emit 请求进入独立 `BuildPlan`；完整 cache key 组合两者，不能让 frontend snapshot 因换 target 无意义失效。

### 对象

结构化对象跨布局默认使用显式 `ObjectView` 或拒绝。只读 view 可以保存 source object 和 accessor/offset mapping；可写 view 只有读写类型、store representation 和 aliasing 均等价时允许。隐式复制不能伪装成 identity conversion。

### GC

GC v1 先做 single-mutator、stop-the-world、non-moving tracing。每个 safepoint 必须发布准确 active roots，死亡 slot 必须清空或由 bitmap 排除；root publication 是优化器可见的 effect，优化后必须重新审计。

### 异常

第一条纵切不启用 EH。Rust helper 的普通失败先走显式 status/result；native unwind 只有在目标专属 bridge contract 完整后才可成为产品 profile，且 Rust frame 默认不参与 TypeScript unwind。

### Rust 产物

首版 core crates 以 `rlib` 组织，由一个 `bingo-runtime` umbrella crate 导出唯一 staticlib，避免重复 allocator/panic/runtime symbols。RegExp/Intl 等重型外部引擎只在 capability manifest 明确声明时作为独立原生依赖加入链接。

### Lock 迁移

当前 lock 已如实记录 snapshot schema 2、`reproducibilityStatus: pinned-fork-commit`、`exceptions=none`、`pqcqaq/typescript-go` fork remote/commit 和 reviewed upstream ancestor；`commit == forkCommit`，且 upstream 必须是 fork commit 的祖先。旧 `reproducible-patch`、patch object、materialize/apply 脚本均已退役。lock 版本变更必须继续由实现、迁移测试、compatibility 分类、远端 fork verification 和 clean-clone 门禁共同驱动，不能只改字段。

## 7. Phase 1.5 实现退出条件（已通过；fork 交付重验待执行）

前五项实现条件已经关闭，Phase 2A 可以按既定依赖继续；这些条件只锁定 frontend/lowering contract，不要求 real LLVM/backend 提前完成。第六项的旧 patch 证据已归档，现行 pinned-fork 交付必须在迁移完成后重新验收：

1. `FE-008a/009a`：`frontendwire.ValidateProgramSnapshot` 成为 serialized validation 单一真源；Kind payload/role、semantic reference、effect/module/lowerer facts 与 overload ownership/redirect 的 checked-in negative tests 全部通过，checker-time AST analyzer 只产出 proof。
2. `FE-011a`：capture 源头 target-independent；semantic options 完整；BuildPlan 只能绑定已验证 FrontendSnapshot/typed key；target/path/profile/cache regression 全绿。
3. `FE-011b`：首切使用 canonical `exceptions=none`（或等价明确名称），default/lock/BuildPlan 不再声称尚未实现的 `llvm-eh`；status-code/native-unwind 保留为后续独立 profile。
4. `FE-010a`：新进程从磁盘 replay；`go list -deps` 闭包无 parser/checker/AST/tsoptions；events/HIR 有显式 primitive evaluation-order/single-block proof；compatibility/snapshot/options migration full regression 全绿。
5. `IR-000a`：executor、specialization budget/fixed point、pre/post verifier hooks、independent effect proof、每步 dump/golden 与 validate-snapshot -> typed-HIR production prefix 通过全量 regression；后续 production handlers 与真正 MIR target/layout verifier留在 Phase 2A。
6. `FND-004a`：关闭条件已满足：`.gitmodules`、lock、parent gitlink 与 checkout 固定同一 `pqcqaq/typescript-go` fork commit，reviewed upstream 是其祖先，doctor、远端 fork fetch/full test/vet、committed parent HEAD clean clone、本地 doctor/full test/vet、frontend 九阶段、replay 双构建及本地和远端隔离 verifier 均已通过。

## 7.1 Primitive vertical slice gate（历史初版；当前以 10.4 节为准）

Phase 1.5 实现条件通过后，首条可运行链按以下顺序闭合：

7. `(IR-007a -> IR-001a -> IR-002a -> IR-003a) || BE-001a || RT-002a`：前者只实现 target-independent number/void TsType/RepType、参数读取、加法、单 block return 的 HIR contract；BE/RT 分别建立 TargetMachine/DataLayout 与 empty runtime/startup scaffold。bool/string/null/undefined、调用和 general CFG 留在 Phase 2B。
8. `BE-001a + RT-002a + BuildPlan -> TC-001a -> IR-004a/005a`：resolver 产出 immutable TargetContext、authoritative DataLayout 和 AvailableCapabilityCatalog；后续 MIR verifier 计算 BoundCapabilityClosure，完整 runtime registry、CFG/call/global backend 不能反向阻塞本纵切。
9. `RT-002b`、`BE-002a/004a`、`REL-001a`、`VERT-001`、`REL-002a`：固定 C ABI、real LLVM/object/LLD、最小 case runner 与 Node `add` oracle 差分；完整 `REL-001` release runner 不作为 Phase 2A 的前置。

更细的 diagnostic DTO（stage/span/profile/multiplicity/capability）和 artifact/oracle execution 在 `REL-001` 闭合；更广泛的 fuzz/并发矩阵继续作为 `REL-003` 门禁，不属于 Phase 1.5 入口条件。

## 8. 明确延后

在 `VERT-001` 前不实现 dynamic/Proxy、WeakRef/finalization、ARC/arena、self-hosted stdlib、native EH、async/generator、Windows backend、statepoint、跨语言 LTO 或完整多 archive capability 选择。它们继续保留在路线图中，但不能阻塞最早的可运行编译器反馈。

## 9. 初次审计验证结果（历史）

本节保留发现缺口时的证据链；其中 patch/materialized-exact/remote apply 命令属于已退役历史机制，不得作为现行交付步骤。当前交付以第 10 节的 pinned-fork 说明为准。

通过：

- CLI profile/snapshot/subset/module/validator 定向测试。
- 同一组高风险定向测试的 Go race run。
- `go vet ./...`。
- `version --json`、`doctor --json` 和当前窄范围 `test --stage frontend --json` smoke；doctor 报告本机与 WSL 工具链完整。
- 54 份父仓库 Markdown 的 fence/local-link/trailing-whitespace 检查，以及父仓库/submodule `git diff --check`。

初次审计时已通过：

- `go test ./internal/bingo -count=1`。
- `go test ./internal/tsfrontend -count=1`，包含 schema v2 fixture loader 和更新后的 compatibility baseline。
- FE replay/readiness/canonical-hash/options/path/BuildPlan 定向测试及其 race/vet。
- `go run ./cmd/ts2bin compatibility --update-baseline` 后的 baseline byte-identical 检查。
- `[历史，已退役机制]` `scripts/doctor.ps1 -Quiet`：旧 lock schema、patch hash、materialized-exact 和 reproducible-patch 全部通过。
- `[历史，已退役机制]` remote checkout 的 strict patch apply、smoke、一次 `go test ./...` 与 `go vet ./...` 有通过日志；旧 `verify-typescript-go-patch.ps1 -SkipFullTests` 曾以 0 退出并完成 long-path cleanup。parent clean clone 当时仍尚未包含根交付物，因此只记为 partial，不记 FND-004 complete。

初次审计时尚未通过/尚未实现：

- `IR-000` executor/fixed-point/pre-post/dump、独立 MIR verifier。
- `VERT-001` real LLVM/object/LLD executable 和 Node differential。
- 完整 frontend stage runner 的 race/shuffle/repeat/fuzz 组合（已有 `scripts/test-frontend.ps1`，但尚未作为本轮全部门禁执行）。
- overlay 负例仍通过：Kind-specific payload/role、raw target-independent hash、三项 TS option projection、typed BuildPlan hash binding，以及 HIR/MIR 无返回/非法 store/entry phi/sparse/duplicate-ID 校验。

反向 overlay 复核（均为当前工作树、未修改仓库）：

```powershell
go test -overlay='C:\Users\qcqcqc\.codex\visualizations\2026\08\04\019fcb6f-8eaf-79e2-afeb-efdfa7b2ad36\frontend_overlay_v2.json' ./internal/tsfrontend -run '^TestAudit' -count=1 -v
go test -overlay='C:\Users\qcqcqc\.codex\visualizations\2026\08\04\019fcb6f-8eaf-79e2-afeb-efdfa7b2ad36\ir_overlay_v2.json' ./internal/bingo -run '^TestAudit' -count=1 -v
go test -overlay='C:\Users\qcqcqc\.codex\visualizations\2026\08\04\019fcb6f-8eaf-79e2-afeb-efdfa7b2ad36\replay_overlay.json' ./internal/tsfrontend -run '^TestAudit' -count=1 -v
```

结果：frontend overlay 的 4 个漏洞断言全部 PASS（错误接受）；IR overlay 的 5 个 verifier 漏洞断言全部 PASS（错误接受）。replay overlay 中的旧“第二个 return 被接受”断言 FAIL，说明 exactly-one-return 修复有效；同一 overlay 的 raw backend-dependent hash 断言 PASS，说明 FE-011 仍未在 capture 源头闭合。

### 9.1 二次复核验证（历史检查点）

初次 overlay 结论是发现问题时的历史证据；对应实现已经变化，最终关闭应以 checked-in negative tests 和以下新命令为准。二次复核结果：

- `go list -deps ./cmd/ts2bin-replay` 仅匹配包名 `internal/ast2bingo`，不再列出 `internal/ast`、`binder`、`parser`、`checker` 或 `tsoptions`，说明 production replay 依赖闭包方向正确。
- `go test ./internal/bingo` 通过，包含 canonical PassExecutor/fixed-point/hooks/effect/dump tests。
- `go test ./internal/frontendwire` 通过，覆盖 wrapper unknown-field、rehashed corruption 和 embedded Kind manifest；仍缺 capture/wire validator parity 与 effect-helper drift 负例，现有测试不能证明单一规则。
- 初次联合运行暴露的 `KindImportType`、`KindTypeLiteral` effect registry 分类不一致已修复；`go test ./internal/ast2bingo ./cmd/ts2bin-replay`、FE effect/shape/BuildPlan 定向测试和 `go test ./internal/bingo` 通过。全量 `go test ./internal/tsfrontend` 仍因 compatibility baseline、snapshot fixture 和 default-options golden 漂移失败。
- `[历史，已退役机制]` `scripts/doctor.ps1 -Quiet` 当时失败：`typescript-go patch state=divergent`，worktree diff 不匹配 locked patch；该失败处理路径已由 pinned-fork commit/ancestry/remote verification 取代。

因此在该历史检查点不能宣布 Phase 1.5 complete。失败是明确的迁移验收阻断，不推翻架构方向，也不应回退 `frontendwire` 拆分；先统一 wire/capture registry 与 canonical DTO，再人工审查并更新有意变化的 baseline/golden。

## 10. 二次审计收口（当前事实源）

本节 supersede 前文在实现收口前记录的 `acceptance-blocked` 说明；历史证据仍保留用于解释为什么这些门禁被加入。总体方向确认不变：

```text
typescript-go checker
  -> target-independent frontendwire snapshot
  -> typed Bingo HIR
BuildPlan + toolchain/runtime manifests
  -> ResolveTargetContext
typed HIR + TargetContext
  -> RepresentationPlan -> target-aware MIR
  -> LLVM/object
  -> Rust C ABI staticlib + LLD
```

### 10.1 已关闭的 Phase 1.5 实现门

- `FE-008a/009a`：`frontendwire.ValidateProgramSnapshot` 是唯一 serialized validator；`tsfrontend.ValidateProgramSnapshot` 仅委托它。capture 侧仍可生成 checker-time proof，但 serialized tree/shape/effect/module/required-fact 规则不再复制。
- `FE-011a`：项目内 `BaseURL`、`RootDirs`、`TypeRoots` 和 paths substitutions 已相对化；wire validator 在 digest/content hash 之前拒绝残留 drive、UNC、POSIX rooted path，并覆盖 source file、module、diagnostic span 和 config identity。合法的 `../...` 与 `@stdlib/...` 仍保留为可搬迁身份。Windows/WSL 同根 bytes/hash 回归及跨盘 fail-closed 回归通过。
- `FE-011b`：默认、golden、lock 和 BuildPlan 均使用 `exceptions=none`；`llvm-eh` 仅作为未来常量并明确 `unavailable`，不再作为已支持 provenance。
- UTF-8 wire 规范化：checker 合成符号名先规范化为有效 U+FFFD；专门的 capture -> canonical encode -> decode -> re-encode 测试通过。Kind/API/stdlib baseline 完全不变，100 个 semantic digest 中 28 个为可解释的符号名规范化变化，snapshot contract golden 只有一处 U+FFFD 表达变化，config golden 不变。

### 10.2 BuildPlan 的准确边界

`BuildPlan` 现在明确是绑定 `FrontendSnapshot` hash 的 canonical unresolved backend request。`ResolveBuildPlan(FrontendSnapshot, buildConfig)` 只做 defaults、canonicalization、枚举/哈希完整性和 frontend binding；它不证明 host toolchain、LLVM data layout、runtime archive、GC/EH capability 或 target 可执行。source subset gate 只消费 snapshot，并将未实现的 BigInt/RegExp lowerer 报为 target-independent `subset.lowerer_unavailable`；所选 runtime 缺 capability 属于 resolver 之后的诊断。Phase 2A 的硬边界改为：

```text
BuildPlan
  -> ResolveTargetContext(toolchain manifest, runtime manifest, LLVM TargetMachine)
  -> immutable TargetContext + authoritative DataLayout
     + AvailableCapabilityCatalog
  -> RepresentationPlan
  -> target-aware MIR -> structural MIR verifier
  -> BindRuntimeCapabilities -> BoundCapabilityClosure + frozen effects
  -> LLVM/object/link
```

任何表示规划、MIR、LLVM 或链接代码都不得直接消费未解析的 `BuildPlan`。`TC-001a` 只接受显式 Linux x86-64、LLVM 20、generic CPU、锁定 runtime 和 no-EH 组合；空 target、interop/unsafe、ARC/arena、bounds-off、未知 runtime/feature 均应稳定返回 `unavailable`。LLVM `TargetMachine` 查询的 DataLayout 是唯一权威值；toolchain manifest 只锁定 expected layout/hash，ABI layout manifest 只交叉校验且 mismatch 时 fail closed。`AvailableCapabilityCatalog` 只表示 manifest 的可用目录，实际程序闭包必须在 structural MIR 后生成 `BoundCapabilityClosure`。TC-001a 必须引入保存 canonical bytes/digest 的 typed resolver envelope；当前 pass state 的 `[]string` facts 只表达顺序，不能作为 target/capability proof。IR-004a 的 RepresentationPlan join pre-verifier 再核对 HIR FrontendSnapshotHash、BuildPlan.FrontendHash 和 resolver hashes。Link 接受相同 immutable TargetContext/hash，只复验 manifests/artifacts，不重新 ResolveTargetContext。这保留了 frontend 的 target independence，同时不把通用请求 schema 误标成可执行能力。

### 10.3 交付证据

此前工作树在旧 patch 机制下通过过以下实现回归；这些命令结果仅作历史证据，旧 patch hash 和 materialize/apply 路径均已失效：

```text
go test ./internal/frontendwire ./internal/tsfrontend ./internal/ast2bingo ./internal/bingo ./cmd/ts2bin ./cmd/ts2bin-replay -count=1
go test -race ./internal/frontendwire ./internal/tsfrontend ./internal/ast2bingo ./internal/bingo ./cmd/ts2bin ./cmd/ts2bin-replay -count=1
go vet ./...
.\scripts\test-frontend.ps1 -Stage all -RepeatCount 5
go test ./... -count=1
```

`[历史，已退役机制]` 二次审计时的核心六包、frontend 九阶段、全仓 test/vet、doctor materialized-exact、`b2dca40` clean clone 与 isolated patch apply 曾通过；旧 patch SHA-256 只解释当时证据，不代表现行 checkout。

现行交付使用 `pqcqaq/typescript-go` 的 pinned fork commit、reviewed upstream ancestor 和显式 upstream merge。相关 `.gitmodules`、lock 与脚本迁移已经落盘；本地 doctor、迁移后的 frontend/全仓回归、locked replay 双构建和隔离 fork full test/vet、远端 fork fetch/full test/vet，以及 committed parent HEAD clean-clone 已通过；`FND-004` 已关闭。

### 10.4 调整后的 Phase 2A 顺序

1. `FE-012a` 先让 subset gate/lowering 只消费 validated snapshot/envelope；裸 gate 结果不能作为 HIR proof。
2. `IR-007a -> IR-001a -> IR-002a -> IR-003a` 冻结并验证 target-independent number/void HIR contract，同时协调升为 HIR schema major 2、加入 `CompilerBuildIdentity` 与 logical capability requirements。
3. `BE-001a`（Go-LLVM/TargetMachine/DataLayout）与 `RT-002a`（Rust workspace/empty startup scaffold）并行。
4. `BE-001a + RT-002a + BuildPlan -> TC-001a` 用 typed multi-artifact resolver envelope 绑定 BuildPlan/manifests，产出 immutable TargetContext、authoritative DataLayout 和 AvailableCapabilityCatalog，同时原样保留 HIR；resolver 不语义读取 HIR，首次 provenance join 保留给下一步 RepresentationPlan。
5. `IR-003a + TC-001a -> IR-004a/005a` 先在 RepresentationPlan join 核对 HIR/BuildPlan/compiler identity/context provenance，再实现 target-aware number/void MIR 与 structural/final verifier；`RT-002b` 固定 `extern "C" double add(double,double)` harness，`BE-002a/004a` 完成 real LLVM/object/LLD。
6. `REL-001a -> VERT-001 -> REL-002a` 形成 snapshot-only 到 process/Node oracle 的首条可观察纵切；通过前不扩展 bool、调用、general CFG、对象、GC、EH、async 或第二目标。

### 10.5 Phase 2A 入口风险（历史检查点，已由 10.6 复审）

以下是进入 2026-08-06 复审时的风险原貌，不代表当前未关闭状态；其中 patch identity 是已退役交付机制的历史表述。现行结论与开发顺序以 10.6 为准。

- 当前 HIR/replay/lock 仍标 schema major 1，但 mandatory provenance 已在 pre-release 期间扩展。`IR-001a` 必须协调升 major 2并增加旧 major 拒绝/migration tests，不能把当前 v1 当成稳定兼容承诺。
- `[历史，已退役机制]` HIR provenance 当时只有 upstream tsgo commit，不足以区分同一上游基线上的不同补丁。现行 `CompilerBuildIdentity` 覆盖 upstream commit、fork commit 与 lowering schema/hash，并进入 HIR/MIR/artifact/cache key。
- 当前 production replay 在 HIR 构造前完整验证 snapshot，`Frontend.Build` 也只返回最终验证通过的 snapshot；但公共 `RunSubsetGate` 本身不执行完整 validator。`FE-012a` 必须把 capture-core validation 与 diagnostic sealing 分层，并让 gate 接受 validated token/envelope 或自行 fail closed。
- 当前 `PassState.Artifact + Facts []string` 只能证明执行顺序，不能证明 resolver 输入或 join。`TC-001a` 必须引入 typed multi-artifact envelope；`IR-005a` 还要补 module-level duplicate FunctionID、MIR provenance，以及 non-empty available catalog 与 empty add bound closure 的分层负例。

这些项是 Phase 2A 首切的实现入口；Phase 1.5 实现契约已经关闭，但 pinned-fork clean-delivery gate（`FND-004a`）仍待执行。任何一项未关闭都不能生成可交给 LLVM 的 target-aware MIR。

### 10.6 Phase 2A 入口契约复审（2026-08-06）

第 10.5 节记录的是进入本轮时的风险清单；当前实现证据已关闭前三项，并纠正了第四项的职责边界：

1. `FE-012a` complete：capture-core validation、subset decision 与最终 diagnostic sealing 已分层；返回 snapshot 是 canonical 深拷贝，公开 gate 自行完整验证，replay 三种 wrapper 均拒绝重哈希 flags/modifiers/type-closure 篡改。
2. `IR-007a/001a/002a/003a` complete：number contract v1、HIR major 2、完整 CompilerBuildIdentity、identity-free source plan、logical requirements、number-only lowering与 verifier negative matrix 已闭合；不同 upstream/fork driver identity 产生不同 HIR provenance/hash，独立 CLI 输出保留注入 identity。
3. typed artifact envelope substrate complete：role/schema/payload digest、canonical bytes、不可变 executor transition 与 typed read/write metadata 已实现，但它不等于 `TC-001a` 的真实 resolver。
4. 方向纠正：`ResolveTargetContext` 的语义输入只有 BuildPlan/toolchain/runtime manifests。HIR 可随 envelope 不可变保留，但不得被写成 resolver 依赖；`RepresentationPlan` 才首次验证 HIR、BuildPlan、TargetContext/DataLayout/catalog 的 provenance join。

因此下一开发顺序调整为 `BE-001a || RT-002a -> TC-001a -> IR-004a/005a -> RT-002b + BE-002a/004a -> REL-001a -> VERT-001 -> REL-002a`。`TC-001a` 在真实 LLVM DataLayout 与 runtime/toolchain manifests 出现前保持 pending；MIR v1 的兼容 verifier 修复和通用 JSON envelope 都不能冒充它已完成。
