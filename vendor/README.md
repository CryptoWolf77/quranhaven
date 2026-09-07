# Quran library integration

`quran_library/` is a local copy of the published `quran_library` 4.2.1 package,
retaining its code, Android plugin, bundled assets, `LICENSE`, and `NOTICE`.
The Pub cache is not modified. The original code license does not replace the
separate terms for Quran text, fonts, Tafsir, translations, and other resources.

The local patch adds `QuranContentConfig.configure(baseUrl: ..., allowUpstreamFallback: false)`.
Call it before `QuranLibrary.init()`. The URL is the complete versioned content
root (for example `https://content.example.org/v1/`). When configured, all optional
Tafsir, translation, word-information, and Tajweed explanation requests use only
that host. When unconfigured, those downloads are disabled unless upstream access
is explicitly enabled. Bundled Quran text, metadata, fonts, Saadi Tafsir, English
translation, and existing local downloads remain usable. Audio is unchanged.

Content paths relative to that root:

- `tafsir/<filename>.json.gz`
- `word-info/<directory>/sura_NNN.json`
- `word-info/meaning-word-oldv/meaning-word-oldv.json`
- `tajweed/sura_NNN.json`
- `archives/word_qeraat.zip`, `archives/word_tasreef.zip`, `archives/word_eerab.zip`,
  `archives/meaning-word-oldv.json.zip`, and `archives/tajweed_aya.zip`

The patch also prevents failed Tafsir downloads from being marked as successful
and resets download indicators after errors. Web learning resources retain the
upstream package's in-memory behavior; self-hosting alone does not add persistent
PWA downloads.

The unavailable `in-tafsir-jalalayn.json.gz` catalog entry is omitted: neither
upstream mirror publishes that file. It is not substituted with a different
language. Other catalog classifications retain their upstream behavior.
Saved selection and download indices are migrated once to preserve their
resource identity after the removal.

`QuranLibrary().prepareTafsir(index, pageNumber: ...)` is an additional awaitable
entry point. It downloads missing native resources, parses the selected content,
and returns errors to the caller. Existing reading callbacks keep their behavior.
