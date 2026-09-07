import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;
import 'tafsir_cache_store.dart';

TafsirCacheStore createTafsirCacheStore() => _BrowserTafsirCache();

class _BrowserTafsirCache implements TafsirCacheStore {
  static const cacheName = 'quran-haven-tafsir-v1';
  @override
  bool get supported {
    try {
      return web.window.isSecureContext &&
          !web.window.caches.isUndefinedOrNull &&
          !web.window.navigator.locks.isUndefinedOrNull;
    } catch (_) {
      return false;
    }
  }

  Future<web.Cache> _open() => web.window.caches.open(cacheName).toDart;

  @override
  Future<List<TafsirCacheEntry>> entries() async {
    final cache = await _open();
    final result = <TafsirCacheEntry>[];
    for (final request in (await cache.keys().toDart).toDart) {
      final response = await cache.match(request).toDart;
      if (response == null) continue;
      result.add(TafsirCacheEntry(
        url: Uri.parse(request.url),
        bytes: int.tryParse(response.headers.get('Content-Length') ?? '') ?? 0,
        sha256: response.headers.get('X-Quran-SHA256') ?? '',
      ));
    }
    return result;
  }

  @override
  Future<Uint8List?> read(Uri url) async {
    final response = await (await _open()).match(url.toString().toJS).toDart;
    if (response == null) return null;
    return (await response.arrayBuffer().toDart).toDart.asUint8List();
  }

  @override
  Future<void> put(TafsirCacheEntry entry, Uint8List bytes) async {
    final headers = web.Headers()
      ..set('Content-Type', 'application/gzip')
      ..set('Content-Length', bytes.length.toString())
      ..set('X-Quran-SHA256', entry.sha256);
    // Exact compressed bytes, without Content-Encoding: the app decompresses.
    await (await _open())
        .put(
            entry.url.toString().toJS,
            web.Response(
                bytes.toJS, web.ResponseInit(status: 200, headers: headers)))
        .toDart;
  }

  @override
  Future<void> delete(Uri url) async {
    await (await _open()).delete(url.toString().toJS).toDart;
  }

  @override
  Future<void> withWriteLock(Future<void> Function() action) async {
    // Includes other tabs: the budget check and publication are one operation.
    await web.window.navigator.locks
        .request(
            cacheName,
            ((web.Lock lock) {
              return action().then<JSAny?>((_) => null).toJS;
            }).toJS)
        .toDart;
  }

  @override
  Future<Uint8List> fetch(Uri url, int maxBytes,
      {void Function(int)? onProgress}) async {
    final abort = web.AbortController();
    final timer = Timer(const Duration(minutes: 2), () => abort.abort());
    try {
      final response = await web.window
          .fetch(
              url.toString().toJS,
              web.RequestInit(
                  credentials: 'omit',
                  cache: 'no-store',
                  redirect: 'error',
                  signal: abort.signal))
          .toDart;
      if (!response.ok || response.body == null) {
        throw StateError('Quran resource unavailable.');
      }
      final announced =
          int.tryParse(response.headers.get('Content-Length') ?? '');
      if (announced != null && announced > maxBytes) {
        throw StateError('Quran resource exceeds download limit.');
      }
      final reader = web.ReadableStreamDefaultReader(response.body!);
      final output = BytesBuilder(copy: false);
      try {
        while (true) {
          final chunk = await reader.read().toDart;
          if (chunk.done) break;
          final bytes = (chunk.value as JSUint8Array).toDart;
          if (output.length + bytes.length > maxBytes) {
            abort.abort();
            throw StateError('Quran resource exceeds download limit.');
          }
          output.add(bytes);
          onProgress?.call(output.length);
        }
      } finally {
        reader.releaseLock();
      }
      return output.takeBytes();
    } finally {
      timer.cancel();
      abort.abort();
    }
  }
}
