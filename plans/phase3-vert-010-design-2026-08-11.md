# VERT-010 Owned Object and Static Property Vertical Slice

Status: `SelfAudited`. The D3/A3 slice is complete locally: snapshot/HIR v9/MIR v7, exact TargetContext capability binding, isolated LLVM emission, runtime harness, ELF execution, Node differential, `emit-vert010` artifact publication, unified case-manifest execution, negative matrices, fuzz, determinism, and final gates are verified. The slice covers one closed object literal with data properties, static property read/write, reference identity, and alias-observable mutation through the real snapshot/HIR/MIR/LLVM/runtime/ELF/Node chain. Automatic CI remains owner-deferred, so this is not `Integrated`.

## Issue Brief

- IDs / phase: `OBJ-001a + OBJ-006a + BE-003a + VERT-010`, Phase 3 order 5.
- Dependencies: self-audited `OBJ-000a`, `OBJ-000b + BE-004b`, `GC-001a + BE-003b`, and `RT-006a`.
- Change / audit level: D3 / A3. The slice adds serialized IR, GC-root behavior, runtime calls, target layout binding, and observable alias semantics.
- Positive source fixture: `objectAlias(value: number): number` allocates `{ value }`, aliases the reference, increments through the alias, and returns through the original reference.
- Non-goals: computed keys, accessors, optional chains, logical property assignment, spread, methods, prototypes, dynamic shapes, classes, closures, object equality syntax, optional properties, reference-valued fields, exceptions, and async cleanup.

## Frontend Admission

The accepted snapshot must be schema v2, canonical, and already pass the public subset gate. The object lowerer additionally requires:

1. A single `KindObjectLiteralExpression` whose children are declaration-ordered `KindShorthandPropertyAssignment` nodes.
2. Each shorthand property resolves to one data-property symbol and one supported value type. V1 accepts exactly one required mutable `number` property named `value`.
3. Every `KindPropertyAccessExpression` uses an identifier receiver and identifier property name. The access symbol must equal the object property's stable symbol identity.
4. Assignment is a `KindBinaryExpression` with `KindEqualsToken`; the accepted read-modify-write RHS is the already supported binary64 `+` expression.
5. Local symbols for the object and alias are distinct, while assignment of the object reference to the alias preserves identity. No implicit copy or structural conversion is permitted.

The snapshot lowerer registry gains exact handlers for object literal and shorthand property nodes. Unsupported object/property nodes fail the readiness gate; no generic fallback or function-name admission is introduced.

## HIR v9 Contract

HIR schema v9 adds `TypeObject` and an immutable module-level object semantic contract. The contract binds a stable semantic type key, declaration-ordered property records, property symbol identity, mutability, required presence, and source type. The first record is exactly `value: number`; its canonical source type key is serialized in HIR so the reader independently reconstructs and verifies the semantic contract hash rather than trusting an opaque digest.

The accepted operation vocabulary is:

| Operation | Operands / result | Effect | Meaning |
| --- | --- | --- | --- |
| `object.alloc` | none / `object-ref` | `allocate` | Identity-creating owned allocation and safepoint |
| `object.field.init` | object, value / `object-ref` | `write` | Initialize an unpublished object and return the same identity |
| `object.alias` | object / `object-ref` | `pure` | SSA alias preserving reference identity |
| `object.field.load` | object / field type | `read` | Static data-property read |
| `object.field.store` | object, value / `object-ref` | `write` | Published mutation and same-identity result |

Every field operation carries the semantic type key and property symbol key. It does not carry a physical offset. `object.alloc` requires `rt.gc.alloc`; the module requirement closure is the exact sorted set needed by allocation, shadow-stack publication/reload, safepoint, and cleanup. A numeric field store does not require `rt.gc.write_barrier`; reference fields remain outside this slice.

The HIR verifier independently proves dense value IDs, dominance, object/value types, exact property membership, initialization before publication, alias identity, effect/capability agreement, and that the returned number is loaded through the original object after the alias store. Malformed or old-major HIR never reaches representation planning.

## MIR v7 and Layout Binding

MIR schema v7 adds `RepGcRef` plus an immutable object layout binding copied from the verified `OBJ-000b` contract. The binding contains semantic type key, object-layout content hash, target-layout hash, ABI schema hash, object size/alignment, shape identity, and declaration-ordered fields. Each field record binds property symbol key, representation, byte offset, required presence, and trace status.

Representation planning performs the first semantic-to-physical join:

- `TypeObject -> RepGcRef` only when the target context's exact triple/DataLayout has a verified layout record.
- `number -> f64` retains the Phase 2 binary64 contract.
- The `value` field offset must be target-derived, aligned, in bounds, non-overlapping, and absent from trace offsets.
- Mutable alias admission requires identical object-layout content hashes; size equality is insufficient.

MIR object instructions retain semantic type/property keys and add the verified physical layout hash and field offset. The final verifier recomputes membership and bounds, checks the exact bound capability closure, and invokes the canonical GC safety-plan verifier. Layout/property/hash/offset substitution fails before LLVM.

## GC Root Plan

Allocation and the forced collection point are safepoints. The function links one shadow-stack frame before the allocation sequence and unlinks it on the sole normal return. The inactive slot is cleared and published before the allocation safepoint; the new reference is stored and published before forced collection, then reloaded before use. The exact verified sequence is:

```text
frame.link
root.clear(slot=0)
root.publish(activeMask=0)
safepoint(allocation)
object.alloc
root.store(slot=0, object)
root.publish(activeMask=1)
object.field.init(value)
safepoint(forced-collection)
root.reload(slot=0, object)
object.alias
object.field.load(alias)
object.field.store(alias, incrementedValue)
object.field.load(object)
frame.unlink
return
```

The allocator itself receives no unrooted live object. The forced safepoint makes root publication and reload observable in the real ELF path. A future second allocation must add its own publish/safepoint/reload evidence before it is admitted. Numeric field stores forbid a write barrier; later reference-valued fields must use the published-owner barrier rule frozen by `GC-001a`.

## LLVM and Runtime Binding

LLVM lowering is selected by verified operation/representation registries, not fixture or function name. It declares only symbols resolved from the bound runtime capabilities. The shape and property metadata are private constant globals whose bytes and offsets match the canonical object-layout ABI.

`object.alloc` calls `bingo_gc_alloc_v1` with the frozen shape descriptor and traps on non-success status. Frame/root operations use the versioned `bingo_gc_*_v1` ABI. Field access uses an inbounds byte offset only after MIR verification, then a typed aligned `double` load/store. LLVM verification runs at O0 and after `default<O2>`; the root/effect call order and alias-observable load/store must remain present.

The case harness accepts one binary64 argument and prints the result bits. The real ELF and locked Node oracle must agree for ordinary values, `-0`, infinities, and canonical NaN under the existing number contract. The executable must demonstrate that a store through `alias` changes the later load through `object`.

## Negative and Determinism Matrix

- Source/snapshot: computed key, accessor, method, spread, optional property, wrong property symbol, copied alias, unsupported field type, and additional property.
- HIR: old/unknown schema, forged semantic contract, wrong operation order/type/effect/capability, missing initialization, non-identity alias, wrong property key, and stale content hash.
- MIR: target/DataLayout/layout/schema hash substitution, wrong field offset/alignment/representation, trace mismatch, missing root event, forged active set, spurious numeric barrier, and capability closure mismatch.
- Backend/runtime: missing or substituted runtime symbol, malformed shape descriptor, allocation failure, LLVM verifier failure, and optimized root/effect order drift.
- Determinism: repeated snapshot-to-HIR, HIR-to-MIR, LLVM object, runtime archive/manifest, linked ELF, and provenance report bytes are identical for identical locked inputs.

## Exit Criteria

The slice reaches `SelfAudited` only when the real source fixture traverses the canonical snapshot/HIR v9/MIR v7/LLVM/object/LLD/ELF chain; Node differential proves alias-observable mutation; all source/HIR/MIR/layout/property/root/capability negatives fail closed before their protected boundary; Go test/vet/race/shuffle/fuzz, LLVM O0/O2, Rust fmt/test/clippy, C ABI, deterministic rebuild, and `git diff --check` pass; and plan/progress/lock identities are synchronized. Owner-deferred CI prevents an `Integrated` claim.

## Self-Audit Evidence

- The unified `static-core/objectalias` command completed the source-to-ELF chain and matched Node for positive zero, negative zero, one, positive infinity, and payload qNaN. Current identities include HIR `fbfee40355541c3d8b43f08852de521b476abc1fe86d35e1a3616860d868f23f`, bound MIR `59ac3caf1162571bbb6fcb5e1a9772a110ec6c45fa46d666f574845f501b5c6e`, object `7e49631a37824a4825e453aa8e0defad6774f81ba98be4ca1c2e7d638d2169c9`, and report content `fa527cd274caf8e10f14526ca5f41f4897b14548ebaf5fe3d3563c722deb5f71`.
- Source rejection covers computed keys, accessors, methods, spread, optional/additional properties, copied aliases, property-symbol substitution, and unsupported field types. HIR and MIR tests cover schema, semantic-contract, initialization, effect/capability, layout/schema/target/offset/representation/trace, root, barrier, and bound-symbol tampering; generic GC and LLVM tests independently cover active sets, spurious barriers, and O2 call order.
- Full Go test/vet, focused race, shuffle, three VERT decoder fuzz targets, LLVM20 backend/link/runner/CLI, Rust fmt/test/clippy, and both repository `git diff --check` gates pass. Two complete reports were non-empty and byte-identical with file SHA-256 `c584ff68d7a5888d469cf8675bfc5ab6ee2ed8eaecefada611c22e9fa616d9dd`.
- Miri is unavailable in the locked toolchain, so no Miri result is claimed. CI remains intentionally disabled by the project owner; the maximum status is `SelfAudited`.
