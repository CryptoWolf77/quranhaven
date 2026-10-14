# Offline interface fonts

The established Cairo and Noto Naskh Arabic interface fonts are retained.
The catalogue also displays the native Bengali language name, whose
characters require an additional fallback. Noto Sans Bengali is bundled for
that label; no Quran text/font resource or source archive is modified.

Source: [Google Fonts Noto Sans Bengali](https://github.com/google/fonts/tree/main/ofl/notosansbengali).
Downloaded unchanged on 2026-09-07 from `NotoSansBengali[wdth,wght].ttf`.
Local name: `assets/fonts/NotoSansBengali.ttf`.
SHA-256: `dcd42978094e584a849c84a51450eeac40c8826057d566ea6d4b9627a403a05a`.

Copyright 2022 The Noto Project Authors. Distributed under the
[SIL Open Font License 1.1](https://raw.githubusercontent.com/google/fonts/main/ofl/notosansbengali/OFL.txt).
The complete unchanged license is bundled at
`assets/fonts/OFL-NotoSansBengali.txt` and registered in the app's license page.
License SHA-256: `754f0e221aa7d5a915489f3bf1f20fe53ddc35ab2834a4d91656d78f9622de70`.

## Local symbol fallback

Noto Sans Symbols is also bundled as an inherited interface fallback, after
the existing Cairo/Naskh/Bengali choices. This makes symbols covered by that
font available locally to the interface and guide text; it does not replace
the primary typeface or the Hafs Quran font. No guide text style overrides the
shared fallback list. Other explicit font families in the app are Quran Hafs
or morphology monospace spans, and are not changed by this fix.

Source: [Google Fonts Noto Sans Symbols](https://github.com/google/fonts/tree/main/ofl/notosanssymbols).
Downloaded unchanged on 2026-10-15 from
[`NotoSansSymbols[wght].ttf`](https://raw.githubusercontent.com/google/fonts/main/ofl/notosanssymbols/NotoSansSymbols%5Bwght%5D.ttf).
Local name: `assets/fonts/NotoSansSymbols.ttf`.
SHA-256: `f7e7e04b4a24b6c78893d50cbfd2b2f6cae49617ab047bfef668d252adb128f7`.

Copyright 2022 The Noto Project Authors (https://github.com/notofonts/symbols).
Distributed under the
[SIL Open Font License 1.1](https://raw.githubusercontent.com/google/fonts/main/ofl/notosanssymbols/OFL.txt).
The complete unchanged license is bundled at
`assets/fonts/OFL-NotoSansSymbols.txt` and registered in the app's license page.
License SHA-256: `b118dd41337806a5d4797052c77caf3bd096aed783e5eb21b4d11154351e1ac0`.
The font is used unmodified; the local asset filename differs from the
upstream filename, while its internal family name remains Noto Sans Symbols.

A direct cmap check confirms that the guide's U+2190 LEFTWARDS ARROW and
U+2192 RIGHTWARDS ARROW are not covered by the existing Cairo/Naskh/Bengali
set and are covered by this original Noto Sans Symbols font. With the local
fallback added, all 118 guide codepoints and all 140 non-control codepoints
in the current Arabic/English/Spanish localization files have local coverage.
The font/asset-bundle tests also verify that the unchanged primary typeface
and local fallback are inherited by guide text at 2x scale in each language.
This source-level evidence does not replace the final offline browser retest.

Font-character checks cover current app labels and catalogue language
names. They do not establish coverage of arbitrary user input or every optional
commentary's full text. Physical-device and full offline acceptance still apply.
