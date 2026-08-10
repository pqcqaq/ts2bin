#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
TARGET="${1:-$ROOT/target/first-slice}"
TRIPLE=x86_64-unknown-linux-gnu
CLANG="${CLANG:-clang-20}"

python3 "$ROOT/tools/generate_abi.py" --check
cargo build --manifest-path "$ROOT/Cargo.toml" --workspace --release --locked --target "$TRIPLE" --target-dir "$TARGET/cargo"

ARCHIVE="$TARGET/cargo/$TRIPLE/release/libbingo_runtime.a"
STARTUP="$TARGET/bingo_startup_empty.o"
MANIFEST="$TARGET/runtime-manifest.json"
SMOKE="$TARGET/runtime-link-smoke"

"$CLANG" -target "$TRIPLE" -I"$ROOT/include" -c "$ROOT/startup/empty.c" -o "$STARTUP"
python3 "$ROOT/tools/write_runtime_manifest.py" --archive "$ARCHIVE" --startup "$STARTUP" --output "$MANIFEST"
"$CLANG" -target "$TRIPLE" -I"$ROOT/include" "$ROOT/tests/link_smoke.c" "$STARTUP" "$ARCHIVE" -ldl -lpthread -lm -o "$SMOKE"
"$SMOKE"

printf 'umbrella=%s\nstartup=%s\nmanifest=%s\nsmoke=%s\n' "$ARCHIVE" "$STARTUP" "$MANIFEST" "$SMOKE"
