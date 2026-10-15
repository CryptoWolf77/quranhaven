// Run only in a dedicated test installation. Uses real Apple plugins, bundled
// videos, fonts and the production content URL; no mocked platform channels.
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:quran_flutter/main.dart' as app;
import 'package:quran_flutter/app/quran_app.dart';
import 'package:quran_flutter/features/guide/presentation/tutorial_video_controller.dart';
import 'package:quran_flutter/features/settings/data/reading_preferences_repository.dart';
import 'package:quran_flutter/features/settings/domain/reading_preferences.dart';
import 'package:quran_flutter/features/personal/data/personal_repository.dart';
import 'package:quran_flutter/features/personal/domain/personal_models.dart';
import 'package:quran_flutter/l10n/generated/app_localizations.dart';
import 'package:quran_library/quran_library.dart';

Future<void> until(
  WidgetTester tester,
  bool Function() ready, {
  Duration timeout = const Duration(seconds: 15),
}) async {
  final watch = Stopwatch()..start();
  while (!ready() && watch.elapsed < timeout) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(ready(), isTrue, reason: 'Timed out after $timeout');
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final evidence = <String, Object?>{};

  testWidgets(
    'real iOS localized navigation and native storage',
    (tester) async {
      expect(Platform.isIOS, isTrue);
      await app.main();
      await tester.pumpAndSettle();
      final repo = ReadingPreferencesRepository();
      final original = await repo.load();
      final personal = PersonalRepository();
      final previous = await personal.load();
      final fixture = AyahNote(
        id: 'ios-acceptance-fixture',
        reference: const AyahReference(1, 5),
        title: 'iOS acceptance',
        body: 'بيانات اختبار · prueba',
        updatedAt: DateTime.utc(2026, 10, 15),
      );
      try {
        await personal.save(
          PersonalData(
            notes: [...previous.notes, fixture],
            collections: previous.collections,
          ),
        );
        expect(
          (await PersonalRepository().load()).notes.last.body,
          fixture.body,
        );
        evidence['nativePersonalStorage'] = 'round-trip passed';
        for (final language in ['ar', 'en', 'es']) {
          final l = lookupAppLocalizations(Locale(language));
          for (final theme in [ThemeMode.light, ThemeMode.dark]) {
            await tester.pumpWidget(const SizedBox.shrink());
            await repo.save(
              ReadingPreferences(locale: Locale(language), themeMode: theme),
            );
            await tester.pumpWidget(const QuranApp());
            await tester.pumpAndSettle();
            final home = find.byKey(const ValueKey('home-guide-open'));
            expect(home, findsOneWidget);
            expect(
              Directionality.of(tester.element(home)),
              language == 'ar' ? TextDirection.rtl : TextDirection.ltr,
            );
            await binding.takeScreenshot('$language-${theme.name}-home');
            for (final label in [l.quran, l.library, l.plans, l.settings]) {
              // The same destination label is exposed by NavigationBar and Rail.
              final rail = find.byType(NavigationRail);
              final icons = {
                l.quran: Icons.menu_book_outlined,
                l.library: Icons.local_library_outlined,
                l.plans: Icons.track_changes_outlined,
                l.settings: Icons.tune_outlined,
              };
              final nav = rail.evaluate().isEmpty
                  ? find.text(label).hitTestable().last
                  : find.descendant(
                      of: rail,
                      matching: find.byIcon(icons[label]!),
                    );
              await tester.tap(nav);
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);
              if (theme == ThemeMode.light || label == l.quran) {
                final screen = label == l.quran
                    ? 'reader'
                    : label == l.library
                    ? 'library'
                    : label == l.plans
                    ? 'plans'
                    : 'settings';
                await binding.takeScreenshot('$language-${theme.name}-$screen');
              }
            }
            final rail = find.byType(NavigationRail);
            await tester.tap(
              rail.evaluate().isEmpty
                  ? find.text(l.home).hitTestable().last
                  : find.descendant(
                      of: rail,
                      matching: find.byIcon(Icons.home_outlined),
                    ),
            );
            await tester.pumpAndSettle();
            await tester.ensureVisible(home);
            await tester.tap(home);
            await tester.pumpAndSettle();
            expect(find.text(l.guideTitle).hitTestable(), findsWidgets);
            if (theme == ThemeMode.light) {
              await binding.takeScreenshot('$language-light-guide');
            }
            await tester.tap(find.byType(BackButton));
            await tester.pumpAndSettle();
          }
        }
        // Exercise canonical first/last page navigation on the actual native view.
        QuranLibrary().jumpToPage(604);
        await tester.pumpAndSettle();
        QuranLibrary().jumpToPage(1);
        await tester.pumpAndSettle();
        evidence['localizedNavigation'] =
            'ar/en/es light/dark, all five destinations and guide';
      } finally {
        await personal.save(previous);
        await repo.save(original);
      }
      binding.reportData = {...?binding.reportData, ...evidence};
    },
    timeout: const Timeout(Duration(minutes: 10)),
  );

  testWidgets(
    'all 39 bundled videos decode, pause, seek, end and replay on Apple',
    (tester) async {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final videos =
          manifest
              .listAssets()
              .where(
                (a) => a.startsWith('assets/tutorials/') && a.endsWith('.mp4'),
              )
              .toList()
            ..sort();
      expect(videos.length, 39);
      final results = <Map<String, Object?>>[];
      for (final asset in videos) {
        final video = createTutorialVideo(asset);
        try {
          await video.initialize();
          expect(video.initialized, isTrue);
          expect(video.hasError, isFalse);
          expect(video.playing, isFalse, reason: 'No autoplay: $asset');
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Center(
                  child: SizedBox(
                    width: 300,
                    height: 600,
                    child: video.video(),
                  ),
                ),
              ),
            ),
          );
          await video.play();
          await until(
            tester,
            () => video.position > const Duration(milliseconds: 500),
          );
          await video.pause();
          final paused = video.position;
          await tester.pump(const Duration(milliseconds: 650));
          expect((video.position - paused).inMilliseconds.abs(), lessThan(250));
          final middle = Duration(
            milliseconds: video.duration.inMilliseconds ~/ 2,
          );
          await video.seek(middle);
          await tester.pump(const Duration(milliseconds: 250));
          expect((video.position - middle).inMilliseconds.abs(), lessThan(750));
          await video.seek(video.duration - const Duration(milliseconds: 400));
          await video.play();
          await until(tester, () => video.ended);
          await video.seek(Duration.zero);
          await video.play();
          await until(
            tester,
            () => video.position > const Duration(milliseconds: 250),
          );
          expect(video.hasError, isFalse);
          results.add({
            'asset': asset,
            'durationMs': video.duration.inMilliseconds,
            'playPauseSeekEndReplay': 'passed',
          });
        } finally {
          await tester.pumpWidget(const SizedBox.shrink());
          await video.release();
        }
        // Retain partial evidence if a later decoder fails.
        binding.reportData = {
          ...?binding.reportData,
          ...evidence,
          'nativeVideos': results,
        };
        debugPrint('IOS_VIDEO_PASS ${jsonEncode(results.last)}');
      }
    },
    timeout: const Timeout(Duration(minutes: 15)),
    skip: const bool.fromEnvironment('IOS_UI_ONLY'),
  );
}
