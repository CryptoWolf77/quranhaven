import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_library/quran_library.dart';
import 'package:quran_library/src/core/platform/native_surah_download_io.dart';

void main() {
  late Directory directory;
  late _AudioAdapter adapter;
  late Dio dio;
  final mp3 = Uint8List.fromList([0x49, 0x44, 0x33, ...List.filled(97, 0)]);

  setUp(() async {
    directory = await Directory.systemTemp.createTemp(
      'quran-native-audio-test-',
    );
    adapter = _AudioAdapter(mp3);
    dio = Dio()..httpClientAdapter = adapter;
  });
  tearDown(() async {
    dio.close(force: true);
    await directory.delete(recursive: true);
  });

  Future<bool> download({
    int surah = 3,
    String path = '128/ar.test',
    String root = 'https://audio.example.test/murattal/',
    CancelToken? token,
    void Function(int, int)? onProgress,
  }) => NativeSurahDownloader.download(
    directory: directory.path,
    readerPath: path,
    recordingRoot: root,
    surahNumber: surah,
    dio: dio,
    cancelToken: token ?? CancelToken(),
    onProgress: onProgress,
  );

  test(
    'stores exact selected Surah and preserves an earlier recording',
    () async {
      final previous = File('${directory.path}/128/ar.test001.mp3');
      await previous.parent.create(recursive: true);
      await previous.writeAsBytes(mp3);
      expect(await download(), isTrue);
      expect(
        adapter.requests.single.uri.toString(),
        'https://audio.example.test/murattal/003.mp3',
      );
      expect(adapter.requests.single.followRedirects, isFalse);
      expect(
        await File('${directory.path}/128/ar.test003.mp3').readAsBytes(),
        mp3,
      );
      expect(await previous.readAsBytes(), mp3);
      expect(
        await directory
            .list(recursive: true)
            .where((f) => f.path.contains('.part-'))
            .length,
        0,
      );
    },
  );
  test(
    'existing valid recording succeeds without network or player access',
    () async {
      expect(await download(), isTrue);
      adapter.requests.clear();
      expect(await download(), isTrue);
      expect(adapter.requests, isEmpty);
    },
  );
  test(
    'retains legacy slash-suffixed reader directory and exact114 filename',
    () async {
      expect(
        await download(surah: 114, path: 'abdulBasit/murattal/mp3/'),
        isTrue,
      );
      expect(adapter.requests.single.uri.path, '/murattal/114.mp3');
      expect(
        await File(
          '${directory.path}/abdulBasit/murattal/mp3/114.mp3',
        ).readAsBytes(),
        mp3,
      );
    },
  );
  test(
    'all29 approved Surah profiles keep their native offline paths',
    () async {
      for (final reader in ReadersConstants.surahReaderInfo) {
        expect(
          await NativeSurahDownloader.download(
            directory: directory.path,
            readerPath: reader.readerNamePath,
            recordingRoot: reader.recordingRoot,
            surahNumber: 114,
            dio: dio,
            cancelToken: CancelToken(),
          ),
          isTrue,
          reason: reader.name,
        );
        expect(
          await File(
            '${directory.path}/${reader.readerNamePath}114.mp3',
          ).readAsBytes(),
          mp3,
        );
      }
    },
  );
  test(
    'invalid existing bytes are preserved and never reported as ready',
    () async {
      final target = File('${directory.path}/128/ar.test003.mp3');
      await target.parent.create(recursive: true);
      await target.writeAsString('this is not audio');
      await expectLater(download(), throwsStateError);
      expect(await target.readAsString(), 'this is not audio');
      expect(adapter.requests, isEmpty);
    },
  );
  test('cancel removes only its partial file and reports false', () async {
    final token = CancelToken();
    adapter.chunked = true;
    expect(
      await download(
        token: token,
        onProgress: (_, _) {
          token.cancel('Owner cancelled');
        },
      ),
      isFalse,
    );
    expect(
      await directory.list(recursive: true).where((f) => f is File).length,
      0,
    );
  });
  test('cancel before start makes no request', () async {
    final token = CancelToken()..cancel();
    expect(await download(token: token), isFalse);
    expect(adapter.requests, isEmpty);
  });
  test(
    'non-MP3 response is rejected without a completed or partial file',
    () async {
      adapter.bytes = Uint8List.fromList(List.filled(100, 0x3c));
      await expectLater(download(), throwsStateError);
      expect(
        await directory.list(recursive: true).where((f) => f is File).length,
        0,
      );
    },
  );
  test('truncated content length is rejected and cleaned', () async {
    adapter.declared = mp3.length + 10;
    await expectLater(download(), throwsStateError);
    expect(
      await directory.list(recursive: true).where((f) => f is File).length,
      0,
    );
  });
  test('overlarge declared response is rejected before writing', () async {
    adapter.declared = NativeSurahDownloader.maxBytes + 1;
    await expectLater(download(), throwsStateError);
    expect(
      await directory.list(recursive: true).where((f) => f is File).length,
      0,
    );
  });
  test('missing content length still permits a bounded valid MP3', () async {
    adapter.omitLength = true;
    expect(await download(), isTrue);
  });
  test('HTTP failure propagates rather than falsely succeeding', () async {
    adapter.status = 503;
    await expectLater(download(), throwsA(isA<DioException>()));
    expect(
      await directory.list(recursive: true).where((f) => f is File).length,
      0,
    );
  });
  test('rejects wrong Surah bounds, traversal and non-public URLs', () async {
    for (final surah in [0, 115]) {
      await expectLater(download(surah: surah), throwsArgumentError);
    }
    for (final path in ['../escape', '/absolute', 'test//name']) {
      await expectLater(download(path: path), throwsArgumentError);
    }
    for (final root in [
      'http://audio.example/',
      'https://user:pass@audio.example/',
      'https://audio.example/?secret=1',
      'https://audio.example/#fragment',
    ]) {
      await expectLater(download(root: root), throwsArgumentError);
    }
    expect(adapter.requests, isEmpty);
  });
}

class _AudioAdapter implements HttpClientAdapter {
  _AudioAdapter(this.bytes);
  Uint8List bytes;
  int? declared;
  int status = 200;
  bool chunked = false;
  bool omitLength = false;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final stream = chunked
        ? Stream<Uint8List>.fromIterable([
            Uint8List.sublistView(bytes, 0, 20),
            Uint8List.sublistView(bytes, 20),
          ])
        : Stream<Uint8List>.value(bytes);
    return ResponseBody(
      stream,
      status,
      headers: {
        'content-type': ['audio/mpeg'],
        if (!omitLength) 'content-length': ['${declared ?? bytes.length}'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
