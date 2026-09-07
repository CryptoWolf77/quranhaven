"""Integrity and archive safety checks for the content preparation tool."""

import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
import zipfile


SCRIPT = Path(__file__).resolve().parents[1] / "content/prepare_content.py"
SPEC = importlib.util.spec_from_file_location("prepare_content", SCRIPT)
content = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(content)


class ContentToolsTests(unittest.TestCase):
    def test_traversal_archive_is_rejected_before_extracting(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            archive = root / "malicious.zip"
            with zipfile.ZipFile(archive, "w") as bundle:
                bundle.writestr("valid.json", "{}")
                bundle.writestr("../escaped.txt", "unexpected")
            with self.assertRaises(content.ContentError):
                content.extract_safe(archive, root / "output")
            self.assertFalse((root / "escaped.txt").exists())
            self.assertFalse((root / "output/valid.json").exists())

    def test_windows_unsafe_paths_are_rejected(self):
        with tempfile.TemporaryDirectory() as temporary:
            for name in [r"..\outside.json", "C:/outside.json", "/outside.json",
                         "file.json:stream", "folder./file.json"]:
                with self.subTest(name=name), self.assertRaises(content.ContentError):
                    content.safe_path(Path(temporary), name)

    def test_archive_symlink_is_rejected(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            archive = root / "symlink.zip"
            with zipfile.ZipFile(archive, "w") as bundle:
                entry = zipfile.ZipInfo("link")
                entry.create_system = 3
                entry.external_attr = 0o120777 << 16
                bundle.writestr(entry, "../outside")
            with self.assertRaises(content.ContentError):
                content.extract_safe(archive, root / "output")

    def test_extraction_preserves_exact_original_bytes(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            archive = root / "valid.zip"
            original = b'\xef\xbb\xbf{"text":"unaltered"}\r\n'
            with zipfile.ZipFile(archive, "w") as bundle:
                bundle.writestr("data/quran.json", original)
            original_hash = content.sha256(archive)
            content.extract_safe(archive, root / "output")
            self.assertEqual(original, (root / "output/data/quran.json").read_bytes())
            self.assertEqual(original_hash, content.sha256(archive))

    def make_manifest(self, root):
        public = root / "public/v1"
        public.mkdir(parents=True)
        resource = public / "sample.json"
        resource.write_bytes(b"{}")
        manifest = {"schema_version": 1, "files": [{"path": "sample.json",
                    "bytes": 2, "sha256": content.sha256(resource)}]}
        (public / "manifest.json").write_text(json.dumps(manifest), encoding="utf-8")
        return public

    def test_manifest_detects_same_size_tampering(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            public = self.make_manifest(root)
            (public / "sample.json").write_bytes(b"[]")
            with self.assertRaisesRegex(content.ContentError, "integrity mismatch"):
                content.verify_manifest(root)

    def test_manifest_rejects_unlisted_files(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            public = self.make_manifest(root)
            (public / "unexpected.json").write_bytes(b"{}")
            with self.assertRaisesRegex(content.ContentError, "Unmanifested"):
                content.verify_manifest(root)

    def test_manifest_detects_missing_file(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            public = self.make_manifest(root)
            (public / "sample.json").rename(public / "moved.json")
            with self.assertRaisesRegex(content.ContentError, "Missing published file"):
                content.verify_manifest(root)

    def test_missing_official_original_fails(self):
        with tempfile.TemporaryDirectory() as temporary:
            with self.assertRaisesRegex(content.ContentError, "Missing official original"):
                content.archive_records(Path(temporary))

    def test_quran_with_missing_ayah_fails(self):
        with self.assertRaisesRegex(content.ContentError, "6,236 Ayahs"):
            content.validate_verses([], "incomplete")


if __name__ == "__main__":
    unittest.main()
