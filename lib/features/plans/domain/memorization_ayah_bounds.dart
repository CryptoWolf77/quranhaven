import 'package:quran_library/quran_library.dart';

/// Ayah limits for a one-based Surah number in a memorization plan.
class MemorizationAyahBounds {
  const MemorizationAyahBounds._(this.ayahCount);

  factory MemorizationAyahBounds.forSurah({
    required int surahNumber,
    required Iterable<SurahNamesModel> surahs,
  }) {
    RangeError.checkValueInInterval(surahNumber, 1, 114, 'surahNumber');
    // Library list positions are zero-based; Quran Surah numbers are not.
    // Match the metadata identity so the result also survives list reordering.
    final metadata = surahs.singleWhere((surah) => surah.number == surahNumber);
    if (metadata.ayahsNumber < 1) {
      throw StateError('Missing Ayah count for Surah $surahNumber');
    }
    return MemorizationAyahBounds._(metadata.ayahsNumber);
  }

  final int ayahCount;

  int get defaultEndAyah => ayahCount.clamp(1, 7);

  bool contains(int? ayah) => ayah != null && ayah >= 1 && ayah <= ayahCount;
}
