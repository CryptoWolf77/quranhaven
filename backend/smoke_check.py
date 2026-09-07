"""Check the cloud API safely; account writes require --exercise-account."""

from __future__ import annotations

import argparse
from dataclasses import dataclass, field
import gzip
from http.client import HTTPException, HTTPSConnection
import io
import ipaddress
import json
import secrets
import socket
import ssl
import sys
import time
from urllib.error import HTTPError, URLError
from urllib.parse import urlsplit
from urllib.request import (
    HTTPRedirectHandler, HTTPSHandler, ProxyHandler, Request, build_opener,
)
from uuid import uuid4
import zlib


MAX_RESPONSE_BYTES = 2 * 1024 * 1024
WEB_ORIGIN = "https://quranhaven.org"
BAD_ORIGIN = "https://untrusted.example.invalid"
EXERCISE_REQUEST_INTERVAL = 4.1


class CheckFailure(ValueError):
    """A sanitized failure safe to show without response bodies or credentials."""


def api_origin(value: str) -> str:
    try:
        parsed = urlsplit(value)
        port = parsed.port
        hostname = parsed.hostname
    except ValueError as error:
        raise CheckFailure("Provide a valid HTTP(S) API origin") from error
    if (
        parsed.scheme not in {"http", "https"}
        or not hostname
        or parsed.username is not None
        or parsed.password is not None
        or parsed.query or parsed.fragment
        or parsed.path not in {"", "/"}
        or any(character.isspace() or ord(character) < 32 for character in value)
        or any(character in value for character in ("\\", "%", "*"))
        or port == 0
    ):
        raise CheckFailure("Provide an HTTP(S) origin without credentials, paths, or wildcards")
    if parsed.scheme == "http" and hostname not in {"localhost", "127.0.0.1", "::1"}:
        raise CheckFailure("Public API deployments must use HTTPS")
    return f"{parsed.scheme}://{parsed.netloc}".rstrip("/")


class NoRedirects(HTTPRedirectHandler):
    # Never forward an account payload or bearer token through a redirect.
    def redirect_request(self, request, fp, code, message, headers, new_url):
        return None


class ResolvedHTTPSConnection(HTTPSConnection):
    def __init__(self, host: str, *, connect_address: str, **kwargs):
        super().__init__(host, **kwargs)
        self._create_connection = lambda address, *args, **kw: socket.create_connection(
            (connect_address, address[1]), *args, **kw)


class ResolvedHTTPSHandler(HTTPSHandler):
    """Override only this client's address; retain TLS verification and SNI."""

    def __init__(self, hostname: str, address: str):
        super().__init__(context=ssl.create_default_context())
        self.hostname = hostname
        try:
            self.address = str(ipaddress.ip_address(address))
        except ValueError as error:
            raise CheckFailure("--resolve-address must be a valid IP address") from error

    def https_open(self, request):
        def connection(host, **kwargs):
            result = ResolvedHTTPSConnection(host, connect_address=self.address, **kwargs)
            if result.host != self.hostname:
                raise CheckFailure("Refusing a request away from the configured HTTPS host")
            return result
        return self.do_open(connection, request, context=self._context)


@dataclass
class Response:
    status: int
    headers: dict
    body: bytes = field(repr=False)

    def json_object(self) -> dict:
        encoding = self.headers.get("content-encoding", "identity").strip().lower()
        body = self.body
        if len(body) > MAX_RESPONSE_BYTES:
            raise CheckFailure("API response exceeded the size limit")
        if encoding == "gzip":
            try:
                with gzip.GzipFile(fileobj=io.BytesIO(body)) as stream:
                    body = stream.read(MAX_RESPONSE_BYTES + 1)
            except (OSError, EOFError, zlib.error) as error:
                raise CheckFailure("API returned invalid compressed JSON") from error
            if len(body) > MAX_RESPONSE_BYTES:
                raise CheckFailure("Decoded API response exceeded the size limit")
        elif encoding != "identity":
            raise CheckFailure("API returned an unsupported transport encoding")
        try:
            result = json.loads(body)
        except (ValueError, UnicodeError, RecursionError) as error:
            raise CheckFailure("API returned invalid JSON") from error
        if not isinstance(result, dict):
            raise CheckFailure("API JSON must be an object")
        return result


class APIClient:
    def __init__(self, base: str, resolve_address: str | None = None):
        self.base = api_origin(base)
        handlers = [NoRedirects()]
        if resolve_address:
            parsed = urlsplit(self.base)
            if parsed.scheme != "https":
                raise CheckFailure("--resolve-address requires HTTPS")
            handlers.extend([
                ProxyHandler({}), ResolvedHTTPSHandler(parsed.hostname, resolve_address),
            ])
        self.opener = build_opener(*handlers)

    def request(self, method: str, path: str, *, expected=200, payload=None,
                token: str | None = None, headers: dict | None = None) -> Response:
        if not path.startswith("/") or path.startswith("//") or "?" in path or "#" in path:
            raise CheckFailure("Invalid API check path")
        request_headers = {
            "User-Agent": "QuranHaven-Cloud-Check/1.0",
            "Accept": "application/json",
            "Accept-Encoding": "identity",
            **(headers or {}),
        }
        if token:
            request_headers["Authorization"] = f"Bearer {token}"
        data = None
        if payload is not None:
            data = json.dumps(payload, allow_nan=False).encode("utf-8")
            request_headers["Content-Type"] = "application/json"
        request = Request(self.base + path, data=data, headers=request_headers, method=method)
        try:
            response = self.opener.open(request, timeout=30)
        except HTTPError as error:
            response = error
        except (OSError, URLError, HTTPException) as error:
            raise CheckFailure(f"{method} {path}: connection or TLS verification failed") from error
        with response:
            statuses = (expected,) if isinstance(expected, int) else expected
            if response.status not in statuses:
                raise CheckFailure(f"{method} {path}: unexpected HTTP {response.status}")
            try:
                body = response.read(MAX_RESPONSE_BYTES + 1)
            except (OSError, HTTPException) as error:
                raise CheckFailure(f"{method} {path}: response could not be read") from error
            if len(body) > MAX_RESPONSE_BYTES:
                raise CheckFailure(f"{method} {path}: response exceeded the size limit")
            return Response(response.status, {key.lower(): value for key, value in response.headers.items()}, body)


def require(condition: bool, message: str) -> None:
    if not condition:
        raise CheckFailure(message)


def check_read_only(client: APIClient) -> None:
    require(client.request("GET", "/health").json_object().get("status") == "ok",
            "Health endpoint did not report status ok")
    for method in ("GET", "PUT"):
        client.request(method, "/v1/sync", expected=401,
                       payload={"data": {}} if method == "PUT" else None)
    for path in ("/docs", "/openapi.json", "/redoc"):
        client.request("GET", path, expected=404)
    preflight = {
        "Origin": WEB_ORIGIN,
        "Access-Control-Request-Method": "PUT",
        "Access-Control-Request-Headers": "authorization,content-type",
    }
    allowed = client.request("OPTIONS", "/v1/sync", expected=(200, 204), headers=preflight)
    require(allowed.headers.get("access-control-allow-origin") == WEB_ORIGIN,
            "The Quran Haven web origin is not explicitly allowed by CORS")
    methods = {item.strip().upper() for item in allowed.headers.get("access-control-allow-methods", "").split(",")}
    require({"GET", "POST", "PUT", "DELETE"}.issubset(methods),
            "CORS does not allow the account and backup methods")
    allowed_headers = {item.strip().lower() for item in allowed.headers.get("access-control-allow-headers", "").split(",")}
    require({"authorization", "content-type"}.issubset(allowed_headers),
            "CORS does not allow the required request headers")
    denied = client.request("OPTIONS", "/v1/sync", expected=(200, 204, 400),
                            headers={**preflight, "Origin": BAD_ORIGIN})
    require("access-control-allow-origin" not in denied.headers,
            "CORS unexpectedly allows an untrusted origin")
    denied_get = client.request("GET", "/health", headers={"Origin": BAD_ORIGIN})
    require("access-control-allow-origin" not in denied_get.headers,
            "An untrusted origin received an allowed-origin header")


@dataclass(repr=False)
class SyntheticAccount:
    email: str
    password: str
    token: str | None = None
    deleted: bool = False


def auth_token(response: Response) -> str:
    value = response.json_object().get("access_token")
    require(isinstance(value, str) and bool(value), "Authentication response did not contain a token")
    return value


def account_email(response: Response) -> str | None:
    user = response.json_object().get("user")
    require(isinstance(user, dict), "Authentication response did not contain a user object")
    return user.get("email")


def exercise_accounts(client: APIClient, *, sleep=time.sleep) -> None:
    """Create two unique accounts, test only their data, and remove them."""
    accounts: list[SyntheticAccount] = []
    cleanup_failed = False
    previous_mutation = False

    def request(method: str, path: str, **kwargs) -> Response:
        nonlocal previous_mutation
        # The gateway shares a 15/minute account limit across register, login,
        # and delete. Pace exercise writes (including cleanup) conservatively;
        # read-only checks and GET requests do not wait or change that limit.
        if method in {"POST", "PUT", "DELETE"}:
            if previous_mutation:
                sleep(EXERCISE_REQUEST_INTERVAL)
            previous_mutation = True
        return client.request(method, path, **kwargs)

    try:
        for _ in range(2):
            account = SyntheticAccount(f"quranhaven-smoke-{uuid4().hex}@example.com", secrets.token_urlsafe(36))
            registered = request("POST", "/v1/auth/register", expected=201, payload={
                "display_name": "Quran Haven synthetic check",
                "email": account.email,
                "password": account.password,
            })
            # Track immediately after a confirmed creation, before parsing a token.
            accounts.append(account)
            account.token = auth_token(registered)
            require(account_email(registered) == account.email,
                    "Registration returned a different synthetic account")

        first, second = accounts
        logged_in = request("POST", "/v1/auth/login", payload={
            "email": first.email, "password": first.password,
        })
        first.token = auth_token(logged_in)
        require(account_email(logged_in) == first.email,
                "Login returned a different synthetic account")

        for account in accounts:
            empty = request("GET", "/v1/sync", token=account.token).json_object()
            require(empty.get("data") is None and empty.get("revision") == 0,
                    "A new synthetic account already has backup data")

        snapshot = {"schema_version": 1, "last_read_page": 42,
                    "bookmarks": [{"id": 1, "color": 4283215696,
                                   "name": "Smoke check", "ayah_id": 1,
                                   "ayah_number": 1, "page": 1}],
                    "smoke_check_id": uuid4().hex, "plans": {"khatmah": None, "memorization": []}}
        saved = request("PUT", "/v1/sync", token=first.token,
                               payload={"data": snapshot}).json_object()
        require(saved.get("data") == snapshot and saved.get("revision") == 1,
                "Synthetic backup did not save correctly")
        restored = request("GET", "/v1/sync", token=first.token).json_object()
        require(restored.get("data") == snapshot and restored.get("revision") == 1,
                "Synthetic backup did not restore correctly")
        isolated = request("GET", "/v1/sync", token=second.token).json_object()
        require(isolated.get("data") is None and isolated.get("revision") == 0,
                "Synthetic accounts are not isolated")
        second_snapshot = {"schema_version": 1, "last_read_page": 7, "smoke_check_id": uuid4().hex}
        request("PUT", "/v1/sync", token=second.token, payload={"data": second_snapshot})
        unchanged = request("GET", "/v1/sync", token=first.token).json_object()
        require(unchanged.get("data") == snapshot, "One synthetic account changed another account's backup")

        for account in accounts:
            request("DELETE", "/v1/account", token=account.token, expected=204)
            account.deleted = True
            request("GET", "/v1/sync", token=account.token, expected=401)
            request("POST", "/v1/auth/login", expected=401,
                           payload={"email": account.email, "password": account.password})
    finally:
        # Never enumerate, discover, or delete any existing user's account.
        for account in accounts:
            if account.deleted:
                continue
            try:
                if not account.token:
                    account.token = auth_token(request("POST", "/v1/auth/login", payload={
                        "email": account.email, "password": account.password,
                    }))
                request("DELETE", "/v1/account", token=account.token, expected=204)
                account.deleted = True
            except (CheckFailure, OSError):
                cleanup_failed = True
        if cleanup_failed:
            raise CheckFailure("A synthetic account could not be cleaned up; check the service before repeating account checks")


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--base-url", default="https://api.quranhaven.org")
    parser.add_argument("--resolve-address", help="Connect directly to this IP while preserving HTTPS host/certificate validation")
    parser.add_argument("--exercise-account", action="store_true",
                        help="Explicitly create two temporary synthetic accounts, test backups, and delete only those accounts")
    args = parser.parse_args(argv)
    try:
        client = APIClient(args.base_url, args.resolve_address)
        check_read_only(client)
        if args.exercise_account:
            exercise_accounts(client)
        detail = "; synthetic account, isolation, backup, and deletion checks passed" if args.exercise_account else "; no accounts created"
        print(f"PASS: API health, authentication boundaries, production docs, and CORS passed{detail}.")
        return 0
    except CheckFailure as error:
        # These messages are constructed locally; never include remote bodies,
        # credentials, base-URL input, or wrapped network exception messages.
        print(f"FAIL: {error}", file=sys.stderr)
        return 1
    except (OSError, URLError, HTTPException):
        print("FAIL: Cloud API connection failed. No response body was logged.", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
