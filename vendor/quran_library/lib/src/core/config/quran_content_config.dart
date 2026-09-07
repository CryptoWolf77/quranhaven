part of '/quran.dart';

/// Selects the host for optional learning resources before [QuranLibrary.init].
/// Bundled Quran text, metadata, fonts, and audio sources are unaffected.
class QuranContentConfig {
  QuranContentConfig._();

  static Uri? _baseUri;
  static bool _allowUpstreamFallback = false;

  static bool get isConfigured => _baseUri != null;
  static bool get canDownload => isConfigured || _allowUpstreamFallback;

  /// [baseUrl] is the complete versioned content root, for example
  /// `https://content.example.org/v1/`. A configured host is always exclusive:
  /// failures never contact the original providers, even if fallback is true.
  /// Without a host, upstream access requires explicit opt-in.
  static void configure({String? baseUrl, bool allowUpstreamFallback = false}) {
    final value = baseUrl?.trim() ?? '';
    Uri? parsed;
    if (value.isNotEmpty) {
      parsed = Uri.tryParse(value);
      if (parsed == null ||
          !parsed.hasAuthority ||
          parsed.host.isEmpty ||
          !const {'https', 'http'}.contains(parsed.scheme) ||
          parsed.userInfo.isNotEmpty ||
          parsed.hasQuery ||
          parsed.hasFragment) {
        throw ArgumentError.value(
          baseUrl,
          'baseUrl',
          'Expected an absolute HTTP(S) content root without credentials, query, or fragment.',
        );
      }
      parsed = parsed.replace(
        path: parsed.path.endsWith('/') ? parsed.path : '${parsed.path}/',
      );
    }
    _baseUri = parsed;
    _allowUpstreamFallback = allowUpstreamFallback;
  }

  /// Resolves a fixed resource path using the configured content policy.
  static List<String> candidates(
    String relativePath, {
    required List<String> upstream,
  }) {
    final path = Uri.tryParse(relativePath);
    if (path == null ||
        path.isAbsolute ||
        path.hasAuthority ||
        relativePath.startsWith('/') ||
        relativePath.contains('\\') ||
        path.hasQuery ||
        path.hasFragment ||
        path.pathSegments.any((segment) => segment == '..' || segment == '.')) {
      throw ArgumentError.value(
        relativePath,
        'relativePath',
        'Expected a path within the content root.',
      );
    }
    final base = _baseUri;
    if (base != null) return [base.resolveUri(path).toString()];
    if (_allowUpstreamFallback && upstream.isNotEmpty) return upstream;
    throw StateError('The Quran content server has not been configured.');
  }

  static void requireDownloadsConfigured() {
    if (!canDownload) {
      throw StateError('The Quran content server has not been configured.');
    }
  }
}
