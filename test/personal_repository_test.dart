import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quran_flutter/features/personal/data/personal_repository.dart';
import 'package:quran_flutter/features/personal/domain/personal_models.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

final class MemoryPersonalPrefs extends SharedPreferencesAsyncPlatform {
  String? value;
  bool fail = false;
  int writes = 0;
  @override
  Future<String?> getString(
    String key,
    SharedPreferencesOptions options,
  ) async => value;
  @override
  Future<void> setString(
    String key,
    String value,
    SharedPreferencesOptions options,
  ) async {
    if (fail) throw StateError('quota');
    this.value = value;
    writes++;
  }

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

void main() {
  SharedPreferencesAsyncPlatform? original;
  late MemoryPersonalPrefs prefs;
  setUp(() {
    original = SharedPreferencesAsyncPlatform.instance;
    prefs = MemoryPersonalPrefs();
    SharedPreferencesAsyncPlatform.instance = prefs;
  });
  tearDown(() => SharedPreferencesAsyncPlatform.instance = original);
  test('a corrupt saved document is reported without overwriting it', () async {
    prefs.value = '{corrupt';
    final repo = PersonalRepository();
    await expectLater(repo.load(), throwsFormatException);
    expect(prefs.value, '{corrupt');
    expect(prefs.writes, 0);
  });
  test(
    'write failure preserves prior data and never returns success',
    () async {
      final repo = PersonalRepository();
      await repo.save(const PersonalData());
      final before = prefs.value;
      prefs.fail = true;
      await expectLater(
        repo.save(
          const PersonalData(
            collections: [AyahCollection(id: 'c1', name: 'Daily', ayahs: [])],
          ),
        ),
        throwsStateError,
      );
      expect(prefs.value, before);
      expect(prefs.writes, 1);
    },
  );
}
