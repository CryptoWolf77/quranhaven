import 'dart:convert';
import '../../plans/domain/plans_models.dart';
import '../../settings/domain/reading_preferences.dart';
import 'personal_models.dart';

const readerBackupKeys = {
  'last_page',
  'fontsSelected2',
  'IS_BOLD_BOOL',
  'DISPLAY_MODE',
  'FONT_SIZE',
  'TAFSEER_VAL',
  'TRANS',
  'IS_TAFSEER',
  'SURAH_READER_INDEX',
  'AYAH_READER_INDEX',
  'LAST_SURAH',
  'SELECTED_SURAH_INDEX',
  'LAST_POSITION',
  'READER_NAME',
  'AYAH_AUDIO_PLAYER_SOUND',
};

class LocalBackup {
  const LocalBackup({
    required this.createdAt,
    required this.personal,
    required this.preferences,
    required this.khatmah,
    required this.memorization,
    required this.bookmarks,
    required this.reader,
    required this.reminderHour,
    required this.reminderMinute,
  });
  static const maxBytes = 5 * 1024 * 1024;
  final DateTime createdAt;
  final PersonalData personal;
  final ReadingPreferences preferences;
  final KhatmahPlan? khatmah;
  final List<MemorizationPlan> memorization;
  final List<Map<String, Object?>> bookmarks;
  final Map<String, Object?> reader;
  final int reminderHour, reminderMinute;
  Map<String, Object?> toJson() => {
    'format': 'Quran Haven local backup',
    'schemaVersion': 1,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'data': {
      'personal': personal.toJson(),
      'preferences': preferences.toJson(),
      'khatmah': khatmah?.toJson(),
      'memorization': memorization.map((p) => p.toJson()).toList(),
      'bookmarks': bookmarks,
      'reader': reader,
      'reminder': {'hour': reminderHour, 'minute': reminderMinute},
    },
  };
  String encode() => const JsonEncoder.withIndent('  ').convert(toJson());
  factory LocalBackup.decode(String text) {
    if (utf8.encode(text).length > maxBytes) {
      throw const FormatException('Backup is too large');
    }
    final root = objectMap(jsonDecode(text));
    exactKeys(root, {'format', 'schemaVersion', 'createdAt', 'data'});
    if (root['format'] != 'Quran Haven local backup' ||
        root['schemaVersion'] != 1) {
      throw const FormatException('Unsupported backup');
    }
    final created = strictBackupDate(root['createdAt']);
    final data = objectMap(root['data']);
    exactKeys(data, {
      'personal',
      'preferences',
      'khatmah',
      'memorization',
      'bookmarks',
      'reader',
      'reminder',
    });
    final preferences = objectMap(data['preferences']);
    exactKeys(preferences, {'locale', 'theme_mode'});
    if (!const {null, 'ar', 'en', 'es'}.contains(preferences['locale']) ||
        !const {
          'system',
          'light',
          'dark',
        }.contains(preferences['theme_mode'])) {
      throw const FormatException('Invalid reading preferences');
    }
    KhatmahPlan? khatmah;
    if (data['khatmah'] != null) {
      final k = objectMap(data['khatmah']);
      exactKeys(k, {
        'startedAt',
        'targetDate',
        'completedPages',
        'isPaused',
        'isRamadanPlan',
      });
      _int(k['completedPages'], 0, 604);
      _bool(k['isPaused']);
      _bool(k['isRamadanPlan']);
      final start = _date(k['startedAt']), end = _date(k['targetDate']);
      if (end.isBefore(start) || end.difference(start).inDays > 3650) {
        throw const FormatException('Invalid plan dates');
      }
      khatmah = KhatmahPlan.fromJson(k);
    }
    final plans = boundedList(data['memorization'], 100).map((e) {
      final m = objectMap(e);
      exactKeys(m, {
        'id',
        'surahNumber',
        'startAyah',
        'endAyah',
        'currentAyah',
        'repetitions',
        'rangeRepetitions',
        'delaySeconds',
        'hideAyah',
        'memorizedAyahs',
        'revisionAyahs',
      });
      boundedString(m['id'], 80);
      final s = _int(m['surahNumber'], 1, 114),
          a = _int(m['startAyah'], 1, hafsAyahCounts[s - 1]);
      final b = _int(m['endAyah'], a, hafsAyahCounts[s - 1]);
      _int(m['currentAyah'], a, b);
      _int(m['repetitions'], 1, 100);
      _int(m['rangeRepetitions'], 1, 100);
      _int(m['delaySeconds'], 0, 120);
      _bool(m['hideAyah']);
      for (final key in ['memorizedAyahs', 'revisionAyahs']) {
        final values = boundedList(m[key], 286);
        for (final v in values) {
          _int(v, a, b);
        }
        if (values.toSet().length != values.length) {
          throw const FormatException('Duplicate progress');
        }
      }
      return MemorizationPlan.fromJson(m);
    }).toList();
    if (plans.map((p) => p.id).toSet().length != plans.length) {
      throw const FormatException('Duplicate plan ID');
    }
    final marks = boundedList(data['bookmarks'], 10000).map((e) {
      final m = objectMap(e);
      exactKeys(m, {'id', 'ayahId', 'ayahNumber', 'page', 'color', 'name'});
      _int(m['id'], 0, 9007199254740991);
      final uq = _int(m['ayahId'], 1, 6236);
      _int(m['page'], 1, 604);
      _int(m['color'], 0, 4294967295);
      boundedString(m['name'], 120, empty: true);
      var remainder = uq;
      for (final count in hafsAyahCounts) {
        if (remainder <= count) break;
        remainder -= count;
      }
      if (m['ayahNumber'] != remainder) {
        throw const FormatException('Bookmark Ayah mismatch');
      }
      return m;
    }).toList();
    if (marks.map((m) => m['id']).toSet().length != marks.length) {
      throw const FormatException('Duplicate bookmark ID');
    }
    final reader = objectMap(data['reader']);
    for (final e in reader.entries) {
      if (!readerBackupKeys.contains(e.key)) {
        throw const FormatException('Unknown reader field');
      }
      switch (e.key) {
        case 'last_page':
          _int(e.value, 1, 604);
        case 'fontsSelected2':
          _int(e.value, 0, 0);
        case 'IS_BOLD_BOOL':
        case 'IS_TAFSEER':
          _bool(e.value);
        case 'DISPLAY_MODE':
          _int(e.value, 0, 4);
        case 'FONT_SIZE':
          if (e.value is! num ||
              !(e.value as num).isFinite ||
              (e.value as num) < 10 ||
              (e.value as num) > 100) {
            throw const FormatException('Invalid font size');
          }
        case 'TAFSEER_VAL':
          _int(e.value, 0, 1000);
        case 'SURAH_READER_INDEX':
        case 'AYAH_READER_INDEX':
          _int(e.value, 0, 200);
        case 'LAST_SURAH':
          _int(e.value, 1, 114);
        case 'SELECTED_SURAH_INDEX':
          _int(e.value, 0, 113);
        case 'LAST_POSITION':
          _int(e.value, 0, 86400);
        case 'TRANS':
          boundedString(e.value, 80);
        case 'READER_NAME':
        case 'AYAH_AUDIO_PLAYER_SOUND':
          boundedString(e.value, 200, empty: true);
      }
    }
    final reminder = objectMap(data['reminder']);
    exactKeys(reminder, {'hour', 'minute'});
    return LocalBackup(
      createdAt: created,
      personal: PersonalData.fromJson(objectMap(data['personal'])),
      preferences: ReadingPreferences.fromJson(preferences),
      khatmah: khatmah,
      memorization: plans,
      bookmarks: marks,
      reader: reader,
      reminderHour: _int(reminder['hour'], 0, 23),
      reminderMinute: _int(reminder['minute'], 0, 59),
    );
  }
  static int _int(Object? v, int min, int max) {
    if (v is! int || v < min || v > max) {
      throw const FormatException('Invalid number');
    }
    return v;
  }

  static void _bool(Object? v) {
    if (v is! bool) throw const FormatException('Invalid boolean');
  }

  static DateTime _date(Object? v) {
    return strictBackupDate(v);
  }
}

/// Roll back every attempted key, including a write that mutates before throwing.
Future<void> restoreTransaction(
  Map<String, Object?> values, {
  required Future<Object?> Function(String) read,
  required Future<void> Function(String, Object?) write,
}) async {
  final before = <String, Object?>{};
  for (final key in values.keys) {
    before[key] = await read(key);
  }
  final attempted = <String>[];
  try {
    for (final e in values.entries) {
      attempted.add(e.key);
      await write(e.key, e.value);
    }
  } catch (error) {
    var rollbackFailed = false;
    for (final key in attempted.reversed) {
      try {
        await write(key, before[key]);
      } catch (_) {
        rollbackFailed = true;
      }
    }
    if (rollbackFailed) {
      throw StateError(
        'Restore and rollback failed; keep the exported safety copy',
      );
    }
    rethrow;
  }
}
