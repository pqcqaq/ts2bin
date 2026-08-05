# Rust Runtime Core 与静态链接规格

本文固定 `bingo-rt` 的实现语言、安全边界、构建产物和最终链接流程。Bingo 编译器前端与 LLVM backend 仍使用 Go；随用户程序发布并进入目标进程的 runtime core 使用 Rust，实现为目标相关的原生静态库。标准库的 API 覆盖、capability 和语义分组仍以 [stdlib-runtime-plan.md](stdlib-runtime-plan.md) 为准，具体对象、GC、异常和 LLVM 映射仍以 [runtime-and-backend-lowering-algorithms.md](runtime-and-backend-lowering-algorithms.md) 为准。

## 1. 架构决策

首版固定以下组合：

```text
runtime implementation  = Rust
runtime artifact        = exactly one umbrella staticlib (.a / .lib)
internal crate artifact = rlib only
public ABI              = versioned extern "C"
panic policy            = abort; no panic crosses the ABI
language exception      = explicit status/result -> Bingo MIR exception edge
memory management       = Bingo-owned single-mutator STW non-moving tracing GC
linker                  = LLD family selected by target object format
stdlib algorithms       = Rust primitives + verified self-hosted TypeScript
```

选择 Rust 的目的，是把字符串、集合、调度器和标准库算法的大部分实现保持在 safe Rust 中，并将原始指针、布局、GC 和平台 ABI 的不安全操作集中到少数可审计模块。Rust 的类型安全不能替代 Bingo 的 MIR verifier、root map、write barrier 或 ABI 校验；它只缩小必须使用 `unsafe` 的范围。

每个 target/profile/feature set 只发布并链接一个 `bingo-runtime` umbrella `staticlib`。workspace 内部的 `bingo-abi`、memory、core、collections、async、resource 和 platform crate 只以 `rlib` 依赖进入 umbrella；不得把它们分别构建为多个 `staticlib` 再混链。Rust `staticlib` 会封装其 Rust 传递依赖，多个内部 archive 容易重复带入 allocator、panic/runtime、personality、标准库和全局 metadata symbol，并使链接顺序决定实际实现。BigInt、RegExp、ICU 等非 Rust runtime core 的重型外部引擎可以由 manifest 作为独立原生 archive 加入，但不改变“一个 Rust umbrella staticlib”的规则。

以下方案不作为首版核心：

- 不使用 Go 实现目标 runtime，避免引入第二套 GC、调度器、panic/unwind 和较大的 Go 运行时。
- 不把 Rust ABI、trait object、标准库容器或 panic 直接暴露给 LLVM 生成代码。
- 不手写整套 LLVM IR runtime；LLVM IR 只用于生成代码、平台 EH 和必要的目标 shim。
- 不把 Rust LLVM bitcode 作为稳定发布接口。Rust 编译器、LLVM major 和内部 metadata 会使 bitcode 跨版本契约过于脆弱；首版只发布一个 umbrella 原生 archive。
- 不把完整 JavaScript engine 作为 static profile 的对象模型。QuickJS 等实现只可作为 differential oracle 或未来独立 dynamic profile。

## 2. 编译与链接流水线

```text
TypeScript source
  -> tsgo snapshot
  -> Bingo HIR/MIR
  -> LLVM module/object
  -> app.o / app.obj

verified self-hosted stdlib
  -> specialization / descriptor sharing
  -> stdlib.o / stdlib.obj

Rust bingo-runtime workspace
  -> cargo/rustc for locked target and profile
  -> libbingo_runtime.a / bingo_runtime.lib

startup object + app object + stdlib object
  + exactly one Rust umbrella staticlib
  + optional manifest-selected external-engine archives
  -> target LLD driver + explicit host libraries
  -> executable/shared artifact
```

`ts2bin build` 不临时编译任意工作树中的 runtime 源码。正式发布随 CLI 携带按 target/profile 预构建且签名锁定的 umbrella archive、startup object、capability manifest 和 ABI/layout manifest。开发模式可以显式使用本地 runtime build，但其完整 hash 必须进入 provenance，且不得污染 release cache。

## 3. Rust Workspace 与职责

建议目录：

```text
runtime/bingo-rt/
  Cargo.toml
  rust-toolchain.toml
  crates/
    bingo-abi/            # internal rlib: repr(C) ABI、状态码、schema
    bingo-memory/         # internal rlib: heap、GC、root、barrier
    bingo-core/           # internal rlib: string、object、array、error
    bingo-collections/    # internal rlib: collection/iterator storage
    bingo-async/          # internal rlib: promise、scheduler、handles
    bingo-resource/       # internal rlib: dispose、cleanup adapters
    bingo-platform/       # internal rlib: TLS、thread、EH/link shims
    bingo-regexp/         # internal rlib adapter; engine may be external
    bingo-intl/           # internal rlib adapter; ICU may be external
    bingo-runtime/        # only crate_type=staticlib umbrella exporter
  include/                # 从 bingo-abi 生成并锁定的 C ABI header
  manifests/              # capability、layout、target 和构建 provenance
  tests/
```

依赖方向固定为：

```text
bingo-abi
  <- bingo-memory
  <- bingo-core
  <- collections / async / resource
  <- optional regexp / intl / platform
  <- bingo-runtime umbrella staticlib
```

除 `bingo-runtime` 外，workspace crate 的发布 crate type 固定为 `rlib`。runtime crate 不依赖 TypeScript AST、checker、Bingo HIR 或 CLI；它只依赖版本化 ABI 类型、编译器生成的 descriptor/layout 数据和显式 host capability。

## 4. 公共 ABI

所有跨 LLVM/Rust 边界的类型必须是 `#[repr(C)]` 的固定布局数据、整数、浮点、函数指针或不透明 handle。禁止暴露 Rust `String`、`Vec`、`HashMap`、引用、slice、默认布局 enum、trait object、future 和 closure。

```rust
#[repr(C)]
pub struct BingoStatus {
    pub code: u32,
    pub exception: *mut BingoException,
}

#[repr(C)]
pub struct BingoUtf16View {
    pub data: *const u16,
    pub len: usize,
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn bingo_rt_string_concat_v1(
    left: *mut BingoString,
    right: *mut BingoString,
    output: *mut *mut BingoString,
) -> BingoStatus {
    // ABI validation and rooting are unsafe; the semantic worker is safe Rust.
    match unsafe { string_concat_from_abi(left, right, output) } {
        Ok(()) => BingoStatus::success(),
        Err(error) => error.into_status(),
    }
}
```

导出符号遵循 `<namespace>_<operation>_v<abi-major>`，例如 `bingo_rt_array_push_v1`。每个符号在 capability manifest 中声明：

```text
logical capability ID
exported symbol
ABI major and signature hash
RepType parameters/result
ownership and nullability
MayAllocate / MayThrow / MaySuspend / MayBlock
required roots and write-barrier behavior
target/profile constraints
implementation artifact hash
```

ABI header 由 `bingo-abi` 的单一 schema 生成。Rust、Go backend 和测试不得各自维护一份字段顺序或常量副本。CI 必须比较 Rust `size_of/align_of/offset`、manifest 和 LLVM DataLayout 计算结果。

## 5. Safe Rust 与 Unsafe 边界

允许使用 `unsafe` 的区域必须收敛到：

- `extern "C"` 参数解码、空指针和 descriptor 验证。
- Bingo GC heap 的对象分配、trace、sweep 和 pointer bitmap。
- shadow stack/root slot 注册和 safepoint reload。
- write barrier、原子、TLS、平台调用和外部库 FFI。
- 固定 ABI layout 与原始字节/UTF-16/TypedArray 视图。

String、Array、Map/Set、Promise 状态转换和大部分标准库算法应由 safe Rust 实现。每个 `unsafe` block 必须有局部安全契约，说明指针对齐、有效期、alias、GC root 和并发前置条件。

GC handle 不得提供可跨 safepoint 任意保存的 Rust 引用：

```text
Gc<T>       stable non-moving heap handle; not a root by itself
Root<T>     registered root valid for a lexical/runtime scope
Weak<T>     non-root weak handle resolved through the collector
ExternRef   host-owned handle governed by an FFI manifest
```

强制规则：

1. `Gc<T>` 不允许通过无约束 `DerefMut` 长期借用 payload。
2. 任何 MayAllocate/MaySuspend/MayBlock/MayEnterHost 调用前，活跃 `Gc<T>` 必须进入 `Root<T>` 或编译器生成的 root slot。
3. Bingo GC object 不由 Rust `Drop` 释放；`Drop` 只能清理 runtime 自身的非 GC 资源。
4. Rust `Box`/`Arc` 可用于 frozen manifest、平台 handle 等 runtime 元数据，不能替代普通 Bingo 对象的 tracing heap。
5. `GcRef` 和 `ExternRef` 不得相互 cast；FFI pin/handle 规则必须显式存在。
6. collector 即使首版非移动，也保留 write-barrier 和 root API，防止实现把“当前不移动”误当作无限生命周期证明。

GC v1 的 thread contract 是运行时 ABI 的一部分：每个 runtime instance 只有一个 owning mutator thread 可以读写 Bingo heap、运行 TypeScript callback 或进入 collection。scheduler/IO worker 只能处理不含裸 `Gc<T>` 的 host-owned 数据并向 mutator 投递消息；跨线程 callback 必须排队，不能直接重入。`Root<T>` 和 shadow-stack frame 只能由 owning mutator 注册/注销，runtime 在每次 ABI 入口校验 thread identity。`SharedArrayBuffer`/`Atomics`、第二 mutator、并发/增量 collector 和跨线程直接 heap handle 在 v1 稳定拒绝，启用它们需要新的 ABI/effect/verifier profile。

## 6. `std`、分配器与 Panic 策略

实施分两步：

1. 端到端原型允许 `bingo-runtime` 使用受控 `std`，但宿主文件、网络、环境、时间和线程能力必须通过 platform capability 隔离。
2. ABI、GC 和核心对象稳定后，将 `bingo-abi`、`bingo-memory`、`bingo-core` 收敛到 `no_std + alloc`；platform、Intl、RegExp 等可选 crate 可保留 `std`。

release profile 固定 `panic=abort`。任何用户输入、OOM policy、边界检查、转换失败和 TypeScript exception 都不得依赖 Rust panic。内部实现使用 `Result<T, RuntimeError>`，在最外层 ABI 转换为 `BingoStatus`、out-result 和已 root 的 exception handle。

首个可执行异常 profile 是全链 status-code：所有 MayThrow ABI 导出以 status/result 返回，LLVM 调用点显式分支到 MIR exception successor，cleanup dispatcher 执行 `finally`、resource dispose、root frame 注销和 handle release。普通 Rust frame 永远不允许被 TypeScript/外部异常展开，Rust helper 默认 `nounwind`。

native-unwind 只能作为后续、单独锁定的 target profile 出现。LLVM generated code 与极薄平台 EH shim 负责把 `ExceptionCarrier` 交给 Itanium 或 MSVC 机制；该 shim 必须定义 personality、carrier ownership、foreign exception policy、rethrow、uncaught boundary、shadow-stack cleanup 和链接库。即使在 native-unwind profile，普通 Rust helper 仍以 status 返回。status-code 与 native-unwind 的 object、startup、umbrella archive 和 ABI note 不得混链；这样 `finally`、GC root 和 cleanup 的事实始终由 MIR 控制，而不是交给 Rust panic runtime。

## 7. 标准库实现分层

标准库不应全部写成 Rust。固定三层：

| 层 | 适合内容 | 交付形式 |
| --- | --- | --- |
| Rust primitives | GC、内部槽、UTF-16 storage、array buffer、hash/equality、Symbol、exception、microtask | 唯一 target-specific umbrella `staticlib` 中的 capability |
| self-hosted TypeScript | Array/String 高阶方法、Set composition、Iterator Helpers、Promise combinator、DisposableStack 等规范算法 | verified Bingo HIR/package；按需 specialization 或 descriptor sharing |
| external engine adapter | BigInt、ECMAScript RegExp、ICU/Intl、timezone/Temporal、host API | umbrella 内的 `rlib` adapter + manifest 锁定的可选外部 archive/data |

泛型 self-hosted stdlib 不预先穷举成固定 archive。发布物携带锁定且已验证的 stdlib HIR/package；构建用户程序时根据 `InstantiationKey` 单态化，或在表示兼容时调用 descriptor-shared 实现。常用实例可进入按 target/profile/version 分区的 artifact cache。

static profile 的内建 prototype/shape 必须遵守支持矩阵的冻结规则。Proxy、任意 prototype mutation、开放 property descriptor 和完整动态反射不能因为 Rust runtime 能实现就自动进入 static profile。

## 8. 构建产物与版本锁定

runtime 使用 Cargo/rustc 按锁定 toolchain、target 和 profile 构建：

```text
runtime/<target>/<profile>/
  bingo-startup.o | bingo-startup.obj
  libbingo_runtime.a | bingo_runtime.lib
  external/                 # optional manifest-selected engine archives/data
  capabilities.json
  abi-layout.json
  runtime.lock.json
```

`runtime.lock.json` 至少记录：

```text
Rust toolchain and target
Cargo.lock hash and enabled features
runtime source commit
runtime ABI major
capability and layout hashes
panic/std/gc/exception profiles
external dependency and data hashes
umbrella archive, startup object and external artifact digests
```

umbrella archive 按函数/数据 section 构建，最终链接启用 ELF `--gc-sections`、Mach-O `-dead_strip` 或 COFF `/OPT:REF`。Cargo feature 决定 umbrella 中编译哪些 Rust capability；ICU、RegExp、BigInt 等外部引擎 artifact 只有被 manifest capability 闭包选择时才单独加入。v1 不提供 Atomics capability，因为 single-mutator profile 明确拒绝共享 heap 并发。

首版不把 Rust bitcode 或跨语言 LTO 作为发布契约。Rust crate 内部可以使用其 toolchain 支持的优化；Bingo 用户代码与 runtime 之间的优化边界保持版本化 C ABI。若未来加入跨语言 LTO，必须作为独立 runtime/profile、锁定 rustc 与 LLVM major，并重新审计 unwind、root 和 symbol visibility。

## 9. 最终链接算法

```text
Link(targetContext, targetContextHash, verifiedMIR, appObjects):
  1. Accept the already resolved immutable TargetContext and hash; revalidate
     target/toolchain/runtime manifests, but do not resolve or select a target again.
  2. Compute (or verify) the transitive BoundCapabilityClosure from bound MIR intrinsics.
  3. Select exactly one umbrella runtime whose target/profile/features/ABI hashes match.
  4. Compare capability signatures, layout manifest and exception/GC profiles.
  5. Add startup object, app/stdlib objects and that one umbrella staticlib.
  6. Add only manifest-selected external-engine archives and platform/host libraries;
     never search implicit user paths.
  7. Write a deterministic linker response file in stable ModuleId/capability order.
  8. Invoke ld.lld, lld-link or the selected Mach-O LLD-compatible driver.
  9. Reject unresolved runtime symbols, duplicate ABI majors or incompatible runtime notes.
 10. Publish atomically and embed complete provenance in the artifact.
```

`ts2bin doctor` 必须报告 Rust runtime 是否覆盖当前 target/profile，并显示 rustc build ID、umbrella archive hash、LLD、ABI/layout/capability hash 和缺失的外部数据。release linker 不得从系统默认路径偶然找到另一个 `bingo-runtime`。

## 10. 测试与审计门禁

Rust runtime 最低门禁：

- `VERT-001` 在 clean build 中生成唯一空 umbrella archive，并与真实 `add(number, number)` object/startup 经 LLD 链接运行；link map 证明没有第二个 Rust runtime archive。
- `cargo fmt --check`、锁定 lint/clippy 规则和独立 crate tests。
- ABI symbol、signature、size/alignment/offset 与 Go/LLVM schema 的双向测试。
- `unsafe` 模块的 Miri/模型测试；原始 heap、FFI 和平台代码另做 sanitizer/目标机测试。
- single-mutator/第二 mutator 拒绝、跨线程 callback 排队、GC cycle、O0/O2 root across call/throw/await、dead root slot、write barrier、weak/finalization 和 OOM/failure path。
- `panic=abort` release build 中，用户输入不得触发 panic；导出函数 fuzz 必须返回结构化 status，status/native-unwind artifact 混链必须稳定失败。
- umbrella archive 的 capability closure、dead-strip、重复 ABI 和错误 target/profile 负例；内部 Rust `staticlib` 混链必须被拒绝。
- self-hosted stdlib 的 HIR/MIR golden、Node/Test262 differential 和 specialization determinism。
- Rust toolchain、Cargo feature、external data 或 archive hash 变化必须触发 D3/D4 审计和可复现构建检查。

## 11. 实施顺序

1. 建立 `bingo-abi` schema、内部 `rlib` workspace、唯一 umbrella `staticlib` 和 deterministic response file；同时由 `BE-001a` 建立 LLVM TargetMachine/DataLayout 基座。
2. 由 `RT-002a` 建立 empty startup 与 manifest scaffold，再由 `TC-001a` 绑定 TargetContext、DataLayout 和 AvailableCapabilityCatalog。
3. 完成 `VERT-001` 所需的 number-only object/link path：把真实 go-llvm 生成的 `add(number, number)` object 经 LLD 链接并运行；此步不依赖 GC/EH。
4. 实现 status/panic boundary、TargetContext 对应 umbrella 选择、artifact note/hash 与 profile 混链拒绝。
5. 实现 allocator、ObjectHeader、descriptor、single-mutator shadow-stack root、最小 tracing GC 和 String，并通过 O0/O2 forced-collection root tests。
6. 实现 dense Array、closure/runtime handle、Error，并完成第一条有分配和 callback 的纵切。
7. 加入 self-hosted stdlib package，先实现 String/Array/Math 的小型能力闭包。
8. 加入 Map/Set、iterator、Promise/microtask 和 resource crate；语言异常继续使用 status-code。
9. Linux/Windows bridge contract 通过后再构建独立 native-unwind umbrella profile。
10. 分别接入 BigInt、RegExp、Intl/Temporal 和 dynamic/host adapter；每项使用独立 capability，外部 engine archive 由 manifest 选择。
11. core 稳定后收敛到 `no_std + alloc`，再评估第二 mutator、并发 GC、statepoint 或跨语言 LTO。

一个 runtime 功能只有同时具备 safe/unsafe 契约、ABI schema、capability、target umbrella archive、失败策略、GC/effect 标记、链接闭包和 conformance 测试，才算可由 static profile 调用。
