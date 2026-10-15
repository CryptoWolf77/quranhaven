// Run seed as simulator build 14, then verify as build 15 without uninstalling.
// Only the dedicated acceptance simulator is suitable for this two-stage test.
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:quran_flutter/main.dart' as app;
import 'package:quran_flutter/features/personal/data/backup_repository.dart';
import 'package:quran_flutter/features/personal/data/personal_repository.dart';
import 'package:quran_flutter/features/personal/domain/local_backup.dart';
import 'package:quran_flutter/features/personal/domain/personal_models.dart';
import 'package:quran_flutter/features/plans/data/plans_repository.dart';
import 'package:quran_flutter/features/plans/domain/plans_models.dart';
import 'package:quran_library/quran_library.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const phase = String.fromEnvironment('IOS_UPDATE_PHASE');
  testWidgets('personal records survive an in-place simulator update', (
    tester,
  ) async {
    expect(Platform.isIOS, isTrue);
    expect(phase, anyOf('seed', 'verify'));
    await app.main();
    await tester.pumpAndSettle();
    final directory = await AudioCtrl.instance.state.dir;
    final prior = File('${directory.path}/ios-update-prior.json');
    final marker = File('${directory.path}/ios-update-marker.txt');
    final repo = BackupRepository();
    final fixture = PersonalData(
      notes: [
        AyahNote(
          id: 'ios-update-fixture',
          reference: const AyahReference(1, 5),
          title: 'In-place update acceptance',
          body: 'اختبار ترقية محلي · prueba local',
          updatedAt: DateTime.utc(2026, 10, 15),
        ),
      ],
      collections: [
        const AyahCollection(
          id: 'ios-update-collection',
          name: 'Update acceptance',
          ayahs: [AyahReference(1, 5)],
        ),
      ],
    );
    if (phase == 'seed') {
      // Fail closed if a previous interrupted run still needs its restoration.
      expect(await prior.exists(), isFalse);
      await prior.writeAsString((await repo.export()).encode(), flush: true);
      await PersonalRepository().save(fixture);
      await PlansRepository().saveKhatmah(
        KhatmahPlan(
          startedAt: DateTime(2026, 10, 15),
          targetDate: DateTime(2026, 11, 15),
          completedPages: 42,
          isPaused: true,
        ),
      );
      await marker.writeAsString('Quran Haven iOS update fixture', flush: true);
      binding.reportData = {'phase': phase, 'seeded': true};
    } else {
      expect(await prior.exists(), isTrue);
      final previous = LocalBackup.decode(await prior.readAsString());
      try {
        expect((await PersonalRepository().load()).toJson(), fixture.toJson());
        final plan = await PlansRepository().loadKhatmah();
        expect(plan, isNotNull);
        expect(plan!.completedPages, 42);
        expect(plan.isPaused, isTrue);
        expect(await marker.readAsString(), 'Quran Haven iOS update fixture');
        binding.reportData = {
          'phase': phase,
          'notesAndCollectionsRetained': true,
          'pausedPlanRetained': true,
          'sandboxFileRetained': true,
        };
      } finally {
        await repo.restore(previous);
        await marker.delete();
        await prior.delete();
      }
    }
    expect(tester.takeException(), isNull);
  });
}
