# Phase 3 OBJ-005 Function Thunk Design

## Status and scope

This sub-slice starts at `Implementing`. It freezes a target-independent
canonical proof for one required object-reference parameter and one
object-reference return value. It does not yet add source syntax, HIR/MIR,
LLVM, runtime allocation, optional/rest parameters, `this`, overloads,
checked casts, copies, exception bridging, or host entry.

## Semantic contract

For `SourceFn -> TargetFn`, the generated thunk must prove:

1. the target argument converts to the source parameter (`TargetParam ->
   SourceParam`);
2. the source result converts to the target result (`SourceReturn ->
   TargetReturn`);
3. source effects are a subset of effects admitted by the target contract;
4. source, target, and thunk use the frozen `bingo.funcref.object.v1` calling
   convention and the same closure-environment ABI;
5. the thunk performs no allocation, copy, runtime check, suspension, host
   entry, or hidden identity change.

Both conversion paths are recomputed from an embedded canonical
`TypeRelationGraph`; caller-supplied reliable flags are not accepted.
Bivariant, invariant, unknown, or otherwise unmeasurable source-language
proofs are not sufficient for this artifact and remain rejected.

## Verification

The schema uses strict unknown-member decoding, a bounded input size, a
canonical content hash, canonical effect ordering, exact single-parameter ABI
shape, and recomputed shortest relation paths. Tests cover direction reversal,
unrelated parameter/return types, effect widening, ABI/environment changes,
runtime-check/allocation/copy/host-entry substitutions, stale hashes, unknown
members, and oversized input.

Completion of this artifact alone does not make the function-thunk feature
`SelfAudited`; a real frontend fixture, HIR consumer, MIR/LLVM materialization,
and differential execution remain required.

The real `functionthunk` fixture now contains exported body-resolved `source`
and `target` functions plus `adapted: typeof target = source`. Both signatures
are single required `call` ABI functions with complete `read` effect proofs;
the replay binds their declaration identities, exact `Animal`/`Dog` interface
symbols and object types, the contextual target at the assignment, and the
canonical `Dog extends Animal` relation edge. An earlier ambient declaration
variant produced `unknown`/incomplete effects and is intentionally rejected,
rather than being admitted as a thunk shortcut.

FunctionThunk HIR uses an additive schema instead of extending the frozen
general HIR type enum before a target FuncRef representation exists. HIR v1
materializes a dense three-step wrapper:

```text
parameter.convert(TargetParam -> SourceParam)
source.call(source signature, source effects)
return.convert(SourceReturn -> TargetReturn)
```

The two conversions carry the replay-derived relation paths and no effects;
only the call inherits the exact source signature effects. The HIR verifier
rebuilds all IDs, operands, type directions, paths, call signature, effects,
return value, and environment-preservation bit. The self-contained replay to
HIR join owns source provenance validation; the standalone HIR reader owns
canonical structure and content identity. Target-dependent FuncRef layout,
MIR call ABI, root handling, and LLVM remain out of this increment.

FunctionThunk MIR v1 follows the same additive boundary and embeds the
canonical HIR. It is the first target-dependent artifact: target triple and
DataLayout hash are content-bound, object parameters/results use `gc-ref`, and
FuncRef is fixed as `{code-ptr, gc-ref-or-null}` with code/environment field
indices 0/1. The two proven upcasts lower to reference-preserving identity
operations rather than allocation, copy, runtime check, or LLVM bitcast. The
source call retains its exact signature hash and effects; the current `read`
fixture is not a safepoint, while an admitted `allocate` effect is marked as
one. The backend plan and LLVM20 Linux emitter now project the exact
`{code, environment}` pair and emit the indirect source call without
allocation, runtime call, copy, or bitcast. Until a GC root publication plan
is attached, the backend rejects any source call marked as a safepoint.
Linux-tagged tests cover O0/O2 verification, ELF emission, a C ABI harness,
environment/object identity, and Node differential output. They have not run
on the current Windows host because WSL is inaccessible, so native evidence
remains pending and `OBJ-005` stays `Implementing`.

The user-visible artifact boundary is `emit-function-thunk-replay`. It accepts
only a canonical frontend snapshot, injects the current compiler identity, and
atomically publishes a no-clobber self-contained replay. Production lowering
strictly joins that replay to the current compiler identity and a canonical
static BuildPlan whose frontend hash matches. It then derives HIR, target-bound
MIR, backend plan, and LLVM emission from the observed TargetMachine. No
runtime manifest/capability binding is accepted or needed for this pure static
thunk; that boundary must remain separate from checked casts.
