# Phase 3 OBJ-005 Checked Object Cast Design

Status: `Implementing`.

## Scope

This increment adds an explicit, checked object conversion boundary. It is not
TypeScript `as`, `satisfies`, a non-null assertion, a structural readonly view,
or `unsafeCast`. Those forms either preserve compile-time typing only or have
their own immutable proof contracts.

The initial checked cast accepts one runtime object reference and one closed
target object semantic/layout contract. It returns either the same reference
with the target view proof or an explicit failed result. It never allocates,
copies, mutates, calls user accessors, or traverses arbitrary prototype/dynamic
property state.

## Admission

1. Source must enter through an explicit dynamic/FFI boundary artifact; a
   static object value or TypeScript assertion is not an admissible source.
2. Target semantic and layout contracts must be canonical and bind one locked
   target triple/DataLayout.
3. The runtime shape descriptor must be authenticated by the target layout
   contract, including property count, keys, kinds, representation, presence
   and trace metadata.
4. The first implementation permits required public data properties only. It
   rejects optional properties, accessors, private/protected identity,
   functions, arrays, inherited/prototype members and dynamic keys.
5. Success returns the original identity and a readonly target surface; a
   writable target requires a distinct alias/store proof.

## Runtime ABI

The runtime capability is introduced only with a versioned ABI and manifest
entry. The candidate ABI is a non-throwing predicate:

```c
int32_t bingo_shape_matches_v1(const void *object, const BingoShapeDescriptorV1 *target_shape, uint8_t *out_match);
```

`out_match` is exactly 0 or 1. A non-zero status is a runtime contract failure,
not a failed cast. The caller performs no unchecked header dereference before
the capability validates its input. The capability is forbidden from invoking
user getter/setter code or allocating.

## Rejection Matrix

- `as T`, `<T>value`, `satisfies`, non-null assertion or forged assertion proof.
- Static source, unknown target shape, stale manifest/ABI hash or substituted
  target layout/semantic contract.
- Optional/accessor/private/protected/function/dynamic/prototype surface.
- A runtime match result without the exact capability status/match provenance.
- Any success path that changes object identity, exposes target writes, or
  reaches an LLVM bitcast/copy adapter.

## Evidence Required

- Strict decoder/hash/tamper/fuzz coverage for the checked-cast contract and
  bound MIR.
- A real dynamic-boundary fixture with both matching and nonmatching shapes.
- Runtime manifest, ABI C/Rust/header generation and capability closure.
- Linux LLVM object/harness/Node differential for success, failure, NaN,
  optional/presence and forged-shape negatives.

Automatic CI remains owner-deferred. This design does not advance OBJ-005 to
`SelfAudited` or `Integrated`.

The first target-independent implementation slice is now present in
`internal/bingo/object_checked_cast.go`: a hashed dynamic-boundary artifact,
strict checked-cast contract, target semantic/layout provenance checks, and a
required-public-data-only admission rule. Decoder/tamper tests and bounded fuzz
coverage pass locally.

The initial runtime capability is generated from `schema/abi-v1.json` as
`bingo_shape_matches_v1(object, target_shape, out_match) -> status` and listed
as `rt.object.shape_matches` in the target manifest. It first verifies that
`object` is a live runtime-heap allocation, clears `out_match`, and then
structurally compares its allocator-authenticated descriptor with the target
descriptor, including bounded property keys and physical metadata.
Null, foreign, or stale objects are contract failures rather than unchecked
header reads. A real dynamic-boundary fixture, bound lowering, and Linux
ELF/native/Node differential remain next steps.

The runtime verifier now validates source descriptors as readable data or
accessor shapes, while applying the required-public-data-only rule only to the
target descriptor. Thus an accessor/optional source produces `match=0` against
the first target shape; malformed descriptors still produce a non-zero status.
Source shapes may also carry additional validated properties: matching is a
target-property subset check, with source object size/alignment required only
to be large enough for the target slots. Source and target trace metadata are
validated independently rather than compared by module-local identity.

`CheckedObjectCastBoundContract` now freezes the canonical cast together with
the TargetContext hash, available-capability-catalog hash, and the exact
`rt.object.shape_matches` / `bingo_shape_matches_v1` signature binding. The
artifact is decoder/fuzz covered, but TargetContext does not admit a positive
binding until an authoritative runtime manifest rebuild locks the new
capability; this prevents a source-only manifest edit from reaching lowering.
The `targetcontext.BindCheckedObjectCast` path is nevertheless wired and
fails closed when the locked catalog lacks that capability.

The target-aware backend plan is also implemented. It embeds the complete
bound artifact and independently rechecks semantic hash, layout content hash,
physical layout hash, property count, exact runtime symbol, checked status,
the `0|1` match domain, and success as the original source reference. Its
canonical form forbids allocation, copying, accessor invocation, and any
additional runtime call. LLVM emission still waits for a positively locked
runtime capability binding.

A Linux LLVM 20 emitter and tagged O0/O2 structural test are now checked in.
The wrapper emits the plan-owned target shape, clears output state, calls
`bingo_shape_matches_v1`, propagates non-zero status, rejects a result outside
the `0|1` domain, and stores the original source reference only for match=1.
Its tagged LLVM tests have not run because this host cannot start WSL; this is
source integration, not LLVM/ELF evidence.

A locked Node oracle now models the first exact public-data shape with the
protocol `<match 0|1>:<binary64 bits>`. Matching, missing, extra-property, and
accessor cases are distinct; success reads from the same object and preserves
payload NaN bits. This is oracle evidence only and does not replace native ELF
execution.

A runtime-owned C harness now accepts `<matching|extra|missing|accessor>
<binary64 bits>` and emits the same `<0|1>:<bits>` protocol. It allocates the
source through the runtime, invokes the LLVM wrapper, checks status/match and
source identity, and is wired into the build script/manifest writer. Only C
syntax and build wiring are host-verified; its ELF object and manifest hashes
still require the authoritative Linux rebuild.

The first-slice linker now recognizes the checked-cast wrapper as an explicit
`i32` status ABI instead of applying the existing `double` entry-point rule.
It selects only the manifest-authenticated checked-cast harness and fails
closed when that artifact is absent. The native invocation helper accepts only
the four canonical shape cases and lowercase 16-digit payload bits, and
requires exactly one `<0|1>:<lowercase bits>` output line. These are source and
protocol-boundary tests only: the locked manifest still blocks a real link and
no ELF/native differential claim is made.

A real interop-profile frontend fixture now freezes the source-side admission
facts without inventing a user-visible intrinsic. It contains exactly one
ambient `hostObject(shape: "matching" | "missing"): unknown` declaration and
one required-public-readonly `HostValue.value: number` target. The closed case
union provides real matching/nonmatching source-shape inputs. The checker-free replay rejects every
TypeScript `as` node, requires the declaration-only unknown-effect signature,
rebuilds the target semantic/layout contracts, and emits the canonical
`ffi-import` checked-cast contract. Rehashed return/effect/readonly/assertion
substitutions, strict decode, determinism, size bounds, and decoder fuzz are
covered. This proves frontend provenance only; the eventual source syntax or
CLI boundary remains a separate design decision and positive bound lowering
still waits for the authoritative runtime manifest rebuild.

The production `bingomir` boundary now joins that replay with the exact
BuildPlan frontend hash, resolved TargetContext, available-capability catalog,
bound checked-cast artifact, and backend plan before LLVM emission is allowed.
It first requires an interop-profile BuildPlan; static-profile substitution,
nil TargetMachine, and frontend substitution fail before binding. The current
first-slice TargetContext/runtime manifest is intentionally static-only, so a
real interop plan stops at runtime-profile resolution before the capability
catalog is considered. A Linux LLVM20 tagged test records that exact
fail-closed boundary but has not run on this Windows host. Positive binding
and emission require an authoritative interop runtime manifest that also
publishes `rt.object.shape_matches`, rather than a manually forged catalog.

Replay provenance is now explicit rather than implicit: the replay artifact
stores the host name symbol ID, host signature hash, source `unknown` type
hash, target type hash, and target property key. Its canonical decoder
requires the boundary source ID and cast source/target/property fields to agree
with that evidence. This closes the prior gap where a canonical cast and a
frontend hash were only correlated by construction. Host-symbol, signature,
source, target, and property substitutions are covered by artifact negatives.

The replay reader is now schema v2. Its frontend evidence is itself a
schema-v1 canonical artifact containing the frontend snapshot hash and its
host/signature/source/target/property facts. The dynamic boundary source ID is
`frontend-evidence:<content hash>`, so even a fully rehashed evidence,
boundary, and cast chain for another snapshot cannot retain the outer replay
identity. Old replay schema v1/v2 and evidence without a canonical hash are
rejected rather than silently upgraded.

The replay major is now v3. Frontend evidence also carries the validated
`CompilerBuildIdentity` and the canonical matching/missing case-union type
hash. Those fields participate in the evidence content hash and are compared
with the outer replay identity. A valid artifact from another compiler build
or another dynamic-case union therefore cannot be rehashed into this replay.

The replay major is now v4 and embeds the complete canonical frontend
`ProgramSnapshot`. Construction and decoding share one checker-free derivation
function; the decoder validates the snapshot and independently rebuilds the
frontend evidence, dynamic boundary, target semantic/layout contracts, and
checked-cast contract before comparing content hashes. A rehashed embedded
snapshot substitution and old v3 reader are rejected. This replaces reliance
on opaque frontend hashes with a self-contained replay proof.

Target admission no longer uses `TypeSnapshot.DebugText`, which is explicitly
diagnostic-only and absent from canonical type identity. The derivation now
locates the unique `HostValue` interface declaration through its canonical
name identifier, verifies the symbol's declaration reverse edge, and requires
the object type symbol and payload scalar to bind that same symbol. Changing
only diagnostic type text preserves the semantic cast; interface-name, symbol
declaration, or type-symbol substitutions fail closed.

The dynamic-case reader no longer binds admission to the current compiler's
numeric string-literal flag encoding. It validates the normalized literal
kind/tag and extracts the canonical string value from the structured payload,
then requires the closed `matching | missing` set. Target-property admission
is independently closed over the object's property list/fact, property symbol
parent and type, unique declaration/value-declaration reverse edge, owning
`HostValue` interface, readonly getter-only data shape, and canonical `number`
read type. Rehashed setter, parent-symbol, declaration, and read-type
substitutions are rejected before semantic/layout planning.

The first user-visible boundary is an artifact command rather than new
TypeScript syntax: `ts2bin emit-checked-cast-replay --output FILE SNAPSHOT`
accepts only a canonical frontend snapshot, derives the self-contained replay
v4 with the injected compiler identity, and publishes it atomically without
replacing an existing file. It does not accept a runtime manifest or emit
LLVM, so its success proves frontend admission only. Static fixtures, missing
compiler identity, malformed snapshots, and occupied outputs fail closed.
The checked-cast replay implementation is now included in
`PrimitiveLoweringHash`; compiler identity therefore changes when this reader
changes instead of authenticating an implementation subset that omitted it.
No `as`, `satisfies`, non-null assertion, or invented intrinsic is assigned
runtime-cast semantics by this command. The ambient FFI declaration in the
fixture is the source-level provenance fact; the artifact command is the
formal user boundary. A second TypeScript cast syntax is intentionally out of
scope for this increment.

Production lowering now has a matching artifact-consumer entry point,
`LowerCheckedObjectCastReplay`/`ExecuteCheckedObjectCastReplay`. It strictly
decodes the replay, compares its embedded compiler identity with the current
compiler, joins the exact BuildPlan frontend hash, and then enters the same
TargetContext/capability/backend chain as snapshot construction. Snapshot and
artifact paths are tested for identical fail-closed ordering; neither path can
reach binding until the authoritative interop runtime profile is available.
