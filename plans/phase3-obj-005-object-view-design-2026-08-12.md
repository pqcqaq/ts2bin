# Phase 3 OBJ-005 ObjectView Design

Status: `Implementing`. The canonical proof, HIR artifact, explicit operation, readonly data-property MIR/backend plan, real frontend replay, production pipeline, LLVM 20 emitter, runtime harness, and Node oracle are implemented and host-verified. ObjectView MIR v2 additionally admits a receiver-bound accessor read only when it can rejoin the same canonical PlaceRef receiver/getter/effect proof; the accessor backend independently reconstructs the getter identity, nullable representation, and backing offset before emitting the receiver-preserving call. Tagged Linux tests bind both real data-property and accessor snapshots into ELF/native/Node differentials, but those tests have not run because WSL is unavailable on the current host. This OBJ-005 work does not add implicit copying, checked runtime casts, function thunks, dynamic values, or `unsafeCast`.

## Scope

- Input is a pair of canonical `ObjectSemanticContract` values, canonical source/target `ObjectLayoutContract` values, and the canonical `TypeRelationGraph` established by OBJ-004.
- The planner independently reconstructs every target readable-property relation from the relation graph. It never trusts an unbound `Reliable` boolean.
- The result is `ObjectView`: source identity and reference equality are preserved; target writes are forbidden; mapping binds target property key to the corresponding source property key, kind, read type relation path, and physical field/accessor layout facts.
- Source and target layout contracts remain target-specific. A readonly view may have different object layout hashes only when every mapped read is represented by a safe, explicitly frozen mapping; it never authorizes a direct mutable alias or an LLVM bitcast.
- The first reader lowers one data-property view to a target-aware MIR/backend admission plan. `view.bind` has a fresh SSA result ID but is proven identity-preserving and non-allocating; each data read uses the source physical offset/presence/representation frozen in the proof. The LLVM emitter produces one source-offset `f64` load with no bitcast, allocation, runtime call, or GC capability.
- MIR v2 admits an accessor mapping only when the embedded canonical VERT-011 PlaceRef identifies the same source object type, property, source SSA receiver, getter symbol, read type and `call/read/throw` effects. The getter receiver is the fresh view SSA identity, which is proven identical to the source. Backend planning deliberately rejects this read until source getter code and its receiver ABI are joined in one emission artifact.

## Admission

1. Verify canonical source/target semantic contracts, relation graph, and layouts.
2. Bind each layout's `TypeKey` to its semantic contract.
3. Reject private-identity, property-kind, required/optional, absent-read, and target-write mismatches.
4. For each target read type, derive a deterministic path from source read type to target read type. Exact equality uses a one-node path.
5. Canonically order mappings by target property key and hash the complete proof.
6. Bind the proof to a canonical HIR module, function and source object-producing value. The source value must carry the source object type key.

## Rejection Matrix

- Any writable target property: reject this readonly-view reader; mutable view requires a separate layout/store/alias proof.
- Missing source property, accessor/data mismatch, private nominal mismatch, optional source for required target, or missing source read type: reject.
- Reversed/unreachable type relation, substituted relation path, stale hash, unknown member, oversized input, or reordered mapping: reject.
- Source/target semantic or layout type-key mismatch: reject.
- HIR function/value/source-type substitution or unsupported HIR reader: reject.
- `as any as T`, `unsafeCast<T>`, dynamic boundary, and copying request: reject in this reader; their provenance/runtime contracts are distinct future increments.

## Evidence

- Unit and strict decoder round-trip/tamper coverage.
- Real two-module `Dog -> Animal` relation and `ReadonlyBox<Dog> -> ReadonlyBox<Animal>` source evidence reused from OBJ-004.
- Checked-in `objectview` fixture proves a real `{ value: number } -> ReadonlyValue` assignment. A mutable alias updates the source and the readonly view performs the return read, so snapshot replay must preserve identity rather than silently copy. The checker-free replay binds contextual assignment facts, distinct source/target property symbols, mutability, layouts, HIR value 3, MIR and backend plan; rehashed source tampering remains fail closed.
- Linux-tagged O0/O2 verification, ELF emission, C harness execution, and locked Node bit differential are checked in. Current Windows host verification covers compilation, unit tests, vet, focused race, and diff integrity; WSL is inaccessible, so native ELF execution is not yet claimed.
- Accessor receiver binding is now closed at MIR v2 with getter/receiver/ABI/effect substitution negatives and an accessor fuzz seed. A separate deterministic `objectaccessorview` snapshot and strict checker-free replay bind the getter-only target annotation and contextual source assignment to the existing VERT-011 accessor HIR without changing that frozen fixture. Backend plan v2 and Linux-tagged LLVM getter code join now emit the nullable out-parameter ABI; native/Node execution remains environment-blocked, and the current executable source fixture closes the data-property identity/no-copy increment only.

Automatic CI remains owner-deferred. Design acceptance is not implementation completion.
