import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_flutter/features/account/domain/cloud_bookmark.dart';
import 'package:quran_flutter/features/account/domain/cloud_restore_snapshot.dart';
import 'package:quran_flutter/features/account/domain/reading_preferences.dart';
import 'package:quran_library/quran_library.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late List<SurahNamesModel> surahs;
  setUpAll(() {
    surahs = SurahResponseModel.fromJson(
      jsonDecode(
        utf8.decode(
          gzip.decode(
            File(
              'vendor/quran_library/assets/jsons/surahs_name.json.gz',
            ).readAsBytesSync(),
          ),
        ),
      ),
    ).surahs;
  });
  int count(int surah) =>
      surahs.singleWhere((s) => s.number == surah).ayahsNumber;
  Map<String, Object?> bookmark() => {
    'id': 123,
    'name': 'Al-Fatihah',
    'color': 0xAAFFD354,
    'ayah_id': 7,
    'ayah_number': 7,
    'page': 1,
  };
  List<CloudBookmark> parse(Object? data) => CloudBookmark.parseList(
    data,
    ayahsInSurah: count,
    pageForAyah: (id) => id <= 7 ? 1 : 2,
  );

  test('portable bookmark retains every field and Quran identity', () {
    expect(parse([bookmark()]).single.toJson(), bookmark());
    expect(
      parse([
        {...bookmark(), 'ayah_id': 8, 'ayah_number': 1, 'page': 2},
      ]).single.ayahNumber,
      1,
    );
  });
  test('invalid references, names, IDs and colors are rejected', () {
    for (final changes in <Map<String, Object?>>[
      {'id': -1},
      {'id': 1.2},
      {'color': -1},
      {'color': 0x100000000},
      {'name': ''},
      {'name': 'x' * 201},
      {'ayah_id': 0},
      {'ayah_id': 6237},
      {'ayah_number': 6},
      {'ayah_id': 8},
      {'page': 2},
      {'page': 605},
    ]) {
      expect(
        () => parse([
          {...bookmark(), ...changes},
        ]),
        throwsFormatException,
        reason: changes.toString(),
      );
    }
    expect(() => parse([bookmark(), bookmark()]), throwsFormatException);
    expect(() => parse(null), throwsFormatException);
    expect(() => parse(['bad']), throwsFormatException);
  });
  test('legacy snapshots preserve bookmarks; explicit empty means clear', () {
    const preferences = ReadingPreferences(
      locale: Locale('en'),
      themeMode: ThemeMode.light,
    );
    CloudRestoreSnapshot snapshot(Map<String, Object?> data) =>
        CloudRestoreSnapshot.parse(
          data,
          currentPreferences: preferences,
          ayahsInSurah: count,
        );
    expect(snapshot({}).bookmarks, isNull);
    expect(snapshot({'bookmarks': []}).bookmarks, isEmpty);
  });

  test(
    'replacement persists before changing visible bookmarks and can clear',
    () async {
      final repository = _MemoryQuranRepository();
      final controller = BookmarksCtrl(quranRepository: repository);
      final mark = BookmarkModel(
        id: 1,
        colorCode: 0xAAFFD354,
        name: 'Al-Fatihah',
        ayahId: 1,
        ayahNumber: 1,
        page: 1,
      );
      await controller.replaceBookmarks([mark]);
      expect(repository.saved, [mark]);
      expect(controller.bookmarksAyahs, [1]);
      repository.fail = true;
      await expectLater(controller.replaceBookmarks([]), throwsStateError);
      expect(controller.bookmarksAyahs, [1]);
      repository.fail = false;
      await controller.replaceBookmarks([]);
      expect(repository.saved, isEmpty);
      expect(controller.bookmarksAyahs, isEmpty);
    },
  );
}

class _MemoryQuranRepository extends QuranRepository {
  List<BookmarkModel> saved = [];
  bool fail = false;
  @override
  Future<void> saveBookmarks(List<BookmarkModel> bookmarks) async {
    if (fail) throw StateError('Storage unavailable');
    saved = List.of(bookmarks);
  }
}
