import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_library/src/core/platform/tafsir_cache_storage.dart';
import 'package:quran_library/src/core/platform/tafsir_cache_store.dart';
import 'package:quran_library/src/core/platform/verified_tafsir_cache.dart';

void main() {
  final url = Uri.parse('https://quranhaven.org/v1/tafsir/es.json.gz');
  late Uint8List bytes;
  late Uint8List manifest;
  late TafsirCacheEntry entry;
  late _MemoryStore store;

  setUp(() {
    bytes = File('content/public/v1/tafsir/es.json.gz').readAsBytesSync();
    manifest = File('content/public/v1/manifest.json').readAsBytesSync();
    entry = VerifiedTafsirCache.entryFromManifest(
      url,
      jsonDecode(utf8.decode(manifest)),
    );
    store = _MemoryStore(url: url, resource: bytes, manifest: manifest);
  });

  test(
    'valid download persists exact compressed bytes and reloads offline',
    () async {
      final cache = VerifiedTafsirCache(store: store);
      final text = await cache.loadText(url, translation: true);
      expect(text, contains('1:1'));
      expect(store.saved[url], bytes);
      expect(await cache.available(), contains(url));
      expect(store.requests, [url.resolve('../manifest.json'), url]);
      store.offline = true;
      final reloaded = VerifiedTafsirCache(store: store);
      expect(await reloaded.loadText(url, translation: true), text);
      expect(store.requests.length, 2);
    },
  );

  test('corrupt network bytes are never published', () async {
    store.resource = Uint8List.fromList(bytes)..[10] ^= 1;
    final cache = VerifiedTafsirCache(store: store);
    await expectLater(
      cache.loadText(url, translation: true),
      throwsFormatException,
    );
    expect(store.saved, isEmpty);
    expect(await cache.available(), isEmpty);
  });

  test('truncated network bytes are never published', () async {
    store.resource = bytes.sublist(0, bytes.length - 1);
    await expectLater(
      VerifiedTafsirCache(store: store).loadText(url, translation: true),
      throwsFormatException,
    );
    expect(store.saved, isEmpty);
  });

  test(
    'corrupt saved bytes are unavailable but remain explicitly deletable',
    () async {
      store.metadata[url] = entry;
      store.saved[url] = Uint8List.fromList(bytes)..[10] ^= 1;
      final cache = VerifiedTafsirCache(store: store);
      await expectLater(
        cache.loadText(url, translation: true),
        throwsFormatException,
      );
      expect(await cache.available(), isEmpty);
      expect(await cache.savedUrls(), contains(url));
      await cache.delete(url);
      expect(store.saved, isEmpty);
      expect(await cache.savedUrls(), isEmpty);
      await cache.loadText(url, translation: true);
      expect(await cache.available(), contains(url));
      expect(store.saved[url], bytes);
    },
  );

  test('storage refusal never reports a resource as saved', () async {
    store.refuseWrite = true;
    final cache = VerifiedTafsirCache(store: store);
    await expectLater(cache.loadText(url, translation: true), throwsStateError);
    expect(store.saved, isEmpty);
    expect(await cache.available(), isEmpty);
  });

  test(
    '160 MiB budget stops download and never evicts existing resources',
    () async {
      final other = Uri.parse('https://quranhaven.org/v1/tafsir/old.json.gz');
      store.metadata[other] = TafsirCacheEntry(
        url: other,
        bytes: VerifiedTafsirCache.maxStoredBytes,
        sha256: entry.sha256,
      );
      final cache = VerifiedTafsirCache(store: store);
      await expectLater(
        cache.loadText(url, translation: true),
        throwsStateError,
      );
      expect(store.metadata.containsKey(other), isTrue);
      expect(store.requests, [url.resolve('../manifest.json')]);
    },
  );

  test('only one download is active in an app instance', () async {
    store.waitForFetch = Completer<void>();
    final cache = VerifiedTafsirCache(store: store);
    final pending = cache.loadText(url, translation: true);
    await Future<void>.delayed(Duration.zero);
    await expectLater(cache.loadText(url, translation: true), throwsStateError);
    store.waitForFetch!.complete();
    await pending;
    expect(store.saved.length, 1);
  });

  test(
    'account, unrelated paths, insecure hosts and credential URLs are rejected',
    () {
      for (final path in [
        'https://quranhaven.org/v1/auth/login',
        'https://quranhaven.org/v1/account',
        'https://quranhaven.org/v1/sync',
        'https://quranhaven.org/v1/tafsir/es.json.gz?token=private',
        'https://reader:private@quranhaven.org/v1/tafsir/es.json.gz',
        'http://quranhaven.org/v1/tafsir/es.json.gz',
      ]) {
        expect(
          () => VerifiedTafsirCache.validateUrl(Uri.parse(path)),
          throwsArgumentError,
        );
      }
    },
  );

  test(
    'bad manifest entries, duplicate paths and oversized payloads are rejected',
    () {
      for (final files in [
        [],
        [
          {'path': 'tafsir/es.json.gz', 'bytes': -1, 'sha256': entry.sha256},
        ],
        [
          {
            'path': 'tafsir/es.json.gz',
            'bytes': VerifiedTafsirCache.maxCompressedBytes + 1,
            'sha256': entry.sha256,
          },
        ],
        [
          {'path': 'tafsir/es.json.gz', 'bytes': entry.bytes, 'sha256': 'bad'},
        ],
        [
          for (var i = 0; i < 2; i++)
            {
              'path': 'tafsir/es.json.gz',
              'bytes': entry.bytes,
              'sha256': entry.sha256,
            },
        ],
      ]) {
        expect(
          () => VerifiedTafsirCache.entryFromManifest(url, {
            'schema_version': 1,
            'files': files,
          }),
          throwsFormatException,
        );
      }
    },
  );

  test('decoded JSON must match the selected resource type', () {
    for (final value in [
      null,
      [],
      {},
      {'1:1': 42},
      {
        '1:1': {'t': 'text', 'f': []},
      },
    ]) {
      expect(
        () => VerifiedTafsirCache.validateJson(value, translation: true),
        throwsFormatException,
      );
    }
    expect(
      () => VerifiedTafsirCache.validateJson([
        {'text': 'missing metadata'},
      ], translation: false),
      throwsFormatException,
    );
  });

  test(
    'native cache adapter leaves existing native file behavior unchanged',
    () async {
      final native = createTafsirCacheStore();
      expect(native.supported, isFalse);
      expect(await native.entries(), isEmpty);
      expect(await native.read(url), isNull);
      await expectLater(native.put(entry, bytes), throwsUnsupportedError);
    },
  );

  test(
    'all 44 hosted resources pass byte, JSON and measured size limits',
    () {
      final rawManifest = jsonDecode(utf8.decode(manifest));
      final files = Directory('content/public/v1/tafsir')
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.json.gz'));
      var count = 0, compressedTotal = 0, largestDecoded = 0;
      for (final file in files) {
        final data = file.readAsBytesSync();
        final resourceUrl = url.resolve(file.uri.pathSegments.last);
        final info = VerifiedTafsirCache.entryFromManifest(
          resourceUrl,
          rawManifest,
        );
        final decodedBytes = gzip.decode(data);
        final text = utf8.decode(decodedBytes);
        final result = VerifiedTafsirCache.verifyAndDecode(
          data,
          info,
          translation: text.trimLeft().startsWith('{'),
        );
        expect(result, text, reason: file.path);
        compressedTotal += data.length;
        if (decodedBytes.length > largestDecoded) {
          largestDecoded = decodedBytes.length;
        }
        count++;
      }
      expect(count, 44);
      expect(compressedTotal, 126189490);
      expect(compressedTotal, lessThan(VerifiedTafsirCache.maxStoredBytes));
      expect(largestDecoded, 35649361);
      expect(largestDecoded, lessThan(VerifiedTafsirCache.maxDecodedBytes));
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}

class _MemoryStore implements TafsirCacheStore {
  _MemoryStore({
    required this.url,
    required this.resource,
    required this.manifest,
  });
  final Uri url;
  Uint8List resource;
  final Uint8List manifest;
  final Map<Uri, TafsirCacheEntry> metadata = {};
  final Map<Uri, Uint8List> saved = {};
  final List<Uri> requests = [];
  bool offline = false, refuseWrite = false;
  Completer<void>? waitForFetch;
  @override
  bool get supported => true;
  @override
  Future<List<TafsirCacheEntry>> entries() async => metadata.values.toList();
  @override
  Future<Uint8List?> read(Uri url) async => saved[url];
  @override
  Future<void> put(TafsirCacheEntry entry, Uint8List bytes) async {
    if (refuseWrite) throw StateError('Storage quota exceeded');
    saved[entry.url] = bytes;
    metadata[entry.url] = entry;
  }

  @override
  Future<void> delete(Uri url) async {
    saved.remove(url);
    metadata.remove(url);
  }

  @override
  Future<void> withWriteLock(Future<void> Function() action) => action();
  @override
  Future<Uint8List> fetch(
    Uri requested,
    int maxBytes, {
    void Function(int)? onProgress,
  }) async {
    if (offline) throw StateError('offline');
    requests.add(requested);
    if (waitForFetch != null) await waitForFetch!.future;
    final result = requested == url ? resource : manifest;
    if (result.length > maxBytes) throw StateError('Response exceeds limit');
    onProgress?.call(result.length);
    return result;
  }
}
