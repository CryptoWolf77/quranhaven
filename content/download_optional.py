"""Preserve the exact optional text resources used by quran_library 4.2.1.

Audio is deliberately outside this metadata/text mirror. No Quran text is edited.
Requires curl on PATH; works on the Saudi-connected workstation and ordinary CI.
"""

import argparse
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import datetime, timezone
import gzip
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parent
PUBLIC = ROOT / "public" / "v1"
GH = "https://github.com/alheekmahlib/Islamic_database/releases/download"
GL = "https://gitlab.com/api/v4/projects/haozo89%2Fislamic_database/packages/generic"
ARCHIVES = {
    "word_qeraat.zip": ("word_qeraat", "word-info/word_qeraat"),
    "word_tasreef.zip": ("word_tasreef", "word-info/word_tasreef"),
    "word_eerab.zip": ("word_eerab", "word-info/word_eerab"),
    "meaning-word-oldv.json.zip": ("meaning-word-oldv.json.zip", "word-info/meaning-word-oldv"),
    "tajweed_aya.zip": ("tajweed_aya", "tajweed"),
}


def validate(path: Path) -> None:
    if path.name.endswith(".zip"):
        with zipfile.ZipFile(path) as archive:
            bad = archive.testzip()
            if bad:
                raise ValueError(f"Corrupt ZIP entry: {bad}")
    else:
        with gzip.open(path, "rt", encoding="utf-8-sig") as stream:
            data = json.load(stream)
        if not isinstance(data, (dict, list)) or not data:
            raise ValueError(f"Empty/invalid JSON in {path.name}")


def fetch(path: Path, urls: list[str], bundled: Path | None = None) -> dict:
    path.parent.mkdir(parents=True, exist_ok=True)
    source = urls[0]
    if path.is_file():
        validate(path)
    elif bundled is not None and bundled.is_file():
        shutil.copyfile(bundled, path)
        source = "quran_library:4.2.1/assets/" + path.name
        validate(path)
    else:
        part = path.with_name(path.stem + ".part" + path.suffix)
        failures = []
        for url in urls:
            result = subprocess.run(
                ["curl.exe" if __import__("os").name == "nt" else "curl",
                 "-fsSL", "--retry", "2", "--connect-timeout", "20",
                 "--max-time", "600", "--output", str(part), url],
                capture_output=True, text=True, check=False,
            )
            try:
                if result.returncode:
                    raise RuntimeError(result.stderr.strip())
                validate(part)
                part.replace(path)
                source = url
                break
            except Exception as error:
                failures.append(f"{url}: {error}")
        else:
            raise RuntimeError("\n".join(failures))
    return {"path": path.relative_to(PUBLIC).as_posix(), "source": source,
            "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
            "bytes": path.stat().st_size}


def prepare_web_json() -> None:
    for filename, (_, directory) in ARCHIVES.items():
        target = PUBLIC / directory
        target.mkdir(parents=True, exist_ok=True)
        found = set()
        with zipfile.ZipFile(PUBLIC / "archives" / filename) as archive:
            for info in archive.infolist():
                name = Path(info.filename.replace("\\", "/")).name
                wanted = bool(re.fullmatch(r"sura_\d{3}\.json", name))
                if filename == "meaning-word-oldv.json.zip":
                    wanted = name == "meaning-word-oldv.json"
                if not wanted:
                    continue
                if name in found:
                    raise ValueError(f"Duplicate resource {name} in {filename}")
                raw = archive.read(info)
                json.loads(raw.decode("utf-8-sig"))
                (target / name).write_bytes(raw)
                found.add(name)
        expected = ({"meaning-word-oldv.json"} if filename == "meaning-word-oldv.json.zip"
                    else {f"sura_{s:03}.json" for s in range(1, 115)})
        if found != expected:
            raise ValueError(f"Unexpected JSON inventory in {filename}: missing={expected-found}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--package", type=Path, default=ROOT.parent / "vendor" / "quran_library")
    parser.add_argument("--workers", type=int, default=4)
    args = parser.parse_args()
    source = args.package / "lib/src/tafsir/core/data/models/tafsir_and_translate_names.dart"
    filenames = sorted(set(re.findall(r"databaseName: '([^']+\.json\.gz)'", source.read_text(encoding="utf-8"))))
    filenames = [name for name in filenames if name != 'in-tafsir-jalalayn.json.gz']
    if len(filenames) != 44:
        raise ValueError(f"Expected 44 available resources, found {len(filenames)}")
    jobs = [(PUBLIC / "tafsir" / f, [f"{GH}/tafsir_and_translate/{f}",
             f"{GL}/tafsir_and_translate/1.0.0/{f}"], args.package / "assets" / f)
            for f in filenames]
    jobs += [(PUBLIC / "archives" / f, [f"{GH}/{tag}/{f}", f"{GL}/{tag}/1.0.0/{f}"], None)
             for f, (tag, _) in ARCHIVES.items()]
    records, failures = [], []
    with ThreadPoolExecutor(max_workers=args.workers) as pool:
        pending = {pool.submit(fetch, *job): job[0].name for job in jobs}
        for future in as_completed(pending):
            try:
                record = future.result()
                records.append(record)
                print(f"Verified {record['path']} ({record['bytes']:,} bytes)", flush=True)
            except Exception as error:
                failures.append(f"{pending[future]}: {error}")
                print(f"FAILED {failures[-1]}", flush=True)
    provenance = ROOT / "provenance" / "optional-downloads.json"
    existing = json.loads(provenance.read_text(encoding="utf-8")) if provenance.is_file() else {}
    old_records = {row["path"]: row for row in existing.get("files", [])}
    for row in records:
        old = old_records.get(row["path"])
        if old and old["sha256"] == row["sha256"]:
            row["source"] = old["source"]
    provenance.write_text(json.dumps({"retrieved_at": datetime.now(timezone.utc).isoformat(),
        "package_version": "4.2.1", "files": sorted(records, key=lambda r:r["path"]),
        "unavailable": [{"path": "tafsir/in-tafsir-jalalayn.json.gz",
            "reason": "Not published in the upstream release or source tree; both release hosts return 404. Removed from the app catalog; no substitute used."}],
        "failures": failures}, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    if failures:
        raise SystemExit(f"{len(failures)} resource downloads failed; rerun to resume.")
    prepare_web_json()
    print(f"Complete: {len(records)} verified downloads and 457 web JSON resources.")


if __name__ == "__main__":
    main()
