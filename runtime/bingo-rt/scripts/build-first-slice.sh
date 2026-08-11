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
APPLICATION_STARTUP="$TARGET/bingo_application_startup.o"
HARNESS="$TARGET/bingo_add_harness.o"
COMPUTE_HARNESS="$TARGET/bingo_compute_harness.o"
CHOOSE_HARNESS="$TARGET/bingo_choose_harness.o"
CLASSIFY_HARNESS="$TARGET/bingo_classify_harness.o"
COALESCE_HARNESS="$TARGET/bingo_coalesce_harness.o"
COALESCE_ASSIGN_HARNESS="$TARGET/bingo_coalesce_assign_harness.o"
STRING_LENGTH_HARNESS="$TARGET/bingo_string_length_harness.o"
MANIFEST="$TARGET/runtime-manifest.json"
SMOKE="$TARGET/runtime-link-smoke"

"$CLANG" -target "$TRIPLE" -I"$ROOT/include" -c "$ROOT/startup/empty.c" -o "$STARTUP"
"$CLANG" -target "$TRIPLE" -I"$ROOT/include" -c "$ROOT/startup/application.c" -o "$APPLICATION_STARTUP"
"$CLANG" -target "$TRIPLE" -I"$ROOT/include" -c "$ROOT/harness/add_bits.c" -o "$HARNESS"
"$CLANG" -target "$TRIPLE" -I"$ROOT/include" -c "$ROOT/harness/compute_bits.c" -o "$COMPUTE_HARNESS"
"$CLANG" -target "$TRIPLE" -I"$ROOT/include" -c "$ROOT/harness/choose_bits.c" -o "$CHOOSE_HARNESS"
"$CLANG" -target "$TRIPLE" -I"$ROOT/include" -c "$ROOT/harness/classify_bits.c" -o "$CLASSIFY_HARNESS"
"$CLANG" -target "$TRIPLE" -I"$ROOT/include" -c "$ROOT/harness/coalesce_bits.c" -o "$COALESCE_HARNESS"
"$CLANG" -target "$TRIPLE" -I"$ROOT/include" -DBINGO_COALESCE_ENTRYPOINT=coalesceAssign -c "$ROOT/harness/coalesce_bits.c" -o "$COALESCE_ASSIGN_HARNESS"
"$CLANG" -target "$TRIPLE" -I"$ROOT/include" -c "$ROOT/harness/string_length_bits.c" -o "$STRING_LENGTH_HARNESS"
python3 "$ROOT/tools/write_runtime_manifest.py" --archive "$ARCHIVE" --startup "$STARTUP" --application-startup "$APPLICATION_STARTUP" --harness "$HARNESS" --compute-harness "$COMPUTE_HARNESS" --choose-harness "$CHOOSE_HARNESS" --classify-harness "$CLASSIFY_HARNESS" --coalesce-harness "$COALESCE_HARNESS" --coalesce-assign-harness "$COALESCE_ASSIGN_HARNESS" --string-length-harness "$STRING_LENGTH_HARNESS" --output "$MANIFEST"
"$CLANG" -target "$TRIPLE" -I"$ROOT/include" "$ROOT/tests/link_smoke.c" "$STARTUP" "$ARCHIVE" -ldl -lpthread -lm -o "$SMOKE"
"$SMOKE"

printf 'umbrella=%s\nstartup=%s\napplication_startup=%s\nharness=%s\ncompute_harness=%s\nchoose_harness=%s\nclassify_harness=%s\ncoalesce_harness=%s\ncoalesce_assign_harness=%s\nstring_length_harness=%s\nmanifest=%s\nsmoke=%s\n' "$ARCHIVE" "$STARTUP" "$APPLICATION_STARTUP" "$HARNESS" "$COMPUTE_HARNESS" "$CHOOSE_HARNESS" "$CLASSIFY_HARNESS" "$COALESCE_HARNESS" "$COALESCE_ASSIGN_HARNESS" "$STRING_LENGTH_HARNESS" "$MANIFEST" "$SMOKE"
