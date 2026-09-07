"""Unit tests for deployed-byte checks; no network access required."""

import gzip
import hashlib
import importlib.util
from pathlib import Path
import ssl
import unittest
from unittest.mock import patch


SCRIPT = Path(__file__).resolve().parents[1] / "deployment/smoke_check.py"
SPEC = importlib.util.spec_from_file_location("smoke_check", SCRIPT)
smoke = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(smoke)


class DeploymentToolsTests(unittest.TestCase):
    def test_address_override_preserves_tls_hostname_and_verification(self):
        handler = smoke.ResolvedHTTPSHandler("quranhaven.org", "104.21.36.64")
        self.assertTrue(handler._context.check_hostname)
        self.assertEqual(handler._context.verify_mode, ssl.CERT_REQUIRED)
        connection = smoke.ResolvedHTTPSConnection("quranhaven.org", connect_address=handler.address,
                                                   context=handler._context)
        self.assertEqual(connection.host, "quranhaven.org")
        with patch.object(smoke.socket, "create_connection") as connect:
            connection._create_connection(("quranhaven.org", 443), timeout=1)
            connect.assert_called_once_with(("104.21.36.64", 443), timeout=1)

    def test_address_override_requires_an_ip_literal(self):
        with self.assertRaises(ValueError):
            smoke.ResolvedHTTPSHandler("quranhaven.org", "other.example.org")

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

    def test_gzip_file_with_separate_http_gzip_layer_is_accepted(self):
        data, entry = self.sample()
        wire = gzip.compress(data)
        headers = {"Access-Control-Allow-Origin": "*", "Content-Encoding": "gzip"}
        self.assertEqual(smoke.decode_transport(wire, headers), data)
        smoke.verify_resource(wire, headers, entry)

    def test_gzip_file_falsely_labeled_as_http_gzip_is_rejected(self):
        data, entry = self.sample()
        with self.assertRaises(ValueError):
            smoke.verify_resource(data, {"Access-Control-Allow-Origin": "*",
                                         "Content-Encoding": "gzip"}, entry)

    def test_plain_json_with_http_gzip_is_accepted(self):
        data = b'{"schema_version":1}'
        entry = {"path": "manifest.json", "bytes": len(data),
                 "sha256": hashlib.sha256(data).hexdigest()}
        smoke.verify_resource(gzip.compress(data), {"Access-Control-Allow-Origin": "*",
                                                    "Content-Encoding": "gzip"}, entry)

    def test_unknown_or_stacked_transport_encoding_is_rejected(self):
        for encoding in ("br", "deflate", "gzip, gzip", ""):
            with self.subTest(encoding=encoding), self.assertRaises(ValueError):
                smoke.decode_transport(b"payload", {"Content-Encoding": encoding})

    def test_damaged_or_non_gzip_transport_is_rejected(self):
        data, _ = self.sample()
        for wire in (b'{"not":"compressed"}', gzip.compress(data)[:-5]):
            with self.subTest(wire=wire), self.assertRaises(ValueError):
                smoke.decode_transport(wire, {"Content-Encoding": "gzip"})

    def test_transport_decode_does_not_guess_from_file_magic(self):
        data, _ = self.sample()
        self.assertEqual(smoke.decode_transport(data, {}), data)
        self.assertEqual(smoke.decode_transport(data, {"Content-Encoding": "identity"}), data)

    def test_mismatched_bytes_inside_valid_http_gzip_are_rejected(self):
        data, entry = self.sample()
        with self.assertRaises(ValueError):
            smoke.verify_resource(gzip.compress(data + b"changed"),
                                  {"Access-Control-Allow-Origin": "*",
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
