"""Read-only pixel/format checks for the committed Quran Haven artwork."""

from __future__ import annotations

import argparse
import json
import math
from pathlib import Path
import xml.etree.ElementTree as ET

from PIL import Image


def inspect(path: Path, expected: tuple[int, int], mode: str):
    with Image.open(path) as image:
        assert image.format == "PNG", path
        assert image.size == expected, (path, image.size, expected)
        assert image.mode == mode, (path, image.mode, mode)
        assert image.info.get("srgb") == 0, (path, "missing sRGB declaration")
        alpha = image.getchannel("A").getextrema() if mode == "RGBA" else None
    return {"path": str(path), "size": list(expected), "mode": mode,
            "bytes": path.stat().st_size, "alpha": alpha}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[2])
    root = parser.parse_args().root.resolve()
    records = []
    adaptive = []
    for density, size in (("mdpi", 48), ("hdpi", 72), ("xhdpi", 96),
                          ("xxhdpi", 144), ("xxxhdpi", 192)):
        folder = root / f"android/app/src/main/res/mipmap-{density}"
        records.append(inspect(folder / "ic_launcher.png", (size, size), "RGBA"))
        n = round(size * 108 / 48)
        path = folder / "ic_launcher_foreground.png"
        records.append(inspect(path, (n, n), "RGBA"))
        with Image.open(path) as image:
            visible = [(x, y) for y in range(n) for x in range(n)
                       if image.getpixel((x, y))[3] > 0]
            max_radius = max(math.hypot(x - n / 2, y - n / 2) for x, y in visible)
            safe_radius = n * 33 / 108
            assert max_radius < safe_radius, (path, max_radius, safe_radius)
            adaptive.append({"density": density, "safeRadius": safe_radius,
                             "artworkRadius": round(max_radius, 2)})

    namespace = "{http://schemas.android.com/apk/res/android}drawable"
    xml = root / "android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml"
    tree = ET.parse(xml).getroot()
    assert tree.tag == "adaptive-icon"
    assert tree.find("background").get(namespace) == "@color/quran_haven_launcher_background"
    assert tree.find("foreground").get(namespace) == "@mipmap/ic_launcher_foreground"
    colors = ET.parse(root / "android/app/src/main/res/values/quran_haven_launcher.xml")
    assert colors.find("color").text == "#146e5c"

    catalog = root / "ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json"
    unique_ios = set()
    for entry in json.loads(catalog.read_text(encoding="utf-8"))["images"]:
        path = catalog.parent / entry["filename"]
        size = round(float(entry["size"].split("x")[0]) * int(entry["scale"][0]))
        result = inspect(path, (size, size), "RGB")
        if path not in unique_ios:
            records.append(result)
            unique_ios.add(path)

    for size in (192, 512):
        for prefix in ("Icon-", "Icon-maskable-"):
            records.append(inspect(root / f"web/icons/{prefix}{size}.png", (size, size), "RGB"))
    records.append(inspect(root / "web/favicon.png", (32, 32), "RGBA"))
    records.append(inspect(root / "assets/brand/app-icon-1024.png", (1024, 1024), "RGB"))
    store = inspect(root / "assets/brand/google-play-icon-512.png", (512, 512), "RGBA")
    assert store["alpha"] == (255, 255)
    assert store["bytes"] < 1024 * 1024
    records.append(store)
    records.append(inspect(root / "assets/brand/google-play-feature-1024x500.png", (1024, 500), "RGB"))
    print(json.dumps({"result": "PASS", "pngCount": len(records),
                      "uniqueIosImages": len(unique_ios), "adaptiveSafeZones": adaptive,
                      "storeIcon": store, "storeFeature": records[-1]}, indent=2))


if __name__ == "__main__":
    main()
