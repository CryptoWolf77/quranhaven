import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import '../domain/corpus_morphology.dart';

CorpusIndex verifyCorpusBytes(Uint8List bytes) {
  if (bytes.length != corpusByteCount ||
      sha256.convert(bytes).toString() != corpusSha256) {
    throw const FormatException('Corpus integrity verification failed');
  }
  return CorpusIndex.parse(utf8.decode(bytes));
}

class CorpusRepository {
  static Future<CorpusIndex>? _pending;
  Future<CorpusIndex> load() {
    return _pending ??= _read().catchError((Object error, StackTrace stack) {
      _pending = null;
      Error.throwWithStackTrace(error, stack);
    });
  }

  Future<CorpusIndex> _read() async {
    final data = await rootBundle.load(corpusAsset);
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    return verifyCorpusBytes(bytes);
  }

  Future<String> licenseText() => rootBundle.loadString(corpusLicenseAsset);
  Future<String> provenanceText() =>
      rootBundle.loadString('assets/learning/SOURCE.json');
}
