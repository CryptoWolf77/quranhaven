"""Read-only format, provenance and meaningful-book safe-zone checks."""
from __future__ import annotations

import argparse
import hashlib
import json
import math
from pathlib import Path
import xml.etree.ElementTree as ET

from PIL import Image

MASTER_SHA256 = "01c29aafee831d03d79682a4aae67afd541a5323e0983ce3125f2df9b9152821"


def inspect(path: Path, size: tuple[int, int], mode: str):
    with Image.open(path) as image:
        assert image.format == "PNG" and image.size == size and image.mode == mode, path
        assert image.info.get("srgb") == 0, (path, "sRGB missing")
        if mode == "RGBA":
            assert image.getchannel("A").getextrema() == (255, 255), path
    return {"path": str(path), "size": list(size), "mode": mode, "bytes": path.stat().st_size}


def book_radius(path: Path):
    # Inspection only: the returned image's gold/ivory book has R>80; the
    # emerald backdrop has much lower red. This never edits/extracts pixels.
    with Image.open(path) as raw:
        image = raw.convert("RGB")
        n = image.width
        points = [(x, y) for y in range(n) for x in range(n) if image.getpixel((x, y))[0] > 80]
        assert points, path
        return max(math.hypot(x - n / 2, y - n / 2) for x, y in points), n


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[2])
    root = parser.parse_args().root.resolve()
    master = root / "assets/brand/quran-haven-book-v2.png"
    assert hashlib.sha256(master.read_bytes()).hexdigest() == MASTER_SHA256
    metadata = json.loads((root / "assets/brand/quran-haven-book-v2.source.json").read_text(encoding="utf-8"))
    assert metadata["output"]["sha256"] == MASTER_SHA256
    assert (root / "assets/brand/app-icon-1024.png").exists(), "Prior master was removed"
    radius, n = book_radius(master)
    assert radius < n * 33 / 108
    rows = []
    zones = []
    for density, size in (("mdpi", 48), ("hdpi", 72), ("xhdpi", 96), ("xxhdpi", 144), ("xxxhdpi", 192)):
        folder = root / f"android/app/src/main/res/mipmap-{density}"
        rows.append(inspect(folder / "ic_launcher.png", (size, size), "RGB"))
        n = round(size * 108 / 48)
        foreground = folder / "ic_launcher_foreground.png"
        rows.append(inspect(foreground, (n, n), "RGB"))
        r, _ = book_radius(foreground)
        safe = n * 33 / 108
        assert r < safe, (foreground, r, safe)
        zones.append({"density": density, "bookRadius": round(r, 2), "safeRadius": safe})
    namespace = "{http://schemas.android.com/apk/res/android}drawable"
    adaptive = ET.parse(root / "android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml").getroot()
    assert adaptive.find("background").get(namespace) == "@color/quran_haven_launcher_background"
    assert adaptive.find("foreground").get(namespace) == "@mipmap/ic_launcher_foreground"

    catalog = root / "ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json"
    ios = set()
    for entry in json.loads(catalog.read_text(encoding="utf-8"))["images"]:
        n = round(float(entry["size"].split("x")[0]) * int(entry["scale"][0]))
        path = catalog.parent / entry["filename"]
        result = inspect(path, (n, n), "RGB")
        if path not in ios:
            rows.append(result)
            ios.add(path)

    for n in (192, 512):
        for prefix in ("Icon-", "Icon-maskable-"):
            path = root / f"web/icons/{prefix}{n}.png"
            rows.append(inspect(path, (n, n), "RGB"))
            if "maskable" in prefix:
                r, _ = book_radius(path)
                assert r < n * .4, (path, "Maskable safe zone exceeded")
    rows.append(inspect(root / "web/favicon.png", (32, 32), "RGB"))
    rows.append(inspect(root / "assets/brand/quran-haven-book-v2-1024.png", (1024, 1024), "RGB"))
    store = inspect(root / "assets/brand/google-play-icon-512.png", (512, 512), "RGBA")
    assert store["bytes"] < 1024 * 1024
    rows.append(store)
    banner = inspect(root / "assets/brand/google-play-feature-1024x500.png", (1024, 500), "RGB")
    rows.append(banner)
    print(json.dumps({"result": "PASS", "pngCount": len(rows), "uniqueIos": len(ios),
                      "masterUnchanged": True, "adaptiveSafeZones": zones,
                      "playIcon": store, "featureGraphic": banner}, indent=2))


if __name__ == "__main__":
    main()
