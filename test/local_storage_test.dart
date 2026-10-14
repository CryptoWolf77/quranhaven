import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_flutter/features/plans/data/plans_repository.dart';
import 'package:quran_flutter/features/plans/domain/plans_models.dart';
import 'package:quran_flutter/features/reminders/data/reminder_repository.dart';
import 'package:quran_flutter/features/settings/data/reading_preferences_repository.dart';
import 'package:quran_flutter/features/settings/domain/reading_preferences.dart';
import 'package:quran_flutter/features/settings/presentation/settings_page.dart';
import 'package:quran_flutter/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MemoryPreferences platform;
  SharedPreferencesAsyncPlatform? previousPlatform;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    previousPlatform = SharedPreferencesAsyncPlatform.instance;
    platform = MemoryPreferences();
    SharedPreferencesAsyncPlatform.instance = platform;
  });
  tearDown(() => SharedPreferencesAsyncPlatform.instance = previousPlatform);

  test(
    'an upgrade reads the existing preferences without a cloud account',
    () async {
      SharedPreferences.setMockInitialValues({
        'reader.preferences.v1': '{"locale":"ar","theme_mode":"dark"}',
      });
      final preferences = await ReadingPreferencesRepository().load();
      expect(preferences.locale, const Locale('ar'));
      expect(preferences.themeMode, ThemeMode.dark);
    },
  );

  test('all supported preferences survive a new repository instance', () async {
    for (final language in ['ar', 'en', 'es', null]) {
      for (final theme in ThemeMode.values) {
        await ReadingPreferencesRepository().save(
          ReadingPreferences(
            locale: language == null ? null : Locale(language),
            themeMode: theme,
          ),
        );
        final loaded = await ReadingPreferencesRepository().load();
        expect(loaded.locale?.languageCode, language);
        expect(loaded.themeMode, theme);
      }
    }
  });

  test(
    'invalid local preferences safely use defaults without clearing data',
    () async {
      for (final value in [
        'invalid',
        '[]',
        '{"locale":"xx"}',
        '{"theme_mode":"x"}',
      ]) {
        SharedPreferences.setMockInitialValues({
          'reader.preferences.v1': value,
          'unrelated': 'keep',
        });
        final loaded = await ReadingPreferencesRepository().load();
        expect(loaded.locale, isNull);
        expect(loaded.themeMode, ThemeMode.system);
        final storage = await SharedPreferences.getInstance();
        expect(storage.getString('unrelated'), 'keep');
        expect(storage.getString('reader.preferences.v1'), value);
      }
    },
  );

  test('Khatmah and memorization retain their existing local keys', () async {
    final khatmah = KhatmahPlan(
      startedAt: DateTime(2026, 10, 1),
      targetDate: DateTime(2026, 10, 30),
      completedPages: 42,
      isPaused: true,
    );
    const memorization = MemorizationPlan(
      id: 'existing-plan',
      surahNumber: 1,
      startAyah: 1,
      endAyah: 7,
      currentAyah: 3,
      repetitions: 5,
      rangeRepetitions: 2,
      delaySeconds: 3,
      hideAyah: true,
      memorizedAyahs: {1, 2},
      revisionAyahs: {3},
    );
    platform.values.addAll({
      'plans.khatmah.v1': jsonEncode(khatmah.toJson()),
      'plans.memorization.v1': jsonEncode([memorization.toJson()]),
      'unrelated': 'keep',
    });
    final repository = PlansRepository();
    expect((await repository.loadKhatmah())!.toJson(), khatmah.toJson());
    expect(
      (await repository.loadMemorizationPlans()).single.toJson(),
      memorization.toJson(),
    );

    final updated = khatmah.copyWith(completedPages: 50);
    await repository.saveKhatmah(updated);
    await repository.saveMemorizationPlans([
      memorization.copyWith(currentAyah: 4),
    ]);
    final restarted = PlansRepository();
    expect((await restarted.loadKhatmah())!.completedPages, 50);
    expect((await restarted.loadMemorizationPlans()).single.currentAyah, 4);
    await restarted.deleteKhatmah();
    expect(await PlansRepository().loadKhatmah(), isNull);
    expect(platform.values['unrelated'], 'keep');
    expect(platform.values.containsKey('plans.memorization.v1'), isTrue);
  });

  test(
    'daily reminder settings remain local across repository instances',
    () async {
      await ReminderRepository().save(
        const ReminderSettings(enabled: true, hour: 6, minute: 15),
      );
      final settings = await ReminderRepository().load();
      expect(settings.enabled, isTrue);
      expect(settings.hour, 6);
      expect(settings.minute, 15);
      expect(platform.values['reminders.daily.enabled.v1'], true);
    },
  );

  for (final language in ['ar', 'en', 'es']) {
    testWidgets('Settings explains local-only storage in $language', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(960, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      Locale? selectedLocale;
      ThemeMode? selectedTheme;
      final locale = Locale(language);
      final l10n = await AppLocalizations.delegate.load(locale);
      await tester.pumpWidget(
        MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SettingsPage(
              locale: locale,
              themeMode: ThemeMode.system,
              onLocaleChanged: (value) => selectedLocale = value,
              onThemeModeChanged: (value) => selectedTheme = value,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(l10n.localStorageTitle), findsOneWidget);
      expect(find.text(l10n.localStorageBody), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(find.byType(TextFormField), findsNothing);
      final targetLanguage = language == 'en' ? 'Español' : 'English';
      await tester.ensureVisible(find.text(targetLanguage));
      // The backup card makes Settings taller; settle the scroll/layout before
      // hit-testing a control below the original viewport.
      await tester.pumpAndSettle();
      await tester.tap(find.text(targetLanguage));
      expect(selectedLocale, Locale(language == 'en' ? 'es' : 'en'));
      await tester.ensureVisible(find.text(l10n.dark));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.dark));
      expect(selectedTheme, ThemeMode.dark);
      expect(tester.takeException(), isNull);
    });
  }

  test('current app/build source contains no cloud client configuration', () {
    for (final entity in Directory(
      'lib',
    ).listSync(recursive: true).whereType<File>()) {
      if (!entity.path.endsWith('.dart')) continue;
      final source = entity.readAsStringSync();
      for (final forbidden in [
        'QURAN_API_URL',
        'api.quranhaven.org',
        'flutter_secure_storage',
        'AccountRepository',
        'CloudRestoreService',
        'features/account/',
      ]) {
        expect(source, isNot(contains(forbidden)), reason: entity.path);
      }
    }
    expect(
      File('Dockerfile').readAsStringSync(),
      isNot(contains('QURAN_API_URL')),
    );
    expect(
      File('android/app/src/main/AndroidManifest.xml').readAsStringSync(),
      contains('android:allowBackup="false"'),
    );
  });
}

final class MemoryPreferences extends SharedPreferencesAsyncPlatform {
  final values = <String, Object>{};

  @override
  Future<String?> getString(
    String key,
    SharedPreferencesOptions options,
  ) async => values[key] as String?;
  @override
  Future<bool?> getBool(String key, SharedPreferencesOptions options) async =>
      values[key] as bool?;
  @override
  Future<int?> getInt(String key, SharedPreferencesOptions options) async =>
      values[key] as int?;
  @override
  Future<void> setString(
    String key,
    String value,
    SharedPreferencesOptions options,
  ) async {
    values[key] = value;
  }

  @override
  Future<void> setBool(
    String key,
    bool value,
    SharedPreferencesOptions options,
  ) async {
    values[key] = value;
  }

  @override
  Future<void> setInt(
    String key,
    int value,
    SharedPreferencesOptions options,
  ) async {
    values[key] = value;
  }

  @override
  Future<void> clear(
    ClearPreferencesParameters parameters,
    SharedPreferencesOptions options,
  ) async {
    final keys = parameters.filter.allowList ?? values.keys.toSet();
    for (final key in keys) {
      values.remove(key);
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
