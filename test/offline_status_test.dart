import 'package:flutter_test/flutter_test.dart';
import 'package:quran_flutter/features/offline/domain/offline_status.dart';

void main() {
  test('status decodes valid progress and ready information', () {
    final status = OfflineStatus.fromMap({
      'supported': true,
      'state': 'preparing',
      'offlineReady': true,
      'completedBytes': 25,
      'totalBytes': 100,
      'persisted': false,
      'errorCode': 'cancelled',
    });
    expect(status.supported, isTrue);
    expect(status.preparing, isTrue);
    expect(status.offlineReady, isTrue);
    expect(status.progress, 0.25);
    expect(status.persisted, isFalse);
    expect(status.errorCode, 'cancelled');
  });

  test(
    'missing and malformed bridge values do not throw or imply readiness',
    () {
      for (final value in <Map<Object?, Object?>>[
        {},
        {'supported': 'true', 'offlineReady': 1, 'state': 3},
        {'completedBytes': -1, 'totalBytes': '100', 'persisted': 'true'},
        {'completedBytes': double.nan, 'totalBytes': double.infinity},
        {'errorCode': 400},
        {
          'errorCode': ['bad'],
        },
      ]) {
        final status = OfflineStatus.fromMap(value);
        expect(status.supported, isFalse);
        expect(status.offlineReady, isFalse);
        expect(status.completedBytes, 0);
        expect(status.totalBytes, 0);
        expect(status.progress, isNull);
        expect(status.persisted, isNull);
        expect(status.errorCode, isNull);
      }
    },
  );

  test('display progress stays bounded and zero totals are indeterminate', () {
    expect(
      OfflineStatus.fromMap({
        'completedBytes': 200,
        'totalBytes': 100,
      }).progress,
      1,
    );
    expect(
      OfflineStatus.fromMap({'completedBytes': 0, 'totalBytes': 100}).progress,
      0,
    );
    expect(
      OfflineStatus.fromMap({'completedBytes': 20, 'totalBytes': 0}).progress,
      isNull,
    );
    expect(
      OfflineStatus.fromMap({
        'completedBytes': 2.7,
        'totalBytes': 10.9,
      }).progress,
      0.2,
    );
  });
}
