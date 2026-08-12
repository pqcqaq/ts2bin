# Phase 3 OBJ-004 Variance Proof Design

Status: `SelfAudited`. This D2/A2 slice implements a target-independent per-declaration proof, a separately versioned recursive dependency graph, checker-free cross-module type-relation evidence, and a canonical direct-reuse HIR gate that also requires physical object-layout equality. It does not implement checked casts, layout adapters, or thunks; those remain `OBJ-005`.

## Scope

- A versioned canonical contract records one generic declaration, declaration-ordered type parameters, explicit `in`/`out` annotations, tsgo compatibility hints, and source-origin occurrence paths.
- Bingo recomputes occurrence polarity from the occurrence kind. Callers cannot inject an inferred variance result.
- Readonly properties, readonly elements, getters, and function returns are positive positions.
- Function parameters and setter inputs are negative positions.
- Writable properties, mutable elements, and inout positions are invariant (`Both`).
- Conditional/mapped residuals, dynamic values, extern opaque values, and unreliable or unmeasurable tsgo hints produce `Unknown` and prohibit direct cross-instantiation ABI reuse.
- Explicit `out` accepts only unused/positive evidence. Explicit `in` accepts only unused/negative evidence. `in out` and unannotated parameters remain invariant for cross-instantiation ABI reuse even when occurrences are one-sided.
- TypeScript method bivariance is compatibility evidence only and never authorizes a function-pointer bitcast or direct ABI reuse.
- A variance graph embeds complete canonical v1 declaration contracts. Dense graph nodes bind one declaration parameter; edges bind owner/dependency nodes, a positive/negative/both/unknown transform, and a stable occurrence path.
- Tarjan SCCs are reconstructed from canonical edges. SCC IDs are assigned by the component's smallest node ID, not traversal completion order.
- Fixed-point state starts from each embedded declaration proof, applies dependency transforms, and monotonically joins until stable. The five-element lattice bounds convergence; exceeding the derived update budget is an internal verifier failure.

## Canonical Contract

- Parameter and occurrence IDs are dense and declaration ordered.
- Each occurrence belongs to exactly one parameter and carries a non-empty, stable source path.
- Occurrences are globally ordered by parameter ID, then source order, then path; duplicates are rejected.
- The proof records inferred polarity, direct-reuse admission, and a stable reason, but the verifier reconstructs all three from parameters and occurrences.
- Schema version, complete payload, proof rows, and source paths participate in the content hash. Unknown members, stale hashes, oversized inputs, invalid hints, forged proof rows, and reordered occurrences fail closed.
- Graph contracts require declaration hashes in lexical order, nodes in declaration/parameter order, edges in owner/dependency/path order, and one recomputed proof per node. Graph proofs store final polarity and SCC ID only; direct ABI admission remains a later per-conversion decision after annotation/layout checks.
- Type-relation nodes bind canonical type keys to declaration keys and ordered generic argument keys. Base-type edges come from frozen snapshot facts; duplicate records for the same cross-module symbol are connected only when their ordered argument hashes match.
- A direct-reuse HIR gate embeds and verifies a canonical supported HIR reader, binds one function/object-producing value to the source type, reconstructs covariant or contravariant argument paths, and requires identical `ObjectLayoutContract.LayoutHash`. Invariant, unknown, reversed, layout-mismatched, unbound, or substituted evidence fails closed.

## Rejection Matrix

- Duplicate/nondense parameter or occurrence IDs and unknown parameter references.
- Empty declaration keys, parameter names, or occurrence paths.
- Annotation conflicts (`out` with negative/both/unknown; `in` with positive/both/unknown).
- tsgo `Unmeasurable`/`Unreliable`, residual/dynamic/opaque occurrence, or forged direct-reuse admission.
- tsgo covariance over a writable property or mutable element.
- tsgo bivariance used to claim direct ABI reuse.
- Unknown schema/member, stale content hash, proof substitution, and input over 96 KiB.
- Graph edge to an unknown node, duplicate/noncanonical edge, forged SCC membership, forged fixed-point polarity, embedded declaration substitution, or graph input over 256 KiB.

## Evidence Plan

1. Canonical contract, polarity lattice, planner, strict decoder, deterministic round trip, and tamper matrix.
2. Bounded decoder fuzz seed plus focused repeat/shuffle/race tests.
3. Checker-free snapshot occurrence extraction for readonly box, consumer callback, mutable cell, and unreliable residual fixtures.
4. Recursive/nested generic dependency graph and Tarjan fixed point use an independent strict artifact so v1 declaration readers remain frozen. Real snapshot replay covers self-recursive and positive/negative mutually recursive interfaces.
5. `OBJ-005` consumes only canonical `OBJ-004` proofs after object layout compatibility; no adapter or thunk is introduced by this slice.

## Local Evidence

- The real two-module fixture proves `Dog -> Animal` through snapshot base facts and symbol-equivalent imported type records, then admits `ReadonlyBox<Dog> -> ReadonlyBox<Animal>` only after variance and layout checks.
- Self and mutually recursive interfaces exercise canonical dependency edges, Tarjan SCC reconstruction, and bounded fixed-point convergence.
- Strict decoders cover declaration, variance graph, relation graph, conversion proof, and HIR gate artifacts. Focused fuzz, tamper/reversal/layout negatives, deterministic snapshot generation, full Go test/vet, race, and diff checks pass locally.

Automatic CI remains owner-deferred, so this slice is not `Integrated`.
