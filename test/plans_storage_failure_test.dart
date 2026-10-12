import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_flutter/features/plans/data/plans_repository.dart';
import 'package:quran_flutter/features/plans/domain/plans_models.dart';
import 'package:quran_flutter/features/plans/presentation/plans_page.dart';
import 'package:quran_flutter/l10n/generated/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

final class UnusedPreferences extends SharedPreferencesAsyncPlatform {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class RejectingPlansRepository extends PlansRepository {
  KhatmahPlan? saved;
  bool rejectReads = false;
  bool rejectWrites = true;
  @override
  Future<KhatmahPlan?> loadKhatmah() async {
    if (rejectReads) throw StateError('storage unavailable');
    return saved;
  }

  @override
  Future<List<MemorizationPlan>> loadMemorizationPlans() async => [];
  @override
  Future<void> saveKhatmah(KhatmahPlan plan) async {
    if (rejectWrites) throw StateError('storage full');
    saved = plan;
  }

  @override
  Future<void> deleteKhatmah() async {
    if (rejectWrites) throw StateError('storage full');
    saved = null;
  }
}

Widget host(RejectingPlansRepository repository) => MaterialApp(
  locale: const Locale('en'),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ],
  home: Scaffold(
    body: PlansPage(
      currentPage: 1,
      onOpenReader: () {},
      repository: repository,
    ),
  ),
);

void main() {
  SharedPreferencesAsyncPlatform? previous;
  setUp(() {
    previous = SharedPreferencesAsyncPlatform.instance;
    SharedPreferencesAsyncPlatform.instance = UnusedPreferences();
  });
  tearDown(() => SharedPreferencesAsyncPlatform.instance = previous);
  testWidgets('rejected creation never claims a plan was saved', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repo = RejectingPlansRepository();
    await tester.pumpWidget(host(repo));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create Khatmah plan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start plan'));
    await tester.pumpAndSettle();
    expect(repo.saved, isNull);
    expect(find.text('Active Khatmah'), findsNothing);
    expect(
      find.textContaining('Your change could not be saved'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('rejected progress and deletion preserve the last saved plan', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repo = RejectingPlansRepository()
      ..saved = KhatmahPlan(
        startedAt: DateTime.now(),
        targetDate: DateTime.now().add(const Duration(days: 29)),
        completedPages: 10,
      );
    await tester.pumpWidget(host(repo));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Complete today's target"));
    await tester.pumpAndSettle();
    expect(repo.saved!.completedPages, 10);
    expect(find.text('10 of 604 pages'), findsOneWidget);
    await tester.tap(find.byTooltip('Plan options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete plan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(repo.saved, isNotNull);
    expect(find.text('10 of 604 pages'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('read failure shows retry without overwriting existing storage', (
    tester,
  ) async {
    final repo = RejectingPlansRepository()..rejectReads = true;
    await tester.pumpWidget(host(repo));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Local progress could not be read'),
      findsOneWidget,
    );
    expect(find.text('Create Khatmah plan'), findsNothing);
    repo.rejectReads = false;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('Create Khatmah plan'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
