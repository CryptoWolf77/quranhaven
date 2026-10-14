import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:quran_flutter/features/personal/data/local_files_stub.dart';
import 'package:quran_flutter/features/personal/data/local_restore_lifecycle.dart';
import 'package:share_plus/share_plus.dart';

class _MisreportedFile extends XFile {
  _MisreportedFile() : super('unused');
  @override
  Future<int> length() async => 10;
  @override
  Stream<Uint8List> openRead([int? start, int? end]) async* {
    yield Uint8List(5 * 1024 * 1024);
    yield Uint8List(1);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const documents = MethodChannel('org.quranhaven/local_documents');
  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(documents, null),
  );
  test(
    'Android SAF sends exact JSON only to user-mediated save channel',
    () async {
      MethodCall? sent;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(documents, (call) async {
            sent = call;
            return true;
          });
      final bytes = Uint8List.fromList(utf8.encode('{"local":"private"}'));
      expect(
        await saveAndroidDocument(
          bytes,
          'quran-backup.json',
          'application/json',
        ),
        true,
      );
      expect(sent!.method, 'save');
      expect(sent!.arguments['bytes'], bytes);
      expect(sent!.arguments['mime'], 'application/json');
      expect(sent!.arguments['name'], 'quran-backup.json');
    },
  );
  test(
    'Android save cancellation or unavailable result never claims saved',
    () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(documents, (_) async => false);
      expect(
        await saveAndroidDocument(
          Uint8List.fromList([123, 125]),
          'backup.json',
          'application/json',
        ),
        false,
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(documents, (_) async => null);
      expect(
        await saveAndroidDocument(
          Uint8List.fromList([123, 125]),
          'backup.json',
          'application/json',
        ),
        false,
      );
    },
  );
  test(
    'Android provider errors propagate without a fake successful save',
    () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            documents,
            (_) async => throw PlatformException(code: 'save_failed'),
          );
      await expectLater(
        saveAndroidDocument(
          Uint8List.fromList([123, 125]),
          'backup.json',
          'application/json',
        ),
        throwsA(isA<PlatformException>()),
      );
    },
  );
  test(
    'Android export rejects traversal, unsupported type, mismatch and oversized bytes before chooser',
    () async {
      var called = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(documents, (_) async {
            called = true;
            return true;
          });
      for (final entry in [
        ('../backup.json', 'application/json'),
        ('backup.json', 'text/html'),
        ('image.png', 'application/json'),
      ]) {
        await expectLater(
          saveAndroidDocument(
            Uint8List.fromList([123, 125]),
            entry.$1,
            entry.$2,
          ),
          throwsFormatException,
        );
      }
      await expectLater(
        saveAndroidDocument(
          Uint8List(5 * 1024 * 1024 + 1),
          'backup.json',
          'application/json',
        ),
        throwsFormatException,
      );
      expect(called, false);
    },
  );
  test(
    'native document chooser cancellation returns null without reads',
    () async {
      expect(await chooseBackupFile(picker: () async => null), null);
    },
  );
  test('native JSON document is exact UTF8 with no writes', () async {
    const source = '{"note":"ملاحظة خاصة"}';
    final file = XFile.fromData(
      Uint8List.fromList(utf8.encode(source)),
      name: 'backup.json',
    );
    expect(await chooseBackupFile(picker: () async => file), source);
  });
  test('oversized selected document rejected before decode', () async {
    final file = XFile.fromData(Uint8List(5 * 1024 * 1024 + 1));
    await expectLater(readBoundedBackupFile(file), throwsFormatException);
  });
  test(
    'bounded stream rejects a lying size without accepting partial content',
    () async {
      await expectLater(
        readBoundedBackupFile(_MisreportedFile()),
        throwsFormatException,
      );
    },
  );
  test('invalid UTF8 selected document rejected', () async {
    await expectLater(
      readBoundedBackupFile(XFile.fromData(Uint8List.fromList([0xff]))),
      throwsFormatException,
    );
  });
  for (final status in ShareResultStatus.values) {
    test(
      'native share result ${status.name} preserves honest completion',
      () async {
        final bytes = Uint8List.fromList(utf8.encode('private local JSON'));
        ShareParams? sent;
        final result = await shareLocalFile(
          bytes,
          'backup.json',
          'application/json',
          origin: const Rect.fromLTWH(10, 10, 40, 40),
          share: (params) async {
            sent = params;
            return ShareResult('test', status);
          },
        );
        expect(result, status == ShareResultStatus.success);
        expect(sent!.fileNameOverrides, ['backup.json']);
        expect(sent!.files!.single.mimeType, 'application/json');
        expect(await sent!.files!.single.readAsBytes(), bytes);
        expect(sent!.sharePositionOrigin, const Rect.fromLTWH(10, 10, 40, 40));
      },
    );
  }
  test(
    'native iPad sharing refuses absent anchor and does not call OS',
    () async {
      var called = false;
      await expectLater(
        shareLocalFile(
          Uint8List(1),
          'image.png',
          'image/png',
          share: (_) async {
            called = true;
            return const ShareResult('test', ShareResultStatus.success);
          },
        ),
        throwsStateError,
      );
      expect(called, false);
    },
  );
  test('native share failure is propagated, never reported as saved', () async {
    await expectLater(
      shareLocalFile(
        Uint8List(1),
        'image.png',
        'image/png',
        origin: const Rect.fromLTWH(1, 1, 10, 10),
        share: (_) async => throw StateError('system share failed'),
      ),
      throwsStateError,
    );
  });
  test(
    'restore lifecycle preparation and refresh are separate, failures propagate',
    () async {
      var prepared = 0, refreshed = 0;
      LocalRestoreLifecycle.beforeRestore = () async {
        prepared++;
      };
      LocalRestoreLifecycle.refreshAfterRestore = () async {
        refreshed++;
        throw StateError('restart required');
      };
      addTearDown(() {
        LocalRestoreLifecycle.beforeRestore = null;
        LocalRestoreLifecycle.refreshAfterRestore = null;
      });
      await LocalRestoreLifecycle.prepare();
      expect(prepared, 1);
      expect(refreshed, 0);
      await expectLater(LocalRestoreLifecycle.refresh(), throwsStateError);
      expect(refreshed, 1);
    },
  );
}
