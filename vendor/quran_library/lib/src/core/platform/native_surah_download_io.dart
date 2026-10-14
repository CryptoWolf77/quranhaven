import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

/// Download-only storage: never changes a player, playlist or listening position.
class NativeSurahDownloader {
  static const maxBytes = 256 * 1024 * 1024;

  static Future<bool> download({
    required String directory,
    required String readerPath,
    required String recordingRoot,
    required int surahNumber,
    required Dio dio,
    required CancelToken cancelToken,
    void Function(int received, int total)? onProgress,
  }) async {
    final root = Uri.parse(recordingRoot);
    // Existing reader paths intentionally include a trailing directory slash.
    final segments = readerPath.split('/');
    if (segments.isNotEmpty && segments.last.isEmpty) segments.removeLast();
    if (surahNumber < 1 ||
        surahNumber > 114 ||
        !root.isAbsolute ||
        root.scheme != 'https' ||
        root.host.isEmpty ||
        root.userInfo.isNotEmpty ||
        root.hasQuery ||
        root.hasFragment ||
        !root.path.endsWith('/') ||
        p.isAbsolute(readerPath) ||
        !RegExp(r'^[A-Za-z0-9_./-]+$').hasMatch(readerPath) ||
        segments.any((s) => s == '..' || s.isEmpty)) {
      throw ArgumentError('Invalid public recitation location');
    }
    final base = p.normalize(p.absolute(directory));
    final name = '$readerPath${surahNumber.toString().padLeft(3, '0')}.mp3';
    final target = File(p.join(base, name));
    if (!p.isWithin(base, target.path)) {
      throw ArgumentError('Audio path must remain in the app directory');
    }
    if (cancelToken.isCancelled) return false;
    if (await target.exists()) {
      if (!await _validMp3(target)) throw StateError('Invalid saved recording');
      return true;
    }

    File? partial;
    RandomAccessFile? sink;
    try {
      final response = await dio.get<ResponseBody>(
        root
            .resolve('${surahNumber.toString().padLeft(3, '0')}.mp3')
            .toString(),
        cancelToken: cancelToken,
        options: Options(
          responseType: ResponseType.stream,
          followRedirects: false,
          receiveTimeout: const Duration(seconds: 45),
          validateStatus: (code) => code == 200,
        ),
      );
      final body = response.data;
      if (body == null) throw StateError('Empty audio response');
      final declared = int.tryParse(
        response.headers.value(HttpHeaders.contentLengthHeader) ?? '',
      );
      if (declared != null && (declared < 10 || declared > maxBytes)) {
        throw StateError('Audio exceeds the supported size');
      }
      await target.parent.create(recursive: true);
      final nonce = Random.secure().nextInt(1 << 32).toRadixString(16);
      partial = File('${target.path}.part-$nonce');
      await partial.create(exclusive: true);
      sink = await partial.open(mode: FileMode.write);
      var received = 0;
      await for (final chunk in body.stream) {
        if (cancelToken.isCancelled) return false;
        received += chunk.length;
        if (received > maxBytes || (declared != null && received > declared)) {
          throw StateError('Audio response exceeded its declared size');
        }
        await sink.writeFrom(chunk);
        onProgress?.call(received, declared ?? 0);
      }
      await sink.flush();
      await sink.close();
      sink = null;
      if (cancelToken.isCancelled) return false;
      if ((declared != null && received != declared) ||
          !await _validMp3(partial)) {
        throw StateError('Incomplete or invalid MP3 recording');
      }
      // Never replace a recording that appeared while this download was active.
      if (await target.exists()) throw StateError('Recording already exists');
      await partial.rename(target.path);
      partial = null;
      return true;
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) return false;
      rethrow;
    } finally {
      await sink?.close();
      if (partial != null && await partial.exists()) await partial.delete();
    }
  }

  static Future<bool> _validMp3(File file) async {
    final size = await file.length();
    if (size < 10 || size > maxBytes) return false;
    final input = await file.open();
    try {
      final bytes = await input.read(4);
      return (bytes[0] == 0x49 && bytes[1] == 0x44 && bytes[2] == 0x33) ||
          (bytes[0] == 0xff &&
              (bytes[1] & 0xe0) == 0xe0 &&
              (bytes[1] & 0x18) != 0x08 &&
              (bytes[1] & 0x06) != 0);
    } finally {
      await input.close();
    }
  }
}
