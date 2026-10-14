import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_flutter/features/reminders/data/reminder_repository.dart';
import 'package:quran_flutter/features/reminders/data/reminder_service.dart';
import 'package:quran_flutter/features/settings/presentation/settings_page.dart';
import 'package:quran_flutter/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'local_storage_test.dart' show MemoryPreferences;

class _Repository extends ReminderRepository {
  ReminderSettings value = const ReminderSettings(
    enabled: false,
    hour: 19,
    minute: 0,
  );
  final writes = <ReminderSettings>[];
  final failWrites = <int>{};
  bool failLoad = false;
  @override
  Future<ReminderSettings> load() async {
    if (failLoad) throw StateError('read');
    return value;
  }

  @override
  Future<void> save(ReminderSettings next) async {
    writes.add(next);
    if (failWrites.contains(writes.length)) throw StateError('write');
    value = next;
  }
}

class _Notifications extends ReminderService {
  bool allowed = true, failSchedule = false, failCancel = false, active = true;
  int cancellations = 0;
  final scheduled = <TimeOfDay>[];
  @override
  bool get isSupported => true;
  @override
  Future<void> cancelDaily() async {
    cancellations++;
    if (failCancel) throw StateError('cancel');
    active = false;
  }

  @override
  Future<bool> scheduleDaily({
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    scheduled.add(TimeOfDay(hour: hour, minute: minute));
    if (failSchedule) {
      active = true;
      throw StateError('schedule');
    }
    active = allowed;
    return allowed;
  }
}

Widget _host(
  _Repository repository,
  _Notifications notifications, {
  String language = 'es',
}) => MaterialApp(
  locale: Locale(language),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  builder: (c, child) => MediaQuery(
    data: MediaQuery.of(c).copyWith(alwaysUse24HourFormat: false),
    child: child!,
  ),
  home: Scaffold(
    body: SettingsPage(
      locale: Locale(language),
      themeMode: ThemeMode.system,
      onLocaleChanged: (_) {},
      onThemeModeChanged: (_) {},
      reminderRepository: repository,
      reminderService: notifications,
    ),
  ),
);
Future<void> _editMinute(WidgetTester t, {int minute = 15}) async {
  final button = find.byIcon(Icons.schedule_rounded);
  await t.ensureVisible(button);
  await t.pumpAndSettle();
  await t.tap(button);
  await t.pumpAndSettle();
  final context = t.element(find.byType(TimePickerDialog)),
      material = MaterialLocalizations.of(context);
  await t.tap(find.byTooltip(material.inputTimeModeButtonLabel));
  await t.pumpAndSettle();
  final fields = find.byType(TextFormField);
  expect(fields, findsNWidgets(2));
  final expectedHour = material.formatHour(
    const TimeOfDay(hour: 19, minute: 0),
    alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(
      t.element(fields.first),
    ),
  );
  expect(t.widget<TextFormField>(fields.first).controller!.text, expectedHour);
  await t.enterText(fields.at(1), '$minute');
  await t.tap(find.text(material.okButtonLabel));
  await t.pumpAndSettle();
  expect(find.byType(TimePickerDialog), findsNothing);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferencesAsyncPlatform? previous;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    previous = SharedPreferencesAsyncPlatform.instance;
    SharedPreferencesAsyncPlatform.instance = MemoryPreferences();
  });
  tearDown(() => SharedPreferencesAsyncPlatform.instance = previous);
  for (final language in ['ar', 'en', 'es']) {
    testWidgets(
      '$language 19:00 on12-hour device preserves hour when only minute changes',
      (t) async {
        final repo = _Repository(), service = _Notifications();
        await t.pumpWidget(_host(repo, service, language: language));
        await t.pumpAndSettle();
        await _editMinute(t);
        expect(repo.value.hour, 19);
        expect(repo.value.minute, 15);
        expect(repo.value.enabled, false);
        expect(service.scheduled, isEmpty);
        expect(
          MediaQuery.alwaysUse24HourFormatOf(
            t.element(find.byType(SettingsPage)),
          ),
          false,
        );
        expect(t.takeException(), null);
      },
    );
  }
  testWidgets(
    'enabled time change publishes success only after scheduling and persistence',
    (t) async {
      final repo = _Repository()
        ..value = const ReminderSettings(enabled: true, hour: 19, minute: 0);
      final service = _Notifications();
      await t.pumpWidget(_host(repo, service));
      await t.pumpAndSettle();
      await _editMinute(t);
      expect(service.scheduled.single, const TimeOfDay(hour: 19, minute: 15));
      expect(repo.writes.map((v) => v.enabled), [false, true]);
      expect(repo.value.enabled, true);
      expect(repo.value.minute, 15);
      expect(service.active, true);
      expect(t.widget<SwitchListTile>(find.byType(SwitchListTile)).value, true);
    },
  );
  testWidgets(
    'permission-denied schedule leaves new time durably disabled, not falsely enabled',
    (t) async {
      final repo = _Repository()
        ..value = const ReminderSettings(enabled: true, hour: 19, minute: 0);
      final service = _Notifications()..allowed = false;
      await t.pumpWidget(_host(repo, service));
      await t.pumpAndSettle();
      await _editMinute(t);
      expect(repo.value.enabled, false);
      expect(repo.value.minute, 15);
      expect(service.active, false);
      expect(
        t.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
        false,
      );
      final l = await AppLocalizations.delegate.load(const Locale('es'));
      expect(find.text(l.notificationDenied), findsOneWidget);
      expect(t.takeException(), null);
    },
  );
  testWidgets(
    'scheduling exception cancels partial notification and recovers disabled old time',
    (t) async {
      final repo = _Repository()
        ..value = const ReminderSettings(enabled: true, hour: 19, minute: 0);
      final service = _Notifications()..failSchedule = true;
      await t.pumpWidget(_host(repo, service));
      await t.pumpAndSettle();
      await _editMinute(t);
      expect(repo.value.enabled, false);
      expect(repo.value.minute, 0);
      expect(service.active, false);
      final l = await AppLocalizations.delegate.load(const Locale('es'));
      expect(find.text(l.reminderUpdateFailed), findsOneWidget);
      expect(t.takeException(), null);
    },
  );
  testWidgets(
    'failed enabled write cancels scheduled notification and restores disabled snapshot',
    (t) async {
      final repo = _Repository()
        ..value = const ReminderSettings(enabled: true, hour: 19, minute: 0)
        ..failWrites.add(2);
      final service = _Notifications();
      await t.pumpWidget(_host(repo, service));
      await t.pumpAndSettle();
      await _editMinute(t);
      expect(repo.value.enabled, false);
      expect(repo.value.minute, 0);
      expect(service.active, false);
      expect(service.cancellations, 2);
      final l = await AppLocalizations.delegate.load(const Locale('es'));
      expect(find.text(l.localSaveFailed), findsOneWidget);
      expect(t.takeException(), null);
    },
  );
  testWidgets(
    'cancellation failure keeps previous durable setting visible and performs no writes',
    (t) async {
      final repo = _Repository()
        ..value = const ReminderSettings(enabled: true, hour: 19, minute: 0);
      final service = _Notifications()..failCancel = true;
      await t.pumpWidget(_host(repo, service));
      await t.pumpAndSettle();
      await _editMinute(t);
      expect(repo.value.enabled, true);
      expect(repo.value.minute, 0);
      expect(repo.writes, isEmpty);
      expect(service.scheduled, isEmpty);
      expect(t.widget<SwitchListTile>(find.byType(SwitchListTile)).value, true);
      expect(t.takeException(), null);
    },
  );
  testWidgets(
    'unrecoverable storage fault explains uncertainty instead of claiming enabled',
    (t) async {
      final repo = _Repository()
        ..value = const ReminderSettings(enabled: true, hour: 19, minute: 0)
        ..failWrites.addAll([1, 2]);
      final service = _Notifications();
      await t.pumpWidget(_host(repo, service));
      await t.pumpAndSettle();
      await _editMinute(t);
      expect(service.scheduled, isEmpty);
      expect(service.active, false);
      expect(
        t.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
        false,
      );
      final l = await AppLocalizations.delegate.load(const Locale('es'));
      expect(find.text(l.reminderStateUncertain), findsOneWidget);
      expect(t.takeException(), null);
    },
  );
  testWidgets(
    'failed reminder load preserves data and blocks writes until explicit retry',
    (t) async {
      final repo = _Repository()..failLoad = true;
      final service = _Notifications();
      await t.pumpWidget(_host(repo, service));
      await t.pumpAndSettle();
      expect(find.byType(SwitchListTile), findsNothing);
      expect(repo.writes, isEmpty);
      final l = await AppLocalizations.delegate.load(const Locale('es'));
      await t.ensureVisible(find.text(l.retry));
      await t.pumpAndSettle();
      repo.failLoad = false;
      await t.tap(find.text(l.retry));
      await t.pumpAndSettle();
      expect(find.byType(SwitchListTile), findsOneWidget);
      expect(repo.writes, isEmpty);
      expect(t.takeException(), null);
    },
  );
}
