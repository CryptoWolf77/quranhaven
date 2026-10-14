import 'package:dio/dio.dart';

/// Web downloads are handled by the host app's verified browser cache.
class NativeSurahDownloader {
  static Future<bool> download({
    required String directory,
    required String readerPath,
    required String recordingRoot,
    required int surahNumber,
    required Dio dio,
    required CancelToken cancelToken,
    void Function(int received, int total)? onProgress,
  }) =>
      Future.error(UnsupportedError('Native audio download is unavailable'));
}
