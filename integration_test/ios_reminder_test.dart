// Run on a dedicated iOS simulator with Notifications already allowed in its
// Settings. The separate manual denial check must precede this acceptance run.
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:integration_test/integration_test.dart';
import 'package:quran_flutter/main.dart' as app;
import 'package:quran_flutter/features/reminders/data/reminder_service.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'daily native reminder is unique, delivered and cancellable',
    (tester) async {
      expect(Platform.isIOS, isTrue);
      await app.main();
      await tester.pumpAndSettle();
      final plugin = FlutterLocalNotificationsPlugin();
      final service = ReminderService(notifications: plugin);
      try {
        await service.cancelDaily();
        // Resolve the OS permission prompt before choosing the minute to test;
        // time spent on that prompt must not move the test target into the past.
        expect(
          await service.scheduleDaily(
            hour: 0,
            minute: 0,
            title: 'Quran Haven permission acceptance',
            body: 'Temporary test schedule',
          ),
          isTrue,
        );
        await service.cancelDaily();
        final target = DateTime.now().add(const Duration(minutes: 1));
        debugPrint(
          'IOS_REMINDER_CLOCK now=${DateTime.now().toIso8601String()} zone=${DateTime.now().timeZoneOffset} native=${(await FlutterTimezone.getLocalTimezone()).identifier} target=$target',
        );
        await plugin.show(
          id: 2002,
          title: 'Quran Haven immediate acceptance',
          body: 'Foreground delivery diagnostic',
          notificationDetails: const NotificationDetails(
            iOS: DarwinNotificationDetails(),
          ),
        );
        await tester.pump(const Duration(seconds: 2));
        debugPrint(
          'IOS_REMINDER_IMMEDIATE ${(await plugin.getActiveNotifications()).map((n) => '${n.id}:${n.title}').toList()}',
        );
        for (var attempt = 0; attempt < 2; attempt++) {
          expect(
            await service.scheduleDaily(
              hour: target.hour,
              minute: target.minute,
              title: 'Quran Haven iOS acceptance',
              body: 'Local daily reminder test',
            ),
            isTrue,
          );
          final pending = await plugin.pendingNotificationRequests();
          expect(pending.where((r) => r.id == 2001).length, 1);
        }
        final watch = Stopwatch()..start();
        var delivered = false;
        while (!delivered && watch.elapsed < const Duration(seconds: 90)) {
          await tester.pump(const Duration(milliseconds: 250));
          delivered = (await plugin.getActiveNotifications()).any(
            (r) => r.id == 2001,
          );
        }
        expect(
          delivered,
          isTrue,
          reason: 'Must observe actual OS delivery, not only saved settings',
        );
        binding.reportData = {
          ...?binding.reportData,
          'nativeDailyReminder': {
            'uniqueAfterReschedule': true,
            'actuallyDelivered': true,
            'scheduledHour': target.hour,
            'scheduledMinute': target.minute,
            'observedAt': DateTime.now().toIso8601String(),
          },
        };
        await binding.takeScreenshot('native-reminder-delivered');
      } finally {
        await plugin.cancel(id: 2002);
        await service.cancelDaily();
        expect(
          (await plugin.pendingNotificationRequests()).where(
            (r) => r.id == 2001,
          ),
          isEmpty,
        );
      }
    },
    timeout: const Timeout(Duration(minutes: 4)),
  );
}
