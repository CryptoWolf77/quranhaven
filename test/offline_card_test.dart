import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_flutter/features/offline/data/offline_service.dart';
import 'package:quran_flutter/features/offline/domain/offline_status.dart';
import 'package:quran_flutter/features/offline/presentation/offline_card.dart';
import 'package:quran_flutter/l10n/generated/app_localizations.dart';

const _unprepared = OfflineStatus(supported: true, state: 'unprepared');
const _ready = OfflineStatus(
  supported: true,
  state: 'ready',
  offlineReady: true,
);
const _cancelled = OfflineStatus(
  supported: true,
  state: 'cancelled',
  offlineReady: true,
);

Widget _host(
  OfflineService service, {
  String locale = 'en',
  double textScale = 1,
}) {
  return MaterialApp(
    locale: Locale(locale),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
    home: Scaffold(
      body: SingleChildScrollView(child: OfflineCard(service: service)),
    ),
  );
}

void main() {
  late _FakeOfflineService service;

  setUp(() => service = _FakeOfflineService());
  tearDown(() => service.dispose());

  testWidgets(
    'opening only reads status and subscribes, without changing offline data',
    (tester) async {
      await tester.pumpWidget(_host(service));
      await tester.pumpAndSettle();

      expect(service.statusCalls, 1);
      expect(service.prepareCalls, 0);
      expect(service.cancelCalls, 0);
      expect(service.removeCalls, 0);
      expect(service.activateCalls, 0);
      expect(find.text('Not prepared for offline reading'), findsOneWidget);
      expect(service.events.hasListener, isTrue);
      await tester.pumpWidget(const SizedBox.shrink());
      expect(service.events.hasListener, isFalse);
      expect(
        service.disposed,
        isFalse,
        reason: 'The injected service belongs to its caller',
      );
    },
  );

  testWidgets('preparation requires a click and follows progress events', (
    tester,
  ) async {
    service.preparePending = Completer<OfflineStatus>();
    await tester.pumpWidget(_host(service));
    await tester.pumpAndSettle();
    expect(service.prepareCalls, 0);
    await tester.tap(find.text('Prepare offline reading'));
    await tester.pump();
    expect(service.prepareCalls, 1);

    service.emit(
      const OfflineStatus(
        supported: true,
        state: 'preparing',
        completedBytes: 1024 * 1024,
        totalBytes: 4 * 1024 * 1024,
      ),
    );
    await tester.pump();
    expect(find.text('Saving Quran for offline reading…'), findsOneWidget);
    expect(find.text('1.0 / 4.0 MB saved'), findsOneWidget);
    expect(
      tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .value,
      0.25,
    );
    expect(find.text('Cancel download'), findsOneWidget);
    service.preparePending!.complete(_ready);
    await tester.pumpAndSettle();
    expect(find.text('Ready for offline reading'), findsOneWidget);
  });

  testWidgets(
    'cancel explicitly interrupts preparation and retains the prepared version',
    (tester) async {
      service.preparePending = Completer<OfflineStatus>();
      await tester.pumpWidget(_host(service));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Prepare offline reading'));
      await tester.pump();
      service.emit(
        const OfflineStatus(
          supported: true,
          state: 'preparing',
          offlineReady: true,
        ),
      );
      await tester.pump();
      await tester.tap(find.text('Cancel download'));
      await tester.pumpAndSettle();

      expect(service.cancelCalls, 1);
      expect(service.removeCalls, 0);
      expect(
        find.text(
          'Download cancelled. A previously prepared version, if any, is kept.',
        ),
        findsOneWidget,
      );
      expect(find.text('Remove offline app files'), findsOneWidget);
    },
  );

  testWidgets(
    'removal does nothing until confirmed, and dialog cancellation preserves files',
    (tester) async {
      service.current = _ready;
      await tester.pumpWidget(_host(service));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove offline app files'));
      await tester.pumpAndSettle();
      expect(service.removeCalls, 0);
      expect(
        find.textContaining(
          'Your reading progress, account, and saved Tafsir are kept.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();
      expect(service.removeCalls, 0);
      expect(find.text('Ready for offline reading'), findsOneWidget);

      await tester.tap(find.text('Remove offline app files'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(TextButton, 'Remove offline app files'),
      );
      await tester.pumpAndSettle();
      expect(service.removeCalls, 1);
      expect(service.prepareCalls, 0);
      expect(service.cancelCalls, 0);
      expect(find.text('Offline app files removed'), findsOneWidget);
      expect(find.text('Not prepared for offline reading'), findsOneWidget);
    },
  );

  testWidgets('unsupported browsers cannot start preparation', (tester) async {
    service.current = const OfflineStatus();
    await tester.pumpWidget(_host(service));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Offline preparation is unavailable'),
      findsOneWidget,
    );
    final prepare = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Prepare offline reading'),
    );
    expect(prepare.onPressed, isNull);
    expect(find.text('Remove offline app files'), findsNothing);
    expect(service.prepareCalls, 0);
  });

  testWidgets(
    'an update does not activate or reload until the user chooses it',
    (tester) async {
      service.current = const OfflineStatus(
        supported: true,
        state: 'updateReady',
        offlineReady: true,
      );
      await tester.pumpWidget(_host(service));
      await tester.pumpAndSettle();
      expect(find.text('An offline update is ready'), findsOneWidget);
      expect(service.activateCalls, 0);
      await tester.tap(find.text('Apply update and reload'));
      await tester.pumpAndSettle();
      expect(service.activateCalls, 1);
      expect(service.prepareCalls, 0);
      expect(service.removeCalls, 0);
    },
  );

  for (final entry in const {
    'other_tabs_open':
        'Close other Quran Haven tabs, then apply the update again.',
    'activation_timeout':
        'The update could not activate yet. Reload this tab and try again.',
  }.entries) {
    testWidgets('${entry.key} offers a direct explicit activation retry', (
      tester,
    ) async {
      service.current = OfflineStatus(
        supported: true,
        state: 'error',
        offlineReady: true,
        errorCode: entry.key,
      );
      await tester.pumpWidget(_host(service));
      await tester.pumpAndSettle();
      expect(find.text(entry.value), findsOneWidget);
      expect(service.activateCalls, 0);
      await tester.tap(find.text('Apply update and reload'));
      await tester.pumpAndSettle();
      expect(service.activateCalls, 1);
      expect(service.prepareCalls, 0);
    });
  }

  testWidgets('action failures show an error and do not leave the card busy', (
    tester,
  ) async {
    service.prepareError = StateError('test storage failure');
    await tester.pumpWidget(_host(service));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Prepare offline reading'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Offline preparation could not finish.'),
      findsOneWidget,
    );
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cancel failures are shown without an unhandled exception', (
    tester,
  ) async {
    service.current = const OfflineStatus(supported: true, state: 'preparing');
    service.cancelError = StateError('test cancellation failure');
    await tester.pumpWidget(_host(service));
    await tester.pump();
    await tester.tap(find.text('Cancel download'));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(
      find.textContaining('Offline preparation could not finish.'),
      findsOneWidget,
    );
  });

  for (final locale in ['en', 'ar', 'es']) {
    testWidgets(
      '$locale card and confirmation fit a narrow screen at 2x text',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 600));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        service.current = _ready;
        await tester.pumpWidget(_host(service, locale: locale, textScale: 2));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final context = tester.element(find.byType(OfflineCard));
        final l10n = AppLocalizations.of(context);
        expect(
          Directionality.of(context),
          locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        );
        final remove = find.widgetWithText(OutlinedButton, l10n.offlineRemove);
        await tester.ensureVisible(remove);
        await tester.pumpAndSettle();
        await tester.tap(remove);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(service.removeCalls, 0);
        final cancel = find.widgetWithText(TextButton, l10n.cancel);
        await tester.ensureVisible(cancel);
        await tester.tap(cancel);
        await tester.pumpAndSettle();
        expect(service.removeCalls, 0);
      },
    );
  }
}

class _FakeOfflineService implements OfflineService {
  final events = StreamController<OfflineStatus>.broadcast(sync: true);
  OfflineStatus current = _unprepared;
  Completer<OfflineStatus>? preparePending;
  Object? prepareError;
  Object? cancelError;
  int statusCalls = 0;
  int prepareCalls = 0;
  int cancelCalls = 0;
  int removeCalls = 0;
  int activateCalls = 0;
  bool disposed = false;

  void emit(OfflineStatus value) {
    current = value;
    events.add(value);
  }

  @override
  Stream<OfflineStatus> get changes => events.stream;
  @override
  Future<OfflineStatus> status() async {
    statusCalls++;
    return current;
  }

  @override
  Future<OfflineStatus> prepare() async {
    prepareCalls++;
    if (prepareError != null) throw prepareError!;
    return preparePending?.future ?? _ready;
  }

  @override
  Future<OfflineStatus> cancel() async {
    cancelCalls++;
    if (cancelError != null) throw cancelError!;
    if (preparePending != null && !preparePending!.isCompleted) {
      preparePending!.complete(_cancelled);
    }
    return _cancelled;
  }

  @override
  Future<OfflineStatus> remove() async {
    removeCalls++;
    return _unprepared;
  }

  @override
  Future<OfflineStatus> activateAndReload() async {
    activateCalls++;
    return _ready;
  }

  @override
  void dispose() {
    if (disposed) return;
    disposed = true;
    events.close();
  }
}
