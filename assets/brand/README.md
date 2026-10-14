# Quran Haven release identity

## Current book identity (v2)

The owner requested a new book-based app/site mark. Its actual built-in
`image_gen` output is preserved unchanged as `quran-haven-book-v2.png`; original
prompts, source output paths, SHA-256, dimensions and visual limitations are
recorded in `quran-haven-book-v2.source.json`. No Arabic letters or Quran verse
text appears in this new artwork. The earlier qaf master below remains available
as `app-icon-1024.png`; it is not the current platform-icon source.

Current mechanical export/check commands:

```text
python assets/brand/generate_book_brand_assets.py --root . --write
python assets/brand/check_book_brand_assets.py --root .
```

These exports preserve the selected book image's geometry and colors. There is
no hand redraw, semantic editing or background removal. Native/PWA/favicon PNGs
are opaque; the Play icon is opaque RGBA, and the feature graphic is RGB. The
meaningful ivory/gold book, rather than the full emerald bitmap backdrop, fits
the Android/PWA mask safe zones. Generated artwork retains subtle residual color
texture despite the requested flat fills; that is preserved and disclosed, not
silently repainted. Design/store acceptance remains separate from pixel checks.

## Earlier qaf identity (retained source)

Original Quran Haven artwork extending the application's existing Arabic ق
monogram, with a minimal open-book line. No Quran verse, publisher logo, Flutter
mark or external photograph is embedded.

Palette: emerald `#146e5c`, parchment `#f7f2e7`, gold `#d8c995`.
The isolated letter is rendered using the project's existing bundled Cairo Bold
interface font; the geometric book and banner composition are original artwork.
No new runtime or launcher-generation package is added to the application.

The reproducible source is `generate_brand_assets.py` (Pillow and the bundled
Cairo font). From the project root, run:

```text
python assets/brand/generate_brand_assets.py --root . --write
python assets/brand/check_brand_assets.py --root .
```

The generator produces the Android density-specific legacy icons and transparent
adaptive foregrounds; opaque iOS AppIcon raster sizes from the unchanged Xcode
catalogue; web/PWA icons; the 1024px master; a 512px Google Play icon; and a
1024×500px Google Play feature graphic. The existing application identifier,
manifest permissions, signing configuration and app UI are not changed.

Android's adaptive icon uses a solid emerald background and a separately inset
foreground, keeping the visible artwork within the central 66dp safe zone of the
108dp canvas. iOS artwork has no alpha channel or pre-applied system corner
mask. All generated PNGs declare sRGB color space. The Play icon is a 32-bit
RGBA PNG with every alpha value 255 (visibly
opaque), with no pre-applied corner mask or shadow. The 32px favicon and
pre-adaptive Android icons have transparent outer
corners; PWA maskable icons have full opaque backgrounds and an inset mark.

Store text is limited to the product name, “Read · Listen · Learn”, and
“Your daily Quran journey”. Price/promotional wording such as “Free” is omitted
from the feature graphic, following Google's current recommendations. See
[Google Play preview asset requirements](https://support.google.com/googleplay/android-developer/answer/9866151?hl=en)
and [icon design specifications](https://developer.android.com/distribute/google-play/resources/icon-design-specifications).
These images do not establish store acceptance, screenshot
accuracy, signed release readiness or completed device testing.
