abstract final class AppConfig {
  static const contentBaseUrl = String.fromEnvironment('QURAN_CONTENT_URL');

  /// Includes the versioned path, for example https://content.example.org/v1/.
  static Uri? get contentBaseUri => _validUri(contentBaseUrl, allowHttp: true);

  static Uri? _validUri(String value, {bool allowHttp = false}) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.hasAuthority) return null;
    if (uri.scheme == 'https' || (allowHttp && uri.scheme == 'http')) {
      return uri;
    }
    return null;
  }
}
