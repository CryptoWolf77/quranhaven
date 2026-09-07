"""Unit tests for deployed-byte checks; no network access required."""

import gzip
import hashlib
import importlib.util
from pathlib import Path
import unittest


SCRIPT = Path(__file__).resolve().parents[1] / "deployment/smoke_check.py"
SPEC = importlib.util.spec_from_file_location("smoke_check", SCRIPT)
smoke = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(smoke)


class DeploymentToolsTests(unittest.TestCase):
    def test_public_origin_requires_https(self):
        self.assertEqual(smoke.content_root("https://quranhaven.org/"), "https://quranhaven.org")
        self.assertEqual(smoke.content_root("http://127.0.0.1:8080"), "http://127.0.0.1:8080")
        for value in ("http://quranhaven.org", "https://quranhaven.org/v1/",
                      "https://name:secret@quranhaven.org", "https://quranhaven.org?secret=1"):
            with self.subTest(value=value), self.assertRaises(ValueError):
                smoke.content_root(value)

    def sample(self):
        data = gzip.compress(b'{"text":"unchanged"}')
        return data, {"path": "tafsir/test.json.gz", "bytes": len(data),
                      "sha256": hashlib.sha256(data).hexdigest()}

    def test_exact_gzip_file_is_accepted(self):
        data, entry = self.sample()
        smoke.verify_resource(data, {"Access-Control-Allow-Origin": "*"}, entry)

    def test_http_gzip_decoding_is_rejected(self):
        data, entry = self.sample()
        with self.assertRaises(ValueError):
            smoke.verify_resource(data, {"Access-Control-Allow-Origin": "*",
                                         "Content-Encoding": "gzip"}, entry)

    def test_changed_bytes_are_rejected(self):
        data, entry = self.sample()
        with self.assertRaises(ValueError):
            smoke.verify_resource(data + b"changed", {"Access-Control-Allow-Origin": "*"}, entry)

    def test_missing_cors_is_rejected(self):
        data, entry = self.sample()
        with self.assertRaises(ValueError):
            smoke.verify_resource(data, {}, entry)


if __name__ == "__main__":
    unittest.main()
