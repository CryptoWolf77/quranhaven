"""Generate an integrity manifest for the built, public Flutter web shell only."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import re
from urllib.parse import quote


TOKEN = "__QURAN_OFFLINE_VERSION__"
MAX_TOTAL_BYTES = 160 * 1024 * 1024
MAX_FILE_BYTES = 64 * 1024 * 1024
ROOT_FILES = {
    "index.html", "flutter_bootstrap.js", "main.dart.js", "flutter.js",
    "manifest.json", "favicon.png", "version.json",
}
CANVASKIT_FILES = {
    "canvaskit/canvaskit.js", "canvaskit/canvaskit.wasm",
    "canvaskit/chromium/canvaskit.js", "canvaskit/chromium/canvaskit.wasm",
}
REQUIRED_FILES = {
    "index.html", "flutter_bootstrap.js", "main.dart.js", "manifest.json",
    "canvaskit/canvaskit.js", "canvaskit/canvaskit.wasm",
    "assets/AssetManifest.bin", "assets/FontManifest.json",
    "assets/packages/quran_library/assets/jsons/surahs_name.json.gz",
    "assets/packages/quran_library/assets/jsons/quranV4.json.gz",
    "assets/packages/quran_library/assets/jsons/qpc_v4_ayah_info.json.gz",
    "assets/packages/quran_library/assets/jsons/qpc-hafs-word-by-word.json.gz",
    "assets/packages/quran_library/assets/jsons/qpc-v4.json.gz",
    "assets/packages/quran_library/assets/saadi.json.gz",
    "assets/packages/quran_library/assets/en.json.gz",
    "assets/packages/quran_library/assets/fonts/Cairo-Regular.ttf",
    "assets/packages/quran_library/assets/fonts/NotoNaskhArabic-VariableFont_wght.ttf",
}
REQUIRED_FILES.update(
    f"assets/packages/quran_library/assets/fonts/quran_fonts_qfc4/QCF4{page:03d}_COLOR-Regular.ttf.gz"
    for page in range(1, 605)
)


def allowed(relative: str) -> bool:
    parts = relative.split("/")
    if any(not part or part.startswith(".") for part in parts):
        return False
    if relative.endswith((".map", ".symbols", ".pem", ".key", ".p12", ".jks")):
        return False
    return relative in ROOT_FILES or relative in CANVASKIT_FILES or parts[0] in {"assets", "icons"}


def normalize_version(source: str, variable: str) -> str:
    pattern = rf'const {variable} = "(?:{TOKEN}|[a-f0-9]{{64}})";'
    normalized, count = re.subn(pattern, f'const {variable} = "{TOKEN}";', source)
    if count != 1:
        raise ValueError(f"Expected exactly one offline version marker in {variable}")
    return normalized


def generate(web_root: Path) -> dict:
    root = web_root.resolve(strict=True)
    if not root.is_dir():
        raise ValueError("--web-root must be a built Flutter web directory")
    files = []
    for path in sorted(root.rglob("*")):
        relative = path.relative_to(root).as_posix()
        if not allowed(relative):
            continue
        if path.is_symlink() or root not in path.resolve().parents:
            raise ValueError("Offline assets must not be symlinks or escape the web directory")
        if path.is_file():
            if not 0 < path.stat().st_size <= MAX_FILE_BYTES:
                raise ValueError("An offline asset is empty or exceeds the individual size limit")
            files.append((relative, path))
    names = {name for name, _ in files}
    if missing := REQUIRED_FILES - names:
        raise ValueError("Built web directory is missing required offline files: " + ", ".join(sorted(missing)))
    bootstrap_path = root / "flutter_bootstrap.js"
    worker_path = root / "quran_service_worker.js"
    offline_index_path = root / "offline-index.bin"
    if worker_path.is_symlink() or offline_index_path.is_symlink():
        raise ValueError("Generated offline files must not be symlinks")
    bootstrap = normalize_version(bootstrap_path.read_text(encoding="utf-8"), "SHELL_VERSION")
    worker = normalize_version(worker_path.read_text(encoding="utf-8"), "BUILD_VERSION")
    # Derive a repeatable release identity before stamping the bootstrap itself.
    identity = hashlib.sha256(b"quran-haven-offline-shell-policy-v1\n")
    identity.update(worker.encode())
    for name, path in files:
        data = bootstrap.encode() if name == "flutter_bootstrap.js" else path.read_bytes()
        identity.update(name.encode() + b"\0" + hashlib.sha256(data).digest())
    version = identity.hexdigest()
    stamped_bootstrap = bootstrap.replace(TOKEN, version)
    stamped_worker = worker.replace(TOKEN, version)
    entries = []
    for name, path in files:
        data = stamped_bootstrap.encode() if name == "flutter_bootstrap.js" else path.read_bytes()
        if not data or len(data) > MAX_FILE_BYTES:
            raise ValueError("An offline asset is empty or exceeds the individual size limit")
        entries.append({"path": "/" + quote(name, safe="/-._~"), "bytes": len(data),
                        "sha256": hashlib.sha256(data).hexdigest()})
    total = sum(entry["bytes"] for entry in entries)
    if total > MAX_TOTAL_BYTES:
        raise ValueError("The offline shell exceeds the 160 MiB budget")
    result = {"schemaVersion": 1, "version": version, "totalBytes": total, "files": entries}
    # These are generated build artifacts, never application sources.
    bootstrap_path.write_text(stamped_bootstrap, encoding="utf-8", newline="\n")
    worker_path.write_text(stamped_worker, encoding="utf-8", newline="\n")
    # Serve this exact-byte copy as application/octet-stream. HTML-aware CDN
    # features may inject markup into index.html; the manifest still hashes the
    # original index and the worker stores these verified bytes under that key.
    # This transport alias is deliberately not a separate offline cache entry.
    offline_index_path.write_bytes((root / "index.html").read_bytes())
    (root / "offline-manifest.json").write_text(
        json.dumps(result, ensure_ascii=True, separators=(",", ":")) + "\n", encoding="utf-8", newline="\n")
    return result


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--web-root", type=Path, required=True)
    args = parser.parse_args()
    try:
        result = generate(args.web_root)
        print(f"Prepared offline manifest: {len(result['files'])} files, {result['totalBytes']} bytes, release {result['version'][:12]}.")
        return 0
    except (OSError, ValueError) as error:
        print(f"Offline manifest failed: {error}")
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
