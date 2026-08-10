#!/usr/bin/env bash
set -Eeuo pipefail

QUIET=0
if [[ $# -gt 0 && "$1" == "--quiet" ]]; then
  QUIET=1
  shift
fi
if [[ $# -ne 0 ]]; then
  echo "usage: doctor.sh [--quiet]" >&2
  exit 2
fi

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
LOCK="$ROOT/ts2bin.lock.json"
FAILURES=()

report() {
  local name="$1" ok="$2" detail="$3"
  if [[ "$ok" == 1 ]]; then
    [[ "$QUIET" == 1 ]] || printf '[ok]   %s: %s\n' "$name" "$detail"
  else
    FAILURES+=("$name")
    printf '[FAIL] %s: %s\n' "$name" "$detail"
  fi
}

command_path() {
  command -v "$1" 2>/dev/null || true
}

root_git() {
  git -c "safe.directory=$ROOT" -C "$ROOT" "$@"
}

submodule_git() {
  git -c "safe.directory=$ROOT/typescript-go" -C "$ROOT/typescript-go" "$@"
}

check_version() {
  local name="$1" expected="$2" command_name="$3"
  shift 3
  local path value
  path="$(command_path "$command_name")"
  if [[ -z "$path" ]]; then
    report "$name" 0 "command not found; expected $expected"
    return
  fi
  value="$("$path" "$@" 2>/dev/null | head -n 1 || true)"
  if [[ -n "$value" && "$value" == *"$expected"* ]]; then
    report "$name" 1 "$value"
  else
    report "$name" 0 "${value:-command failed}; expected $expected"
  fi
}

LOCK_ASSIGNMENTS=""
if [[ -f "$LOCK" ]] && LOCK_ASSIGNMENTS="$(python3 - "$LOCK" <<'PY'
import json
import shlex
import sys

with open(sys.argv[1], encoding="utf-8") as stream:
    lock = json.load(stream)
tsgo = lock["typescriptGo"]
tools = lock["toolchains"]
stdlib = tsgo["stdlib"]
replay = tools["replayBuild"]
values = {
    "LOCK_SCHEMA": lock.get("schemaVersion"),
    "LOCK_FORMAT": lock.get("lockFormat"),
    "LOCKED_COMMIT": tsgo.get("commit"),
    "FORK_COMMIT": tsgo.get("forkCommit"),
    "UPSTREAM_COMMIT": tsgo.get("upstreamCommit"),
    "FORK_REMOTE": tsgo.get("forkRemote"),
    "UPSTREAM_REMOTE": tsgo.get("remote"),
    "TS_VERSION": tsgo.get("version"),
    "REPRO_STATUS": tsgo.get("reproducibilityStatus"),
    "LEGACY_PATCH_ABSENT": str(tsgo.get("patch") is None).lower(),
    "GO_VERSION": tools.get("go"),
    "NODE_VERSION": tools.get("node"),
    "NPM_VERSION": tools.get("npm"),
    "RUST_VERSION": tools.get("rust"),
    "LLVM_MAJOR": tools.get("llvmMajor"),
    "LLD_MAJOR": tools.get("lldMajor"),
    "STDLIB_HASH": stdlib.get("sha256"),
    "STDLIB_COUNT": stdlib.get("fileCount"),
    "STDLIB_BYTES": stdlib.get("totalBytes"),
    "REPLAY_GOOS": replay.get("goos"),
    "REPLAY_GOARCH": replay.get("goarch"),
    "REPLAY_GOAMD64": replay.get("goamd64"),
    "REPLAY_CGO": replay.get("cgoEnabled"),
    "REPLAY_GOENV": replay.get("goenv"),
    "REPLAY_GOFLAGS": replay.get("goflags"),
    "REPLAY_GOWORK": replay.get("gowork"),
    "REPLAY_TOOLCHAIN": replay.get("gotoolchain"),
    "REPLAY_EXPERIMENT": replay.get("goexperiment"),
    "REPLAY_FIPS": replay.get("gofips140"),
    "REPLAY_DEBUG": replay.get("godebug"),
}
for name, value in values.items():
    print(f"{name}={shlex.quote('' if value is None else str(value))}")
PY
)"; then
  eval "$LOCK_ASSIGNMENTS"
  schema_ok=0
  [[ "$LOCK_SCHEMA" == 2 && "$LOCK_FORMAT" == ts2bin.lock.v2 ]] && schema_ok=1
  report "lock schema" "$schema_ok" "schema=$LOCK_SCHEMA; format=$LOCK_FORMAT"

  identity_ok=0
  [[ "$LOCKED_COMMIT" =~ ^[0-9a-f]{40}$ &&
     "$LOCKED_COMMIT" == "$FORK_COMMIT" &&
     "$UPSTREAM_COMMIT" =~ ^[0-9a-f]{40}$ &&
     "$REPRO_STATUS" == pinned-fork-commit &&
     "$LEGACY_PATCH_ABSENT" == true ]] && identity_ok=1
  report "typescript-go fork metadata" "$identity_ok" "commit=$LOCKED_COMMIT; fork=$FORK_COMMIT; upstream=$UPSTREAM_COMMIT; status=$REPRO_STATUS"

  replay_ok=0
  [[ "$REPLAY_GOOS" == windows && "$REPLAY_GOARCH" == amd64 &&
     "$REPLAY_GOAMD64" == v1 && "$REPLAY_CGO" == 0 &&
     "$REPLAY_GOENV" == off && -z "$REPLAY_GOFLAGS" &&
     "$REPLAY_GOWORK" == off && "$REPLAY_TOOLCHAIN" == "go$GO_VERSION" &&
     -z "$REPLAY_EXPERIMENT" && "$REPLAY_FIPS" == off &&
     -z "$REPLAY_DEBUG" ]] && replay_ok=1
  report "replay build target" "$replay_ok" "goos=$REPLAY_GOOS; goarch=$REPLAY_GOARCH; goamd64=$REPLAY_GOAMD64; cgo=$REPLAY_CGO"

  check_version "Go" "go$GO_VERSION" go version
  check_version "Node" "v$NODE_VERSION" node --version
  check_version "npm" "$NPM_VERSION" npm --version
  check_version "Rust" "rustc $RUST_VERSION" rustc --version
  check_version "Cargo" "cargo $RUST_VERSION" cargo --version

  LLVM_CONFIG="$(command_path "llvm-config-$LLVM_MAJOR")"
  [[ -n "$LLVM_CONFIG" ]] || LLVM_CONFIG="$(command_path llvm-config)"
  CLANG="$(command_path "clang-$LLVM_MAJOR")"
  [[ -n "$CLANG" ]] || CLANG="$(command_path clang)"
  LLD="$(command_path "ld.lld-$LLD_MAJOR")"
  [[ -n "$LLD" ]] || LLD="$(command_path ld.lld)"
  [[ -n "$LLVM_CONFIG" ]] && check_version "LLVM" "$LLVM_MAJOR." "$LLVM_CONFIG" --version || report "LLVM" 0 "llvm-config not found"
  [[ -n "$CLANG" ]] && check_version "Clang" "$LLVM_MAJOR." "$CLANG" --version || report "Clang" 0 "clang not found"
  [[ -n "$LLD" ]] && check_version "LLD" "LLD $LLD_MAJOR" "$LLD" --version || report "LLD" 0 "ld.lld not found"
  check_version "CMake" "cmake version " cmake --version
  check_version "Ninja" "" ninja --version
else
  report "lock schema" 0 "unable to read $LOCK with python3"
fi

if [[ -n "$(command_path git)" && -n "${LOCKED_COMMIT:-}" ]]; then
  gitlink="$(root_git ls-files --stage -- typescript-go 2>/dev/null | awk 'NR==1 {print $2}' || true)"
  checkout="$(submodule_git rev-parse HEAD 2>/dev/null || true)"
  closure_ok=0
  [[ "$gitlink" == "$LOCKED_COMMIT" && "$checkout" == "$LOCKED_COMMIT" ]] && closure_ok=1
  report "typescript-go revision closure" "$closure_ok" "gitlink=${gitlink:-missing}; checkout=${checkout:-missing}; lock=$LOCKED_COMMIT"

  dirty_output=""
  if dirty_output="$(submodule_git status --porcelain --untracked-files=all 2>/dev/null)"; then
    dirty="$(printf '%s' "$dirty_output" | awk 'NF {count++} END {print count+0}')"
    report "typescript-go fork worktree" "$([[ "$dirty" == 0 ]] && echo 1 || echo 0)" "changes=$dirty"
  else
    report "typescript-go fork worktree" 0 "unable to inspect checkout"
  fi

  configured="$(root_git config -f .gitmodules --get submodule.typescript-go.url 2>/dev/null || true)"
  origin="$(submodule_git remote get-url origin 2>/dev/null || true)"
  remote_ok=0
  [[ "$configured" == "$FORK_REMOTE" && "$origin" == "$FORK_REMOTE" ]] && remote_ok=1
  report "typescript-go fork remote" "$remote_ok" "configured=${configured:-missing}; origin=${origin:-missing}; lock=$FORK_REMOTE"

  if submodule_git merge-base --is-ancestor "$UPSTREAM_COMMIT" "$FORK_COMMIT" 2>/dev/null; then
    report "typescript-go upstream ancestry" 1 "upstream=$UPSTREAM_COMMIT; fork=$FORK_COMMIT"
  else
    report "typescript-go upstream ancestry" 0 "upstream=$UPSTREAM_COMMIT; fork=$FORK_COMMIT"
  fi
else
  report "git" 0 "git unavailable or lock metadata missing"
fi

legacy_present=0
for legacy in \
  patches/typescript-go/ts2bin.patch \
  patches/typescript-go/README.md \
  scripts/materialize-typescript-go.ps1 \
  scripts/update-typescript-go-patch.ps1 \
  scripts/verify-typescript-go-patch.ps1; do
  [[ ! -e "$ROOT/$legacy" ]] || legacy_present=1
done
report "legacy typescript-go patch flow" "$([[ "$legacy_present" == 0 ]] && echo 1 || echo 0)" "legacy patch metadata and scripts must be absent"

DETAILS=""
if [[ -n "${TS_VERSION:-}" ]]; then
  DETAILS="$(python3 - "$ROOT" "$TS_VERSION" "$UPSTREAM_COMMIT" "$STDLIB_HASH" "$STDLIB_COUNT" "$STDLIB_BYTES" <<'PY'
import hashlib
import pathlib
import re
import sys

root, expected_version, expected_upstream, expected_hash, expected_count, expected_bytes = sys.argv[1:]
root = pathlib.Path(root)

source = root / "typescript-go/internal/core/version.go"
text = source.read_text(encoding="utf-8") if source.exists() else ""
match = re.search(r'var\s+version\s*=\s*"([^"]+)"', text)
observed = match.group(1) if match else "missing"
print(f"VERSION\t{int(observed == expected_version)}\tobserved={observed}; lock={expected_version}")

source = root / "typescript-go/internal/tsfrontend/baseline.go"
text = source.read_text(encoding="utf-8") if source.exists() else ""
match = re.search(r'TypeScriptGoUpstreamCommit\s*=\s*"([0-9a-f]{40})"', text)
observed = match.group(1) if match else "missing"
print(f"UPSTREAM\t{int(observed == expected_upstream)}\tsource={observed}; lock={expected_upstream}")

libs = root / "typescript-go/internal/bundled/libs"
digest = hashlib.sha256()
count = total = 0
if libs.is_dir():
    files = sorted((path for path in libs.rglob("*") if path.is_file()),
                   key=lambda path: path.relative_to(libs).as_posix())
    for path in files:
        digest.update(path.relative_to(libs).as_posix().encode("utf-8"))
        digest.update(b"\0")
        data = path.read_bytes()
        digest.update(data)
        digest.update(b"\0")
        count += 1
        total += len(data)
observed_hash = digest.hexdigest()
ok = observed_hash == expected_hash and str(count) == expected_count and str(total) == expected_bytes
print(f"STDLIB\t{int(ok)}\tfiles={count}; bytes={total}; sha256={observed_hash}")
PY
)"
fi

while IFS=$'\t' read -r kind ok detail; do
  case "$kind" in
    VERSION) report "TypeScript version" "$ok" "$detail" ;;
    UPSTREAM) report "TypeScript upstream provenance" "$ok" "$detail" ;;
    STDLIB) report "bundled stdlib" "$ok" "$detail" ;;
  esac
done <<<"$DETAILS"

if [[ "${#FAILURES[@]}" -eq 0 ]]; then
  [[ "$QUIET" == 1 ]] || echo "All required Linux toolchain checks passed."
  exit 0
fi
printf '%d check(s) failed.\n' "${#FAILURES[@]}" >&2
exit 1
