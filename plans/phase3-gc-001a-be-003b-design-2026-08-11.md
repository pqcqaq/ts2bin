# GC-001a / BE-003b Root and Barrier Safety Contract

Status: `SelfAudited`. This D3/A3 slice freezes the single-mutator shadow-stack root publication, safepoint, dead-slot, reload, write-barrier, and LLVM O2 preservation contract required before any owned object allocation. It does not implement allocation, marking, sweeping, heap traversal, weak references, finalization, or a user-visible object vertical slice; those remain in `RT-006a` and later work.

## Issue Brief

- IDs / phase: `GC-001a + BE-003b`, Phase 3 order 3.
- Dependencies: `OBJ-000a`, `OBJ-000b/BE-004b`, verified CFG/SSA, effect freeze, and observed LLVM TargetData.
- Change / audit level: D3 / A3. Incorrect root publication or barrier elimination can produce memory unsafety after optimization.
- Deliverables: versioned canonical GC safety plan, independently recomputed CFG liveness, strict root/barrier verifier, malformed-plan fixtures, bounded decoder fuzz, and LLVM O0/O2 ordering litmus on both Phase 3 DataLayouts.
- Non-goals: allocator implementation, heap ownership, collector traversal, runtime root registry implementation, moving/concurrent/incremental GC, statepoints, exception/async cleanup, or publication of new runtime capabilities.

## Accepted Profile

- Collector profile: single mutator, stop-the-world, precise, non-moving mark-sweep.
- Root backend: explicit shadow stack. `GcRef` is not a root by itself.
- Safepoints: allocation or `MayAllocate` call, configured loop poll, suspend, throw/status handoff, and blocking host boundary. This slice models the contract; later lowerers decide which source operations create those events.
- Root publication operations are compiler-observable effects. They cannot be represented by comments, debug metadata, ordinary removable stores, or an unverified liveness list.
- `gc.statepoint` is not part of v1. A future statepoint backend must differential-test against this shadow-stack contract.

## Canonical Safety Plan

Each function plan contains ordered blocks, explicit CFG successors, root slots, semantic reference definitions/uses, phi incoming edges, and GC events. The verifier independently computes edge-sensitive liveness to a fixed point:

```text
liveOut(block) = union for successor:
  (liveIn(successor) - phiDefs(successor)) + phiUses(successor, block)
liveIn(block) = blockUses + (liveOut(block) - blockDefs)
```

The serialized `liveIn/liveOut` facts are evidence to audit and hash, not trusted inputs: they must equal the recomputed sets exactly.

For every safepoint, the event sequence is frozen:

```text
root.store / root.clear ...
root.publish(exact active slot set)
safepoint(kind, MayAllocate/MaySuspend/MayBlock flags)
root.reload(each live-across value in canonical slot order)
```

Rules:

1. Every value live both before and after a safepoint has exactly one active root slot containing that value.
2. Every active slot is live; stale values may remain only in inactive slots. A slot removed from the active set must be explicitly cleared before a later publication if it could otherwise retain a dead object.
3. The published active set is exact, sorted, unique, and bound to the latest slot contents.
4. Reloads immediately after the safepoint cover every live-across value exactly once and bind the same slot/value pair. Later semantic uses consume the reloaded value, not a register value surviving the call.
5. Entry links one frame before any publication. Every normal return unlinks it. Throw/suspend cleanup is reserved for their later vertical slices but will use the same event contract.
6. Phi uses are edge-specific. Loop backedges participate in fixed-point liveness and cannot rely on one-pass block order.

## Barrier Rules

Every reference field store records owner state and barrier state:

| Owner state | Stored representation | Required action |
| --- | --- | --- |
| unpublished, verifier-proven | `gc-ref` | barrier may be omitted |
| published | `gc-ref` | semantic `gc.write_barrier(owner, slot, value)` is mandatory |
| any | non-reference | barrier is forbidden |

The v1 STW collector may implement a no-op fast path, but MIR/backend retain the semantic barrier event so later collector changes do not require source lowering changes. “Constructor-like code” alone is not an unpublished proof; the plan must carry a stable publication state fact.

## LLVM Preservation Contract

The backend litmus declares opaque external functions for frame link/unlink, root store/clear, active-set publication, safepoint, reload, and write barrier. These calls model the future runtime ABI but are not added to the runtime capability manifest in this slice.

For both Linux x86-64 and Linux AArch64:

1. Build a verified module containing live/dead slot alternation, a safepoint, reload, and a published-owner barrier.
2. Verify the module at O0.
3. Run LLVM 20 `default<O2>` with verify-each.
4. Verify the optimized module and audit that the ordered call sequence remains link -> store/clear -> publish -> safepoint -> reload -> barrier -> unlink.
5. Reject litmus modules with missing/reordered publication, reload, barrier, or cleanup calls.

The frame pointer is passed to opaque side-effecting calls, making its storage externally observable. The contract does not depend on volatile everywhere; ordering is established by calls that may access memory. A future intrinsic or attribute refinement must reproduce this O2 evidence.

## Stable Rejection Reasons

- `gc.cfg_invalid`
- `gc.liveness_mismatch`
- `gc.frame_link_missing`
- `gc.frame_unlink_missing`
- `gc.root_slot_invalid`
- `gc.root_publication_missing`
- `gc.root_publication_inexact`
- `gc.dead_slot_not_cleared`
- `gc.reload_missing`
- `gc.barrier_missing`
- `gc.barrier_spurious`
- `gc.effect_after_freeze`

## Verification Plan

- Positive plans: straight-line live root, dead-slot alternation, branch/phi, loop fixed point, unpublished initialization store, published reference store.
- Negative plans: malformed CFG, forged live sets, missing/duplicate slot, stale active slot, missing clear, missing reload, frame cleanup omission, missing/spurious barrier, non-canonical ordering, schema/hash substitution.
- Decoder: strict unknown-member rejection, content hash, bounded fuzz, canonical round trip.
- Backend: O0/O2 LLVM litmus on both authoritative target machines and call-order audit after optimization.
- Gates: focused tests/vet/race/shuffle/fuzz, LLVM-tagged tests, full Go regression, runtime provenance check, and `git diff --check`.

## Exit Criteria

This slice reaches `SelfAudited` only when CFG liveness is independently recomputed, all safepoints have exact root publication/reload evidence, barrier rules fail closed, O2 preserves the observable sequence on both targets, malformed plans never reach backend, documentation is synchronized, and all local gates pass. Owner-deferred CI prevents an `Integrated` claim. Only then may `RT-006a` implement the minimal heap behind this contract.

## Self-Audit Evidence

- The canonical schema and strict decoder reject unknown members, hash substitution, unknown instruction kinds, duplicate instruction/value identities, unreachable CFG blocks, malformed phi predecessor order, forged liveness, orphan root events, inexact active sets, duplicate live-value publication, missing reloads, frame cleanup omissions, and missing or spurious barriers.
- Focused and full `internal/bingo` tests, `go vet`, race, five shuffled repetitions, and a bounded three-second decoder fuzz run passed locally; the fuzz run executed approximately 75,000 inputs.
- LLVM 20 verified the root/publication/reload/barrier call sequence before and after `default<O2>` on Linux x86-64 and compile-only Linux AArch64 target machines.
- Automatic CI remains intentionally owner-deferred, so the maximum claimed state is `SelfAudited`, not `Integrated`.
