# VERT-013b Derived Class And Super Vertical Slice

Status: `SelfAudited`. This D3/A3 design narrows Phase 3 order 8b to one derived-class slice. The deterministic frontend fixture, strict class contract v2, checker-free replay, HIR v13, base-prefix/derived-suffix layout contract, MIR v11/bound MIR, TargetContext binding, LLVM/ELF/Node differential, runtime harness, unified runner, and atomic CLI artifacts are complete under local evidence. It does not include private fields, protected access, static initialization, variance, or adapters. Automatic CI remains owner-deferred, so this slice is not `Integrated`.

## Scope

- IDs: `OBJ-003b + BE-003a + VERT-013b`, Phase 3 order 8b-1.
- One module containing exactly two nominal classes: a non-derived base and one derived class.
- The base has one public mutable `number` field and one receiver-bound method. The derived class has one additional public mutable `number` field, an explicit constructor that calls `super(start)` before its own field initialization/body, and one receiver-bound method that reads both fields.
- The exported entry allocates the derived class and calls the derived method twice on the same receiver. Dispatch is statically known; method extraction, virtual prototype mutation, and dynamic `super` are rejected.

## Frozen Fixture

```ts
class Counter {
  value: number = 0;
  constructor(start: number) { this.value = start; }
  increment(): number { this.value += 1; return this.value; }
}

class StepCounter extends Counter {
  step: number = 1;
  constructor(start: number, step: number) {
    super(start);
    this.step = step;
  }
  increment(): number {
    this.value += this.step;
    return this.value;
  }
}

export function derivedCounter(start: number, step: number): number {
  const counter = new StepCounter(start, step);
  return counter.increment() + counter.increment();
}
```

## Contract Invariants

- Class contract v2 retains dense nominal IDs and adds `baseClassId`, `super` constructor identity, derived-constructor ABI, and base-layout prefix ownership.
- Derived construction order is fixed: allocate complete receiver, execute base field initialization and base constructor body, initialize derived fields, then execute derived constructor body.
- The derived instance layout is a canonical base-prefix plus derived suffix. Existing base offsets cannot move; field symbol and class identity are bound into the layout hash.
- `super()` is a direct statically-bound call and consumes the same receiver. A constructor that omits, duplicates, or executes `super()` after derived field/body work is rejected.
- Method lookup is nominal and statically resolved for this slice. Receiver type, method identity, and ABI are explicit in HIR/MIR; no function-pointer extraction is admitted.

## Explicitly Rejected

Multiple inheritance, mixins, `super` property reads, dynamic prototype mutation, method extraction, `#private`, TypeScript private/protected, static fields/blocks/methods, accessors, decorators, abstract/generic classes, constructor return overrides, implicit constructors, variance conversions, checked casts, and object adapters.

## Required Evidence

1. Strict bounded class-contract v2 decoder, old-version isolation, and constructor/order/identity tamper matrix with fuzz.
2. Real snapshot replay proving base/derived symbols, `super` target, field order, and derived method dispatch, followed by independent HIR v13.
3. Base-prefix/derived-suffix layout and exact GC/root binding; forged base offset, class identity, receiver, or `super` callee must fail before LLVM.
4. LLVM O0/O2, ELF/link execution, runtime harness, and Node differential for binary64 edge values.
5. Atomic CLI artifacts, unified runner, deterministic report/runtime identities, full local gates, and synchronized plan/progress records before `SelfAudited`.
