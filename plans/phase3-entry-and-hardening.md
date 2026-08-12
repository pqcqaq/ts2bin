# Phase 2.5 Hardening and Phase 3 Entry Plan

Status: accepted plan revision. Local engineering hardening and the Phase 2B self-audit record are complete; see [phase2b-a3-self-audit-2026-08-11.md](phase2b-a3-self-audit-2026-08-11.md). The independent A3 review for `APP-001/CLI-001/VERT-009` remains pending. Automatic CI activation is intentionally deferred by the project owner and is not changed by this plan. Until it is restored, changes may reach `LocalVerified` or `SelfAudited`, but not `Integrated`, `ReleaseCandidate`, or `Released` solely from local evidence.

## 1. Phase 2.5 hardening

| ID | Status | Result / exit evidence |
| --- | --- | --- |
| `ENG-001` | `complete` | ELF and report use a shared staged, atomic no-clobber publisher; encode/publish failure rolls back the ELF, with concurrent-owner and injected-failure regression coverage. |
| `ENG-002` | `complete` | Primitive snapshot lowering, MIR function-set verification, and LLVM emission use explicit registries; lowerer ambiguity is rejected and LLVM does not retain a duplicate function-name admission whitelist. |
| `REL-003a` | `complete` | Seeded Go fuzz targets exercise strict `FrontendSnapshot`, `ProgramSnapshot`, Phase 2 HIR, and structural MIR decoding with bounded inputs and canonical round trips; fixed HIR unknown-field/schema/hash negatives cover the decoder contract. Sustained fuzzing and corpus management remain in `REL-003`. |
| `GOV-001` | `review-blocked` | `APP-001/CLI-001/VERT-009` has local D3 evidence but still requires an independent A3 design and implementation review before release-profile consumption. |
| Automatic CI | `owner-deferred` | The manual workflow remains unchanged. Local gates remain mandatory; deferred CI cannot be cited as Integrated evidence. |

## 2. Phase 3 vertical sequence

Phase 3 continues the Phase 2 method: each semantic contract must close through snapshot proof, HIR/MIR verification, target layout, LLVM/object/link, isolated execution, and Node or specification differential evidence. Broad object or class implementation is not a single issue.

| Order | ID | Scope | Required evidence |
| --- | --- | --- | --- |
| 1 | `OBJ-000a` (`SelfAudited`) | Object semantic model: reference identity, aliasing, equality, readonly/write rules, escape categories, and dynamic boundary | [Design/self-audit](phase3-obj-000a-design-2026-08-11.md); canonical strict decoder, bounded fuzz, positive/negative semantic fixtures; no physical layout |
| 2 | `OBJ-000b + BE-004b` (`SelfAudited`) | Versioned object header/shape/field/trace layout against Linux x86-64 and compile-only Linux AArch64 | [Design/self-audit](phase3-obj-000b-be-004b-design-2026-08-11.md); Rust `repr(C)`/C/LLVM size-align-offset diff, strict decoder/fuzz, schema/layout substitution rejection |
| 3 | `GC-001a + BE-003b` (`SelfAudited`) | Single-mutator root liveness, safepoints, dead-slot clearing, write barrier, and O2 preservation contract | Canonical verifier; LLVM litmus before/after optimization on both targets; malformed root map rejection |
| 4 | `RT-006a` (`SelfAudited`) | Minimal non-moving tracing heap sufficient for owned object allocation; no weak references, async frames, or finalization | [设计/自审](phase3-rt-006a-design-2026-08-11.md); Rust unsafe audit, C ABI smoke, cycle/root stress, archive and manifest determinism |
| 5 | `OBJ-001a + OBJ-006a + BE-003a + VERT-010` (`SelfAudited`) | Object literal plus static property read/write with identity-preserving allocation | [Design/self-audit](phase3-vert-010-design-2026-08-11.md); canonical source-to-ELF case runner, exact capability/root binding, Node differential, closed negative matrices, fuzz, and deterministic reports pass |
| 6 | `IR-006b + OBJ-003a/006b + VERT-011` (`SelfAudited`) | Computed key, getter, optional chain, and property logical assignment PlaceRef single evaluation | [Design/self-audit](phase3-vert-011-design-2026-08-11.md); canonical source-to-ELF runner, Node side-effect counters, CLI publication, negative matrices, fuzz, and deterministic rebuild evidence pass |
| 7 | `OBJ-002a + BE-003a + VERT-012` (`SelfAudited`) | First escaping mutable capture, function value, by-cell environment, indirect call; lexical `this`, recursion, nested environments, and adapters remain deferred | [Design/self-audit](phase3-vert-012-design-2026-08-11.md); strict contract/HIR/MIR, exact GC layouts/root plan, LLVM/ELF/Node, manifest harness, CLI, runner, fuzz, and deterministic evidence pass |
| 8a | `OBJ-003b + BE-003a + VERT-013a` (`SelfAudited`) | Base class nominal identity, constructor receiver, ordered instance field initialization, receiver-bound method | [Design/self-audit](phase3-vert-013a-design-2026-08-11.md); strict contract/HIR/MIR, exact layout and GC binding, LLVM/ELF/Node, manifest harness, CLI, runner, fuzz, race, and deterministic evidence pass |
| 8b-1 | `OBJ-003b + BE-003a + VERT-013b` (`SelfAudited`) | One statically-dispatched derived class, direct `super()` construction, base-prefix/derived-suffix layout | [Design](phase3-vert-013b-design-2026-08-12.md); snapshot through bound MIR v11, LLVM/ELF/Node, runtime harness, unified runner and atomic CLI artifacts complete; CI owner-deferred |
| 8b-2 | `OBJ-003b` (`Implementing`) | Private/protected nominal identity and access checks | [Design](phase3-obj-003b-access-design-2026-08-12.md); canonical access/execution contracts, snapshot replay v2, HIR v15, structural MIR v13, access-aware layout, post-layout bound MIR, strict backend plan, LLVM emitter, runtime harness, runner and CLI are implemented; authoritative Linux runtime rebuild, locked manifests, O0/O2, ELF and native/Node differential evidence remain required |
| 8c | `OBJ-004 + OBJ-005` | Variance proof, checked casts, layout adapters and thunks | Cross-module-ready contracts; no implicit mutable covariance |

`BE-003a` owns object/closure LLVM lowering, `BE-003b` owns GC root/barrier lowering, and later `BE-003c` owns EH lowering. No feature waits for a monolithic Phase 6 backend issue before it can run.

## 3. Runtime and cleanup sequencing

- `RT-003a`: owned UTF-16 string and array/tuple storage depends on `RT-006a`; borrowed UTF-16 remains the completed Phase 2 contract.
- `RT-003b`: Map/Set depends on owned allocation plus stable SameValueZero and iterator contracts.
- `RT-004a`: synchronous iterator close covers normal, break, continue, and return.
- `RT-004b`: throw/finally iterator close depends on `EH-001 + ADV-001 + BE-003c`.
- `RT-005a`: synchronous `using` cleanup covers normal and structured control-flow exits.
- `RT-005b`: throwing `using` cleanup depends on the EH vertical slice.
- `RT-005c`: `await using` depends on `ADV-002` async/Promise state machines.
- `RT-007a`: the no-allocation/no-throw/no-suspend stdlib seed must not depend on owned collection runtime merely to publish its package format.

## 4. Phase 3 entry gate

Phase 3 implementation may start after `ENG-001/002` and `REL-003a` pass locally. Release-profile consumption remains blocked by `GOV-001` and by intentionally deferred automatic CI. Before the first owned object is accepted, `OBJ-000a/000b`, `GC-001a`, `BE-004b`, and the relevant ABI/schema review must all be complete.
