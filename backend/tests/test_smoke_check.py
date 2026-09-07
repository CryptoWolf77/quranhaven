"""Network-free tests for the standalone production cloud smoke checker."""

import contextlib
import gzip
import importlib.util
import io
import json
from pathlib import Path
import sys
import unittest
from unittest.mock import patch


SPEC = importlib.util.spec_from_file_location("cloud_smoke_check", Path(__file__).resolve().parents[1] / "smoke_check.py")
smoke = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = smoke
SPEC.loader.exec_module(smoke)


def response(value, status=200, headers=None):
    return smoke.Response(status, headers or {}, json.dumps(value).encode())


class FakeAPI:
    def __init__(self):
        self.accounts = {}
        self.deleted = []
        self.fail_backup = False
        self.calls = []

    def request(self, method, path, *, expected=200, payload=None, token=None, headers=None):
        self.calls.append((method, path))
        if path == "/v1/auth/register":
            token = "private-token-" + payload["email"]
            self.accounts[token] = {"email": payload["email"], "password": payload["password"], "data": None, "revision": 0}
            return response({"access_token": token, "user": {"email": payload["email"]}}, 201)
        if path == "/v1/auth/login":
            for token, account in self.accounts.items():
                if account["email"] == payload["email"] and account["password"] == payload["password"]:
                    return response({"access_token": token, "user": {"email": payload["email"]}})
            if expected != 401:
                raise smoke.CheckFailure("Login failed")
            return response({}, 401)
        if token not in self.accounts:
            if expected != 401:
                raise smoke.CheckFailure("Missing synthetic account")
            return response({}, 401)
        if method == "DELETE":
            self.deleted.append(self.accounts.pop(token))
            return response({}, 204)
        account = self.accounts[token]
        if method == "PUT":
            if self.fail_backup:
                raise smoke.CheckFailure("Backup rejected")
            account["data"] = payload["data"]
            account["revision"] += 1
        return response({"data": account["data"], "revision": account["revision"]})


class CloudSmokeTests(unittest.TestCase):
    def test_origins_accept_https_and_loopback_only_http(self):
        self.assertEqual(smoke.api_origin("https://api.quranhaven.org/"), "https://api.quranhaven.org")
        self.assertEqual(smoke.api_origin("http://127.0.0.1:8000"), "http://127.0.0.1:8000")
        self.assertEqual(smoke.api_origin("http://[::1]:8000/"), "http://[::1]:8000")

    def test_origins_reject_unsafe_and_malformed_urls(self):
        for value in ("http://api.quranhaven.org", "https://reader:secret@example.com",
                      "https://example.com/v1", "https://example.com?token=private",
                      "https://example.com#private", "https://example.com:0", "https://example.com:99999",
                      "https://example.com:bad", "https://[::1", "https://*.example.com",
                      " https://example.com", "https://example.com\n", "https://example.com\\evil",
                      "https://exa%6dple.com", "file:///tmp/test", "https://"):
            with self.subTest(value=value), self.assertRaises(smoke.CheckFailure):
                smoke.api_origin(value)

    def test_json_response_identity_gzip_and_nonobject(self):
        self.assertEqual(response({"status": "ok"}).json_object(), {"status": "ok"})
        self.assertEqual(smoke.Response(200, {"content-encoding": "gzip"}, gzip.compress(b'{"status":"ok"}')).json_object(), {"status": "ok"})
        for body, headers in ((b"[]", {}), (b"private-secret-not-json", {}),
                              (b"invalid-gzip", {"content-encoding": "gzip"}),
                              (b"{}", {"content-encoding": "br"}), (b"\xff", {})):
            with self.subTest(body=body), self.assertRaises(smoke.CheckFailure) as raised:
                smoke.Response(200, headers, body).json_object()
            self.assertNotIn("private-secret", str(raised.exception))

    def test_json_response_size_limits_include_decompressed_bytes(self):
        with patch.object(smoke, "MAX_RESPONSE_BYTES", 32):
            for body, headers in ((b" " * 33, {}), (gzip.compress(b" " * 100), {"content-encoding": "gzip"})):
                with self.assertRaises(smoke.CheckFailure):
                    smoke.Response(200, headers, body).json_object()

    def test_explicit_address_keeps_certificate_validation(self):
        handler = smoke.ResolvedHTTPSHandler("api.quranhaven.org", "173.249.43.226")
        self.assertTrue(handler._context.check_hostname)
        self.assertEqual(handler._context.verify_mode, smoke.ssl.CERT_REQUIRED)
        with self.assertRaises(smoke.CheckFailure):
            smoke.APIClient("http://localhost:8000", "127.0.0.1")
        with self.assertRaises(smoke.CheckFailure):
            smoke.ResolvedHTTPSHandler("api.quranhaven.org", "another-host.example")

    def test_redirects_are_not_followed(self):
        self.assertIsNone(smoke.NoRedirects().redirect_request(None, None, 307, "", {}, "https://other.example"))

    def test_account_check_removes_only_its_two_created_accounts(self):
        client = FakeAPI()
        existing = {"email": "existing@example.com", "password": "existing", "data": {"keep": True}, "revision": 1}
        client.accounts["existing-token"] = existing.copy()
        pauses = []
        smoke.exercise_accounts(client, sleep=pauses.append)
        self.assertEqual(client.accounts, {"existing-token": existing})
        self.assertEqual(len(client.deleted), 2)
        self.assertNotEqual(client.deleted[0]["email"], client.deleted[1]["email"])
        self.assertTrue(all(account["email"].startswith("quranhaven-smoke-") for account in client.deleted))
        self.assertTrue(all(account["email"].endswith("@example.com") for account in client.deleted))
        mutations = sum(method in {"POST", "PUT", "DELETE"} for method, _ in client.calls)
        self.assertEqual(mutations, 9)
        self.assertEqual(pauses, [4.1] * (mutations - 1))

    def test_failed_account_check_still_cleans_up(self):
        client = FakeAPI()
        client.fail_backup = True
        pauses = []
        with self.assertRaises(smoke.CheckFailure):
            smoke.exercise_accounts(client, sleep=pauses.append)
        self.assertEqual(client.accounts, {})
        self.assertEqual(len(client.deleted), 2)
        # Both finally-block cleanup deletes are paced after the failed backup.
        self.assertEqual(pauses, [4.1] * 5)

    def test_default_mode_never_exercises_accounts(self):
        output = io.StringIO()
        with patch.object(smoke, "APIClient"), patch.object(smoke, "check_read_only") as readonly, \
                patch.object(smoke, "exercise_accounts") as writes, contextlib.redirect_stdout(output):
            self.assertEqual(smoke.main([]), 0)
        readonly.assert_called_once()
        writes.assert_not_called()
        self.assertIn("no accounts created", output.getvalue())

    def test_opt_in_mode_exercises_accounts_and_output_excludes_secrets(self):
        output, errors = io.StringIO(), io.StringIO()
        def reflected_invalid_response(_client):
            smoke.Response(200, {}, b"private-token and password").json_object()
        with patch.object(smoke, "APIClient"), patch.object(smoke, "check_read_only"), \
                patch.object(smoke, "exercise_accounts", side_effect=reflected_invalid_response) as writes, \
                contextlib.redirect_stdout(output), contextlib.redirect_stderr(errors):
            self.assertEqual(smoke.main(["--exercise-account"]), 1)
        writes.assert_called_once()
        self.assertNotIn("private-token", output.getvalue() + errors.getvalue())
        self.assertNotIn("password", output.getvalue() + errors.getvalue())

    def test_read_only_checks_use_no_accounts_and_reject_wildcard_cors(self):
        calls = []
        class ReadOnlyAPI:
            def request(self, method, path, **kwargs):
                calls.append((method, path, kwargs))
                if method == "OPTIONS" and kwargs["headers"]["Origin"] == smoke.WEB_ORIGIN:
                    assert 204 in kwargs["expected"]
                    return response({}, status=204, headers={
                        "access-control-allow-origin": smoke.WEB_ORIGIN,
                        "access-control-allow-methods": "GET, POST, PUT, DELETE, OPTIONS",
                        "access-control-allow-headers": "Authorization, Content-Type",
                    })
                if method == "OPTIONS":
                    assert 204 in kwargs["expected"]
                    return response({}, status=204)
                return response({"status": "ok"})
        smoke.check_read_only(ReadOnlyAPI())
        self.assertFalse(any("/auth/" in path or path == "/v1/account" for _, path, _ in calls))
        self.assertTrue(any(method == "PUT" and kwargs["expected"] == 401 for method, _, kwargs in calls))
        self.assertTrue(any(path == "/openapi.json" and kwargs["expected"] == 404 for _, path, kwargs in calls))
        class WildcardAPI(ReadOnlyAPI):
            def request(self, method, path, **kwargs):
                result = super().request(method, path, **kwargs)
                if method == "OPTIONS":
                    result.headers["access-control-allow-origin"] = "*"
                return result
        with self.assertRaises(smoke.CheckFailure):
            smoke.check_read_only(WildcardAPI())

    def test_malformed_auth_response_is_sanitized(self):
        for value in ({"access_token": ""}, {"access_token": 123}, {"secret": "private-password"}):
            with self.assertRaises(smoke.CheckFailure) as raised:
                smoke.auth_token(response(value))
            self.assertNotIn("private-password", str(raised.exception))
        with self.assertRaises(smoke.CheckFailure):
            smoke.account_email(response({"user": ["private-password"]}))


if __name__ == "__main__":
    unittest.main()
