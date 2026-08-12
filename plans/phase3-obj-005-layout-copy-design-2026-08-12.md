# Phase 3 OBJ-005 Explicit Layout Copy Adapter Design

Status: `Implementing`.

## Scope

This increment freezes the target-independent physical proof for an explicit
object copy. It is not an implicit structural conversion, readonly view,
mutable alias, checked dynamic cast, LLVM bitcast, or `unsafeCast`.

The adapter allocates a distinct target object and copies a closed list of
required public data properties. Each mapping binds the canonical semantic
contracts, type-relation path, source and target layout identities, field
offsets, and representations. Source and target object identity must differ.

## Admission

1. Both semantic contracts, the type-relation graph, and both target-specific
   layouts must be canonical.
2. The existing object conversion planner must independently admit
   `explicit-copy` as `copy-new-identity`.
3. Source and target layouts must bind their respective semantic type keys and
   the same observed target context.
4. Every target property must be required, public, stored data. The source
   property must have the same key and the same surface restrictions.
5. The source readable type must reach the target input type through the
   canonical relation graph.
6. Each mapping freezes the exact source load offset/representation and target
   store offset/representation in target property order.

## Rejection Matrix

- Implicit conversion, identity preservation, aliasing, or in-place bitcast.
- Optional, accessor, private, protected, dynamic, inherited, or prototype
  properties.
- Missing property, unproven/reversed type relation, stale semantic/layout
  hash, mixed targets, substituted offset, representation, relation path, or
  property order.
- Any contract that invokes user accessors or claims no target allocation.

## Current Evidence

`ObjectLayoutCopyContract` schema v1, canonical hashing, strict size-bounded
decoder, semantic-planner join, physical mapping reconstruction, tamper matrix,
and fuzz entry are implemented. The real static-profile fixture and
checker-free replay bind the exported function, two distinct object literals,
readonly contextual target, source mutation, returned target property, exact
node provenance, and independent source/target property symbols. The replay
embeds the complete canonical frontend snapshot and re-derives the contract,
HIR, and MIR during strict decoding. The reader revalidates the complete
frontend snapshot and compiler provenance, rejects unknown/oversize/stale-hash
substitution, and has a bounded decoder fuzz target. `emit-object-layout-copy-replay` publishes
that artifact deterministically with atomic no-clobber behavior, and the
production consumer joins it to the current compiler identity, exact static
BuildPlan frontend hash, observed TargetMachine, locked TargetContext/catalog,
bound MIR, and backend plan.
The production gates report compiler identity, BuildPlan frontend hash, static
profile, and nil TargetMachine mismatches independently before target
resolution, so no malformed artifact can be confused with a runtime catalog
failure.

Additive HIR v1 fixes target allocation, source loads, target stores, and a
distinct result value. Its embedded GC plan publishes/reloads the source around
the allocation safepoint and rejects reference mappings until a barrier-aware
lowering exists. MIR v1 binds the HIR to its observed triple/DataLayout,
materializes `gc.alloc.target`, `field.load.source`, and `field.store.target`,
and closes the exact six-capability rooted allocation set: `rt.gc.alloc`,
`rt.gc.frame.link`, `rt.gc.frame.unlink`, `rt.gc.root.store`,
`rt.gc.root.publish`, and `rt.gc.root.reload`. The backend plan freezes the
target shape, f64
source/target offsets, new-identity policy, status checking, and the exact
six-call rooted allocation closure. A Linux LLVM20 emitter is connected to
TargetMachine and emits source root publication/reload around allocation plus
the field copy without bitcast or a redundant safepoint call. Its tagged
O0/ELF tests are checked in but have not executed on this Windows host;
The runtime harness `runtime/bingo-rt/harness/object_layout_copy_bits.c` now
allocates the source through the real GC ABI, invokes the emitted adapter,
mutates the source after the copy, and checks distinct identity plus preserved
payload bits. The locked Node oracle has a matching new-identity script and
binary64 differential path. Linux tagged tests compile/link the emitted ELF
object with the existing runtime archive and compare NaN, signed-zero, normal,
and infinity payloads. A dedicated emitter test now verifies the actual
layout-copy module both before and after LLVM `default<O2>`: the six bound GC
calls must remain in execution order, the source reload and f64 load/store data
path must survive, and bitcast or a redundant safepoint call remain forbidden.
These tests are checked in but remain unexecuted on the current Windows host,
so the adapter is production-wired but not yet native-evidence complete.

Automatic CI remains owner-deferred. OBJ-005 remains `Implementing`.
