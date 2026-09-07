import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'tafsir_cache_storage.dart';
import 'tafsir_cache_store.dart';

/// Stores only verified optional public Quran content, never app/account data.
class VerifiedTafsirCache {
  VerifiedTafsirCache({TafsirCacheStore? store})
      : _store = store ?? createTafsirCacheStore();
  static const maxStoredBytes = 160 * 1024 * 1024;
  static const maxCompressedBytes = 12 * 1024 * 1024;
  static const maxDecodedBytes = 40 * 1024 * 1024;
  static const maxManifestBytes = 2 * 1024 * 1024;
  final TafsirCacheStore _store;
  final Set<Uri> _invalid = {};
  bool _busy = false;
  bool get supported => _store.supported;

  static void validateUrl(Uri url) {
    final local = url.host == 'localhost' || url.host == '127.0.0.1';
    if ((url.scheme != 'https' && !(url.scheme == 'http' && local)) ||
        !url.hasAuthority ||
        url.userInfo.isNotEmpty ||
        url.hasQuery ||
        url.hasFragment ||
        url.pathSegments.length < 3 ||
        url.pathSegments[url.pathSegments.length - 2] != 'tafsir' ||
        !RegExp(r'^[a-zA-Z0-9_-]+\.json\.gz$')
            .hasMatch(url.pathSegments.last)) {
      throw ArgumentError(
          'Only fixed self-hosted Tafsir resource URLs may be cached.');
    }
  }

  Future<Set<Uri>> available() async {
    if (!_store.supported) return {};
    return (await _store.entries())
        .where((entry) =>
            !_invalid.contains(entry.url) &&
            entry.bytes > 0 &&
            entry.bytes <= maxCompressedBytes &&
            RegExp(r'^[0-9a-f]{64}$').hasMatch(entry.sha256))
        .map((entry) => entry.url)
        .toSet();
  }

  Future<Set<Uri>> savedUrls() async => !_store.supported
      ? {}
      : (await _store.entries()).map((entry) => entry.url).toSet();

  Future<String> loadText(Uri url,
      {required bool translation, void Function(double)? onProgress}) async {
    validateUrl(url);
    if (!_store.supported) {
      throw UnsupportedError('Persistent Quran storage is unavailable.');
    }
    final existing =
        (await _store.entries()).where((entry) => entry.url == url).firstOrNull;
    if (existing != null) {
      final bytes = await _store.read(url);
      if (bytes != null) {
        try {
          return verifyAndDecode(bytes, existing, translation: translation);
        } catch (_) {
          _invalid.add(url);
          rethrow;
        }
      }
    }
    if (_busy) throw StateError('Another Quran download is already running.');
    _busy = true;
    String? text;
    try {
      await _store.withWriteLock(() async {
        final entries = await _store.entries();
        // Another tab may have finished this same resource while we waited.
        final saved = entries.where((entry) => entry.url == url).firstOrNull;
        if (saved != null) {
          final bytes = await _store.read(url);
          if (bytes != null) {
            text = verifyAndDecode(bytes, saved, translation: translation);
            return;
          }
        }
        final manifestBytes = await _store.fetch(
            url.resolve('../manifest.json'), maxManifestBytes);
        final entry =
            entryFromManifest(url, jsonDecode(utf8.decode(manifestBytes)));
        final used = entries
            .where((item) => item.url != url)
            .fold<int>(0, (sum, item) => sum + item.bytes);
        if (used + entry.bytes > maxStoredBytes) {
          throw StateError(
              'Remove a saved Quran resource before downloading another.');
        }
        final bytes = await _store.fetch(url, entry.bytes,
            onProgress: (count) => onProgress?.call(count / entry.bytes));
        text = verifyAndDecode(bytes, entry, translation: translation);
        // Cache.put is atomic; failures never mark a partially written resource available.
        await _store.put(entry, bytes);
        _invalid.remove(url);
      });
      return text!;
    } finally {
      _busy = false;
    }
  }

  Future<void> delete(Uri url) async {
    validateUrl(url);
    await _store.withWriteLock(() => _store.delete(url));
    _invalid.remove(url);
  }

  static TafsirCacheEntry entryFromManifest(Uri url, Object? raw) {
    validateUrl(url);
    if (raw is! Map || raw['schema_version'] != 1 || raw['files'] is! List) {
      throw const FormatException('Invalid Quran manifest.');
    }
    final path = 'tafsir/${url.pathSegments.last}';
    final matches = (raw['files'] as List)
        .where((item) => item is Map && item['path'] == path)
        .toList();
    if (matches.length != 1) {
      throw const FormatException(
          'Quran resource is not uniquely listed in the manifest.');
    }
    final file = matches.single as Map;
    final size = file['bytes'];
    final hash = file['sha256'];
    if (size is! int ||
        size < 1 ||
        size > maxCompressedBytes ||
        hash is! String ||
        !RegExp(r'^[0-9a-f]{64}$').hasMatch(hash)) {
      throw const FormatException('Invalid Quran resource integrity metadata.');
    }
    return TafsirCacheEntry(url: url, bytes: size, sha256: hash);
  }

  static String verifyAndDecode(Uint8List bytes, TafsirCacheEntry entry,
      {required bool translation}) {
    if (bytes.length != entry.bytes ||
        bytes.length > maxCompressedBytes ||
        crypto.sha256.convert(bytes).toString() != entry.sha256) {
      throw const FormatException('Quran resource integrity check failed.');
    }
    final output = _BoundedOutput(maxDecodedBytes);
    if (!const GZipDecoderWeb()
        .decodeStream(InputMemoryStream(bytes), output, verify: true)) {
      throw const FormatException('Invalid compressed Quran resource.');
    }
    final text = utf8.decode(output.getBytes());
    final decoded = jsonDecode(text);
    validateJson(decoded, translation: translation);
    return text;
  }

  static void validateJson(Object? decoded, {required bool translation}) {
    bool integer(Object? value, int min, int max) =>
        value is int && value >= min && value <= max;
    if (!translation) {
      if (decoded is! List || decoded.isEmpty || decoded.length > 7000) {
        throw const FormatException('Invalid Tafsir entries.');
      }
      for (final row in decoded) {
        if (row is! Map ||
            !integer(row['index'], 1, 6236) ||
            !integer(row['sura'], 1, 114) ||
            !integer(row['aya'], 1, 286) ||
            !integer(row['PageNum'], 1, 604) ||
            row['text'] is! String) {
          throw const FormatException('Invalid Tafsir entry.');
        }
      }
    } else {
      if (decoded is! Map || decoded.isEmpty || decoded.length > 7000) {
        throw const FormatException('Invalid translation entries.');
      }
      var readableEntries = 0;
      for (final entry in decoded.entries) {
        if (entry.key is! String ||
            !RegExp(r'^\d{1,3}:\d{1,3}$').hasMatch(entry.key)) {
          throw const FormatException('Invalid translation Ayah.');
        }
        final parts = (entry.key as String).split(':').map(int.parse).toList();
        if (!integer(parts[0], 1, 114) || !integer(parts[1], 1, 286)) {
          throw const FormatException('Invalid translation Ayah.');
        }
        final value = entry.value;
        final row = value is String ? decoded[value] : value;
        // Some verified Tafsir books deliberately have no commentary for an
        // Ayah. Preserve those empty entries without inventing content.
        if (row is Map && row.isEmpty) continue;
        if (row is! Map || (row['t'] is! String && row['text'] is! String)) {
          throw const FormatException('Invalid translation text.');
        }
        readableEntries++;
        if (row['f'] != null &&
            (row['f'] is! Map ||
                (row['f'] as Map)
                    .entries
                    .any((e) => e.key is! String || e.value is! String))) {
          throw const FormatException('Invalid translation footnotes.');
        }
      }
      if (readableEntries == 0) {
        throw const FormatException('Translation has no readable entries.');
      }
    }
  }
}

class _BoundedOutput extends OutputMemoryStream {
  _BoundedOutput(this.limit);
  final int limit;
  void _check(int additional) {
    if (length + additional > limit) {
      throw const FormatException('Decoded Quran resource exceeds the limit.');
    }
  }

  @override
  void writeByte(int value) {
    _check(1);
    super.writeByte(value);
  }

  @override
  void writeBytes(List<int> bytes, {int? length}) {
    _check(length ?? bytes.length);
    super.writeBytes(bytes, length: length);
  }

  @override
  void writeStream(InputStream stream) {
    _check(stream.length);
    super.writeStream(stream);
  }
}
