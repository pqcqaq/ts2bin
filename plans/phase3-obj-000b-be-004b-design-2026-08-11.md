# OBJ-000b / BE-004b Object Layout ABI

Status: `SelfAudited`. This D3/A3 slice freezes the first target-dependent object header, shape/property metadata, trace metadata, and closed-shape instance layout against two authoritative LLVM 20.1.8 DataLayouts. The canonical contract, independent physical-layout hash, strict decoder/fuzz, Rust/C/LLVM comparison, runtime provenance rebuild, and local gates are complete. Owner-deferred CI prevents an `Integrated` claim. This slice does not allocate, trace, mark, sweep, publish roots, emit property operations, or expose an owned object to user programs; those remain gated by `GC-001a`, `RT-006a`, and `VERT-010`.

## Issue Brief

- IDs / phase: `OBJ-000b + BE-004b`, Phase 3 order 2.
- Dependencies: self-audited `OBJ-000a`, observed LLVM `DataLayout`, and the existing target-context provenance boundary.
- Change / audit level: D3 / A3 because the schema becomes a compiler/runtime/backend ABI and a cache identity input.
- Deliverables: versioned canonical layout contract, deterministic closed-shape planner, Linux x86-64 and Linux AArch64 target records, schema/layout hash substitution rejection, and Rust/C/LLVM size-align-offset comparison.
- Non-goals: allocation, GC algorithms, root maps, barriers, dynamic shapes, prototype mutation, accessor invocation, classes, closures, LLVM object emission, and runtime capability publication.

## Authoritative Target Evidence

LLVM/Clang 20.1.8 reports:

| Target | DataLayout |
| --- | --- |
| `x86_64-unknown-linux-gnu` | `e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128` |
| `aarch64-unknown-linux-gnu` | `e-m:e-p270:32:32-p271:32:32-p272:64:64-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128-Fn32` |

Both targets use little-endian 64-bit pointers with 8-byte ABI alignment, but their complete DataLayout identities remain distinct. A layout proof binds the exact target triple, complete DataLayout string, DataLayout hash, and the resulting contract hash. Matching size/offset values alone cannot substitute one target proof for another.

## ABI Schema

All pointers are non-owning ABI words in this slice. Descriptor pointers refer to immutable non-GC metadata. Object references and trace callback behavior are introduced only after the GC/root contracts exist.

```text
ObjectHeaderV1 {
  descriptor   ptr    // ShapeDescriptorV1 or a future compatible class descriptor
  sizeBytes    usize  // complete allocation size, checked against the frozen layout
  gcWord       usize  // reserved mark/state word; interpretation belongs to GC-001a
}

ShapeDescriptorV1 {
  schemaVersion      u32
  flags              u32
  objectSize         usize
  objectAlign        usize
  propertyCount      u32
  presenceWordCount  u32
  properties         ptr
  trace              ptr
}

PropertyDescriptorV1 {
  key                ptr
  kind               u8
  flags              u8
  reserved           u16
  fieldOffset        u32
  presenceBit        u32
  slot               u32
  enumerationOrder   u32
  valueDescriptor    ptr
}

TraceDescriptorV1 {
  schemaVersion      u32
  flags              u32
  objectSize         usize
  pointerCount       u32
  pointerMapWords    u32
  pointerOffsets     ptr
  traceCallback      ptr
}
```

On both accepted v1 targets the fixed sizes/alignments are: header `24/8`, shape `48/8`, property `40/8`, and trace `40/8`. These values are derived independently from each DataLayout and cross-checked against Rust `repr(C)`, C `offsetof`, and LLVM `TargetData`; they are not hard-coded as a substitute for target observation.

## Closed-Shape Instance Layout

1. Begin after `ObjectHeaderV1`.
2. Allocate `ceil(optionalDataPropertyCount / pointerBits)` presence words. Absence is never encoded by a payload zero value.
3. Process properties in source declaration order. Accessors have no payload field and retain a descriptor slot. Data properties align the cursor to their verified representation alignment, assign an offset, then advance by their size.
4. Record reference-bearing field offsets in declaration order in the trace descriptor. Embedded unboxed aggregates are rejected until their recursive trace contract exists.
5. Round the complete object size to the maximum of pointer alignment and all field alignments. Frozen layouts cannot append fields; a changed property list creates a new layout ID.
6. Enumeration order is stored independently from physical offset. Integer-index, string, and symbol ordering is a later semantic input; the planner never infers enumeration from field packing.

The first representation vocabulary is deliberately closed: `u8`, `u32`, `f64`, `usize`, and `gc-ref`. Every representation carries a stable key plus target-derived size/alignment. `gc-ref` alone contributes a direct pointer offset. Unsupported or target-inconsistent facts fail closed.

## Hash and Admission Rules

- The ABI schema hash covers field names, order, scalar kinds, schema version, and reserved-field policy.
- The target layout hash covers the exact triple, full DataLayout string, endian, pointer size/alignment, and scalar size/alignment facts.
- The object layout content hash covers the semantic type key, schema hash, target layout hash, property descriptors, presence mapping, physical offsets, trace offsets, size, and alignment.
- Decoders reject unknown members, unsupported schema versions, non-canonical property ordering, duplicate offsets/bits, impossible alignment, descriptor/header mismatch, and any hash substitution.
- A mutable `OBJ-000a` view is admitted only when its later source and target object layout content hashes are equal. Size equality is insufficient.

## Verification Plan

- Go fixtures: empty object, mixed scalar/reference object, optional presence, accessor/no-field, alignment padding, declaration-order stability, and deterministic round trip.
- Negative fixtures: wrong schema/DataLayout/layout hash, reordered or duplicate properties, overlapping fields, optional bit collision, accessor with field storage, bad trace offsets, and mutable view with distinct layout hashes.
- LLVM 20 evidence: observe both target machines and compare named struct size/alignment/element offsets with the canonical contract.
- Rust/C evidence: generated ABI declarations report `size_of`, `align_of`, and `offsetof` values equal to the canonical manifest on both compile-only target records.
- Gates: focused tests/vet/race/shuffle/fuzz, project-owned Go regression, runtime generator check, Rust fmt/clippy/test, C compile/run probe where available, and `git diff --check`.

## Exit Criteria

This slice reaches `SelfAudited` only when the canonical contract, two independent target proofs, cross-language size-align-offset evidence, tamper negatives, documentation synchronization, and local gates pass. Owner-deferred CI prevents an `Integrated` claim. No owned object may be accepted until `GC-001a` and `RT-006a` also close.

Local exit evidence:

- Windows: `go test ./... -count=1`, `go vet ./...`, `go test -race ./internal/bingo ./internal/targetcontext -count=1`, shuffled object tests, and a 3-second bounded object-layout decoder fuzz pass.
- Rust: `cargo fmt --all -- --check`, `cargo test -p bingo-abi`, and `cargo clippy -p bingo-abi --all-targets -- -D warnings` using the locked 1.97.1 toolchain.
- C: Clang 20.1.8 accepts the generated header and all `sizeof`/`alignof`/`offsetof` static assertions for both `x86_64-unknown-linux-gnu` and `aarch64-unknown-linux-gnu`.
- LLVM: WSL `CGO_ENABLED=1 go test -tags=llvm20 ./internal/llvmbackend -run ObjectLayout -count=1` observes both target-machine DataLayouts and matches every `TargetData` extent and element offset.
- Runtime provenance: `build-first-slice.sh` rebuild/link/run smoke passes; the runtime archive and existing object hashes are unchanged, while the intentional source/manifest hashes update to `bf3c1df858368617bba6b5d9a3b3f4d3fe383ba9a62bb7cb2886d52cc54ee111` and `d36e254dfd97525a43b7c652bdf042d5990992ac8fc654bc611e2a1be9f23010`.
