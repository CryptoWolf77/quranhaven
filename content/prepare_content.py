"""Prepare and verify the Quran content mirror without modifying source texts.

Uses only Python's standard library. Run with --prepare-only while additional
downloads are in progress, then run again to create the complete manifest.
Optional download provenance is read from provenance/optional-downloads.json,
produced by download_optional.py. Additional named resources can be recorded in
provenance/downloads.json as {"files": {"path": {"source_url": "https://..."}}}.
"""

from __future__ import annotations

import argparse
import gzip
import hashlib
import json
import re
import shutil
import stat
import sys
import zipfile
from datetime import datetime, timezone
from pathlib import Path, PurePosixPath
from urllib.parse import quote


PORTAL_URL = "https://qurancomplex.gov.sa/quran-dev/"
DOWNLOAD_ROOT = "https://download.qurancomplex.gov.sa/resources_dev/"
OFFICIAL_FILES = (
    "UthmanicHafs_v2-0.zip",
    "kfgqpc_hafs_smart_4.zip",
    "hafs_tafseerMouaser_v3.zip",
    "MuyassarGhareeb.docx",
    "Tajweed_Muyassar.docx",
)
OFFICIAL_JSONS = (
    "UthmanicHafs_v2-0/UthmanicHafs_v2-0 data/hafsData_v2-0.json",
    "kfgqpc_hafs_smart_4/kfgqpc_hafs_smart_data/hafs_smart_v8.json",
)
PUBLIC_OFFICIAL_SUFFIXES = {".json", ".csv", ".ttf", ".otf", ".me"}
FONT_SIGNATURES = {b"\x00\x01\x00\x00", b"OTTO", b"true", b"ttcf"}
DERIVED_ARCHIVES = {
    "word-info/word_qeraat/": "word_qeraat.zip",
    "word-info/word_tasreef/": "word_tasreef.zip",
    "word-info/word_eerab/": "word_eerab.zip",
    "word-info/meaning-word-oldv/": "meaning-word-oldv.json.zip",
    "tajweed/": "tajweed_aya.zip",
}


class ContentError(ValueError):
    """An input or published content integrity check failed."""


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def load_json(path: Path):
    opener = gzip.open if path.suffix == ".gz" else open
    with opener(path, "rt", encoding="utf-8-sig") as stream:
        return json.load(stream)


def safe_path(root: Path, relative: str) -> Path:
    """Reject POSIX/Windows traversal, drives, ADS, and symlink escapes."""
    normalized = relative.replace("\\", "/")
    parts = PurePosixPath(normalized).parts
    if root.is_symlink() or not parts or normalized.startswith("/") or any(
        part in {".", ".."} or ":" in part or part.endswith((" ", "."))
        for part in parts
    ):
        raise ContentError(f"Unsafe relative path: {relative!r}")
    candidate = root.joinpath(*parts)
    root_resolved = root.resolve()
    if not candidate.resolve().is_relative_to(root_resolved):
        raise ContentError(f"Path escapes target directory: {relative!r}")
    # Existing symlinks must not be followed even when they remain inside root.
    current = root
    for part in parts:
        current = current / part
        if current.is_symlink():
            raise ContentError(f"Symlink is not allowed: {current}")
    return candidate


def regular_files(root: Path) -> list[Path]:
    if not root.is_dir() or root.is_symlink():
        raise ContentError(f"Expected a regular directory: {root}")
    paths = []
    for path in root.rglob("*"):
        if path.is_symlink():
            raise ContentError(f"Symlink is not allowed: {path}")
        if path.is_file():
            paths.append(path)
    return sorted(paths)


def copy_exact(source: Path, destination: Path) -> None:
    if source.is_symlink() or not source.is_file():
        raise ContentError(f"Expected a regular source file: {source}")
    if destination.exists() and sha256(source) == sha256(destination):
        return
    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(source, destination)
    if sha256(source) != sha256(destination):
        raise ContentError(f"Copy checksum mismatch: {destination}")


def check_zip(archive: Path) -> None:
    with zipfile.ZipFile(archive) as bundle:
        seen = set()
        for entry in bundle.infolist():
            safe_path(Path("archive_validation"), entry.filename)
            key = entry.filename.replace("\\", "/").rstrip("/").casefold()
            if key in seen:
                raise ContentError(f"Duplicate ZIP member: {entry.filename}")
            seen.add(key)
            if stat.S_ISLNK(entry.external_attr >> 16):
                raise ContentError(f"ZIP symlink is not allowed: {entry.filename}")
            if entry.flag_bits & 1:
                raise ContentError(f"Encrypted ZIP member: {entry.filename}")
        corrupt = bundle.testzip()
        if corrupt:
            raise ContentError(f"Corrupt ZIP member in {archive.name}: {corrupt}")


def extract_safe(archive: Path, destination: Path) -> None:
    check_zip(archive)
    destination.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(archive) as bundle:
        for entry in bundle.infolist():
            target = safe_path(destination, entry.filename)
            if entry.is_dir():
                target.mkdir(parents=True, exist_ok=True)
                continue
            target.parent.mkdir(parents=True, exist_ok=True)
            with bundle.open(entry) as source, target.open("wb") as output:
                shutil.copyfileobj(source, output)


def validate_verses(rows: list, label: str) -> set[tuple[int, int]]:
    if not isinstance(rows, list) or len(rows) != 6236:
        raise ContentError(f"{label}: expected exactly 6,236 Ayahs")
    pairs = set()
    ids = set()
    surahs: dict[int, set[int]] = {}
    for row in rows:
        if not isinstance(row, dict):
            raise ContentError(f"{label}: invalid Ayah record")
        surah = int(row["sura_no"])
        ayah = int(row["aya_no"])
        number = int(row["id"])
        if not 1 <= surah <= 114 or ayah < 1:
            raise ContentError(f"{label}: invalid Surah/Ayah number")
        if not row.get("aya_text") or not 1 <= int(row["page"]) <= 604:
            raise ContentError(f"{label}: missing text or invalid page")
        if (surah, ayah) in pairs or number in ids:
            raise ContentError(f"{label}: duplicate Ayah")
        pairs.add((surah, ayah))
        ids.add(number)
        surahs.setdefault(surah, set()).add(ayah)
    if set(surahs) != set(range(1, 115)) or ids != set(range(1, 6237)):
        raise ContentError(f"{label}: incomplete Surah or Ayah IDs")
    if any(numbers != set(range(1, max(numbers) + 1)) for numbers in surahs.values()):
        raise ContentError(f"{label}: non-contiguous Ayah numbers")
    return pairs


def validate_official(root: Path) -> set[tuple[int, int]]:
    validated = [validate_verses(load_json(root / name), name) for name in OFFICIAL_JSONS]
    if validated[0] != validated[1]:
        raise ContentError("The two official Quran JSONs disagree on Ayah numbering")
    return validated[0]


def validate_core(root: Path, expected: set[tuple[int, int]]) -> dict:
    data = load_json(root / "assets/jsons/quranV4.json.gz")["data"]["surahs"]
    if len(data) != 114:
        raise ContentError("Bundled Quran must contain 114 Surahs")
    rows = [
        {"sura_no": surah["number"], "aya_no": ayah["numberInSurah"],
         "id": ayah["number"], "aya_text": ayah["text"], "page": ayah["page"]}
        for surah in data for ayah in surah["ayahs"]
    ]
    if validate_verses(rows, "Bundled Quran") != expected:
        raise ContentError("Bundled and official Quran Ayah numbering disagree")
    names = load_json(root / "assets/jsons/surahs_name.json.gz")["data"]["surahs"]
    if len(names) != 114 or {int(row["number"]) for row in names} != set(range(1, 115)):
        raise ContentError("Bundled Surah index is incomplete")
    font_root = root / "assets/fonts/quran_fonts_qfc4"
    page_fonts = regular_files(font_root)
    expected_fonts = {f"QCF4{page:03d}_COLOR-Regular.ttf.gz" for page in range(1, 605)}
    if {path.name for path in page_fonts} != expected_fonts:
        raise ContentError("Expected exactly 604 QCF4 page fonts")
    font_count = 0
    for path in regular_files(root / "assets/fonts"):
        if path.name.endswith(".ttf.gz"):
            data = gzip.decompress(path.read_bytes())
        elif path.suffix in {".ttf", ".otf"}:
            data = path.read_bytes()
        else:
            continue
        if len(data) < 12 or data[:4] not in FONT_SIGNATURES:
            raise ContentError(f"Invalid font: {path}")
        font_count += 1
    # Decompression/JSON decoding validates the remaining compressed datasets.
    for path in regular_files(root / "assets"):
        if path.name.endswith(".json.gz"):
            load_json(path)
    return {"surahs": 114, "ayahs": 6236, "mushaf_pages": 604,
            "page_fonts": 604, "total_fonts": font_count}


def package_version(package: Path) -> str:
    text = (package / "pubspec.yaml").read_text(encoding="utf-8")
    match = re.search(r"^version:\s*([^\s#]+)", text, re.MULTILINE)
    if not match:
        raise ContentError("Cannot read quran_library version from pubspec.yaml")
    return match.group(1).strip("\"'")


def archive_records(root: Path) -> list[dict]:
    records = []
    for name in OFFICIAL_FILES:
        path = root / "upstream" / name
        if not path.is_file() or path.is_symlink():
            raise ContentError(f"Missing official original: {path}")
        check_zip(path)  # DOCX is also a ZIP container.
        records.append({"path": f"upstream/{name}", "bytes": path.stat().st_size,
                        "sha256": sha256(path), "source_url": DOWNLOAD_ROOT + name,
                        "portal_url": PORTAL_URL, "retrieval_date": "2026-09-07"})
    return records


def read_provenance(root: Path, required: bool = True) -> dict:
    entries = {}
    optional_path = root / "provenance/optional-downloads.json"
    if required and not optional_path.is_file():
        raise ContentError("Optional download provenance is required before finalizing")
    if optional_path.exists():
        optional = load_json(optional_path)
        if optional.get("failures"):
            raise ContentError("Optional downloads have failures; resume them before finalizing")
        if len(optional.get("files", [])) != 49:
            raise ContentError("Expected provenance for 44 Tafsir/translation files and 5 ZIP archives")
        if len({row["path"] for row in optional["files"]}) != 49:
            raise ContentError("Duplicate optional download provenance records")
        for row in optional["files"]:
            path = safe_path(root / "public/v1", row["path"])
            if not path.is_file() or sha256(path) != row["sha256"] or path.stat().st_size != row["bytes"]:
                raise ContentError(f"Optional download provenance mismatch: {row['path']}")
            entries[row["path"]] = {"source_url": row["source"],
                                    "version": optional["package_version"],
                                    "retrieved_at": optional["retrieved_at"]}
            if row["source"].startswith("quran_library:"):
                entries[row["path"]].update({"kind": "quran_library_bundled_asset",
                                              "package": "quran_library",
                                              "package_version": optional["package_version"]})
        for prefix, archive in DERIVED_ARCHIVES.items():
            archive_relative = f"archives/{archive}"
            source = entries.get(archive_relative)
            if source is None:
                raise ContentError(f"Missing optional source archive record: {archive_relative}")
            archive_hash = sha256(root / "public/v1" / archive_relative)
            with zipfile.ZipFile(root / "public/v1" / archive_relative) as bundle:
                members = {}
                for entry in bundle.infolist():
                    name = PurePosixPath(entry.filename.replace("\\", "/")).name
                    if not name.endswith(".json"):
                        continue
                    if name in members:
                        raise ContentError(f"Ambiguous derived member in {archive}: {name}")
                    members[name] = entry
                for path in regular_files(root / "public/v1" / prefix):
                    entry = members.get(path.name)
                    if entry is None or hashlib.sha256(bundle.read(entry)).hexdigest() != sha256(path):
                        raise ContentError(f"Derived JSON differs from original archive: {path}")
                    entries[path.relative_to(root / "public/v1").as_posix()] = {
                        **source, "kind": "archive_member", "archive_path": archive_relative,
                        "archive_sha256": archive_hash,
                        "archive_member": entry.filename,
                    }
    path = root / "provenance/downloads.json"
    if not path.exists():
        return entries
    value = load_json(path)
    additional = value.get("files", value)
    if not isinstance(additional, dict):
        raise ContentError("Download provenance must be an object keyed by public/v1 paths")
    entries.update(additional)
    return entries


def validate_optional(public: Path) -> dict:
    tafsir = regular_files(public / "tafsir")
    if len(tafsir) != 44 or any(not path.name.endswith(".json.gz") for path in tafsir):
        raise ContentError("Expected exactly 44 compressed Tafsir/translation JSON resources")
    for path in tafsir:
        data = load_json(path)
        if not isinstance(data, (dict, list)) or not data:
            raise ContentError(f"Empty or invalid Tafsir/translation dataset: {path.name}")
    archives = regular_files(public / "archives")
    if {path.name for path in archives} != set(DERIVED_ARCHIVES.values()):
        raise ContentError("Expected exactly the five word-information/Tajweed ZIP archives")
    for path in archives:
        check_zip(path)
    web_count = 0
    for prefix in DERIVED_ARCHIVES:
        files = regular_files(public / prefix)
        expected = ({"meaning-word-oldv.json"} if "meaning-word-oldv" in prefix else
                    {f"sura_{number:03d}.json" for number in range(1, 115)})
        if {path.name for path in files} != expected:
            raise ContentError(f"Incomplete derived web JSON inventory: {prefix}")
        for path in files:
            load_json(path)
        web_count += len(files)
    if web_count != 457:
        raise ContentError("Expected exactly 457 derived web JSON resources")
    return {"tafsir_translations": 44, "optional_archives": 5, "web_json_resources": 457}


def write_manifest(root: Path, version: str, originals: list[dict], checks: dict) -> dict:
    public = root / "public/v1"
    supplied = read_provenance(root)
    checks = {**checks, **validate_optional(public)}
    optional = load_json(root / "provenance/optional-downloads.json")
    files = []
    for path in regular_files(public):
        relative = path.relative_to(public).as_posix()
        if relative == "manifest.json":
            continue
        if relative.startswith("core/"):
            provenance = {"kind": "quran_library_bundled_asset", "package": "quran_library",
                          "package_version": version,
                          "package_path": relative.removeprefix("core/"),
                          "source_url": "https://pub.dev/packages/quran_library/versions/" + version}
        elif relative.startswith("official/"):
            archive = relative.split("/", 2)[1] + ".zip"
            provenance = {"kind": "official_portal_archive", "archive": f"upstream/{archive}",
                          "source_url": DOWNLOAD_ROOT + archive, "portal_url": PORTAL_URL}
        else:
            provenance = supplied.get(relative)
            if not isinstance(provenance, dict) or not provenance.get("source_url"):
                raise ContentError(f"Missing source_url provenance for optional file: {relative}")
            provenance = {"kind": "downloaded_resource", **provenance}
        files.append({"path": relative, "url": "/v1/" + quote(relative, safe="/"),
                      "bytes": path.stat().st_size, "sha256": sha256(path),
                      "version": version if relative.startswith("core/") else provenance.get("version", "1"),
                      "provenance": provenance})
    manifest = {"schema_version": 1, "content_version": "v1",
                "generated_at": datetime.now(timezone.utc).isoformat(),
                "package": {"name": "quran_library", "version": version},
                "validation": checks, "original_archives": originals,
                "unavailable": optional.get("unavailable", []), "files": files}
    (public / "manifest.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return manifest


def verify_manifest(root: Path, public_only: bool = False) -> dict:
    public = root / "public/v1"
    manifest = load_json(public / "manifest.json")
    if manifest.get("schema_version") != 1:
        raise ContentError("Unsupported content manifest schema")
    expected = {}
    for record in manifest["files"]:
        relative = record["path"]
        if relative in expected or relative == "manifest.json":
            raise ContentError(f"Duplicate or invalid manifest entry: {relative}")
        expected[relative] = record
        path = safe_path(public, relative)
        if not path.is_file():
            raise ContentError(f"Missing published file: {relative}")
        if path.stat().st_size != record["bytes"] or sha256(path) != record["sha256"]:
            raise ContentError(f"Published file integrity mismatch: {relative}")
    actual = {path.relative_to(public).as_posix() for path in regular_files(public)} - {"manifest.json"}
    if actual != set(expected):
        raise ContentError(f"Unmanifested published files: {sorted(actual - set(expected))}")
    if not public_only:
        current = archive_records(root)
        if current != manifest["original_archives"]:
            raise ContentError("Official originals no longer match the manifest")
        read_provenance(root)
    verses = validate_official(public / "official")
    checks = {**validate_core(public / "core", verses), **validate_optional(public)}
    for name in ("LICENSE", "NOTICE"):
        if not (public / "core" / name).is_file():
            raise ContentError(f"Missing package attribution: core/{name}")
    if checks != manifest["validation"]:
        raise ContentError("Core content validation differs from the manifest")
    return manifest


def prepare(root: Path, package: Path, prepare_only: bool = False) -> dict:
    originals = archive_records(root)
    version = package_version(package)
    official = root / "official"
    public = root / "public/v1"
    for name in OFFICIAL_FILES:
        if not name.endswith(".zip"):
            continue
        archive_dir = Path(name).stem
        extract_safe(root / "upstream" / name, official / archive_dir)
    verses = validate_official(official)
    for path in regular_files(official):
        if path.suffix.lower() in PUBLIC_OFFICIAL_SUFFIXES or path.name.lower().startswith("readme"):
            relative = path.relative_to(official).as_posix()
            copy_exact(path, safe_path(public / "official", relative))
    source_assets = regular_files(package / "assets") + [package / "LICENSE", package / "NOTICE"]
    for path in source_assets:
        relative = path.relative_to(package).as_posix()
        copy_exact(path, safe_path(public / "core", relative))
    expected_assets = {path.relative_to(package).as_posix() for path in source_assets}
    mirrored_assets = {path.relative_to(public / "core").as_posix() for path in regular_files(public / "core")}
    if expected_assets != mirrored_assets:
        raise ContentError(f"Stale files in core mirror: {sorted(mirrored_assets - expected_assets)}")
    checks = validate_core(public / "core", verses)
    if prepare_only:
        return {"prepared": True, "manifest_written": False, "validation": checks,
                "original_archives": originals}
    return write_manifest(root, version, originals, checks)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parent)
    parser.add_argument("--package", type=Path, help="Exact quran_library package directory")
    parser.add_argument("--prepare-only", action="store_true", help="Prepare core/official files without finalizing a manifest")
    parser.add_argument("--verify", action="store_true", help="Verify existing manifest; make no writes")
    parser.add_argument("--public-only", action="store_true", help="With --verify, validate only public/ for a container build")
    args = parser.parse_args()
    try:
        if args.verify:
            if args.prepare_only:
                parser.error("--verify and --prepare-only cannot be combined")
            result = verify_manifest(args.root.resolve(), args.public_only)
        else:
            if args.public_only:
                parser.error("--public-only is only valid with --verify")
            if args.package is None:
                parser.error("--package is required when preparing content")
            result = prepare(args.root.resolve(), args.package.resolve(), args.prepare_only)
        summary = {"ok": True, "mode": "verify" if args.verify else "prepare",
                   "files": len(result.get("files", [])), "validation": result["validation"],
                   "published_bytes": sum(row["bytes"] for row in result.get("files", [])),
                   "unavailable": result.get("unavailable", []),
                   "original_archives": result["original_archives"]}
        print(json.dumps(summary, ensure_ascii=True, indent=2))
        return 0
    except (ContentError, OSError, ValueError, KeyError, TypeError, zipfile.BadZipFile) as error:
        print(f"Content preparation failed: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
