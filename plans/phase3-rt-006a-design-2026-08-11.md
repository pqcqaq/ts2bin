# RT-006a Minimal Tracing Heap

Status: `SelfAudited`. This D3/A3 slice implements the smallest runtime heap that can safely support a later owned-object vertical slice. It binds the already frozen object-layout and GC root contracts to a single-mutator, stop-the-world, precise, non-moving mark-sweep implementation. Automatic CI remains owner-deferred; this slice cannot claim `Integrated` locally.

## Issue Brief

- ID / phase: `RT-006a`, Phase 3 order 4.
- Dependencies: self-audited `OBJ-000b/BE-004b`, `GC-001a/BE-003b`, and the existing single-umbrella-staticlib runtime.
- Change / audit level: D3 / A3. The implementation owns raw allocation, descriptor decoding, root traversal, tracing, sweeping, and an exported C ABI.
- Deliverables: a dedicated `bingo-memory` rlib, generated ABI declarations, runtime exports, exact root-frame traversal, cycle/root stress tests, malformed descriptor/frame/reference rejection, C ABI smoke, and archive/provenance determinism.
- Non-goals: moving, concurrent, or incremental collection; weak references; finalization; async/generator frames; runtime handles; globals/TLS root tables beyond the owning shadow stack; user-visible object lowering; collection tuning or production OOM policy.

## Ownership And Allocation

`bingo-memory::Heap` is the sole owner of Bingo heap allocations. Each allocation uses the frozen shape extent/alignment, is zero-initialized, and starts with a `BingoObjectHeaderV1`. Rust `Box`/`Arc` do not own Bingo objects. Allocation metadata records the raw allocation layout and a validated copy of reference-field offsets, so collection never needs to trust mutable descriptor memory.

The allocator validates before touching object memory:

1. shape and trace schema versions equal v1;
2. object size agrees across shape and trace and includes the complete header;
3. alignment is a supported power of two and satisfies header/pointer alignment;
4. every reference offset is pointer-aligned, unique, ordered, and fully inside the object;
5. v1 callback and bitmap modes are absent unless this slice explicitly implements them.

Allocation failure and malformed boundary input return a stable status. No exported ABI function unwinds or uses panic as input validation.

## Mark And Sweep

Collection starts only while the owning mutator is stopped at a published-root state. The collector:

1. walks the linked shadow-stack frames from newest to oldest;
2. reads only slots selected by each frame's published active bitmap;
3. rejects a non-null root that is not an allocation owned by this heap;
4. marks with an explicit worklist and traces only the allocation's copied pointer offsets;
5. rejects a reachable non-null field reference outside the heap;
6. sweeps every unmarked allocation and clears the mark bit on survivors.

Non-moving allocation keeps object addresses stable. Cycles survive only when reachable from an active root and are reclaimed together after that root is cleared. Unreachable objects are never dereferenced during tracing, so stale references contained only in unreachable garbage cannot create undefined behavior.

## Shadow Stack ABI

The generated ABI adds `BingoGcFrameV1` and `BingoGcStatsV1`. A frame contains its previous link, caller-owned slot array, slot count, and a v1 64-bit active bitmap. The exported operations are:

```text
bingo_gc_heap_reset_v1
bingo_gc_alloc_v1
bingo_gc_frame_link_v1 / bingo_gc_frame_unlink_v1
bingo_gc_root_store_v1 / bingo_gc_root_clear_v1
bingo_gc_root_publish_v1 / bingo_gc_root_reload_v1
bingo_gc_safepoint_v1 / bingo_gc_collect_v1
bingo_gc_write_barrier_v1
bingo_gc_stats_v1
```

All operations return a stable `BingoGcStatusV1`; pointer results use validated out-parameters. Root stores and reloads address slots by canonical zero-based ABI index. A frame may be linked once, must unlink in LIFO order, and may publish only bits below its slot count. Reset is accepted only with no linked frame.

The runtime process has one heap and one owning mutator thread. The first successful heap operation claims ownership. An ABI call from another thread returns `wrong_thread`; it does not create a second implicit heap. Rust crate tests instantiate independent private `Heap` values; cross-ABI tests run in isolated processes.

## Barrier And Safepoint Contract

`bingo_gc_safepoint_v1` performs a collection in this correctness-first slice, providing deterministic forced-collection evidence at every tested safepoint. Later threshold tuning may skip some collections without changing the ABI or root semantics.

The v1 stop-the-world write barrier is a no-op after validating that a non-null owner and value belong to the current heap and that the slot offset is a pointer-aligned in-object location. Keeping the call in the ABI preserves the frozen compiler effect contract for later incremental/concurrent profiles.

## Stable Statuses

- `BINGO_GC_OK`
- `BINGO_GC_INVALID_ARGUMENT`
- `BINGO_GC_WRONG_THREAD`
- `BINGO_GC_OUT_OF_MEMORY`
- `BINGO_GC_CORRUPT_HEAP`
- `BINGO_GC_FRAME_STATE`

## Verification Plan

- Rust unit tests: allocation/header initialization, rooted survival, unrooted sweep, rooted/unrooted cycles, dead-slot exclusion, multi-frame traversal, stable addresses, malformed layouts, foreign roots/references, frame LIFO, reset and barrier validation.
- ABI test: compile a standalone C program from the generated header, allocate a two-object cycle, force collection while rooted, clear the root, collect, and audit stats.
- Tooling: generator `--check`, `cargo fmt`, locked clippy/tests, Miri when the locked component is available, release staticlib rebuild twice, archive hash equality, link smoke, and runtime manifest provenance.
- Compiler regression: existing Go tests, GC verifier tests, LLVM O0/O2 root ordering on both authoritative targets, and `git diff --check`.

## Exit Criteria

`RT-006a` reaches `SelfAudited` only when the implementation matches this contract, unsafe blocks carry local safety reasoning, positive and malformed tests pass independently, the generated ABI is synchronized, runtime rebuilds are deterministic, documentation is synchronized, and all local gates pass. Only then may `VERT-010` allocate the first user-visible owned object. Owner-deferred CI prevents an `Integrated` claim.

## Self-Audit Evidence

- `bingo-memory` validates v1 shape/trace metadata, copies pointer offsets, allocates zeroed non-moving objects, performs exact-root mark/sweep, rejects foreign roots/references, and preserves stable addresses through repeated collection.
- Rust tests cover rooted/unrooted objects, rooted and unreachable cycles, a 4,096-object cycle over eight collections, malformed descriptors, barrier offsets, and mark-failure recovery. `cargo fmt --check`, locked workspace tests, and locked clippy with `-D warnings` pass.
- The generated C ABI smoke links the release umbrella archive and covers header initialization, inactive stale slots, multi-frame traversal, corrupted frame links, LIFO cleanup, malformed descriptors, barrier validation, and cross-thread `wrong_thread` rejection.
- x86-64 C ABI smoke and compile-only AArch64 layout assertions pass. The archive remains byte-identical at `afe3be810f4559a483404b8f80004ef4e825f345ddd874162bba786da6bcff19`; after adding the VERT-010 objectAlias harness, the locked source hash is `c248eafd58116a38c7a70050ec740622b3823b9a5b4ba08c340585a025f62649` and runtime manifest hash is `f127c1fd8fc6e3a46fc298e828596132d19386e1abc3d7da3f310cdb5ba7cd23`.
- Miri is not installed in the locked toolchain, so no Miri result is claimed. Automatic CI remains intentionally deferred; the maximum state is `SelfAudited`, not `Integrated`.
