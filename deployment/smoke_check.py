"""Read-only smoke checks for the deployed app and its exact content bytes."""

from __future__ import annotations

import argparse
import gzip
import hashlib
import json
from pathlib import Path
import sys
from urllib.error import HTTPError, URLError
from urllib.parse import urlsplit
from urllib.request import Request, urlopen


def content_root(value: str) -> str:
    parts = urlsplit(value)
    if (parts.scheme not in {"http", "https"} or not parts.hostname
            or parts.username or parts.password or parts.query or parts.fragment
            or parts.path not in {"", "/"}):
        raise ValueError("Provide an HTTP(S) origin without a path or credentials")
    if parts.scheme == "http" and parts.hostname not in {"localhost", "127.0.0.1", "::1"}:
        raise ValueError("Public deployments must use HTTPS")
    return value.rstrip("/")


def fetch(base: str, path: str, *, expected: int = 200):
    request = Request(base + path, headers={
        "User-Agent": "QuranHaven-Deployment-Check/1.0",
        "Accept-Encoding": "gzip",
        "Origin": "https://example.invalid",
    })
    try:
        response = urlopen(request, timeout=45)
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


def verify_resource(body: bytes, headers, entry: dict) -> None:
    if headers.get("Content-Encoding", "identity").lower() != "identity":
        raise ValueError("Content resources must not have HTTP Content-Encoding")
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
    args = parser.parse_args()
    try:
        base = content_root(args.base_url)
        health, _ = fetch(base, "/health")
        if health.strip() != b"ok":
            raise ValueError("Health response is not the expected service")
        app, headers = fetch(base, "/")
        if headers.get("Content-Encoding") == "gzip":
            app = gzip.decompress(app)
        if b"flutter_bootstrap.js" not in app:
            raise ValueError("Root page is not the Flutter web application")
        fetch(base, "/flutter_bootstrap.js")
        manifest_bytes, headers = fetch(base, "/v1/manifest.json")
        if headers.get("Content-Encoding", "identity").lower() != "identity":
            raise ValueError("Content manifest must be served without HTTP compression")
        local_manifest = Path(__file__).resolve().parents[1] / "content/public/v1/manifest.json"
        if manifest_bytes != local_manifest.read_bytes():
            raise ValueError("Public manifest differs from this project's verified manifest")
        manifest = json.loads(manifest_bytes)
        entries = {entry["path"]: entry for entry in manifest["files"]}
        for relative in ("tafsir/es.json.gz", "tajweed/sura_001.json"):
            data, headers = fetch(base, "/v1/" + relative)
            verify_resource(data, headers, entries[relative])
        fetch(base, "/v1/does-not-exist.json.gz", expected=404)
        fetch(base, "/.env", expected=404)
        fetch(base, "/assets/does-not-exist.json", expected=404)
        print(f"PASS: {base} serves the app, exact verified text resources, and safe 404s.")
        return 0
    except (OSError, URLError, ValueError, KeyError) as error:
        print(f"FAIL: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
