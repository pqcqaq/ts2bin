#!/usr/bin/env bash
set -Eeuo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  exec sudo -- "$0" "$@"
fi

LLVM_MAJOR="${LLVM_MAJOR:-20}"
GO_VERSION="${GO_VERSION:-1.26.0}"
NODE_VERSION="${NODE_VERSION:-22.22.0}"
NPM_VERSION="${NPM_VERSION:-11.17.0}"
RUST_VERSION="${RUST_VERSION:-1.97.1}"
LLVM_APT_BASE="${LLVM_APT_BASE:-https://apt.llvm.org}"
ARCH="$(dpkg --print-architecture)"
case "$ARCH" in
  amd64) GO_ARCH=amd64; NODE_ARCH=x64; RUST_HOST=x86_64-unknown-linux-gnu ;;
  arm64) GO_ARCH=arm64; NODE_ARCH=arm64; RUST_HOST=aarch64-unknown-linux-gnu ;;
  *) echo "unsupported Debian architecture: $ARCH" >&2; exit 2 ;;
esac

export DEBIAN_FRONTEND=noninteractive
if [[ -n "${TS2BIN_PROXY:-}" ]]; then
  export http_proxy="$TS2BIN_PROXY" https_proxy="$TS2BIN_PROXY"
  export HTTP_PROXY="$TS2BIN_PROXY" HTTPS_PROXY="$TS2BIN_PROXY"
fi
CURL=(curl -fL --retry 5 --retry-all-errors --retry-delay 2 --connect-timeout 20)
SOURCES="$(mktemp)"
trap 'rm -f "$SOURCES"' EXIT
# Keep unrelated distro repositories out of the bootstrap transaction. They remain
# untouched on disk and can be used normally after this script finishes.
awk '/^[[:space:]]*deb([[:space:]]|$)/ { print }' /etc/apt/sources.list > "$SOURCES"
APT_OPTS=(-o "Dir::Etc::sourcelist=$SOURCES" -o Dir::Etc::sourceparts=- -o APT::Get::List-Cleanup=0)
apt-get "${APT_OPTS[@]}" update
apt-get "${APT_OPTS[@]}" install -y --no-install-recommends ca-certificates curl gnupg build-essential pkg-config cmake ninja-build git python3 xz-utils

KEYRING=/usr/share/keyrings/llvm-signed.gpg
"${CURL[@]}" -sS https://apt.llvm.org/llvm-snapshot.gpg.key | gpg --dearmor --yes --output "$KEYRING"
CODENAME="$(. /etc/os-release && printf '%s' "$VERSION_CODENAME")"
printf 'deb [signed-by=%s] %s/%s/ llvm-toolchain-%s-%s main\n' "$KEYRING" "$LLVM_APT_BASE" "$CODENAME" "$CODENAME" "$LLVM_MAJOR" > /etc/apt/sources.list.d/ts2bin-llvm.list
cat /etc/apt/sources.list.d/ts2bin-llvm.list >> "$SOURCES"
apt-get "${APT_OPTS[@]}" update
apt-get "${APT_OPTS[@]}" install -y --no-install-recommends "llvm-${LLVM_MAJOR}" "llvm-${LLVM_MAJOR}-dev" "clang-${LLVM_MAJOR}" "lld-${LLVM_MAJOR}" "libclang-${LLVM_MAJOR}-dev" zlib1g-dev libzstd-dev

install -d /opt/ts2bin
install_go() {
  local archive="go${GO_VERSION}.linux-${GO_ARCH}.tar.gz"
  local url="https://go.dev/dl/${archive}"
  local tmp
  [[ -x "/opt/ts2bin/go-${GO_VERSION}/bin/go" ]] && return 0
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' RETURN
  "${CURL[@]}" -sS 'https://go.dev/dl/?mode=json&include=all' -o "$tmp/releases.json"
  "${CURL[@]}" -sS "$url" -o "$tmp/$archive"
  local expected actual
  expected="$(python3 - "$GO_VERSION" "$archive" "$tmp/releases.json" <<'PY'
import json
import sys

version, filename, metadata = sys.argv[1:]
with open(metadata, encoding="utf-8") as stream:
    releases = json.load(stream)
for release in releases:
    if release["version"] == "go" + version:
        for artifact in release["files"]:
            if artifact["filename"] == filename:
                print(artifact["sha256"])
                raise SystemExit(0)
raise SystemExit(f"Go release metadata has no {filename}")
PY
)"
  actual="$(sha256sum "$tmp/$archive" | awk '{print $1}')"
  [[ "$actual" == "$expected" ]] || { echo "Go archive checksum mismatch" >&2; return 1; }
  if [[ ! -x "/opt/ts2bin/go-${GO_VERSION}/bin/go" ]]; then
    tar -xzf "$tmp/$archive" -C "$tmp"
    mv "$tmp/go" "/opt/ts2bin/go-${GO_VERSION}"
  fi
}
install_go

install_node() {
  local archive="node-v${NODE_VERSION}-linux-${NODE_ARCH}.tar.xz"
  local tmp
  [[ -x "/opt/ts2bin/node-${NODE_VERSION}/bin/node" ]] && return 0
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' RETURN
  "${CURL[@]}" -sS "https://nodejs.org/dist/v${NODE_VERSION}/SHASUMS256.txt" -o "$tmp/SHA256SUMS"
  "${CURL[@]}" -sS "https://nodejs.org/dist/v${NODE_VERSION}/${archive}" -o "$tmp/$archive"
  (cd "$tmp" && grep "  ${archive}$" SHA256SUMS | sha256sum -c -)
  if [[ ! -x "/opt/ts2bin/node-${NODE_VERSION}/bin/node" ]]; then
    tar -xJf "$tmp/$archive" -C "$tmp"
    mv "$tmp/node-v${NODE_VERSION}-linux-${NODE_ARCH}" "/opt/ts2bin/node-${NODE_VERSION}"
  fi
}
install_node
if [[ "$(PATH="/opt/ts2bin/node-${NODE_VERSION}/bin:$PATH" npm --version)" != "$NPM_VERSION" ]]; then
  PATH="/opt/ts2bin/node-${NODE_VERSION}/bin:$PATH" npm install --global "npm@${NPM_VERSION}"
fi

if [[ ! -x "/opt/ts2bin/rust-${RUST_VERSION}/bin/rustc" ]]; then
  tmp="$(mktemp -d)"
  "${CURL[@]}" --proto '=https' --tlsv1.2 -sS https://sh.rustup.rs -o "$tmp/rustup-init.sh"
  chmod 755 "$tmp/rustup-init.sh"
  CARGO_HOME="/opt/ts2bin/cargo" RUSTUP_HOME="/opt/ts2bin/rustup" \
    "$tmp/rustup-init.sh" -y --no-modify-path --profile minimal --default-toolchain "$RUST_VERSION"
  mv /opt/ts2bin/cargo "/opt/ts2bin/rust-${RUST_VERSION}"
  rm -rf "$tmp"
fi
CARGO_HOME="/opt/ts2bin/rust-${RUST_VERSION}" RUSTUP_HOME=/opt/ts2bin/rustup \
  "/opt/ts2bin/rust-${RUST_VERSION}/bin/rustup" component add --toolchain "$RUST_VERSION" rustfmt clippy

for tool in go gofmt; do
  ln -sfn "/opt/ts2bin/go-${GO_VERSION}/bin/${tool}" "/usr/local/bin/${tool}"
done
for tool in node npm npx corepack; do
  ln -sfn "/opt/ts2bin/node-${NODE_VERSION}/bin/${tool}" "/usr/local/bin/${tool}"
done
for tool in cargo rustc rustfmt cargo-clippy clippy-driver rustup; do
  dest="/usr/local/bin/${tool}"
  if [[ -L "$dest" ]]; then
    [[ "$(readlink "$dest")" == /opt/ts2bin/* ]] || { echo "refusing to replace $dest" >&2; exit 3; }
    rm -f "$dest"
  elif [[ -e "$dest" ]] && ! grep -q '^# ts2bin rustup wrapper$' "$dest"; then
    echo "refusing to replace non-ts2bin file: $dest" >&2
    exit 3
  fi
  cat > "$dest" <<EOF
#!/bin/sh
# ts2bin rustup wrapper
export CARGO_HOME="\${CARGO_HOME:-\${XDG_CACHE_HOME:-\$HOME/.cache}/ts2bin/cargo}"
export RUSTUP_HOME=/opt/ts2bin/rustup
exec /opt/ts2bin/rustup/toolchains/${RUST_VERSION}-${RUST_HOST}/bin/${tool} "\$@"
EOF
  chmod 755 "$dest"
done
cat > /usr/local/bin/rustup <<EOF
#!/bin/sh
# ts2bin rustup wrapper
export CARGO_HOME=/opt/ts2bin/rust-${RUST_VERSION}
export RUSTUP_HOME=/opt/ts2bin/rustup
exec /opt/ts2bin/rust-${RUST_VERSION}/bin/rustup "\$@"
EOF
chmod 755 /usr/local/bin/rustup
cat > /etc/profile.d/ts2bin-toolchain.sh <<EOF
export PATH=/usr/lib/llvm-${LLVM_MAJOR}/bin:/opt/ts2bin/go-${GO_VERSION}/bin:/opt/ts2bin/node-${NODE_VERSION}/bin:\$PATH
export LLVM_CONFIG=llvm-config-${LLVM_MAJOR}
export CARGO_HOME="\${CARGO_HOME:-\${XDG_CACHE_HOME:-\$HOME/.cache}/ts2bin/cargo}"
export RUSTUP_HOME=/opt/ts2bin/rustup
EOF

export CARGO_HOME="/opt/ts2bin/rust-${RUST_VERSION}"
export RUSTUP_HOME=/opt/ts2bin/rustup

llvm-config-${LLVM_MAJOR} --version
go version
node --version
npm --version
/usr/local/bin/rustc --version
echo "ts2bin WSL toolchain installed"
