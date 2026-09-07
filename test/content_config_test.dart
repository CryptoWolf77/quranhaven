import 'package:flutter_test/flutter_test.dart';
import 'package:quran_library/quran_library.dart';

void main() {
  tearDown(() => QuranContentConfig.configure());

  test('configured content host is exclusive even when fallback is requested', () {
    QuranContentConfig.configure(
      baseUrl: 'https://content.example.org/quran/v1',
      allowUpstreamFallback: true,
    );
    expect(
      QuranContentConfig.candidates(
        'tafsir/es.json.gz',
        upstream: ['https://upstream.invalid/es.json.gz'],
      ),
      ['https://content.example.org/quran/v1/tafsir/es.json.gz'],
    );
  });

  test('unconfigured downloads do not silently use upstream providers', () {
    QuranContentConfig.configure();
    expect(QuranContentConfig.isConfigured, isFalse);
    expect(
      () => QuranContentConfig.candidates(
        'archives/word_qeraat.zip',
        upstream: ['https://upstream.invalid/word_qeraat.zip'],
      ),
      throwsStateError,
    );
  });

  test('resource paths cannot escape the configured content root', () {
    QuranContentConfig.configure(baseUrl: 'https://content.example.org/v1/');
    for (final path in [
      '../private.json',
      '%2e%2e/private.json',
      '/private.json',
      '//other.example.org/file',
      'https://other.example.org/file',
      'tafsir/es.json.gz?redirect=1',
      r'..\private.json',
    ]) {
      expect(
        () => QuranContentConfig.candidates(path, upstream: []),
        throwsArgumentError,
        reason: path,
      );
    }
  });

  test('invalid configured roots fail before any request is made', () {
    for (final url in [
      'file:///content',
      'https://user:password@content.example.org/v1',
      'https://content.example.org/v1?token=secret',
      'https://content.example.org/v1#fragment',
    ]) {
      expect(
        () => QuranContentConfig.configure(baseUrl: url),
        throwsArgumentError,
      );
    }
  });
}
