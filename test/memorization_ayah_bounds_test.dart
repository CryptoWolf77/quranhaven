import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_flutter/features/plans/domain/memorization_ayah_bounds.dart';
import 'package:quran_library/quran_library.dart';

void main() {
  late List<SurahNamesModel> surahs;

  setUpAll(() {
    final compressed = File(
      'vendor/quran_library/assets/jsons/surahs_name.json.gz',
    ).readAsBytesSync();
    final metadata = jsonDecode(utf8.decode(gzip.decode(compressed)));
    surahs = SurahResponseModel.fromJson(
      metadata as Map<String, dynamic>,
    ).surahs;
  });

  for (final entry in {1: 7, 2: 286, 114: 6}.entries) {
    test('Surah ${entry.key} uses its own Ayah count and inclusive bounds', () {
      final bounds = MemorizationAyahBounds.forSurah(
        surahNumber: entry.key,
        surahs: surahs,
      );

      expect(bounds.ayahCount, entry.value);
      expect(bounds.contains(1), isTrue);
      expect(bounds.contains(entry.value), isTrue);
      expect(bounds.contains(entry.value + 1), isFalse);
      expect(bounds.contains(0), isFalse);
      expect(bounds.contains(null), isFalse);
      expect(bounds.defaultEndAyah, entry.value < 7 ? entry.value : 7);
    });
  }

  test('metadata identity, not list position, selects the Surah', () {
    final reversed = surahs.reversed;
    for (final entry in {1: 7, 2: 286, 114: 6}.entries) {
      expect(
        MemorizationAyahBounds.forSurah(
          surahNumber: entry.key,
          surahs: reversed,
        ).ayahCount,
        entry.value,
      );
    }
  });

  test('zero-based and out-of-range Surah numbers are rejected', () {
    for (final number in [-1, 0, 115]) {
      expect(
        () => MemorizationAyahBounds.forSurah(
          surahNumber: number,
          surahs: surahs,
        ),
        throwsRangeError,
      );
    }
  });

  test('missing Surah metadata cannot silently select a neighboring Surah', () {
    expect(
      () => MemorizationAyahBounds.forSurah(
        surahNumber: 2,
        surahs: surahs.where((surah) => surah.number != 2),
      ),
      throwsStateError,
    );
  });
}
