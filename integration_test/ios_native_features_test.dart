// Dedicated simulator installation only. Real downloads, Apple audio and native
// storage are exercised; no plugin channels are mocked.
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:quran_flutter/main.dart' as app;
import 'package:quran_flutter/features/personal/data/backup_repository.dart';
import 'package:quran_flutter/features/personal/data/personal_repository.dart';
import 'package:quran_flutter/features/personal/domain/local_backup.dart';
import 'package:quran_flutter/features/personal/domain/personal_models.dart';
import 'package:quran_flutter/features/personal/domain/saved_text_search.dart';
import 'package:quran_flutter/features/personal/presentation/share_ayah_page.dart';
import 'package:quran_flutter/features/plans/data/plans_repository.dart';
import 'package:quran_flutter/features/plans/domain/plans_models.dart';
import 'package:quran_flutter/l10n/generated/app_localizations.dart';
import 'package:quran_library/quran_library.dart';

Future<void> waitUntil(WidgetTester tester, bool Function() condition) async {
  final watch = Stopwatch()..start();
  while (!condition() && watch.elapsed < const Duration(seconds: 20)) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(condition(), isTrue);
}

// Fail closed for every Dart HTTP client during the saved-content phase.
// This affects test code only; production TLS/network configuration is untouched.
class DenyNetwork extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => throw StateError(
    'Network deliberately unavailable in offline acceptance',
  );
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  HttpClient.enableTimelineLogging = true;
  testWidgets(
    'native downloads, offline playback and JSON/PNG files',
    (tester) async {
      expect(Platform.isIOS, isTrue);
      await app.main();
      await tester.pumpAndSettle();
      final backupRepo = BackupRepository();
      final previous = await backupRepo.export();
      final evidence = <String, Object?>{};
      try {
        final personal = PersonalData(
          notes: [
            AyahNote(
              id: 'ios-native-fixture',
              reference: const AyahReference(1, 5),
              title: 'Native acceptance',
              body: 'بيانات اختبار · prueba',
              updatedAt: DateTime.utc(2026, 10, 15),
            ),
          ],
          collections: [
            const AyahCollection(
              id: 'ios-native-collection',
              name: 'اختبار',
              ayahs: [AyahReference(1, 5)],
            ),
          ],
        );
        await PersonalRepository().save(personal);
        await PlansRepository().saveKhatmah(
          KhatmahPlan(
            startedAt: DateTime(2026, 10, 15),
            targetDate: DateTime(2026, 11, 15),
            completedPages: 42,
            isPaused: true,
          ),
        );
        final exported = await backupRepo.export();
        final directory = await AudioCtrl.instance.state.dir;
        final file = File('${directory.path}/ios-native-acceptance.json');
        try {
          await file.writeAsString(exported.encode(), flush: true);
          final imported = LocalBackup.decode(await file.readAsString());
          await PersonalRepository().save(const PersonalData());
          await PlansRepository().deleteKhatmah();
          await backupRepo.restore(imported);
          expect(
            (await PersonalRepository().load()).toJson(),
            personal.toJson(),
          );
          final plan = await PlansRepository().loadKhatmah();
          expect(plan!.completedPages, 42);
          expect(plan.isPaused, isTrue);
          expect(() => LocalBackup.decode('{broken'), throwsFormatException);
          evidence['nativeBackupFile'] =
              'UTF-8 JSON file write/read/validated restore, notes/collections/paused plan retained';
        } finally {
          if (await file.exists()) await file.delete();
        }

        final library = QuranLibrary();
        final spanish = library.tafsirAndTraslationsCollection.indexWhere(
          (r) => r.fileName == 'es',
        );
        expect(spanish, greaterThanOrEqualTo(0));
        await library.prepareTafsir(spanish, pageNumber: 1);
        final onlineText = await TafsirCtrl.instance.readSavedResourceText(
          spanish,
        );
        final entries = parseSavedBook(onlineText);
        expect(entries.length, 6236);
        expect(entries.first.text, isNotEmpty);
        await library.refreshTafsirDownloads();
        expect(library.getTafsirDownloaded(spanish), isTrue);
        evidence['downloadedTranslation'] = {
          'language': 'es',
          'ayahs': entries.length,
        };

        final audio = AudioCtrl.instance;
        await audio.state.stopAllAudio();
        expect(await library.downloadSurahForOffline(surahNumber: 1), isTrue);
        expect(audio.state.audioPlayer.playing, isFalse);
        audio.state.selectSurahNumber(1);
        final recording = File(audio.localSurahFilePath);
        expect(await recording.length(), greaterThan(1000));
        final previousOverrides = HttpOverrides.current;
        HttpOverrides.global = DenyNetwork();
        try {
          expect(
            await TafsirCtrl.instance.readSavedResourceText(spanish),
            onlineText,
          );
          await library.prepareTafsir(spanish, pageNumber: 1);
          // changeAudioSource is the production path selecting the saved file.
          await audio.changeAudioSource();
          final playback = audio.state.audioPlayer.play();
          await waitUntil(
            tester,
            () => audio.state.audioPlayer.position.inMilliseconds > 700,
          );
          await audio.state.audioPlayer.pause();
          await playback;
          final paused = audio.state.audioPlayer.position;
          await tester.pump(const Duration(milliseconds: 600));
          expect(
            (audio.state.audioPlayer.position - paused).inMilliseconds.abs(),
            lessThan(250),
          );
          await audio.state.audioPlayer.seek(const Duration(seconds: 2));
          expect(
            audio.state.audioPlayer.position.inMilliseconds,
            closeTo(2000, 500),
          );
          evidence['savedAudio'] = {
            'bytes': await recording.length(),
            'noAutoplay': true,
            'offlinePlayPauseSeek': 'passed',
            'httpBlocked': true,
          };
        } finally {
          HttpOverrides.global = previousOverrides;
        }

        expect(await library.removeTafsirDownload(spanish), isTrue);
        expect(library.getTafsirDownloaded(spanish), isFalse);
        await library.prepareTafsir(spanish, pageNumber: 1);
        await library.refreshTafsirDownloads();
        expect(library.getTafsirDownloaded(spanish), isTrue);
        evidence['translationRemoveAndRedownload'] = 'passed';
        expect(audio.state.cachedArtUri?.scheme, 'file');
        evidence['audioArtwork'] = 'bundled Quran Haven logo, local file URI';

        await tester.pumpWidget(
          const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ShareAyahPage(reference: AyahReference(1, 5)),
          ),
        );
        await tester.pumpAndSettle();
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byType(RepaintBoundary).first,
        );
        final image = await boundary.toImage(pixelRatio: 2);
        try {
          final png = (await image.toByteData(
            format: ui.ImageByteFormat.png,
          ))!.buffer.asUint8List();
          final output = File('${directory.path}/ios-native-ayah.png');
          await output.writeAsBytes(png, flush: true);
          final read = await output.readAsBytes();
          expect(read.take(8).toList(), [137, 80, 78, 71, 13, 10, 26, 10]);
          evidence['nativePng'] = {
            'bytes': read.length,
            'width': image.width,
            'height': image.height,
          };
          await output.delete();
        } finally {
          image.dispose();
        }
        await binding.takeScreenshot('native-share-ayah-preview');
        expect(tester.takeException(), isNull);
      } finally {
        await AudioCtrl.instance.state.stopAllAudio();
        await backupRepo.restore(previous);
        binding.reportData = {...?binding.reportData, ...evidence};
        debugPrint('IOS_NATIVE_FEATURES ${jsonEncode(evidence)}');
      }
    },
    timeout: const Timeout(Duration(minutes: 8)),
  );
}
