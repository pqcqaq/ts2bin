# ts2bin

`ts2bin` is a TypeScript-to-native compiler project built around `typescript-go`, a target-independent frontend wire snapshot, Bingo typed HIR, target-aware MIR, LLVM, and a Rust C ABI runtime. The executable boundary is `FrontendSnapshot -> typed HIR`; `BuildPlan + manifests -> ResolveTargetContext`; then `RepresentationPlan -> target-aware MIR -> LLVM/link`. The direction audit kept that architecture and added a Phase 1.5 lowering-contract gate. The Phase 1.5 implementation contracts and Phase 2A entry contracts (`FE-012a`, `IR-007a`, `IR-001a..003a`) are complete; delivery acceptance (`FND-004a`) is complete on the pinned fork and committed parent gitlink. P2A preparation now includes a non-bypassable frontend gate, cross-platform doctor, and parent-repository CI. The next work is the parallel LLVM TargetMachine/DataLayout and Rust runtime-manifest scaffolds. Broad syntax expansion stays blocked until the number-only real-LLVM slice passes. See [the audit](plans/development-audit-2026-08-05.md) and [implementation backlog](plans/implementation-backlog.md).

## Locked Toolchain

Exact versions and the pinned `typescript-go` fork identity live in [`ts2bin.lock.json`](ts2bin.lock.json). The submodule is configured to use `https://github.com/pqcqaq/typescript-go.git`; the currently pinned commit has passed clean remote fetch, full test, and vet verification. The lock fixes both the fork commit used for builds and its reviewed Microsoft upstream ancestor. The supported development setup is:

- Windows: Go, Node/npm, Rust, LLVM/LLD, CMake, Ninja, MSVC, and Windows SDK.
- WSL2 Ubuntu: the complete LLVM 20 development SDK plus matching Go, Node/npm, and Rust toolchains.
- Backend validation runs in WSL because the upstream Windows LLVM binary does not ship the full C/C++ headers required by `tinygo.org/x/go-llvm`.

Check the current machine from PowerShell:

```powershell
.\scripts\doctor.ps1
```

Check a Linux or WSL environment with the same lock, fork, provenance, and
stdlib closure rules:

```bash
./scripts/doctor.sh
```

Bootstrap or repair the WSL toolchain without a proxy:

```powershell
.\scripts\bootstrap-wsl.ps1
```

The wrapper can route WSL downloads through a proxy listening on a Windows port and can select an LLVM mirror:

```powershell
.\scripts\bootstrap-wsl.ps1 -ProxyPort 7890 `
  -LlvmMirror https://mirrors.tuna.tsinghua.edu.cn/llvm-apt
```

Run the real Go-LLVM verifier and Rust-staticlib/LLD link probes:

```powershell
.\scripts\smoke-wsl.ps1
```

Use the same Windows proxy port when external Go modules are not cached:

```powershell
.\scripts\smoke-wsl.ps1 -ProxyPort 7890
```

## Frontend Baseline

The pinned `typescript-go` checkout uses Go 1.26, Node 22.22, and npm 11.17. Its baseline verification is:

```powershell
Set-Location typescript-go
npm ci
npm run build
go test -p 1 ./... -count=1
```

The Phase 1 frontend exposes `version`, `check`, `snapshot`, `compatibility`, `doctor`, and staged `test` commands. Reproduce its focused checks from the `typescript-go` directory. Compatibility fixtures and semantic digests use schema v2; the intentional UTF-8 wire normalization changes were reviewed, regenerated, and locked by canonical round-trip tests. `BuildPlan` is a canonical unresolved backend request. Phase 2A resolves it once into an immutable `TargetContext`, LLVM-authoritative `DataLayout`, and `AvailableCapabilityCatalog` before representation planning or MIR; structural MIR binding then produces the exact `BoundCapabilityClosure` used by LLVM and link.

```powershell
go test ./internal/tsfrontend ./cmd/ts2bin
go run ./cmd/ts2bin version --json
go run ./cmd/ts2bin test --stage frontend --json
go run ./cmd/ts2bin compatibility --json
```

Build the checker-free replay command from the locked fork commit in an
isolated checkout. This verifies the locked Go version and target tuple,
isolates ambient Go workspace flags, and injects the upstream and fork commit
identity from `ts2bin.lock.json`; a direct unconfigured `go build`
intentionally fails closed when asked to mint HIR. The script prints the
resulting binary SHA-256 so repeated isolated builds can be compared directly.

```powershell
.\scripts\build-ts2bin-replay.ps1
```

Verify the pinned fork commit in an isolated checkout. Use the local source
before publishing the fork commit; omit `-UseLocalCheckout` after it is
available from the locked fork remote:

```powershell
.\scripts\verify-typescript-go-fork.ps1 -UseLocalCheckout
```

Upstream updates are explicit merges into the clean fork branch, followed by
lock/provenance updates and the full compatibility gates:

```powershell
.\scripts\merge-typescript-go-upstream.ps1
```

The full current gate is:

```powershell
.\scripts\test-frontend.ps1 -Stage all -RepeatCount 5
Set-Location typescript-go
go test -p 1 ./... -count=1
go vet -p 1 ./...
```

The language reference and examples are under [`handbook/`](handbook/README.md); compiler architecture, support boundaries, runtime ABI, implementation order, and release gates are under [`plans/`](plans/README.md).
