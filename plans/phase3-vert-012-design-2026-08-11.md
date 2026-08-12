# VERT-012 Closure Vertical Slice

Status: `SelfAudited`. This D3/A3 design and implementation close the first escaping closure sub-slice. Automatic CI remains owner-deferred, so the result is not `Integrated`.

## Scope

- IDs: `OBJ-002a + BE-003a + VERT-012`, Phase 3 order 7.
- First executable source shape: an exported function creates one mutable `number` local, returns/uses one escaping zero-argument closure that increments the captured local, and observes repeated indirect calls.
- The closure is represented as `{code identity, environment reference}`. An escaping mutable capture is stored in one heap environment cell, captured by reference, and traced as an exact GC reference from the closure object.
- Function, capture, cell, and environment IDs are dense and canonical. Source symbol identity, signature, mutability, capture mode, storage class, field order, lifetime, and trace requirement are serialized and independently verified.

## Deferred

Lexical `this`, recursion, mutually recursive closures, nested environments, parameter/rest/default captures, object captures, async/generator frames, EH cleanup, dynamic function construction, prototype methods, and signature adaptation remain rejected. They cannot be inferred from this first sub-slice.

## Required evidence

1. Canonical closure contract v1, strict unknown-member decoder, content hash, tamper matrix, and bounded fuzz.
2. Real checker-free snapshot proof for capture ownership and escape, followed by independent HIR/MIR majors.
3. Exact environment/object layout and GC safety binding; malformed capture/root/layout plans fail before backend.
4. LLVM O0/O2, object/LLD/ELF, and Node differential proving two calls share the same mutable cell.
5. Atomic CLI artifacts, unified case runner, deterministic reports/runtime build, full Go/Rust/LLVM gates, and synchronized plans.

## Self-audit result

All required evidence is closed for the admitted sub-slice: deterministic checker-free snapshot capture proof; strict closure contract v1 and HIR v11/MIR v9 readers; by-cell GC layouts and two-slot root plan; bound nine-capability runtime closure including the write barrier; LLVM O0/O2, ELF, and Node bit differential; manifest-owned harness; atomic `emit-vert012`; unified deterministic case runner; full Go test/vet, focused race, decoder fuzz, and two-level diff checks. CI remains disabled by owner decision, and Miri is not claimed.
