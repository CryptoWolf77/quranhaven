"""Read-only smoke checks for the deployed app and its exact content bytes."""

from __future__ import annotations

import argparse
import gzip
import hashlib
from http.client import HTTPSConnection
import io
import ipaddress
import json
from pathlib import Path
import socket
import ssl
import sys
import zlib
from urllib.error import HTTPError, URLError
from urllib.parse import urlsplit
from urllib.request import HTTPSHandler, ProxyHandler, Request, build_opener, urlopen


def content_root(value: str) -> str:
    parts = urlsplit(value)
    if (parts.scheme not in {"http", "https"} or not parts.hostname
            or parts.username or parts.password or parts.query or parts.fragment
            or parts.path not in {"", "/"}):
        raise ValueError("Provide an HTTP(S) origin without a path or credentials")
    if parts.scheme == "http" and parts.hostname not in {"localhost", "127.0.0.1", "::1"}:
        raise ValueError("Public deployments must use HTTPS")
    return value.rstrip("/")


class ResolvedHTTPSConnection(HTTPSConnection):
    """Connect to an explicit IP while keeping the real TLS/SNI hostname."""

    def __init__(self, host: str, *, connect_address: str, **kwargs):
        super().__init__(host, **kwargs)
        self._create_connection = lambda address, *args, **kw: socket.create_connection(
            (connect_address, address[1]), *args, **kw)


class ResolvedHTTPSHandler(HTTPSHandler):
    def __init__(self, hostname: str, address: str):
        # Certificate validation and hostname checks remain enabled.
        super().__init__(context=ssl.create_default_context())
        self.hostname = hostname
        self.address = str(ipaddress.ip_address(address))

    def https_open(self, request):
        def connection(host, **kwargs):
            result = ResolvedHTTPSConnection(host, connect_address=self.address, **kwargs)
            if result.host != self.hostname:
                raise ValueError("Refusing a redirect away from the configured HTTPS host")
            return result

        return self.do_open(connection, request, context=self._context)


def fetch(base: str, path: str, *, expected: int = 200, opener=None):
    request = Request(base + path, headers={
        "User-Agent": "QuranHaven-Deployment-Check/1.0",
        "Accept-Encoding": "gzip",
        "Origin": "https://example.invalid",
    })
    try:
        response = (opener.open if opener else urlopen)(request, timeout=45)
    except HTTPError as error:
        response = error
    with response:
        if response.status != expected:
            raise ValueError(f"{path}: expected HTTP {expected}, got {response.status}")
        if urlsplit(response.url).netloc != urlsplit(base).netloc:
            raise ValueError(f"{path}: redirected away from the configured host")
        body = response.read(32 * 1024 * 1024 + 1)
        if len(body) > 32 * 1024 * 1024:
            raise ValueError(f"{path}: unexpectedly large response")
        return body, response.headers


def decode_transport(body: bytes, headers) -> bytes:
    """Remove only HTTP encoding; a .json.gz file keeps its own gzip layer."""
    encoding = headers.get("Content-Encoding", "identity").strip().lower()
    if encoding == "identity":
        return body
    if encoding != "gzip":
        raise ValueError(f"Unsupported HTTP Content-Encoding: {encoding!r}")
    try:
        with gzip.GzipFile(fileobj=io.BytesIO(body)) as stream:
            decoded = stream.read(32 * 1024 * 1024 + 1)
    except (OSError, EOFError, zlib.error) as error:
        raise ValueError("Invalid gzip HTTP transport payload") from error
    if len(decoded) > 32 * 1024 * 1024:
        raise ValueError("Decoded HTTP response is unexpectedly large")
    return decoded


def verify_resource(body: bytes, headers, entry: dict) -> None:
    body = decode_transport(body, headers)
    if headers.get("Access-Control-Allow-Origin") != "*":
        raise ValueError("Public content CORS header is missing")
    if len(body) != entry["bytes"] or hashlib.sha256(body).hexdigest() != entry["sha256"]:
        raise ValueError(f"Served bytes differ from the manifest: {entry['path']}")
    if entry["path"].endswith(".json.gz"):
        json.loads(gzip.decompress(body))
    elif entry["path"].endswith(".json"):
        json.loads(body)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--base-url", default="https://quranhaven.org")
    parser.add_argument("--resolve-address", help="Connect this HTTPS check to an IP without changing system DNS")
    args = parser.parse_args()
    try:
        base = content_root(args.base_url)
        opener = None
        if args.resolve_address:
            if urlsplit(base).scheme != "https":
                raise ValueError("--resolve-address requires an HTTPS base URL")
            # A deliberate address override must connect directly, not via a proxy.
            opener = build_opener(ProxyHandler({}), ResolvedHTTPSHandler(
                urlsplit(base).hostname, args.resolve_address))
        health, headers = fetch(base, "/health", opener=opener)
        health = decode_transport(health, headers)
        if health.strip() != b"ok":
            raise ValueError("Health response is not the expected service")
        app, headers = fetch(base, "/", opener=opener)
        app = decode_transport(app, headers)
        if b"flutter_bootstrap.js" not in app:
            raise ValueError("Root page is not the Flutter web application")
        bootstrap, headers = fetch(base, "/flutter_bootstrap.js", opener=opener)
        if not decode_transport(bootstrap, headers):
            raise ValueError("Flutter bootstrap script is empty")
        manifest_bytes, headers = fetch(base, "/v1/manifest.json", opener=opener)
        manifest_bytes = decode_transport(manifest_bytes, headers)
        local_manifest = Path(__file__).resolve().parents[1] / "content/public/v1/manifest.json"
        if manifest_bytes != local_manifest.read_bytes():
            raise ValueError("Public manifest differs from this project's verified manifest")
        manifest = json.loads(manifest_bytes)
        entries = {entry["path"]: entry for entry in manifest["files"]}
        for relative in ("tafsir/es.json.gz", "tajweed/sura_001.json"):
            data, headers = fetch(base, "/v1/" + relative, opener=opener)
            verify_resource(data, headers, entries[relative])
        fetch(base, "/v1/does-not-exist.json.gz", expected=404, opener=opener)
        fetch(base, "/.env", expected=404, opener=opener)
        fetch(base, "/assets/does-not-exist.json", expected=404, opener=opener)
        print(f"PASS: {base} serves the app, exact verified text resources, and safe 404s.")
        return 0
    except (OSError, URLError, ValueError, KeyError) as error:
        print(f"FAIL: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
