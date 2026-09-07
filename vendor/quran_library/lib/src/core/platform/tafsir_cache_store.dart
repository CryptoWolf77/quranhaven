import 'dart:typed_data';

class TafsirCacheEntry {
  const TafsirCacheEntry(
      {required this.url, required this.bytes, required this.sha256});
  final Uri url;
  final int bytes;
  final String sha256;
}

abstract interface class TafsirCacheStore {
  bool get supported;
  Future<List<TafsirCacheEntry>> entries();
  Future<Uint8List?> read(Uri url);
  Future<void> put(TafsirCacheEntry entry, Uint8List bytes);
  Future<void> delete(Uri url);
  Future<void> withWriteLock(Future<void> Function() action);
  Future<Uint8List> fetch(Uri url, int maxBytes,
      {void Function(int)? onProgress});
}
