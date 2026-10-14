"""Read-only APK/AAB native-library alignment audit; does not inspect keys."""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import struct
import zipfile


def elf_alignment(data: bytes) -> dict:
    if data[:4] != b"\x7fELF" or len(data) < 64 or data[5] not in (1, 2):
        raise ValueError("Invalid ELF library")
    endian = "<" if data[5] == 1 else ">"
    bits = data[4]
    if bits == 2:
        offset = struct.unpack_from(endian + "Q", data, 32)[0]
        entry_size, count = struct.unpack_from(endian + "HH", data, 54)
        layout = endian + "IIQQQQQQ"
    elif bits == 1:
        offset = struct.unpack_from(endian + "I", data, 28)[0]
        entry_size, count = struct.unpack_from(endian + "HH", data, 42)
        layout = endian + "IIIIIIII"
    else:
        raise ValueError("Unsupported ELF class")
    if entry_size < struct.calcsize(layout) or offset + count * entry_size > len(data):
        raise ValueError("Truncated ELF program headers")
    loads = []
    for index in range(count):
        fields = struct.unpack_from(layout, data, offset + index * entry_size)
        if fields[0] != 1:  # PT_LOAD
            continue
        file_offset, address, alignment = (fields[2], fields[3], fields[7]) if bits == 2 else (fields[1], fields[2], fields[7])
        loads.append({"alignment": alignment,
                      "compatible16KiB": alignment >= 16384 and (address - file_offset) % 16384 == 0})
    if not loads:
        raise ValueError("ELF has no loadable segments")
    return {"bits": 64 if bits == 2 else 32,
            "minimumLoadAlignment": min(item["alignment"] for item in loads),
            "compatible16KiB": all(item["compatible16KiB"] for item in loads)}


def audit(path: Path) -> dict:
    path = path.resolve(strict=True)
    if path.suffix.lower() not in (".apk", ".aab"):
        raise ValueError("Provide an APK or Android app bundle")
    digest = hashlib.sha256()
    with path.open("rb") as artifact:
        for chunk in iter(lambda: artifact.read(1024 * 1024), b""):
            digest.update(chunk)
    libraries = []
    with zipfile.ZipFile(path) as archive:
        for entry in archive.infolist():
            parts = entry.filename.split("/")
            if not entry.filename.endswith(".so") or "lib" not in parts:
                continue
            libraries.append({"path": entry.filename,
                              **elf_alignment(archive.read(entry))})
    if not libraries:
        raise ValueError("Artifact contains no native libraries")
    compatible = all(item["bits"] != 64 or item["compatible16KiB"] for item in libraries)
    return {"artifact": str(path), "bytes": path.stat().st_size,
            "sha256": digest.hexdigest(), "nativeLibraries": libraries,
            "all64BitLibrariesCompatible16KiB": compatible,
            "note": "ELF audit only; APK ZIP alignment, signing and device tests are separate gates."}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("artifact", type=Path)
    args = parser.parse_args()
    try:
        result = audit(args.artifact)
        print(json.dumps(result, indent=2))
        return 0 if result["all64BitLibrariesCompatible16KiB"] else 1
    except (OSError, ValueError, zipfile.BadZipFile) as error:
        parser.error(str(error))
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
