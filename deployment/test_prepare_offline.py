"""Network-free checks for the generated public offline-shell manifest."""

import hashlib
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

SPEC = importlib.util.spec_from_file_location("prepare_offline", Path(__file__).with_name("prepare_offline.py"))
offline = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(offline)
PROJECT = Path(__file__).resolve().parents[1]


class OfflineManifestTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        for name in offline.REQUIRED_FILES:
            path = self.root / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(b"test-public-asset")
        (self.root / "flutter_bootstrap.js").write_text(
            (PROJECT / "web/flutter_bootstrap.js").read_text(encoding="utf-8").replace("{{flutter_js}}", "// loader").replace("{{flutter_build_config}}", "// build config"), encoding="utf-8")
        (self.root / "quran_service_worker.js").write_text(
            (PROJECT / "web/quran_service_worker.js").read_text(encoding="utf-8"), encoding="utf-8")

    def test_exact_hashes_and_idempotent_output(self):
        first = offline.generate(self.root)
        self.assertEqual(first, offline.generate(self.root))
        self.assertEqual(first["totalBytes"], sum(entry["bytes"] for entry in first["files"]))
        for entry in first["files"]:
            data = (self.root / entry["path"].lstrip("/")).read_bytes()
            self.assertEqual(entry["sha256"], hashlib.sha256(data).hexdigest())
        self.assertIn(first["version"], (self.root / "quran_service_worker.js").read_text())
        self.assertNotIn(offline.TOKEN, (self.root / "flutter_bootstrap.js").read_text())
        self.assertEqual(first, json.loads((self.root / "offline-manifest.json").read_text()))

    def test_index_binary_alias_preserves_exact_bytes_without_duplicate_entry(self):
        original = b"<!doctype html>\r\n<html><body>Quran Haven \xd8\xa7</body></html>\r\n"
        (self.root / "index.html").write_bytes(original)
        result = offline.generate(self.root)
        self.assertEqual((self.root / "offline-index.bin").read_bytes(), original)
        self.assertEqual((self.root / "index.html").read_bytes(), original)
        entries = {entry["path"]: entry for entry in result["files"]}
        self.assertNotIn("/offline-index.bin", entries)
        self.assertEqual(entries["/index.html"]["sha256"], hashlib.sha256(original).hexdigest())
        self.assertEqual(entries["/index.html"]["bytes"], len(original))
        self.assertFalse(offline.allowed("offline-index.bin"))
        self.assertEqual(result, offline.generate(self.root))

    def test_excludes_api_content_health_maps_and_unused_renderers(self):
        for name in (".env", "v1/tafsir/es.json.gz", "api/account.json", "health",
                     "main.dart.js.map", "assets/private.pem", "assets/.hidden.json",
                     "canvaskit/skwasm.wasm", "flutter_service_worker.js"):
            path = self.root / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text("not part of public shell")
        result = offline.generate(self.root)
        self.assertEqual({entry["path"].lstrip("/") for entry in result["files"]}, offline.REQUIRED_FILES)

    def test_asset_change_changes_release(self):
        first = offline.generate(self.root)
        (self.root / "main.dart.js").write_text("changed application")
        self.assertNotEqual(first["version"], offline.generate(self.root)["version"])

    def test_missing_core_asset_fails_before_stamping(self):
        (self.root / "assets/AssetManifest.bin").unlink()
        with self.assertRaisesRegex(ValueError, "missing required"):
            offline.generate(self.root)
        self.assertIn(offline.TOKEN, (self.root / "quran_service_worker.js").read_text())

    def test_missing_bootstrap_marker_fails(self):
        (self.root / "flutter_bootstrap.js").write_text("ordinary Flutter bootstrap")
        with self.assertRaisesRegex(ValueError, "version marker"):
            offline.generate(self.root)

    def test_empty_public_asset_fails(self):
        (self.root / "main.dart.js").write_bytes(b"")
        with self.assertRaisesRegex(ValueError, "empty"):
            offline.generate(self.root)


if __name__ == "__main__":
    unittest.main()
