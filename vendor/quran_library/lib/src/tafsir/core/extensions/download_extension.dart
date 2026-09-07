part of '../../tafsir.dart';

extension DownloadExtension on TafsirCtrl {
  Future<bool> downloadFile(
    String path,
    String url, {
    String? fallbackUrl,
  }) async {
    final urls = QuranContentConfig.candidates(
      'tafsir/${Uri.parse(url).pathSegments.last}',
      upstream: [url, if (fallbackUrl != null) fallbackUrl],
    );
    final dio = Dio()
      ..options.connectTimeout = const Duration(seconds: 20)
      ..options.receiveTimeout = const Duration(minutes: 2);
    final partialPath = '$path.part';
    cancelToken = CancelToken();
    try {
      await Directory(dirname(path)).create(recursive: true);
      isDownloading.value = true;
      onDownloading.value = true;
      progressString.value = "0";
      progress.value = 0;
      for (var index = 0; index < urls.length; index++) {
        try {
          await _doDownload(dio, urls[index], partialPath);
          break;
        } catch (e) {
          if (e is DioException && e.type == DioExceptionType.cancel) rethrow;
          if (index == urls.length - 1) rethrow;
          cancelToken = CancelToken();
        }
      }
      final target = File(path);
      if (await target.exists()) await target.delete();
      await File(partialPath).rename(path);
      progress.value = 1;
      progressString.value = "100";
      log("Download completed for $path");
      return true;
    } catch (e) {
      log("Quran content download failed: $e");
      progress.value = 0;
      progressString.value = "0";
      return false;
    } finally {
      try {
        final partial = File(partialPath);
        if (await partial.exists()) await partial.delete();
      } catch (_) {}
      isDownloading.value = false;
      onDownloading.value = false;
      update(['tafsirs_menu_list']);
      dio.close();
    }
  }

  Future<void> _doDownload(Dio dio, String url, String path) async {
    await dio.download(
      url,
      path,
      onReceiveProgress: (rec, total) {
        progressString.value =
            ((rec / (total == -1 ? 50000000 : total)) * 100).toStringAsFixed(0);
        progress.value =
            (rec / (total == -1 ? (total == -1 ? 50000000 : total) : total))
                .toDouble();
        log('progress: ${progressString.value}');
        log('Received: $rec, Total: $total');
      },
      cancelToken: cancelToken,
    );

    // Validate before replacing an existing downloaded resource.
    final file = File(path);
    final bytes = await file.readAsBytes();
    final isGzip = bytes.length >= 2 && bytes[0] == 0x1f && bytes[1] == 0x8b;
    final text = isGzip
        ? GzipJsonAssetService.decodeGzipBytesToString(
            Uint8List.fromList(bytes),
          )
        : utf8.decode(bytes);
    json.decode(text);
    await file.writeAsString(text, flush: true);
  }
}
