# Phase 2B D3/A3 Self-Audit Record

Date: 2026-08-11

Scope: `APP-001 + CLI-001 + VERT-009` and the Phase 2.5 hardening needed to begin Phase 3 implementation. This is an author self-audit record, not an independent A3 approval. It intentionally leaves the independent design and implementation review open.

## Decision

The scoped Phase 2B application preview and its Phase 2.5 engineering gate are locally complete. Phase 3 implementation may begin under the order in [phase3-entry-and-hardening.md](phase3-entry-and-hardening.md). The application preview remains in `SelfAudited` / `review-blocked`; it must not be consumed by an Integrated or release profile until an independent A3 reviewer records approval. Automatic CI remains owner-deferred and unchanged.

## Requirement Audit

| Area | Required invariant | Evidence | Result |
| --- | --- | --- | --- |
| Source boundary | Only one exported, parameterless `main(): number` returning a canonical `0..255` literal reaches application HIR/MIR. No checked-in case name selects code generation. | `internal/applicationbuild` and `cmd/ts2bin` positive/boundary/negative tests; snapshot-only replay path. | Pass |
| ABI/startup | LLVM exports `bingo_program_main_v1`; the manifest-authenticated application startup owns C `main`, verifies ABI version, and maps only a finite integral `0..255` result to process status. | `runtime/bingo-rt/startup/application.c`, `schema/abi-v1.json`, runtime link smoke, WSL application ELF execution. | Pass |
| Runtime identity | Archive, startup objects, manifest, target layout, ABI schema, Clang and LLD are verified before link. | `targetcontext`/`firstslicelink` tests, runtime rebuild and manifest regeneration. | Pass |
| Artifact publication | A verified ELF and report are published only as new files. Publication cannot overwrite a destination created after preflight; report encoding/publication failure removes the ELF. | `internal/artifactio` unit tests; `cmd/ts2bin` injected encode/publication failure tests. | Pass |
| Registry evolution | Primitive source lowerers, MIR function-set verifiers, and LLVM emitters use explicit registries. Ambiguous lowerer matches are rejected; backend admission does not maintain a duplicate function-name whitelist. | `primitive_lowerers_test.go`, `first_slice_mir_verifiers_test.go`, static-core and WSL LLVM tests. | Pass |
| Decoder hardening | FrontendSnapshot, ProgramSnapshot, Phase 2 HIR, and structural MIR reject malformed input and every accepted input canonical-round-trips. | fixed HIR decoder rejection tests plus four seeded fuzz targets. | Pass |
| Determinism | Runtime rebuild and same-path application rebuild preserve archive/object/manifest, ELF, and report SHA-256 values. | two WSL runtime rebuilds; two WSL application builds and ELF execution. | Pass |

## Reproducible Evidence

The following commands were run against the current worktree:

```powershell
go test -p 1 ./internal/artifactio ./internal/bingo ./internal/ast2bingo ./internal/frontendwire ./internal/applicationbuild ./internal/firstslicelink ./internal/firstslicerunner ./internal/bingomir ./internal/irartifact ./internal/llvmbackend ./internal/targetcontext ./cmd/ts2bin ./cmd/ts2bin-replay -count=1
go vet ./internal/artifactio ./internal/bingo ./internal/ast2bingo ./internal/frontendwire ./internal/applicationbuild ./internal/firstslicelink ./internal/firstslicerunner ./internal/bingomir ./internal/irartifact ./internal/llvmbackend ./internal/targetcontext ./cmd/ts2bin ./cmd/ts2bin-replay
go test -race ./internal/artifactio ./internal/bingo ./internal/ast2bingo ./internal/frontendwire ./internal/firstslicelink ./cmd/ts2bin -count=1
go test ./internal/frontendwire -run=^$ -fuzz=FuzzDecodeFrontendSnapshot -fuzztime=2s
go test ./internal/frontendwire -run=^$ -fuzz=FuzzDecodeProgramSnapshot -fuzztime=2s
go test ./internal/bingo -run=^$ -fuzz=FuzzDecodePhase2HIR -fuzztime=2s
go test ./internal/bingo -run=^$ -fuzz=FuzzDecodeStructuralFirstSliceMIR -fuzztime=2s
.\scripts\smoke-wsl.ps1
```

The project-owned Linux build-tag packages were also run in WSL with `LD_PRELOAD` cleared and login profiles disabled:

```bash
CGO_ENABLED=1 go test -tags=llvm20 ./internal/llvmbackend ./internal/bingomir ./internal/firstslicelink ./internal/firstslicerunner ./cmd/ts2bin -count=1
```

In WSL, `runtime/bingo-rt/scripts/build-first-slice.sh` was run twice with SHA-256 comparisons of the archive, startup objects, harnesses, and runtime manifest. A Linux `-tags=llvm20` `ts2bin` binary built with the lock-injected compiler identity built `testdata/ts2bin/application` twice to the same output path. Both builds produced:

```text
ELF:    2720cdba49f21cc2b57384601e55e8dddd84b9633c1dab383ae3327236e45076
report: 1ca5f20a49b4b3e839c4c3b95791fd54ac6d335bb9e1f91806787f0142a2e7b8
exit:   0
```

## Independent A3 Handoff

The independent reviewer must inspect the accepted contract in [phase2b-application-build-design.md](phase2b-application-build-design.md), this evidence, the linked runtime/LLVM changes, and the exact final commits. The reviewer must record a design conclusion and an implementation conclusion separately. This record does not supply a reviewer identity or replace that step.

Known non-code status:

- Automatic CI trigger restoration is intentionally deferred by the project owner.
- The current local worktree is uncommitted, so `ts2bin doctor` correctly reports a dirty fork worktree. A clean committed delivery must rerun doctor before it can claim `Integrated`.
