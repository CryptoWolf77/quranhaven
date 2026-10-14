"""Render Quran Haven's own launcher/store artwork using the bundled Cairo font.

No external images, publisher logo, Quran verse or generated Quran lettering.
The single isolated qaf is the app's existing navigation monogram.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont
from PIL.PngImagePlugin import PngInfo

EMERALD = "#146e5c"
PARCHMENT = "#f7f2e7"
GOLD = "#d8c995"
INK = "#103f35"


def font(root: Path, size: int, weight: str = "Bold") -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(
        str(root / f"vendor/quran_library/assets/fonts/Cairo-{weight}.ttf"), size
    )


def bezier(points: list[tuple[float, float]], steps: int = 60):
    p0, p1, p2, p3 = points
    return [
        (
            (1 - t) ** 3 * p0[0] + 3 * (1 - t) ** 2 * t * p1[0]
            + 3 * (1 - t) * t ** 2 * p2[0] + t ** 3 * p3[0],
            (1 - t) ** 3 * p0[1] + 3 * (1 - t) ** 2 * t * p1[1]
            + 3 * (1 - t) * t ** 2 * p2[1] + t ** 3 * p3[1],
        )
        for t in (i / steps for i in range(steps + 1))
    ]


def symbol(root: Path, scale: int = 3) -> Image.Image:
    """1024-unit transparent artwork; all detail stays inside a central circle."""
    image = Image.new("RGBA", (1024 * scale, 1024 * scale))
    draw = ImageDraw.Draw(image)
    qaf = font(root, 440 * scale)
    box = qaf.getbbox("ق")
    x = (1024 * scale - (box[2] - box[0])) / 2 - box[0]
    y = 240 * scale - box[1]
    draw.text((x, y), "ق", font=qaf, fill=PARCHMENT)

    # A two-page open book, not a second letter: the shallow page curves share
    # one precise centre crease and remain legible at launcher size.
    paths = [
        [(285, 710), (367, 683), (433, 694), (512, 737)],
        [(512, 737), (591, 694), (657, 683), (739, 710)],
        [(285, 710), (285, 727), (285, 743), (285, 757)],
        [(285, 757), (365, 730), (431, 742), (512, 782)],
        [(512, 782), (593, 742), (659, 730), (739, 757)],
        [(739, 757), (739, 743), (739, 727), (739, 710)],
        [(512, 737), (512, 752), (512, 767), (512, 782)],
    ]
    width = 15 * scale
    for path in paths:
        points = [(x * scale, y * scale) for x, y in bezier(path)]
        draw.line(points, fill=GOLD, width=width, joint="curve")
        radius = width / 2
        # Round every subsegment joint so the sampled bezier has no hairline
        # seams after downsampling from the oversampled raster.
        for x, y in points:
            draw.ellipse((x - radius, y - radius, x + radius, y + radius), fill=GOLD)
    return image


def icon(root: Path, size: int, inset: float = 1.0, rounded: bool = False):
    art = symbol(root)
    background = Image.new("RGBA", art.size, EMERALD)
    if inset != 1.0:
        side = round(art.width * inset)
        art = art.resize((side, side), Image.Resampling.LANCZOS)
        background.alpha_composite(art, ((background.width - side) // 2,) * 2)
    else:
        background.alpha_composite(art)
    if rounded:
        mask = Image.new("L", background.size)
        ImageDraw.Draw(mask).rounded_rectangle(
            (0, 0, background.width - 1, background.height - 1),
            radius=background.width * 0.215, fill=255,
        )
        background.putalpha(mask)
    return background.resize((size, size), Image.Resampling.LANCZOS)


def feature(root: Path) -> Image.Image:
    scale = 3
    image = Image.new("RGB", (1024 * scale, 500 * scale), PARCHMENT)
    draw = ImageDraw.Draw(image)

    # A quiet architectural arch provides continuity with the reader's home
    # design. It is intentionally subordinate to the title and monogram.
    arch = [(670, 495), (670, 190), (855, 93), (1040, 190)]
    draw.line([(x * scale, y * scale) for x, y in bezier(arch)],
              fill="#e9e2d0", width=24 * scale)
    draw.line([(1040 * scale, 190 * scale), (1040 * scale, 495 * scale)],
              fill="#e9e2d0", width=24 * scale)
    draw.line([(72 * scale, 90 * scale), (134 * scale, 90 * scale)],
              fill=EMERALD, width=5 * scale)
    draw.text((72 * scale, 101 * scale), "Quran Haven", font=font(root, 70 * scale),
              fill=INK)
    draw.text((75 * scale, 228 * scale), "Read · Listen · Learn",
              font=font(root, 28 * scale, "SemiBold"), fill=EMERALD)
    draw.text((75 * scale, 342 * scale), "Your daily Quran journey",
              font=font(root, 23 * scale, "SemiBold"), fill=INK)
    mark = icon(root, 292 * scale, rounded=True)
    image.paste(mark, (661 * scale, 101 * scale), mark)
    return image.resize((1024, 500), Image.Resampling.LANCZOS)


def save(image: Image.Image, path: Path, opaque: bool = True):
    path.parent.mkdir(parents=True, exist_ok=True)
    if opaque:
        image = image.convert("RGB")
    profile = PngInfo()
    profile.add(b"sRGB", b"\x00")
    image.save(path, optimize=True, pnginfo=profile)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, required=True)
    parser.add_argument("--preview", type=Path)
    parser.add_argument("--write", action="store_true")
    args = parser.parse_args()
    root = args.root.resolve()
    if args.preview:
        args.preview.mkdir(parents=True, exist_ok=True)
        save(icon(root, 1024), args.preview / "quran-haven-icon-1024.png")
        save(feature(root), args.preview / "quran-haven-feature-1024x500.png")
        # Inspect the actual silhouette at several small pixel sizes, including
        # Android's adaptive foreground safe-zone and the 24px browser mark.
        grid = Image.new("RGB", (768, 250), PARCHMENT)
        draw = ImageDraw.Draw(grid)
        for size, x in ((24, 48), (48, 150), (96, 280), (192, 470)):
            im = icon(root, size, rounded=True)
            grid.paste(im, (x, 32), im)
            draw.text((x, 232), f"{size}px", fill=INK, font=font(root, 13))
        save(grid, args.preview / "quran-haven-icon-small-preview.png")
    if not args.write:
        return

    records = []
    outputs = []
    for density, size in (("mdpi", 48), ("hdpi", 72), ("xhdpi", 96),
                          ("xxhdpi", 144), ("xxxhdpi", 192)):
        path = root / f"android/app/src/main/res/mipmap-{density}/ic_launcher.png"
        save(icon(root, size, rounded=True), path, opaque=False)
        outputs.append(path)
        # 108dp artwork with the visible mark scaled into Android's 66dp central
        # safe zone. The launcher can crop only the solid background.
        foreground = symbol(root)
        side = round(foreground.width * 0.82)
        inset = foreground.resize((side, side), Image.Resampling.LANCZOS)
        canvas = Image.new("RGBA", foreground.size)
        canvas.alpha_composite(inset, ((canvas.width - side) // 2,) * 2)
        path = root / f"android/app/src/main/res/mipmap-{density}/ic_launcher_foreground.png"
        save(canvas.resize((round(size * 108 / 48),) * 2, Image.Resampling.LANCZOS),
             path, opaque=False)
        outputs.append(path)

    catalog = root / "ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json"
    for entry in json.loads(catalog.read_text(encoding="utf-8"))["images"]:
        size = round(float(entry["size"].split("x")[0]) * int(entry["scale"][0]))
        path = catalog.parent / entry["filename"]
        save(icon(root, size), path)
        if path not in outputs:
            outputs.append(path)

    for size in (192, 512):
        for prefix in ("Icon-", "Icon-maskable-"):
            path = root / f"web/icons/{prefix}{size}.png"
            save(icon(root, size, inset=0.88 if "maskable" in prefix else 1.0), path)
            outputs.append(path)
    path = root / "web/favicon.png"
    save(icon(root, 32, rounded=True), path, opaque=False)
    outputs.append(path)
    for name, image in (("app-icon-1024.png", icon(root, 1024)),
                        ("google-play-icon-512.png", icon(root, 512)),
                        ("google-play-feature-1024x500.png", feature(root))):
        path = root / "assets/brand" / name
        # Play's upload format is 32-bit PNG with alpha. The image is still
        # visibly opaque (all alpha values 255) and has no pre-applied corner
        # mask; Google Play supplies its own mask/shadow.
        save(image, path, opaque=name != "google-play-icon-512.png")
        outputs.append(path)
    for path in outputs:
        with Image.open(path) as image:
            alpha = image.getextrema()[-1] if image.mode == "RGBA" else None
            records.append({"path": path.relative_to(root).as_posix(),
                            "size": list(image.size), "mode": image.mode,
                            "alpha": list(alpha) if alpha else None})
    print(json.dumps(records, indent=2))


if __name__ == "__main__":
    main()
