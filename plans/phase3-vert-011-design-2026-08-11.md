# VERT-011 PlaceRef and Property Evaluation Vertical Slice

Status: `SelfAudited`. The D3/A3 slice is complete locally: canonical PlaceRef v1, real snapshot replay, HIR v10, MIR v8, exact TargetContext binding, LLVM O0/O2, object/LLD/ELF execution, Node differential side-effect counters, atomic CLI artifact publication, unified case-runner closure, negative matrices, fuzz, and deterministic rebuild evidence all pass. Automatic CI remains owner-deferred, so this is not `Integrated`.

## Issue Brief

- IDs / phase: `IR-006b + OBJ-003a + OBJ-006b + VERT-011`, Phase 3 order 6.
- Dependency: self-audited `VERT-010`, including owned allocation, exact object layout binding, GC roots, static data-property load/store, and alias identity.
- Change / audit level: D3 / A3. The slice changes expression evaluation order, introduces serialized HIR/MIR contracts and CFG, and admits accessor calls that may throw.
- Positive surface: checker-proven static computed keys, getter/setter-backed properties, nullable receiver optional access, and `??=`, `&&=`, `||=` property assignment.
- Non-goals: arbitrary dynamic dictionary objects, Proxy, prototype mutation, `delete`, private/symbol keys, method extraction, optional call, reference-valued fields, exceptions crossing the native boundary, closures, classes, spread, and async cleanup.

## Semantic Sources

- `plans/syntax-lowering-algorithms.md` requires `LowerPlace` to evaluate and save receiver/key once, keep getter/setter property access distinct from raw addresses, and separate `LoadPlace` from `StorePlace`.
- `plans/implementation-specification.md` fixes optional receiver/key/callee single evaluation and logical-assignment address single evaluation as release invariants.
- `plans/runtime-and-backend-lowering-algorithms.md` permits a computed key to use a static shape only when checker/constant-folding proves a fixed key; otherwise static objects fail closed rather than silently becoming dynamic.
- The locked tsgo transformers `internal/transformers/estransforms/optionalchain.go` and `logicalassignment.go` are behavioral oracles: they capture non-copyable receivers and computed keys, skip the key/RHS on untaken branches, and preserve the receiver for property calls. They are not used as Bingo IR generators.
- Handbook chapters `05-object-types.md` and `14-modern-syntax.md` establish optional/accessor source syntax and exact optional-property distinctions; runtime behavior is verified against locked Node.

## Canonical PlaceRef Contract

HIR v10 adds a module-level table of immutable PlaceRefs. A property PlaceRef records:

- dense `PlaceID` and source origin;
- already-evaluated receiver `ValueID` and optional computed-key `ValueID`;
- semantic object type key and property symbol key;
- access plan: `static-data` or `accessor`;
- value type, mutability, and required presence;
- getter/setter symbol identities and their exact semantic effects for accessor places.

The table contains no target offset, DataLayout, runtime symbol, or LLVM address. Direct `.value` uses an absent key value; checker-proven `object[key()]` records the one saved key value plus the same property symbol. Unknown keys, missing property symbols, dynamic access plans, and physical offsets are rejected before HIR.

`place.load` consumes one PlaceID and returns the declared read type. `place.store` consumes the same PlaceID plus a converted value and returns that value. A compound/logical assignment constructs the place once, loads once, and conditionally stores at most once. Accessor load/store carry call/throw effects; data-field operations retain read/write effects.

## Optional and Logical CFG

Optional access evaluates the receiver once, branches on nullish, and evaluates the computed key only in the non-nullish block. The nullish block produces `undefined`; the non-nullish block creates and loads the PlaceRef; a merge phi produces `number | undefined` without evaluating getter/key on the skipped path.

Logical assignment evaluates receiver then key, creates one PlaceRef, loads once, and branches using operator-specific semantics. The RHS and setter execute only on the assigning edge; the non-assigning edge returns the loaded value. `??=` tests null/undefined, while `&&=` and `||=` use the frozen static truthiness plan. The first fixture uses number/undefined contracts already proven by Phase 2; broad JavaScript coercion remains rejected.

## MIR and Backend

MIR v8 resolves `static-data` PlaceRefs to the verified VERT-010 layout hash and field offset. Accessor PlaceRefs resolve to a direct, checker-selected getter/setter function identity and calling convention; no dynamic lookup is introduced. MIR must retain receiver/key evaluation values and explicit CFG/phi edges. Structural verification precedes capability binding and GC-root placement.

The backend emits field address/load/store only after layout verification. Accessor calls preserve the receiver and are treated as safepoints when their effect says they may allocate. O0 and O2 verification must prove receiver/key/getter/setter/RHS call order. No new runtime object capability is expected for checker-proven static keys; any later dynamic plan requires a separately versioned `rt.object.*` slice.

## Negative and Differential Matrix

- Source/snapshot: dynamic key, symbol/private key, optional assignment target, readonly/setterless store, getterless load, computed key with unreliable type fact, copied receiver/key, unsupported result union, and property-symbol substitution.
- PlaceRef: old/unknown schema, duplicate/non-dense IDs, zero or forward receiver/key, direct access carrying a key, computed access missing a key, mismatched object/property/type, physical-layout leakage, accessor missing getter/setter identity, pure accessor effect, and stale content hash.
- HIR/CFG: key evaluated on nullish edge, receiver/key duplicated, load/store use different PlaceIDs, RHS on the non-assigning edge, setter called twice, missing phi predecessor, wrong truthiness/nullish test, and forged effect closure.
- MIR/backend: layout/offset/representation substitution, missing receiver root across accessor safepoint, capability substitution, O2 order drift, and malformed accessor signature.
- Node differential counters cover receiver, key, getter, setter, and RHS counts on taken and untaken optional/logical branches.

## Compatibility, Migration, and Rollback

- Primitive HIR v8/MIR v6 and VERT-010 HIR v9/MIR v7 readers remain strict and unchanged. VERT-011 uses independent v10/v8 readers and commands until the common versioning plan is deliberately consolidated.
- The PlaceRef substrate contains semantic identities only, so adding it does not change runtime ABI, object layout schema, VERT-010 artifacts, or locked runtime manifests.
- Rollback removes the v10/v8 reader/producer and VERT-011 case registration; older readers continue rejecting the new major and no persisted artifact is silently reinterpreted.

## Exit Criteria

`VERT-011` reaches `SelfAudited` only when the canonical PlaceRef contract, strict decoder/fuzz, real snapshot/HIR v10/MIR v8/LLVM/object/ELF chain, Node side-effect counters, complete negative matrices, deterministic reports, Go/Rust/LLVM gates, and documentation synchronization pass. Miri evidence is claimed only if the locked tool is available. Owner-deferred CI prevents an `Integrated` claim.

The self-audit gate is closed. The unified manifest case covers `+0`, `-0`, `1`, infinity, payload NaN, `null`, and `undefined`; the native executable and Node oracle agree bit-for-bit, while receiver, computed key, getter, RHS, and setter counters prove single evaluation and correct short-circuiting. Invalid nullable tags fail with nonzero status and no output. Repeated runtime builds preserve the manifest, harness, and archive hashes. Windows full Go test/vet, focused race, LLVM 20 backend/pipeline/runner/CLI, Rust unit/clippy/rustfmt, three bounded decoder fuzz targets, and both repository diff checks pass. Miri and rustdoc are unavailable in the locked WSL toolchain, so no evidence from either is claimed.

## Implementation Evidence

- PlaceRef schema v1 canonically binds dense place IDs, saved receiver/computed-key SSA values, object/property/source-type identities, direct/computed syntax, static-data/accessor plans, mutability, getter/setter identities, exact load/store effects, source origin, and content hash without target layout or runtime symbols.
- Strict decoding rejects unknown members, old/unknown schema, stale hashes, and artifacts over 256 KiB. Focused tamper tests cover ID/order/key/property/type/mutability/accessor/effect/physical-leakage failures while retaining legal reuse of an already evaluated SSA receiver across distinct places.
- `go test ./internal/bingo -run 'PlaceRef|VERT010' -count=1` passes. `FuzzDecodePlaceRefContract` completed about 85,000 executions in the initial five-second bounded run without a failure.
- PlaceRef v1 now embeds canonical object semantic contracts and joins each place by object/property key, data/accessor kind, read/write type, optionality, and readonly state. Object contracts are strictly type-key ordered; legal reuse of a saved SSA receiver remains allowed.
- HIR v10 canonically fixes one computed accessor `??=` graph: receiver then key then one place/load; the assigning edge alone evaluates RHS and stores once; the other edge unwraps the loaded value; the merge phi has exact predecessors. Old HIR v8 and VERT-010 v9 readers explicitly reject the new module/operation metadata.
- HIR tamper tests cover receiver/key order, copied key, mismatched load/store PlaceID, wrong/reversed nullish branch, RHS on the non-assigning edge, duplicate setter, phi predecessor/value, and forged getter effects. `FuzzDecodeVERT011PlaceHIR` completed an initial bounded run; full Go test/vet, focused race, and submodule diff checks pass.
- The real `propertynullishassign` frontend snapshot now replays without checker or AST retention into the faithful HIR v10 prefix: nullable parameter, object allocation, backing-field initialization, saved computed key, one accessor PlaceRef/load, assigning-edge constant/store, skip-edge unwrap, and exact merge phi. Object/property/read/write/accessor/backing identities are derived from canonical snapshot facts and rebound into the embedded object semantic contract.
- Repeated replay and strict frontend decoding are byte-identical. Rehashed semantic tampering covers dynamic/copied receiver or key, getter symbol substitution, backing/result type mismatch, getter/setter body substitution, RHS substitution, and missing accessor declarations. Full Go test/vet and focused race pass; the latest bounded PlaceRef and HIR decoder fuzz runs completed about 138,000 and 54,000 executions respectively.
- MIR v8 introduces an explicit 16-byte `nullable-f64` object representation (f64 payload plus nullish tag), keeps the accessor property storage-free, retains the saved receiver/key and four-block CFG, and binds exact getter/setter identities plus fixed cdecl signatures. Its strict reader rejects v6/v7 compatibility, stale hashes, layout/offset/representation, accessor ABI, receiver/key, branch/phi/effect, and GC-proof substitution; the initial bounded MIR fuzz run completed about 4,700 executions.
- The validated TargetContext binds the same eight GC capabilities without inventing runtime accessor lookup. LLVM 20 emits private getter/setter functions, closed-shape descriptors, the nullable backing field, exact nullish branch/phi, and shadow-stack operations. O0 and `default<O2>` verification, real ELF object emission, Rust runtime archive linkage, and Node differential execution pass for number, signed zero, infinity, payload NaN, null, and undefined; Node counters prove one receiver/key/getter evaluation and setter/RHS only on the nullish edge.
