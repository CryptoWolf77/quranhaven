import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_flutter/features/account/data/cloud_restore_service.dart';
import 'package:quran_flutter/features/account/data/bookmarks_backup_repository.dart';
import 'package:quran_flutter/features/account/domain/cloud_bookmark.dart';
import 'package:quran_flutter/features/account/data/reading_preferences_repository.dart';
import 'package:quran_flutter/features/account/domain/reading_preferences.dart';
import 'package:quran_flutter/features/plans/data/plans_repository.dart';
import 'package:quran_flutter/features/plans/domain/plans_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _originalPreferences = ReadingPreferences(
  locale: Locale('en'),
  themeMode: ThemeMode.light,
);

Map<String, Object?> _backup() => {
  'schema_version': 1,
  'last_read_page': 90,
  'preferences': {'locale': 'es', 'theme_mode': 'dark'},
  'plans': {
    'khatmah': KhatmahPlan(
      startedAt: DateTime(2026, 9, 1),
      targetDate: DateTime(2026, 9, 30),
      completedPages: 80,
    ).toJson(),
    'memorization': [
      const MemorizationPlan(
        id: 'saved-plan',
        surahNumber: 1,
        startAyah: 1,
        endAyah: 7,
        currentAyah: 4,
        repetitions: 5,
        rangeRepetitions: 2,
        delaySeconds: 2,
        hideAyah: true,
        memorizedAyahs: {1, 2, 3},
        revisionAyahs: {2},
      ).toJson(),
    ],
  },
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MemoryPlans plans;
  late _MemoryBookmarks bookmarks;
  late ReadingPreferences preferences;
  late int page;
  late int preferenceWrites;
  late int progressCallbacks;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    plans = _MemoryPlans();
    bookmarks = _MemoryBookmarks();
    preferences = _originalPreferences;
    page = 42;
    preferenceWrites = 0;
    progressCallbacks = 0;
  });

  Future<void> restore(Map<String, Object?> data) {
    return CloudRestoreService(plans: plans, bookmarks: bookmarks).restore(
      data: data,
      currentPreferences: preferences,
      ayahsInSurah: (surah) => surah == 1 ? 7 : 286,
      onPreferencesRestored: (restored) async {
        await ReadingPreferencesRepository().save(restored);
        preferences = restored;
        preferenceWrites++;
      },
      onProgressRestored: (restored) {
        if (restored != null) page = restored;
        progressCallbacks++;
      },
    );
  }

  test(
    'valid restore applies plans, page and persisted language/appearance',
    () async {
      await restore(_backup());

      expect(page, 90);
      expect(plans.khatmah?.completedPages, 80);
      expect(plans.memorization.single.currentAyah, 4);
      expect(preferences.locale, const Locale('es'));
      expect(preferences.themeMode, ThemeMode.dark);
      final reloaded = await ReadingPreferencesRepository().load();
      expect(reloaded.locale, const Locale('es'));
      expect(reloaded.themeMode, ThemeMode.dark);
      expect(preferenceWrites, 1);
    },
  );

  test(
    'bookmark snapshots restore, empty clears and old backups preserve',
    () async {
      final mark = <String, Object?>{
        'id': 12,
        'color': 0xAAFFD354,
        'name': 'Al-Fatihah',
        'ayah_id': 1,
        'ayah_number': 1,
        'page': 1,
      };
      await restore({
        ..._backup(),
        'bookmarks': [mark],
      });
      expect(bookmarks.saved.single.toJson(), mark);
      await restore(_backup());
      expect(bookmarks.writes, 1);
      await restore({'bookmarks': []});
      expect(bookmarks.saved, isEmpty);
      expect(bookmarks.writes, 2);
    },
  );

  test(
    'invalid bookmarks or later fields never partially replace bookmarks',
    () async {
      for (final invalid in <Map<String, Object?>>[
        {
          'bookmarks': ['bad'],
        },
        {
          'bookmarks': [],
          'preferences': {'locale': 'not-supported'},
        },
        {
          'bookmarks': [],
          'plans': {'memorization': 'bad'},
        },
      ]) {
        await expectLater(
          restore({..._backup(), ...invalid}),
          throwsFormatException,
        );
        expect(bookmarks.writes, 0);
        expect(plans.writes, 0);
      }
    },
  );

  test('explicit null locale and system appearance survive restart', () async {
    await restore({
      'preferences': {'locale': null, 'theme_mode': 'system'},
    });

    final reloaded = await ReadingPreferencesRepository().load();
    expect(preferences.locale, isNull);
    expect(reloaded.locale, isNull);
    expect(reloaded.themeMode, ThemeMode.system);
    expect(plans.writes, 0);
    expect(page, 42);
  });

  test(
    'legacy backups retain absent preferences, page and plan collections',
    () async {
      final originalMemorization = plans.memorization;
      await restore({
        'plans': {'khatmah': null},
      });

      expect(plans.khatmah, isNull);
      expect(plans.memorization, same(originalMemorization));
      expect(preferences, same(_originalPreferences));
      expect(preferenceWrites, 0);
      expect(page, 42);
    },
  );

  test(
    'partial preferences retain fields missing from an older backup',
    () async {
      await restore({
        'preferences': {'theme_mode': 'dark'},
      });
      expect(preferences.locale, const Locale('en'));
      expect(preferences.themeMode, ThemeMode.dark);
      await restore({
        'preferences': {'locale': 'ar'},
      });
      expect(preferences.locale, const Locale('ar'));
      expect(preferences.themeMode, ThemeMode.dark);
    },
  );

  test(
    'malformed late plan data cannot partially delete local progress',
    () async {
      final original = plans.khatmah;
      await expectLater(
        restore({
          ..._backup(),
          'plans': {'khatmah': null, 'memorization': 'not-a-list'},
        }),
        throwsFormatException,
      );

      expect(plans.khatmah, same(original));
      expect(plans.writes, 0);
      expect(preferenceWrites, 0);
      expect(progressCallbacks, 0);
      expect(page, 42);
      expect(preferences, same(_originalPreferences));
    },
  );

  test(
    'invalid numbers, preferences and versions cause no local writes',
    () async {
      for (final changes in <Map<String, Object?>>[
        {'last_read_page': 0},
        {'last_read_page': 605},
        {'last_read_page': 42.5},
        {'last_read_page': '42'},
        {
          'preferences': {'locale': 'fr'},
        },
        {
          'preferences': {'locale': 4},
        },
        {
          'preferences': {'theme_mode': 'midnight'},
        },
        {'preferences': null},
        {'schema_version': 2},
        {'plans': null},
      ]) {
        await expectLater(
          restore({..._backup(), ...changes}),
          throwsFormatException,
        );
        expect(plans.writes, 0, reason: changes.toString());
        expect(preferenceWrites, 0, reason: changes.toString());
        expect(progressCallbacks, 0, reason: changes.toString());
      }
    },
  );

  test(
    'invalid Ayah ranges, markers, IDs and plan dates are rejected first',
    () async {
      for (final change in <Map<String, Object?>>[
        {'surahNumber': 115},
        {'endAyah': 8},
        {'startAyah': 6, 'endAyah': 5},
        {'currentAyah': 0},
        {
          'memorizedAyahs': [8],
        },
        {
          'revisionAyahs': ['2'],
        },
        {'repetitions': -1},
        {'id': ''},
      ]) {
        final backup =
            jsonDecode(jsonEncode(_backup())) as Map<String, Object?>;
        final rawPlans = backup['plans']! as Map<String, Object?>;
        final ranges = rawPlans['memorization']! as List<Object?>;
        ranges[0] = {...ranges[0]! as Map<String, Object?>, ...change};
        await expectLater(restore(backup), throwsFormatException);
        expect(plans.writes, 0, reason: change.toString());
      }
      final backup = _backup();
      final rawPlans = backup['plans']! as Map<String, Object?>;
      final ranges = rawPlans['memorization']! as List<Object?>;
      ranges.add(ranges.first);
      await expectLater(restore(backup), throwsFormatException);
      rawPlans['memorization'] = [];
      rawPlans['khatmah'] = {
        ...rawPlans['khatmah']! as Map<String, Object?>,
        'startedAt': 'not-a-date',
      };
      await expectLater(restore(backup), throwsFormatException);
      expect(plans.writes, 0);
      expect(preferenceWrites, 0);
      expect(progressCallbacks, 0);
    },
  );

  test(
    'corrupt stored preference data falls back without touching other data',
    () async {
      SharedPreferences.setMockInitialValues({
        ReadingPreferencesRepository.storageKey: '{"theme_mode":"invalid"}',
        'plans.khatmah.v1': 'keep-local-progress',
      });
      final reloaded = await ReadingPreferencesRepository().load();
      expect(reloaded.locale, isNull);
      expect(reloaded.themeMode, ThemeMode.system);
      final storage = await SharedPreferences.getInstance();
      expect(storage.getString('plans.khatmah.v1'), 'keep-local-progress');
    },
  );
}

class _MemoryBookmarks implements BookmarksBackupRepository {
  List<CloudBookmark> saved = [];
  int writes = 0;
  @override
  Future<void> replace(List<CloudBookmark> bookmarks) async {
    writes++;
    saved = bookmarks;
  }

  @override
  List<Map<String, Object?>> exportForCloud() =>
      saved.map((e) => e.toJson()).toList();
}

class _MemoryPlans implements PlansRepository {
  KhatmahPlan? khatmah = KhatmahPlan(
    startedAt: DateTime(2026, 8, 1),
    targetDate: DateTime(2026, 8, 30),
    completedPages: 42,
  );
  List<MemorizationPlan> memorization = [];
  int writes = 0;

  @override
  Future<void> deleteKhatmah() async {
    writes++;
    khatmah = null;
  }

  @override
  Future<void> saveKhatmah(KhatmahPlan plan) async {
    writes++;
    khatmah = plan;
  }

  @override
  Future<void> saveMemorizationPlans(List<MemorizationPlan> plans) async {
    writes++;
    memorization = plans;
  }

  @override
  Future<KhatmahPlan?> loadKhatmah() async => khatmah;

  @override
  Future<List<MemorizationPlan>> loadMemorizationPlans() async => memorization;

  @override
  Future<Map<String, Object?>> exportForCloud() async => {
    'khatmah': khatmah?.toJson(),
    'memorization': memorization.map((plan) => plan.toJson()).toList(),
  };

  @override
  Future<void> replaceFromCloud(Map<String, Object?> data) =>
      throw UnimplementedError('Restoration must use validated models');
}
