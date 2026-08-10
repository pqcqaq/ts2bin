#!/usr/bin/env python3
import argparse
import hashlib
import json
from pathlib import Path
import subprocess


ROOT = Path(__file__).resolve().parents[1]


def sha256_file(path):
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        while chunk := stream.read(65536):
            digest.update(chunk)
    return digest.hexdigest()


def source_hash():
    digest = hashlib.sha256()
    roots = [ROOT / "Cargo.toml", ROOT / "Cargo.lock", ROOT / "rust-toolchain.toml"]
    roots.extend(
        path
        for directory in ("crates", "schema", "startup", "include", "tools", "tests", "manifests")
        for path in (ROOT / directory).rglob("*")
        if path.is_file() and "__pycache__" not in path.parts and path.suffix not in {".pyc", ".pyo"}
    )
    for path in sorted(set(roots), key=lambda item: item.relative_to(ROOT).as_posix()):
        relative = path.relative_to(ROOT).as_posix().encode("utf-8")
        digest.update(relative)
        digest.update(b"\0")
        digest.update(path.read_bytes())
        digest.update(b"\0")
    return digest.hexdigest()


def tool_version(*command):
    return subprocess.check_output(command, text=True).splitlines()[0].strip()


def canonical_hash(value):
    encoded = json.dumps(value, sort_keys=True, separators=(",", ":")).encode("utf-8")
    return hashlib.sha256(encoded).hexdigest()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--archive", type=Path, required=True)
    parser.add_argument("--startup", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    arguments = parser.parse_args()
    target_manifest_path = ROOT / "manifests" / "first-slice-target.json"
    abi_schema_path = ROOT / "schema" / "abi-v1.json"
    with target_manifest_path.open(encoding="utf-8") as stream:
        manifest = json.load(stream)
    expected_archive = manifest.pop("umbrellaArchive")
    expected_startup = manifest.pop("startupObject")
    if arguments.archive.name != expected_archive or arguments.startup.name != expected_startup:
        raise SystemExit(
            f"artifact names do not match target manifest: archive={arguments.archive.name}, startup={arguments.startup.name}"
        )
    archive_hash = sha256_file(arguments.archive)
    startup_hash = sha256_file(arguments.startup)
    for capability in manifest["capabilities"]:
        capability["signatureHash"] = canonical_hash(capability["signature"])
        capability["implementationHash"] = archive_hash
    manifest["artifacts"] = {
        "umbrellaArchive": {"file": arguments.archive.name, "sha256": archive_hash, "bytes": arguments.archive.stat().st_size},
        "startupObject": {"file": arguments.startup.name, "sha256": startup_hash, "bytes": arguments.startup.stat().st_size},
    }
    manifest["abiSchemaHash"] = sha256_file(abi_schema_path)
    manifest["targetManifestHash"] = sha256_file(target_manifest_path)
    manifest["sourceHash"] = source_hash()
    manifest["toolchain"] = {
        "rustc": tool_version("rustc", "--version"),
        "cargo": tool_version("cargo", "--version"),
        "clang": tool_version("clang-20", "--version"),
    }
    manifest["contentHash"] = canonical_hash(manifest)
    arguments.output.parent.mkdir(parents=True, exist_ok=True)
    arguments.output.write_text(json.dumps(manifest, sort_keys=True, separators=(",", ":")) + "\n", encoding="utf-8", newline="\n")


if __name__ == "__main__":
    main()
