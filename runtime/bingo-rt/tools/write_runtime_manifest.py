#!/usr/bin/env python3
import argparse
import hashlib
import json
from pathlib import Path
import subprocess


ROOT = Path(__file__).resolve().parents[1]
SUPPORTED_PROFILES = ("static", "interop")


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
        for directory in ("crates", "schema", "startup", "harness", "include", "tools", "tests", "manifests")
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


def load_profile_target_manifest(profile):
    if profile not in SUPPORTED_PROFILES:
        raise ValueError(f"unsupported runtime profile: {profile}")
    target_manifest_path = ROOT / "manifests" / "first-slice-target.json"
    with target_manifest_path.open(encoding="utf-8") as stream:
        manifest = json.load(stream)
    if manifest.get("profile") != "static":
        raise ValueError("first-slice target manifest must remain the static baseline")
    if profile == "interop":
        overlay_path = ROOT / "manifests" / "first-slice-interop-overlay.json"
        with overlay_path.open(encoding="utf-8") as stream:
            overlay = json.load(stream)
        if set(overlay) != {"profile", "capabilities"} or overlay["profile"] != profile:
            raise ValueError("invalid interop profile overlay")
        existing = {capability["logicalName"] for capability in manifest["capabilities"]}
        additions = overlay["capabilities"]
        names = [capability["logicalName"] for capability in additions]
        if len(names) != len(set(names)) or existing.intersection(names):
            raise ValueError("interop overlay capabilities must be unique additions")
        manifest["profile"] = profile
        manifest["capabilities"].extend(additions)
    manifest["capabilities"].sort(key=lambda capability: capability["logicalName"])
    names = [capability["logicalName"] for capability in manifest["capabilities"]]
    if len(names) != len(set(names)):
        raise ValueError("runtime capabilities are not unique")
    profile_target_hash = sha256_file(target_manifest_path) if profile == "static" else canonical_hash(manifest)
    return manifest, profile_target_hash


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--clang", required=True)
    parser.add_argument("--profile", choices=SUPPORTED_PROFILES, default="static")
    parser.add_argument("--archive", type=Path, required=True)
    parser.add_argument("--startup", type=Path, required=True)
    parser.add_argument("--application-startup", type=Path, required=True)
    parser.add_argument("--harness", type=Path, required=True)
    parser.add_argument("--compute-harness", type=Path, required=True)
    parser.add_argument("--choose-harness", type=Path, required=True)
    parser.add_argument("--classify-harness", type=Path, required=True)
    parser.add_argument("--coalesce-harness", type=Path, required=True)
    parser.add_argument("--coalesce-assign-harness", type=Path, required=True)
    parser.add_argument("--string-length-harness", type=Path, required=True)
    parser.add_argument("--object-alias-harness", type=Path, required=True)
    parser.add_argument("--property-nullish-assign-harness", type=Path, required=True)
    parser.add_argument("--closure-counter-harness", type=Path, required=True)
    parser.add_argument("--class-counter-harness", type=Path, required=True)
    parser.add_argument("--derived-counter-harness", type=Path, required=True)
    parser.add_argument("--class-access-harness", type=Path, required=True)
    parser.add_argument("--checked-object-cast-harness", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    arguments = parser.parse_args()
    abi_schema_path = ROOT / "schema" / "abi-v1.json"
    manifest, profile_target_hash = load_profile_target_manifest(arguments.profile)
    expected_archive = manifest.pop("umbrellaArchive")
    expected_startup = manifest.pop("startupObject")
    expected_application_startup = manifest.pop("applicationStartupObject")
    expected_harness = manifest.pop("harnessObject")
    expected_compute_harness = manifest.pop("computeHarnessObject")
    expected_choose_harness = manifest.pop("chooseHarnessObject")
    expected_classify_harness = manifest.pop("classifyHarnessObject")
    expected_coalesce_harness = manifest.pop("coalesceHarnessObject")
    expected_coalesce_assign_harness = manifest.pop("coalesceAssignHarnessObject")
    expected_string_length_harness = manifest.pop("stringLengthHarnessObject")
    expected_object_alias_harness = manifest.pop("objectAliasHarnessObject")
    expected_property_nullish_assign_harness = manifest.pop("propertyNullishAssignHarnessObject")
    expected_closure_counter_harness = manifest.pop("closureCounterHarnessObject")
    expected_class_counter_harness = manifest.pop("classCounterHarnessObject")
    expected_derived_counter_harness = manifest.pop("derivedCounterHarnessObject")
    expected_class_access_harness = manifest.pop("classAccessHarnessObject")
    expected_checked_object_cast_harness = manifest.pop("checkedObjectCastHarnessObject")
    if (
        arguments.archive.name != expected_archive
        or arguments.startup.name != expected_startup
        or arguments.application_startup.name != expected_application_startup
        or arguments.harness.name != expected_harness
        or arguments.compute_harness.name != expected_compute_harness
        or arguments.choose_harness.name != expected_choose_harness
        or arguments.classify_harness.name != expected_classify_harness
        or arguments.coalesce_harness.name != expected_coalesce_harness
        or arguments.coalesce_assign_harness.name != expected_coalesce_assign_harness
        or arguments.string_length_harness.name != expected_string_length_harness
        or arguments.object_alias_harness.name != expected_object_alias_harness
        or arguments.property_nullish_assign_harness.name != expected_property_nullish_assign_harness
        or arguments.closure_counter_harness.name != expected_closure_counter_harness
        or arguments.class_counter_harness.name != expected_class_counter_harness
        or arguments.derived_counter_harness.name != expected_derived_counter_harness
        or arguments.class_access_harness.name != expected_class_access_harness
        or arguments.checked_object_cast_harness.name != expected_checked_object_cast_harness
    ):
        raise SystemExit(
            "artifact names do not match target manifest: "
            f"archive={arguments.archive.name}, startup={arguments.startup.name}, applicationStartup={arguments.application_startup.name}, "
            f"harness={arguments.harness.name}, computeHarness={arguments.compute_harness.name}, chooseHarness={arguments.choose_harness.name}, classifyHarness={arguments.classify_harness.name}, coalesceHarness={arguments.coalesce_harness.name}, coalesceAssignHarness={arguments.coalesce_assign_harness.name}, stringLengthHarness={arguments.string_length_harness.name}, objectAliasHarness={arguments.object_alias_harness.name}, propertyNullishAssignHarness={arguments.property_nullish_assign_harness.name}, closureCounterHarness={arguments.closure_counter_harness.name}, classCounterHarness={arguments.class_counter_harness.name}, derivedCounterHarness={arguments.derived_counter_harness.name}, classAccessHarness={arguments.class_access_harness.name}, checkedObjectCastHarness={arguments.checked_object_cast_harness.name}"
        )
    archive_hash = sha256_file(arguments.archive)
    startup_hash = sha256_file(arguments.startup)
    application_startup_hash = sha256_file(arguments.application_startup)
    harness_hash = sha256_file(arguments.harness)
    compute_harness_hash = sha256_file(arguments.compute_harness)
    choose_harness_hash = sha256_file(arguments.choose_harness)
    classify_harness_hash = sha256_file(arguments.classify_harness)
    coalesce_harness_hash = sha256_file(arguments.coalesce_harness)
    coalesce_assign_harness_hash = sha256_file(arguments.coalesce_assign_harness)
    string_length_harness_hash = sha256_file(arguments.string_length_harness)
    object_alias_harness_hash = sha256_file(arguments.object_alias_harness)
    property_nullish_assign_harness_hash = sha256_file(arguments.property_nullish_assign_harness)
    closure_counter_harness_hash = sha256_file(arguments.closure_counter_harness)
    class_counter_harness_hash = sha256_file(arguments.class_counter_harness)
    derived_counter_harness_hash = sha256_file(arguments.derived_counter_harness)
    class_access_harness_hash = sha256_file(arguments.class_access_harness)
    checked_object_cast_harness_hash = sha256_file(arguments.checked_object_cast_harness)
    for capability in manifest["capabilities"]:
        capability["signatureHash"] = canonical_hash(capability["signature"])
        capability["implementationHash"] = archive_hash
    manifest["artifacts"] = {
        "umbrellaArchive": {"file": arguments.archive.name, "sha256": archive_hash, "bytes": arguments.archive.stat().st_size},
        "startupObject": {"file": arguments.startup.name, "sha256": startup_hash, "bytes": arguments.startup.stat().st_size},
        "applicationStartupObject": {"file": arguments.application_startup.name, "sha256": application_startup_hash, "bytes": arguments.application_startup.stat().st_size},
        "harnessObject": {"file": arguments.harness.name, "sha256": harness_hash, "bytes": arguments.harness.stat().st_size},
        "computeHarnessObject": {"file": arguments.compute_harness.name, "sha256": compute_harness_hash, "bytes": arguments.compute_harness.stat().st_size},
        "chooseHarnessObject": {"file": arguments.choose_harness.name, "sha256": choose_harness_hash, "bytes": arguments.choose_harness.stat().st_size},
        "classifyHarnessObject": {"file": arguments.classify_harness.name, "sha256": classify_harness_hash, "bytes": arguments.classify_harness.stat().st_size},
        "coalesceHarnessObject": {"file": arguments.coalesce_harness.name, "sha256": coalesce_harness_hash, "bytes": arguments.coalesce_harness.stat().st_size},
        "coalesceAssignHarnessObject": {"file": arguments.coalesce_assign_harness.name, "sha256": coalesce_assign_harness_hash, "bytes": arguments.coalesce_assign_harness.stat().st_size},
        "stringLengthHarnessObject": {"file": arguments.string_length_harness.name, "sha256": string_length_harness_hash, "bytes": arguments.string_length_harness.stat().st_size},
        "objectAliasHarnessObject": {"file": arguments.object_alias_harness.name, "sha256": object_alias_harness_hash, "bytes": arguments.object_alias_harness.stat().st_size},
        "propertyNullishAssignHarnessObject": {"file": arguments.property_nullish_assign_harness.name, "sha256": property_nullish_assign_harness_hash, "bytes": arguments.property_nullish_assign_harness.stat().st_size},
        "closureCounterHarnessObject": {"file": arguments.closure_counter_harness.name, "sha256": closure_counter_harness_hash, "bytes": arguments.closure_counter_harness.stat().st_size},
        "classCounterHarnessObject": {"file": arguments.class_counter_harness.name, "sha256": class_counter_harness_hash, "bytes": arguments.class_counter_harness.stat().st_size},
        "derivedCounterHarnessObject": {"file": arguments.derived_counter_harness.name, "sha256": derived_counter_harness_hash, "bytes": arguments.derived_counter_harness.stat().st_size},
        "classAccessHarnessObject": {"file": arguments.class_access_harness.name, "sha256": class_access_harness_hash, "bytes": arguments.class_access_harness.stat().st_size},
        "checkedObjectCastHarnessObject": {"file": arguments.checked_object_cast_harness.name, "sha256": checked_object_cast_harness_hash, "bytes": arguments.checked_object_cast_harness.stat().st_size},
    }
    manifest["abiSchemaHash"] = sha256_file(abi_schema_path)
    manifest["targetManifestHash"] = profile_target_hash
    manifest["sourceHash"] = source_hash()
    manifest["toolchain"] = {
        "rustc": tool_version("rustc", "--version"),
        "cargo": tool_version("cargo", "--version"),
        "clang": tool_version(arguments.clang, "--version"),
    }
    manifest["contentHash"] = canonical_hash(manifest)
    arguments.output.parent.mkdir(parents=True, exist_ok=True)
    arguments.output.write_text(json.dumps(manifest, sort_keys=True, separators=(",", ":")) + "\n", encoding="utf-8", newline="\n")


if __name__ == "__main__":
    main()
