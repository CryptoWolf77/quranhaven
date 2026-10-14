import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_flutter/features/personal/domain/personal_models.dart';
import 'package:quran_flutter/features/personal/domain/local_backup.dart';
import 'package:quran_flutter/features/personal/domain/saved_text_search.dart';

Map<String, Object?> document() =>
    objectMap(jsonDecode(jsonEncode(_rawDocument())));
Map<String, Object?> _rawDocument() => {
  'format': 'Quran Haven local backup',
  'schemaVersion': 1,
  'createdAt': '2026-10-13T00:00:00.000Z',
  'data': {
    'personal': {
      'notes': [
        {
          'id': 'n1',
          'surah': 1,
          'ayah': 5,
          'title': 'تأمل / reflexión',
          'body': 'نص عربي 🌿\nA private reflection',
          'updatedAt': '2026-10-13T00:00:00.000Z',
        },
      ],
      'collections': [
        {
          'id': 'c1',
          'name': 'دعاء / Duʿā',
          'ayahs': [
            {'surah': 114, 'ayah': 6},
          ],
        },
      ],
    },
    'preferences': {'locale': 'es', 'theme_mode': 'dark'},
    'khatmah': {
      'startedAt': '2026-10-01T00:00:00.000',
      'targetDate': '2026-12-01T00:00:00.000',
      'completedPages': 21,
      'isPaused': true,
      'isRamadanPlan': false,
    },
    'memorization': [
      {
        'id': 'm1',
        'surahNumber': 1,
        'startAyah': 1,
        'endAyah': 7,
        'currentAyah': 2,
        'repetitions': 3,
        'rangeRepetitions': 2,
        'delaySeconds': 0,
        'hideAyah': true,
        'memorizedAyahs': [1],
        'revisionAyahs': [2],
      },
    ],
    'bookmarks': [
      {
        'id': 1,
        'ayahId': 5,
        'ayahNumber': 5,
        'page': 1,
        'color': 0xAAFFD354,
        'name': 'الفاتحة',
      },
    ],
    'reader': <String, Object?>{
      'last_page': 49,
      'DISPLAY_MODE': 0,
      'fontsSelected2': 0,
    },
    'reminder': {'hour': 19, 'minute': 0},
  },
};
void main() {
  test('invalid reading preference enum values are rejected', () {
    for (final value in [
      {'locale': 'fr', 'theme_mode': 'dark'},
      {'locale': 'es', 'theme_mode': 'neon'},
      {'locale': 3, 'theme_mode': 'system'},
    ]) {
      final doc = document();
      (doc['data'] as Map)['preferences'] = value;
      expect(() => LocalBackup.decode(jsonEncode(doc)), throwsFormatException);
    }
  });
  test('overflow-normalized dates are rejected', () {
    for (final date in [
      '2026-02-31T00:00:00.000Z',
      '2026-01-01T25:00:00.000Z',
      '2026-10-13',
    ]) {
      expect(() => strictBackupDate(date), throwsFormatException);
    }
  });
  test('Hafs limits contain exactly 114 Surahs and 6236 Ayahs', () {
    expect(hafsAyahCounts.length, 114);
    expect(hafsAyahCounts.reduce((a, b) => a + b), 6236);
    expect(const AyahReference(114, 6).isValid, true);
    expect(const AyahReference(114, 7).isValid, false);
    expect(const AyahReference(2, 286).isValid, true);
  });
  test('valid deep links round trip; absent is distinct from invalid', () {
    final ref = AyahReference.fromUri(const AyahReference(2, 282).publicLink)!;
    expect(ref.key, '2:282');
    expect(AyahReference.fromUri(Uri.parse('https://quranhaven.org/')), null);
    for (final q in [
      'surah=115&ayah=1',
      'surah=1&ayah=8',
      'surah=1',
      'surah=1&surah=2&ayah=1',
      'surah=x&ayah=1',
    ]) {
      expect(
        () => AyahReference.fromUri(Uri.parse('https://quranhaven.org/?$q')),
        throwsFormatException,
      );
    }
  });
  test(
    'backup Unicode round trip preserves private models and source format',
    () {
      final data = LocalBackup.decode(jsonEncode(document()));
      final restored = LocalBackup.decode(data.encode());
      expect(restored.personal.notes.single.body, contains('نص عربي 🌿'));
      expect(restored.personal.collections.single.ayahs.single.key, '114:6');
      expect(restored.preferences.locale!.languageCode, 'es');
      expect(restored.khatmah!.completedPages, 21);
      expect(restored.memorization.single.revisionAyahs, {2});
    },
  );
  test('all future schema versions and foreign format markers rejected', () {
    for (final patch in [
      {'schemaVersion': 2},
      {'format': 'other'},
      {'secret': 'no'},
    ]) {
      final doc = document()..addAll(patch);
      expect(() => LocalBackup.decode(jsonEncode(doc)), throwsFormatException);
    }
  });
  test('arbitrary storage keys and nested secret fields rejected', () {
    for (final target in ['root', 'reader', 'personal', 'reference']) {
      final doc = document();
      final d = doc['data']! as Map<String, Object?>;
      if (target == 'root') {
        d['cloudToken'] = 'secret';
      } else if (target == 'reader') {
        (d['reader'] as Map)['API_TOKEN'] = 'secret';
      } else if (target == 'personal') {
        (d['personal'] as Map)['other'] = 'secret';
      } else {
        (((d['personal'] as Map)['collections'] as List).first
            as Map)['ayahs'] = [
          {'surah': 1, 'ayah': 1, 'secret': 'no'},
        ];
      }
      expect(() => LocalBackup.decode(jsonEncode(doc)), throwsFormatException);
    }
  });
  test('corrupt JSON and files over 5MiB are rejected before writes', () {
    expect(() => LocalBackup.decode('{bad'), throwsFormatException);
    expect(
      () => LocalBackup.decode('x' * (LocalBackup.maxBytes + 1)),
      throwsFormatException,
    );
  });
  test('invalid notes, empty body and out-of-range Ayahs rejected', () {
    for (final patch in [
      {'body': ''},
      {'body': 'x' * 10001},
      {'surah': 114, 'ayah': 7},
      {'updatedAt': 'bad'},
      {'title': 'x' * 121},
    ]) {
      final doc = document();
      final note =
          ((((doc['data'] as Map)['personal'] as Map)['notes'] as List).first
              as Map);
      note.addAll(patch);
      expect(() => LocalBackup.decode(jsonEncode(doc)), throwsFormatException);
    }
  });
  test('duplicates are rejected for notes, collections and progress', () {
    for (final key in ['notes', 'collections']) {
      final doc = document(), p = (doc['data'] as Map)['personal'] as Map;
      final list = p[key] as List;
      list.add(list.first);
      expect(() => LocalBackup.decode(jsonEncode(doc)), throwsFormatException);
    }
    final doc = document();
    final plan = ((doc['data'] as Map)['memorization'] as List).first as Map;
    plan['memorizedAyahs'] = [1, 1];
    expect(() => LocalBackup.decode(jsonEncode(doc)), throwsFormatException);
  });
  test('duplicate collection references are rejected', () {
    final doc = document(),
        c =
            ((((doc['data'] as Map)['personal'] as Map)['collections'] as List)
                    .first
                as Map);
    c['ayahs'] = [
      {'surah': 1, 'ayah': 1},
      {'surah': 1, 'ayah': 1},
    ];
    expect(() => LocalBackup.decode(jsonEncode(doc)), throwsFormatException);
  });
  test('invalid pages, font modes and reminder bounds rejected', () {
    for (final r in [
      {'last_page': 0},
      {'last_page': 605},
      {'DISPLAY_MODE': 5},
      {'FONT_SIZE': -5},
      {'IS_BOLD_BOOL': 'true'},
      {'fontsSelected2': 1},
    ]) {
      final doc = document();
      (doc['data'] as Map)['reader'] = r;
      expect(() => LocalBackup.decode(jsonEncode(doc)), throwsFormatException);
    }
    final doc = document();
    (doc['data'] as Map)['reminder'] = {'hour': 24, 'minute': 0};
    expect(() => LocalBackup.decode(jsonEncode(doc)), throwsFormatException);
  });
  test(
    'memorization range, current Ayah and marked progress bounds validated',
    () {
      for (final patch in [
        {'startAyah': 7, 'endAyah': 1},
        {'currentAyah': 8},
        {'surahNumber': 115},
        {
          'memorizedAyahs': [8],
        },
        {'repetitions': 0},
      ]) {
        final doc = document(),
            p = ((doc['data'] as Map)['memorization'] as List).first as Map;
        p.addAll(patch);
        expect(
          () => LocalBackup.decode(jsonEncode(doc)),
          throwsFormatException,
        );
      }
    },
  );
  test('bookmark identity, duplicate IDs and Ayah mismatch rejected', () {
    for (final patch in [
      {'ayahId': 6237},
      {'ayahNumber': 6},
      {'page': 605},
      {'id': -1},
    ]) {
      final doc = document(),
          b = ((doc['data'] as Map)['bookmarks'] as List).first as Map;
      b.addAll(patch);
      expect(() => LocalBackup.decode(jsonEncode(doc)), throwsFormatException);
    }
  });
  test('khatmah backward dates and impossible progress rejected', () {
    for (final patch in [
      {'completedPages': 605},
      {'targetDate': '2020-01-01T00:00:00.000'},
      {'isPaused': 'yes'},
    ]) {
      final doc = document(), p = (doc['data'] as Map)['khatmah'] as Map;
      p.addAll(patch);
      expect(() => LocalBackup.decode(jsonEncode(doc)), throwsFormatException);
    }
  });
  test('partial write failure rolls back every attempted key', () async {
    final store = <String, Object?>{
      'a': 'original',
      'b': 'old',
      'unrelated': 'kept',
    };
    var reject = true;
    await expectLater(
      restoreTransaction(
        {'a': 'new', 'b': 'replacement', 'c': 1},
        read: (k) async => store[k],
        write: (k, v) async {
          store[k] = v;
          if (k == 'b' && reject) {
            reject = false;
            throw StateError('quota');
          }
        },
      ),
      throwsStateError,
    );
    expect(store['a'], 'original');
    expect(store['b'], 'old');
    expect(store.containsKey('c'), false);
    expect(store['unrelated'], 'kept');
  });
  test('successful transaction touches only whitelist values', () async {
    final store = <String, Object?>{'a': 'old', 'unrelated': 'kept'};
    await restoreTransaction(
      {'a': 'new', 'b': 2},
      read: (k) async => store[k],
      write: (k, v) async => store[k] = v,
    );
    expect(store, {'a': 'new', 'b': 2, 'unrelated': 'kept'});
  });
  test('rollback failure is explicit and never claims recovery', () async {
    await expectLater(
      restoreTransaction(
        {'a': 'new'},
        read: (k) async => 'old',
        write: (k, v) async => throw StateError('unavailable'),
      ),
      throwsA(
        isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('rollback failed'),
        ),
      ),
    );
  });
  test(
    'Arabic diacritics and whitespace normalize without mutating source',
    () {
      expect(normalizeSearch(' إِيَّاكَ  نَسْتَعِينُ '), 'اياك نستعين');
      expect(normalizeSearch('RÉFLEXION'), 'réflexion');
      expect(plainResourceText('<b>Text</b> &amp; &#x627; &#160;'), 'Text & ا');
    },
  );
  test('search matches entire corpus including last Ayah and map aliases', () {
    final entries = parseSavedBook(
      jsonEncode({
        '1:1': {'t': 'opening text'},
        '114:6': {'t': 'From <b>jinn</b> and people'},
        '114:5': '114:6',
      }),
    );
    expect(searchSavedBook(entries, 'jinn').map((e) => e.reference.key), [
      '114:5',
      '114:6',
    ]);
    expect(searchSavedBook(entries, 'zzzzz'), isEmpty);
    expect(searchSavedBook(entries, 'j'), isEmpty);
  });
  test('legacy Tafsir list is parsed and sorted across Surahs', () {
    final entries = parseSavedBook(
      jsonEncode([
        {'sura': 114, 'aya': 6, 'text': 'النَّاس'},
        {'sura': 1, 'aya': 5, 'text': 'إِيَّاكَ نَسْتَعِينُ'},
        {'sura': 115, 'aya': 1, 'text': 'invalid'},
      ]),
    );
    expect(entries.map((e) => e.reference.key), ['1:5', '114:6']);
    expect(searchSavedBook(entries, 'اياك نستعين').single.reference.key, '1:5');
  });
  test('personal storage prevents an unexportable oversized payload', () {
    final notes = [
      for (var i = 0; i < 400; i++)
        AyahNote(
          id: '$i',
          reference: const AyahReference(1, 1),
          title: '',
          body: 'x' * 10000,
          updatedAt: DateTime(2026),
        ),
    ];
    expect(
      () => PersonalData.fromJson(PersonalData(notes: notes).toJson()),
      throwsFormatException,
    );
  });
}
