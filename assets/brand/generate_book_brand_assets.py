"""Mechanical platform exports from the immutable imagegen book master.

No logo drawing, background removal, painting or semantic edits. The original
chosen image and earlier qaf master remain unchanged.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont
from PIL.PngImagePlugin import PngInfo

MASTER_SHA256 = "01c29aafee831d03d79682a4aae67afd541a5323e0983ce3125f2df9b9152821"
PARCHMENT = "#f7f2e7"
INK = "#103f35"
EMERALD = "#146e5c"


def save(image: Image.Image, path: Path, mode: str = "RGB"):
    path.parent.mkdir(parents=True, exist_ok=True)
    profile = PngInfo()
    profile.add(b"sRGB", b"\x00")
    image.convert(mode).save(path, optimize=True, pnginfo=profile)


def icon(master: Image.Image, size: int):
    return master.resize((size, size), Image.Resampling.LANCZOS)


def feature(root: Path, master: Image.Image):
    """Presentation typography with the real source raster, not a new mark."""
    scale = 3
    image = Image.new("RGB", (1024 * scale, 500 * scale), PARCHMENT)
    draw = ImageDraw.Draw(image)
    fonts = root / "vendor/quran_library/assets/fonts"
    title = ImageFont.truetype(str(fonts / "Cairo-Bold.ttf"), 70 * scale)
    body = ImageFont.truetype(str(fonts / "Cairo-SemiBold.ttf"), 28 * scale)
    foot = ImageFont.truetype(str(fonts / "Cairo-SemiBold.ttf"), 23 * scale)
    draw.line([(72 * scale, 90 * scale), (134 * scale, 90 * scale)], fill=EMERALD, width=5 * scale)
    draw.text((72 * scale, 101 * scale), "Quran Haven", font=title, fill=INK)
    draw.text((75 * scale, 228 * scale), "Read · Listen · Learn", font=body, fill=EMERALD)
    draw.text((75 * scale, 342 * scale), "Your daily Quran journey", font=foot, fill=INK)
    # Keep the actual square master intact, with no clipping or fake device.
    rendered = icon(master, 292 * scale)
    image.paste(rendered, (661 * scale, 101 * scale))
    return image.resize((1024, 500), Image.Resampling.LANCZOS)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, required=True)
    parser.add_argument("--preview", type=Path)
    parser.add_argument("--write", action="store_true")
    args = parser.parse_args()
    root = args.root.resolve()
    master_path = root / "assets/brand/quran-haven-book-v2.png"
    assert hashlib.sha256(master_path.read_bytes()).hexdigest() == MASTER_SHA256, "Original source master changed"
    with Image.open(master_path) as source:
        assert source.size == (1254, 1254) and source.mode == "RGB"
        master = source.copy()

    if args.preview:
        args.preview.mkdir(parents=True, exist_ok=True)
        save(icon(master, 1024), args.preview / "book-v2-master-preview.png")
        save(feature(root, master), args.preview / "book-v2-feature-preview.png")
        grid = Image.new("RGB", (900, 290), PARCHMENT)
        draw = ImageDraw.Draw(grid)
        label = ImageFont.truetype(str(root / "vendor/quran_library/assets/fonts/Cairo-SemiBold.ttf"), 14)
        for size, x in ((24, 32), (32, 112), (48, 210), (96, 350), (192, 540)):
            grid.paste(icon(master, size), (x, 28))
            draw.text((x, 240), f"{size}px", font=label, fill=INK)
        save(grid, args.preview / "book-v2-small-preview.png")

    if not args.write:
        return
    outputs = []
    for density, size in (("mdpi", 48), ("hdpi", 72), ("xhdpi", 96), ("xxhdpi", 144), ("xxxhdpi", 192)):
        folder = root / f"android/app/src/main/res/mipmap-{density}"
        path = folder / "ic_launcher.png"
        save(icon(master, size), path)
        outputs.append(path)
        path = folder / "ic_launcher_foreground.png"
        # The image is deliberately opaque. Its entire emerald backdrop can be
        # masked, while the meaningful ivory/gold book already fits centrally
        # inside Android's 66dp circle on the 108dp source canvas.
        n = round(size * 108 / 48)
        save(icon(master, n), path)
        outputs.append(path)

    catalog = root / "ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json"
    for entry in json.loads(catalog.read_text(encoding="utf-8"))["images"]:
        n = round(float(entry["size"].split("x")[0]) * int(entry["scale"][0]))
        path = catalog.parent / entry["filename"]
        save(icon(master, n), path)
        if path not in outputs:
            outputs.append(path)

    for n in (192, 512):
        for prefix in ("Icon-", "Icon-maskable-"):
            path = root / f"web/icons/{prefix}{n}.png"
            save(icon(master, n), path)
            outputs.append(path)
    path = root / "web/favicon.png"
    save(icon(master, 32), path)
    outputs.append(path)
    for filename, image, mode in (
        ("quran-haven-book-v2-1024.png", icon(master, 1024), "RGB"),
        ("google-play-icon-512.png", icon(master, 512), "RGBA"),
        ("google-play-feature-1024x500.png", feature(root, master), "RGB"),
    ):
        path = root / "assets/brand" / filename
        save(image, path, mode)
        outputs.append(path)
    assert hashlib.sha256(master_path.read_bytes()).hexdigest() == MASTER_SHA256
    print(json.dumps({"result": "EXPORTED", "pngCount": len(outputs), "masterUnchanged": True,
                      "outputs": [p.relative_to(root).as_posix() for p in outputs]}, indent=2))


if __name__ == "__main__":
    main()
