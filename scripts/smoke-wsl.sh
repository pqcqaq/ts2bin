#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -n "${TS2BIN_PROXY:-}" ]]; then
  export http_proxy="$TS2BIN_PROXY" https_proxy="$TS2BIN_PROXY"
  export HTTP_PROXY="$TS2BIN_PROXY" HTTPS_PROXY="$TS2BIN_PROXY"
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "[1/2] Go-LLVM verifier"
(cd "$ROOT/tooling/smoke/go-llvm" && CGO_ENABLED=1 go run .)

echo "[2/2] Rust staticlib + Clang/LLD"
cargo build --manifest-path "$ROOT/tooling/smoke/runtime-link/Cargo.toml" --release --target-dir "$TMP/cargo-target"
clang-20 -fuse-ld=lld "$ROOT/tooling/smoke/runtime-link/main.c" \
  "$TMP/cargo-target/release/libts2bin_smoke_runtime.a" \
  -ldl -lpthread -lm -o "$TMP/runtime-link-smoke"
"$TMP/runtime-link-smoke"

echo "All WSL smoke tests passed."
