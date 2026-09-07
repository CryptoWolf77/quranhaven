# Additional reciters — build 5

Eight reciters are appended to both the full-Surah and Ayah-by-Ayah selectors.
All existing entries, including Maher Al-Muaiqly, are unchanged at the owner's request.
Existing indices and download paths remain stable; no saved audio is deleted or moved.

| Reciter | MP3Quran ID (Hafs Murattal edition) |
| --- | --- |
| Mishary Rashid Alafasy | 123 |
| Abdulrahman Al-Sudais | 54 |
| Abu Bakr Al-Shatri | 4 |
| Ali Al-Hudhaify | 74 |
| Abdullah Basfar | 60 |
| Hani Al-Rifai | 89 |
| Salah Al-Budair | 43 |
| Abdulmohsen Al-Qasim | 67 |

Source URLs and exact edition IDs are recorded in `reciters.json`. Official sources:
[MP3Quran API](https://www.mp3quran.net/eng/api),
[live English catalogue](https://www.mp3quran.net/api/v3/reciters?language=eng), and
[EveryAyah recordings](https://everyayah.com/recitations_ayat.html).
EveryAyah calls Abdulmohsen Al-Qasim's folder `Muhsin_Al_Qasim_192kbps`.

The selected MP3Quran editions list all 114 Surahs in Hafs; alternative or partial
narrations are not selected. Native offline downloads use the existing download
manager. Web audio retains the existing streaming behavior. Audio is served by
these providers, not newly mirrored to the Quran Haven server. Their availability
and resource terms remain separate from the application's source-code license.

Run `python deployment/check_reciters.py` to recheck all eight provider entries
and 48 bounded audio samples (Surahs 1, 2, 114 and Ayahs 1:1, 2:255, 114:6).
This checks MP3 headers, not every verse or the entirety of every recording.
`flutter test test/reciters_test.dart` also checks source mappings and legacy
selection/download compatibility without network access.

## Verification — 7 September 2026

- All eight live MP3Quran entries passed the exact edition, Hafs and 114-Surah checks.
- All 48 bounded MP3 samples returned HTTP 206 and public CORS headers.
- All 84 Flutter tests passed. Analysis has only the three existing vendored
  `cacheExtent` deprecation notices, with no new diagnostics.
- Production-configured JavaScript web and Android test builds succeeded.
- A fresh local in-app browser displayed all eight additions in both selectors.
- Android versionCode 5 retains the existing application ID and test certificate.
  Delivery file: `Quran Haven - test build 5.apk`, 144430318 bytes, SHA-256
  `c557fb0f777b22226152ab84bfe72ceaf47801b1c9d7227880f7f25ade93e517`.
- Native offline download code is unchanged. Physical-device download/replay
  acceptance and owner-controlled production signing remain release gates.
