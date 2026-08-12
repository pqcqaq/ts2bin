# Phase 3 OBJ-003b Private/Protected Access Design

Status: `Implementing`. This D3 design covers Phase 3 order `8b-2` only. It adds nominal private identity and protected lexical/receiver access checks without changing the frozen VERT-013b class-contract v2 or introducing variance, casts, adapters, static initialization, decorators, or dynamic dispatch.

## Scope

- A versioned, target-independent class-access contract records declaration-ordered nominal classes, direct base relations, member owners, visibility, and private identity.
- Access requests bind the lexical accessing class, receiver static class, selected member identity, and private identity proof.
- Public access requires a receiver in the declaring class family.
- Private access requires the exact private identity and the declaring class lexical scope. A derived class does not inherit private access rights.
- Protected access requires a lexical class in the declaring family. When the lexical class is derived, the receiver must be that lexical class or one of its subclasses; access through an arbitrary base-typed receiver is rejected.
- External access uses accessing class ID zero and can reach public members only.

## Rejection Matrix

- Unknown class/member IDs, forward/cyclic inheritance, duplicate class/member symbols, and nondense IDs.
- Missing, duplicated, or substituted private identity; private identity attached to public/protected members.
- Private access from derived, unrelated, or external lexical scopes.
- Protected access from unrelated or external scopes.
- Protected access from a derived scope through a receiver that is only the base class or a sibling family.
- A receiver outside the member owner's nominal family, regardless of visibility.
- Old VERT-013b readers accepting the new contract or new readers accepting stale schema/hash/unknown members.

## Vertical Evidence Plan

1. Canonical strict class-access contract, access planner, diagnostic reason stability, tamper matrix, and bounded fuzz.
2. Checked-in TypeScript fixtures with legal private/protected access and compiler-diagnostic fixtures for illegal external, derived-private, and protected-base-receiver access.
3. Checker-free snapshot replay that binds modifier facts, member owner, private identity, lexical containing class, receiver type, and selected property symbol.
4. HIR v15 supersedes the authorization-only v14 artifact. It retains the four planner-replayed member proofs and additionally embeds the canonical execution contract plus five complete target-independent function CFGs: base initialization, derived allocation/direct super, both methods, and the exported entry. v9-v13 readers reject the class-access fields and the v14 reader is not treated as execution evidence.
5. Structural MIR v13 embeds canonical HIR v15 and the execution contract, lowers field/method authorization separately, fixes the representation to `f64`, and binds the exact TargetContext/triple/DataLayout identities without selecting an offset. TargetContext binding rejects frontend substitution; a subsequent bound-MIR artifact must add the resolved root/layout/capability closure before LLVM emission is admitted.
6. Join MIR authorization to canonical base/derived object layout before selecting field offsets or method callees. The layout contract binds both the artifact DataLayout hash and the independent LLVM layout-string hash; base `secret`/`value` fields remain an exact two-field prefix in the derived layout. Since TypeScript private/protected visibility erases at runtime, this slice adds no new runtime ABI; existing LLVM lowering may be reused only after this join is verified.
7. MIR v13 reconstructs every structural instruction from HIR v15: base private/protected initialization, derived allocation/direct super, authorized loads, public calls, and final `fadd`. It preserves the single complete-receiver allocation but remains target-independent with respect to offsets and roots; a bound-MIR closure must add GC safety and exact runtime capability bindings.
8. The production `bingomir` chain and classaccess-specific LLVM 20 emitter now consume the post-layout bound MIR and can produce a canonical object. Linux-tagged verifier/object tests are checked in, but LLVM/O0/O2 evidence is claimed only after they execute in an available Linux LLVM environment; ELF/runtime/Node differential remains a separate gate.
9. Targeted race/full Go gates and synchronized backlog/progress records. Automatic CI remains owner-deferred, so local evidence cannot produce `Integrated` status.

The runtime boundary owns a zero-argument `classAccess` harness and manifest artifact. Its object/hash must come from the authoritative Linux runtime build; hand-authored manifest hashes are prohibited. The unified case has one zero-argument execution with expected binary64 bits `4008000000000000`.
