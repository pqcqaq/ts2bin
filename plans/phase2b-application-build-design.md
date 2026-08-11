# Phase 2B Application Build Preview Design

Status: implemented and locally verified under the project owner's Phase 2 directive. External A3 review remains required before a release profile can consume this preview.

## Issue Brief

- ID / stage / owner: `APP-001 + CLI-001 + VERT-009`, Phase 2B, ts2bin maintainers.
- Problem and user impact: the compiler proves seven real LLVM/ELF fixture slices, but users cannot build a real source project because the CLI and linker expose only case-manifest harnesses.
- Source surface: `export function main(): number` in one static-profile project entry module.
- Support level and profiles: experimental static-core build preview for `x86_64-unknown-linux-gnu`, LLVM 20, no EH, locked `core-es2020` runtime.
- Change level / audit level: D3 / A3. The change adds an application startup object, a versioned program ABI symbol and LLVM/link behavior.
- Dependencies: completed Phase 2A real-object path and the completed Phase 2B number/control-flow contracts.
- Non-goals: argv/env, stdout/stderr APIs, modules beyond the captured project closure, owned strings, allocation/GC use, exceptions, async, FFI, Windows executables and a general product backend.

## Accepted Contract

The project must contain exactly one exported application entrypoint with this source contract:

```ts
export function main(): number {
    return 0;
}
```

VERT-009 accepts a parameterless `main` whose body returns one canonical non-negative integer numeric literal in the inclusive range `0..255`. This intentionally narrow expression contract is independently reconstructed from the serialized frontend snapshot; the CLI may not select a checked-in case or infer machine code from a filename/function whitelist.

The HIR and MIR retain the source name `main`. LLVM exposes the collision-free versioned C ABI symbol:

```c
double bingo_program_main_v1(void);
```

The manifest-authenticated `bingo_application_startup_v1.o` owns C `main`, verifies the runtime ABI, calls `bingo_startup_empty_v1`, calls `bingo_program_main_v1`, and returns the exact integral `0..255` result as the process status. It writes no stdout or stderr. A non-finite, fractional, negative or greater-than-255 result is a violated compiler/ABI invariant and exits with status 70; a runtime ABI mismatch exits with status 71. User source outside the accepted literal range is rejected before HIR production, so those startup defenses are not a source-language conversion rule.

`ts2bin build [-p tsconfig.json] [-o output]` performs the real source path:

```text
tsconfig/source -> ProgramSnapshot -> FrontendSnapshot/BuildPlan
-> verified HIR -> resolved TargetContext -> verified MIR
-> verified LLVM/object -> manifest-authenticated application startup/runtime -> ELF
```

The command writes the executable and a canonical adjacent `<output>.report.json` provenance report. It does not build runtime source during a user build. Runtime artifacts must already exist and match the repository lock and runtime manifest.

## Rejection and Diagnostics

- Missing, duplicate, non-exported or parameterized `main`: stable build diagnostic and no object/executable.
- Non-number return type, missing return, non-literal return, negative/fractional/non-finite/out-of-range literal: stable build diagnostic and no HIR artifact publication.
- Unsupported syntax elsewhere in the emitted project closure: existing subset diagnostics remain authoritative.
- Wrong target/profile/runtime/toolchain or substituted startup/archive bytes: fail before linking.
- MIR/LLVM verifier failure: internal compiler error, never rewritten as unsupported user syntax.

## Artifact and Schema Impact

- HIR major increments from v7 to v8 because a new canonical application function shape is admitted.
- first-slice MIR major increments from v5 to v6 for the corresponding verified function-set contract.
- Runtime ABI schema remains major v1 and adds `bingo_program_main_v1` plus `bingo_application_startup_v1` without changing existing layouts.
- Runtime manifest schema remains v1 and adds a required `applicationStartupObject` artifact. Its source/schema/manifest/content hashes and the repository lock must change together.
- Existing seven fixture harness paths remain accepted and byte-authenticated.

## Tests and Acceptance

Positive and boundary evidence:

- real project `main` returning 0, 1 and 255;
- repeated build produces byte-identical LLVM object, ELF and report hashes;
- produced ELF has no stdout/stderr and returns the exact source status;
- LLVM symbol is `bingo_program_main_v1`, never C `main`.

Negative evidence:

- missing/duplicate/non-exported/parameterized `main`;
- `void`, boolean, negative, fractional, NaN/Infinity-like and 256 return forms;
- rehashed malformed HIR/MIR application shapes;
- substituted application startup object, runtime archive or manifest;
- old HIR v7 and MIR v5 artifacts are rejected by the new decoder.

Required local gates are focused Go tests, LLVM 20 WSL tests, runtime ABI generation check, runtime rebuild/manifest regeneration, `doctor`, deterministic repeated build and `git diff --check`. GitHub workflows remain disabled by project direction.

## Alternatives and Rollback

Reusing a fixture harness was rejected because it would not establish a source-project application boundary. Emitting LLVM `@main` directly was rejected because startup ownership and future runtime initialization would collide with the source symbol. Applying JavaScript `ToInt32` or platform truncation was rejected because process exit behavior would vary or silently accept invalid application results.

Rollback removes the build command and application startup artifact, restores HIR v7/MIR v5 plus the previous runtime hashes, and leaves all seven fixture vertical slices intact. No cache may mix the old and new IR/runtime identities.
