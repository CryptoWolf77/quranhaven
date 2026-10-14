import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_flutter/features/library/presentation/library_page.dart';

void main() {
  test(
    'the requested Surah is passed unchanged and success waits for storage',
    () async {
      final saved = Completer<bool>();
      final requested = <int>[];
      final session = NativeSurahDownloadSession(
        downloadAdapter: (surah) {
          requested.add(surah);
          return saved.future;
        },
        cancelAdapter: () {},
      );
      final result = session.download(67);
      expect(requested, [67]);
      expect(session.isBusy, isTrue);
      saved.complete(true);
      expect(await result, isTrue);
      expect(session.isBusy, isFalse);
    },
  );

  test(
    'cancellation stays locked until transfer cleanup returns false',
    () async {
      final transfer = Completer<bool>();
      var cancellations = 0;
      var downloads = 0;
      final session = NativeSurahDownloadSession(
        downloadAdapter: (_) {
          downloads++;
          return transfer.future;
        },
        cancelAdapter: () => cancellations++,
      );
      final result = session.download(2);
      await session.cancel();
      await session.cancel();
      expect(cancellations, 1);
      expect(session.isBusy, isTrue);
      await expectLater(session.download(1), throwsStateError);
      expect(downloads, 1);
      transfer.complete(false);
      expect(await result, isFalse);
      expect(session.isBusy, isFalse);
      await session.cancel();
      expect(cancellations, 1);
    },
  );

  test('failure propagates without becoming a completed download', () async {
    final failure = StateError('network or storage rejected');
    final session = NativeSurahDownloadSession(
      downloadAdapter: (_) async => throw failure,
      cancelAdapter: () {},
    );
    await expectLater(session.download(36), throwsA(same(failure)));
    expect(session.isBusy, isFalse);
  });

  test('a cancelled request can be retried after its future settles', () async {
    var attempt = 0;
    final session = NativeSurahDownloadSession(
      downloadAdapter: (_) async => ++attempt > 1,
      cancelAdapter: () {},
    );
    expect(await session.download(18), isFalse);
    expect(await session.download(18), isTrue);
    expect(attempt, 2);
    expect(session.isBusy, isFalse);
  });

  test(
    'cancellation adapter failure does not clear the active transfer',
    () async {
      final transfer = Completer<bool>();
      var cancellations = 0;
      final session = NativeSurahDownloadSession(
        downloadAdapter: (_) => transfer.future,
        cancelAdapter: () {
          cancellations++;
          if (cancellations == 1) throw StateError('cancel failed');
        },
      );
      final result = session.download(114);
      await expectLater(session.cancel(), throwsStateError);
      expect(session.isBusy, isTrue);
      await session.cancel();
      expect(cancellations, 2);
      transfer.complete(false);
      expect(await result, isFalse);
    },
  );

  test('out-of-range selection never reaches the native downloader', () async {
    final requested = <int>[];
    final session = NativeSurahDownloadSession(
      downloadAdapter: (surah) async {
        requested.add(surah);
        return true;
      },
      cancelAdapter: () {},
    );
    await expectLater(session.download(0), throwsRangeError);
    await expectLater(session.download(115), throwsRangeError);
    expect(requested, isEmpty);
    expect(session.isBusy, isFalse);
  });
}
