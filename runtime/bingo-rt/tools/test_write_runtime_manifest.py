#!/usr/bin/env python3
import unittest

import write_runtime_manifest as writer


class ProfileTargetManifestTests(unittest.TestCase):
    def test_static_profile_excludes_dynamic_capability(self):
        manifest, target_hash = writer.load_profile_target_manifest("static")
        self.assertEqual(manifest["profile"], "static")
        self.assertEqual(target_hash, writer.sha256_file(writer.ROOT / "manifests" / "first-slice-target.json"))
        self.assertNotIn(
            "rt.dynamic.property_load",
            [capability["logicalName"] for capability in manifest["capabilities"]],
        )

    def test_interop_profile_adds_exact_dynamic_capability(self):
        manifest, target_hash = writer.load_profile_target_manifest("interop")
        self.assertEqual(manifest["profile"], "interop")
        self.assertEqual(target_hash, writer.canonical_hash(manifest))
        capabilities = manifest["capabilities"]
        names = [capability["logicalName"] for capability in capabilities]
        self.assertEqual(names, sorted(names))
        self.assertEqual(len(names), len(set(names)))
        dynamic = [capability for capability in capabilities if capability["logicalName"] == "rt.dynamic.property_load"]
        self.assertEqual(
            dynamic,
            [
                {
                    "logicalName": "rt.dynamic.property_load",
                    "symbolName": "bingo_dynamic_property_load_v1",
                    "abiVersion": "1.0.0",
                    "signature": "u32(dynamic-value-v1,utf16-string-view,dynamic-value-v1*)",
                    "effects": ["call", "read", "throw"],
                    "requiredFeatures": [],
                }
            ],
        )

    def test_unknown_profile_is_rejected(self):
        with self.assertRaisesRegex(ValueError, "unsupported runtime profile"):
            writer.load_profile_target_manifest("unsafe")


if __name__ == "__main__":
    unittest.main()
