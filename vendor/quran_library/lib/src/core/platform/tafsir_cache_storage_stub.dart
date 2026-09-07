import 'dart:typed_data';
import 'tafsir_cache_store.dart';

TafsirCacheStore createTafsirCacheStore() => _NativeTafsirCache();

class _NativeTafsirCache implements TafsirCacheStore {
  @override
  bool get supported => false;
  Never _unavailable() => throw UnsupportedError(
      'Native Quran downloads use their existing file storage.');
  @override
  Future<List<TafsirCacheEntry>> entries() async => [];
  @override
  Future<Uint8List?> read(Uri url) async => null;
  @override
  Future<void> put(TafsirCacheEntry entry, Uint8List bytes) async =>
      _unavailable();
  @override
  Future<void> delete(Uri url) async => _unavailable();
  @override
  Future<void> withWriteLock(Future<void> Function() action) async =>
      _unavailable();
  @override
  Future<Uint8List> fetch(Uri url, int maxBytes,
          {void Function(int)? onProgress}) async =>
      _unavailable();
}
