# OBJ-000a Object Semantic Contract

Status: `SelfAudited` for the Phase 3 implementation slice. The target-independent contract, strict decoder, conversion planner, escape lattice, fixed negative fixtures, bounded fuzz target, and local gates are complete. Automatic CI remains owner-deferred, so this status is not `Integrated`. This document deliberately does not choose a physical layout, allocator, GC root representation, accessor slot ABI, or LLVM lowering; those belong to `OBJ-000b`, `GC-001a`, `RT-006a`, and later vertical slices.

## Issue Brief

- ID / phase: `OBJ-000a`, Phase 3 order 1.
- Change / audit level: D2 / A2. The contract changes type/conversion admission and semantic HIR facts, but does not define a runtime ABI or object layout.
- Dependencies: `IR-000`, `IR-001`, the validated frontend snapshot property facts, and the Phase 2 pass/provenance envelope.
- Deliverables: versioned target-independent object semantic contract, deterministic conversion planner, positive/negative semantic fixtures, and diagnostic reasons suitable for later HIR/MIR admission.
- Non-goals: object allocation, shape tables, field offsets, property enumeration implementation, getters/setters execution, classes, closures, GC, dynamic runtime, and cross-target layout.

## Evidence

The contract is derived from repository-controlled evidence:

| Source | Relevant invariant |
| --- | --- |
| `handbook/05-object-types.md` | `readonly` is a shallow compile-time write restriction; optional means absence is distinct from a present `undefined`; TypeScript object compatibility is structural but does not itself authorize a mutable native alias. |
| `plans/architecture.md` §4.3 | Object/class values are references; identity/equality are reference semantics; cross-layout views must be explicit; implicit field copies create a new identity. |
| `plans/type-system-and-variance-algorithms.md` §§2, 4, 5 | Property facts carry read/write/optional/readonly/accessor/private identity; mutable containers are invariant; `DynamicBoundary` must be explicit; unchecked or unreliable proofs are rejected. |
| `plans/runtime-and-backend-lowering-algorithms.md` §4.3 | `ObjectView` preserves source identity and receiver binding; readonly views may be covariant; writable views require equal read/write contracts and a later layout proof. |
| `typescript-go/internal/frontendwire/snapshot_types.go` | `PropertySnapshot` already serializes read/write type IDs, optional/readonly, getter/setter, visibility, and private identity without checker pointers. |
| `typescript-go/internal/frontendwire/snapshot_validate.go` | Snapshot validation rejects inconsistent property facts and missing private identity before lowering. |

## Accepted Contract

### Identity and aliasing

1. Every object value is a reference to one semantic object identity. Assigning, passing, or returning an object reference preserves identity and creates an alias; it does not copy fields.
2. Reference equality compares semantic object identity. Two distinct allocations are unequal even when their property values are structurally equal.
3. An explicit copy operation is the only operation that creates a new identity. A conversion planner must label it `CopyNewIdentity`; no implicit structural conversion may select it.
4. An `ObjectView` preserves the source identity. Its descriptor is metadata and is not itself an object value.

### Property and mutability rules

1. A property has independent read and write contracts. A getter-only or `readonly` property has no writable entry; a setter-only property has no readable entry.
2. Optional presence is separate from a present value whose type includes `undefined`. A read from an absent optional property is modeled as absence/undefined by the later value contract; it is never an uninitialized payload read.
3. `readonly` is shallow and compile-time. It does not make the source object immutable and does not change object identity or equality.
4. Private identity is nominal. A private property may only match another property with the same private identity; a public name match is insufficient.
5. Accessor receiver binding is part of the semantic property contract. A future view must call the source accessor with the source object as receiver.

### Conversion admission

The planner produces exactly one of these decisions:

| Decision | Identity | Write exposure | Admission |
| --- | --- | --- | --- |
| `Identity` | preserved | source contract | source and target semantic keys equal |
| `ReadonlyView` | preserved | none beyond target readonly/getter reads | every target property is readable, source read type is proven assignable, and private/accessor identity matches |
| `MutableView` | preserved | target writable contract | semantic candidate only when source/target read and write type keys are equal and private/accessor contracts match; it remains marked `RequiresLayoutProof` until `OBJ-000b` supplies that proof |
| `CopyNewIdentity` | new | target contract | explicit copy request only |
| `DynamicBoundary` | profile-defined | dynamic runtime contract | explicit dynamic/interop request only; static profile rejects it |
| `Reject` | none | none | missing proof, mutable alias mismatch, implicit copy, or unsupported dynamic boundary |

The planner is conservative by construction: a TypeScript structural assignability result alone cannot admit a writable native alias. A conversion that would need a field copy, adapter, unchecked cast, or unreliable variance proof is rejected until a later explicit contract supplies it.

### Escape categories

Escape is a value fact, not a type identity. Its categories are ordered by the lifetime obligation they impose:

`Local` < `Caller` < `Heap` < `Dynamic`

- `Local`: no return, unknown call argument, heap/global store, closure capture, or dynamic boundary.
- `Caller`: returned or passed to a statically known call whose contract transfers the reference to the caller but does not store it in a heap object.
- `Heap`: stored in an object/array/global or captured by an escaping closure; it may outlive the current activation.
- `Dynamic`: crosses an explicit dynamic/FFI boundary; static profile rejects this category.

Escape joins are monotonic (`join(a, b)` returns the stronger category). A later pass may prove a narrower category only by a recorded escape proof; it may not silently downgrade a fact after an unknown call, closure escape, or dynamic write.

## Diagnostics and Rejection Reasons

The semantic planner exposes these stable reason strings for later diagnostic mapping. Malformed contracts, including a readonly property carrying a write entry, fail contract verification before planning and return a structural error rather than a conversion reason.

- `object.property_missing`
- `object.property_kind_mismatch`
- `object.read_type_unproven`
- `object.mutable_alias_requires_layout_proof`
- `object.mutable_alias_type_mismatch`
- `object.mutable_alias_optional_mismatch`
- `object.private_identity_mismatch`
- `object.dynamic_boundary_static_profile`
- `object.escape_downgrade`

The package does not assign source spans; callers attach the snapshot node/property origin and profile when converting a reason into a user diagnostic.

## Verification Plan

Positive fixtures cover identity assignment, readonly view, exact mutable semantic candidacy marked as requiring a later layout proof, explicit copy, and monotonic escape joins. Negative fixtures cover writable structural covariance, readonly write exposure, data/accessor substitution, private identity mismatch, missing layout proof, static dynamic boundary, and escape downgrade. Tests use only target-independent DTOs and must remain deterministic under shuffle and race.

## Exit Criteria

`OBJ-000a` exits when the contract types and planner are canonical/strict, all positive and negative fixtures pass, malformed contracts are rejected, no physical layout or runtime symbol is introduced, and the backlog/progress records link this design and its reproducible test command. `OBJ-000b` may then define the first physical object layout against two DataLayouts.

Local exit evidence: `go test ./internal/bingo -count=1`, `go vet ./internal/bingo`, `go test -race ./internal/bingo -count=1`, `go test ./internal/bingo -count=20 -shuffle=on`, `go test ./internal/bingo -run '^$' -fuzz '^FuzzDecodeObjectSemanticContract$' -fuzztime=3s`, `go test ./... -count=1`, and `go vet ./...` all pass on Windows. The frontend adapter is intentionally deferred: `PropertySnapshot.HasGetter/HasSetter` describes semantic readability/writability for data properties as well as accessors, so an adapter must classify accessor kind from the referenced symbol declaration nodes rather than guess from those booleans.
