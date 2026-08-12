# Phase 3 Linux Development Handoff

Status: `ReadyForLinuxContinuation`.

This is the authoritative handoff from the Windows implementation session to
native Linux x86-64 development. Automatic CI remains owner-deferred. Linux
local evidence may reach `LocalVerified` or `SelfAudited`, but not `Integrated`.

## Pinned baseline

- Parent repository: `d7229db`.
- Runtime implementation: `c0364eb`.
- `typescript-go`: `2ef21cd2fbd14752a91025b2aa606d7efdfeb4ea`.
- Target: `x86_64-unknown-linux-gnu`.
- LLVM/Clang/LLD: major 20, currently locked to `20.1.8`.
- Go `1.26.0`, Rust `1.97.1`, Node `v22.22.0`.

Clone/fetch the committed baseline and initialize the submodule. Do not migrate
an uncommitted Windows worktree.

## Bootstrap and baseline gates

Install the native Linux toolchain, LLVM/Clang/LLD 20 development packages,
Go, Rust, Python 3, Node, CMake/Ninja, and pthread/dl/m development headers.

```bash
git status --short
git submodule update --init --recursive
git -C typescript-go rev-parse HEAD
go version
rustc --version
node --version
clang-20 --version
llvm-config-20 --version
ld.lld-20 --version

cd typescript-go
go test ./...
go vet ./...
CGO_ENABLED=1 go test -tags=llvm20 ./internal/llvmbackend ./internal/bingomir ./internal/firstslicerunner ./cmd/ts2bin
cd ../runtime/bingo-rt
cargo fmt --all -- --check
cargo test --workspace
cargo clippy --workspace --all-targets -- -D warnings
python3 tools/generate_abi.py --check
python3 -m unittest tools/test_write_runtime_manifest.py
cd ../..
git diff --check
git -C typescript-go diff --check
```

The submodule HEAD must match the pinned commit before any mutation.

## First Linux mutation: authoritative runtime rebuild

```bash
cd runtime/bingo-rt
bash scripts/build-first-slice.sh
```

The producer must build the release archive, execute the C ABI smokes, and
generate static and interop manifests from real artifacts. Never manually edit
manifest digests, archive/source/target hashes, capability signature hashes, or
runtime hashes in `ts2bin.lock.json`.

Inspect generated diffs, then update consumer locked identities and the lockfile
only from canonical producer output. Re-run every Go/Rust/Python/C/LLVM/ELF/
native/Node gate before committing.

## Immediate closure order

1. `OBJ-003b`: execute the checked-in private/protected O0/O2, ELF, harness,
   runner, CLI, and native/Node tests against the authoritative static runtime.
   Do not expand scope to `#private`, static members, casts, or adapters.
2. `OBJ-005`: execute ObjectView data/accessor tests, explicit layout-copy
   rooted allocation/new-identity tests, and FunctionThunk FuncRef identity
   tests. Publish the authoritative interop identity and close positive checked
   cast binding/native evidence. Do not invent TypeScript cast syntax.
3. `OBJ-006`: use the generated interop manifest to prove positive
   `rt.dynamic.property_load` binding through TargetContext, bound MIR, backend,
   LLVM O0/O2, ELF/link, authenticated host records, and Node differential.
   Static profile capability closure must remain unchanged.

Keep all three `Implementing` until their actual Linux evidence is recorded.
CI being disabled still prevents `Integrated`.

## Remaining Phase 3 sequence

After the three closure items:

1. `RT-003a`: owned UTF-16 string, array/tuple, readonly views. Preserve the
   Phase 2 borrowed `BingoUtf16String` ABI as a separate boundary; owned storage
   must use the real tracing heap and cannot be a leaked test allocation.
2. `MOD-001`: export slots, two-phase initialization, execute-once and cycles.
3. `MOD-002`: representation-grouped generic monomorphization and budgets.
4. `MOD-003`: type-only erasure and explicit ambient/FFI binding.
5. `RT-003b`, `RT-004a`, `RT-005a`: Map/Set, synchronous iteration/close, and
   non-throwing cleanup.
6. `EH-001 -> ADV-001 + BE-003c -> RT-004b/005b`: exception carrier ownership,
   invoke/unwind, throwing IteratorClose and cleanup.
7. Continue full GC, self-hosted stdlib, async/Promise/generator, and advanced
   runtime work only after their documented prerequisites.

Every slice still requires accepted design, canonical artifacts, checker-free
replay, strict negative matrix, bounded fuzz, TargetContext/runtime binding,
real LLVM/ELF execution, independent oracle, deterministic publication, and
evidence updates.

## Commit and evidence discipline

- Start clean and commit reviewable batches.
- For cross-repository slices prefer: compiler/submodule commit, runtime commit,
  then parent docs/lock/gitlink commit.
- Do not push, enable CI, rewrite history, or change release status without the
  owner's explicit instruction.
- Append exact Linux commands, tool versions, generated hashes, test counts and
  native results to `progress.md`; update backlog, task plan and the relevant
  design together.
- Clearly distinguish tests checked in from tests actually executed on Linux.
