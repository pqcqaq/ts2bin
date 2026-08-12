# VERT-013a Base Class Vertical Slice

Status: `SelfAudited`. This D3/A3 design froze the first class sub-slice before implementation. The complete local source-to-ELF evidence now passes. Automatic CI remains owner-deferred, so this evidence cannot establish `Integrated`.

## Scope

- IDs: `OBJ-003b + BE-003a + VERT-013a`, Phase 3 order 8a.
- First executable source shape: one non-derived class with one public mutable `number` instance field, one explicit base constructor taking a `number`, and one receiver-bound zero-argument method that mutates and returns the field. An exported function allocates one instance and invokes the method twice.
- The class contract owns nominal class identity independently of structural object shape. The constructor establishes a fresh heap receiver, defines instance fields in source order, then executes its body. A method call carries the same initialized receiver explicitly.
- Class, field, method, and initialization-step IDs are dense and canonical. Source symbol identity, instance type identity, signatures, visibility, storage kind, receiver requirement, initialization phase, and source order are serialized and independently verified.

## First Fixture

```ts
class Counter {
  value: number = 0;

  constructor(start: number) {
    this.value = start;
  }

  increment(): number {
    this.value += 1;
    return this.value;
  }
}

export function classCounter(start: number): number {
  const counter = new Counter(start);
  return counter.increment() + counter.increment();
}
```

## Deferred And Rejected

`extends`/`super`, derived constructors, constructor object returns, implicit/default constructors, parameter properties, `#private`, TypeScript private/protected fields, static fields/blocks/methods, accessors, computed names, decorators, abstract classes, generic classes, method extraction, dynamic prototype mutation, `instanceof`, multiple classes, multiple fields/methods, and signature adaptation remain rejected. These require separate vertical slices and cannot be inferred from VERT-013a.

## Required Evidence

1. Canonical class contract v1, strict bounded decoder, content hash, tamper matrix, and bounded fuzz.
2. Real checker-free snapshot proof for nominal class/constructor/field/method identities and initialization order, followed by an independent HIR major.
3. Exact instance layout and GC safety binding; class identity, receiver initialization, field order, and method ABI substitutions fail before backend.
4. LLVM O0/O2, object/LLD/ELF, and Node differential proving constructor order, stable receiver identity, and two mutations of one instance.
5. Manifest-owned harness, atomic CLI artifacts, unified case runner, deterministic reports/runtime build, full local gates, and synchronized plans.

## Self-Audit Evidence

- Canonical class contract v1, HIR v12, instance layout v1, MIR v10, bound MIR v1, strict readers, tamper matrices, and old-reader isolation pass.
- Production replay and lowering preserve nominal identity, constructor initialization order, one receiver across both method calls, exact field offset, and the receiver GC root lifetime.
- LLVM 20 verification, ELF emission/link/execution, manifest-owned runtime harness, and Node bit differential pass for `+0`, `-0`, `1`, `Infinity`, and payload NaN.
- `emit-vert013a` atomically publishes the verified artifact set; the unified runner produces byte-identical repeated reports.
- Windows full Go test/vet, focused race, class-contract/MIR fuzz, WSL LLVM-tagged runner/CLI, and root/submodule `git diff --check` pass.

CI remains intentionally disabled by the owner and Miri evidence is not claimed. Status is therefore capped at `SelfAudited`, not `Integrated`.
