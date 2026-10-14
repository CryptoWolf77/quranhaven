import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:quran_library/quran_library.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/local_backup.dart';
import '../domain/personal_models.dart';

class BackupRepository {
  final _async = SharedPreferencesAsync();
  final _box = GetStorage();
  static const _strings = {
    'personal.tools.v1',
    'reader.preferences.v1',
    'plans.khatmah.v1',
    'plans.memorization.v1',
  };
  Future<Object?> _read(String key) async {
    if (key.startsWith('library:')) return _box.read(key.substring(8));
    if (key == 'reader.preferences.v1') {
      return (await SharedPreferences.getInstance()).getString(key);
    }
    if (_strings.contains(key)) return _async.getString(key);
    if (key == 'reminders.daily.enabled.v1') return _async.getBool(key);
    return _async.getInt(key);
  }

  Future<void> _write(String key, Object? value) async {
    if (key.startsWith('library:')) {
      final k = key.substring(8);
      if (value == null) {
        await _box.remove(k);
      } else {
        await _box.write(k, value);
      }
      return;
    }
    if (key == 'reader.preferences.v1') {
      final prefs = await SharedPreferences.getInstance();
      final ok = value == null
          ? await prefs.remove(key)
          : await prefs.setString(key, value as String);
      if (!ok) throw StateError('Local storage write failed');
      return;
    }
    if (value == null) {
      await _async.remove(key);
    } else if (value is String) {
      await _async.setString(key, value);
    } else if (value is bool) {
      await _async.setBool(key, value);
    } else {
      await _async.setInt(key, value as int);
    }
  }

  Future<LocalBackup> export() async {
    Object? decode(Object? v, Object? fallback) =>
        v == null ? fallback : jsonDecode(v as String);
    final reader = <String, Object?>{};
    for (final key in readerBackupKeys) {
      final v = _box.read(key);
      if (v != null) reader[key] = v;
    }
    final bookmarks = (_box.read<List>('bookmarks') ?? [])
        .map((e) => e is String ? jsonDecode(e) : e)
        .toList();
    final root = {
      'format': 'Quran Haven local backup',
      'schemaVersion': 1,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'data': {
        'personal': decode(
          await _read('personal.tools.v1'),
          const PersonalData().toJson(),
        ),
        'preferences': decode(await _read('reader.preferences.v1'), {
          'locale': null,
          'theme_mode': 'system',
        }),
        'khatmah': decode(await _read('plans.khatmah.v1'), null),
        'memorization': decode(await _read('plans.memorization.v1'), []),
        'bookmarks': bookmarks,
        'reader': reader,
        'reminder': {
          'hour': await _read('reminders.daily.hour.v1') ?? 19,
          'minute': await _read('reminders.daily.minute.v1') ?? 0,
        },
      },
    };
    return LocalBackup.decode(jsonEncode(root));
  }

  Future<void> restore(LocalBackup document) async {
    // Validate the entire document again before the first storage write.
    final backup = LocalBackup.decode(document.encode());
    for (final mark in backup.bookmarks) {
      final ayah = QuranCtrl.instance.getAyahByUq(mark['ayahId']! as int);
      if (ayah.page != mark['page']) {
        throw const FormatException('Bookmark page mismatch');
      }
    }
    for (final key in [
      'SURAH_READER_INDEX',
      'AYAH_READER_INDEX',
      'TAFSEER_VAL',
    ]) {
      final value = backup.reader[key];
      final length = key == 'TAFSEER_VAL'
          ? QuranLibrary().tafsirAndTraslationsCollection.length
          : key == 'SURAH_READER_INDEX'
          ? ReadersConstants.activeSurahReaders.length
          : ReadersConstants.activeAyahReaders.length;
      if (value != null && (value as int) >= length) {
        throw const FormatException('Unavailable reader selection');
      }
    }
    final values = <String, Object?>{
      'personal.tools.v1': jsonEncode(backup.personal.toJson()),
      'reader.preferences.v1': jsonEncode(backup.preferences.toJson()),
      'plans.khatmah.v1': backup.khatmah == null
          ? null
          : jsonEncode(backup.khatmah!.toJson()),
      'plans.memorization.v1': jsonEncode(
        backup.memorization.map((p) => p.toJson()).toList(),
      ),
      'library:bookmarks': backup.bookmarks.map(jsonEncode).toList(),
      for (final key in readerBackupKeys) 'library:$key': backup.reader[key],
      'reminders.daily.enabled.v1': false,
      'reminders.daily.hour.v1': backup.reminderHour,
      'reminders.daily.minute.v1': backup.reminderMinute,
    };
    await restoreTransaction(values, read: _read, write: _write);
  }
}
