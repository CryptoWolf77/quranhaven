import 'browser_audio_service_stub.dart'
    if (dart.library.js_interop) 'browser_audio_service_web.dart'
    as platform;

class BrowserAudioEntry {
  const BrowserAudioEntry({
    required this.url,
    required this.readerName,
    required this.surahNumber,
    required this.surahName,
    required this.bytes,
    required this.sha256,
  });
  final String url;
  final String readerName;
  final int surahNumber;
  final String surahName;
  final int bytes;
  final String sha256;
  factory BrowserAudioEntry.fromMap(Map<dynamic, dynamic> map) =>
      BrowserAudioEntry(
        url: map['url'] as String,
        readerName: map['readerName'] as String,
        surahNumber: (map['surahNumber'] as num).toInt(),
        surahName: map['surahName'] as String,
        bytes: (map['bytes'] as num).toInt(),
        sha256: map['sha256'] as String,
      );
}

class BrowserAudioStatus {
  const BrowserAudioStatus({
    this.state = 'idle',
    this.supported = false,
    this.completedBytes = 0,
    this.totalBytes = 0,
    this.errorCode,
  });
  final String state;
  final bool supported;
  final int completedBytes;
  final int totalBytes;
  final String? errorCode;
  factory BrowserAudioStatus.fromMap(Map<dynamic, dynamic> map) =>
      BrowserAudioStatus(
        state: map['state'] as String? ?? 'idle',
        supported: map['supported'] == true,
        completedBytes: (map['completedBytes'] as num?)?.toInt() ?? 0,
        totalBytes: (map['totalBytes'] as num?)?.toInt() ?? 0,
        errorCode: map['errorCode'] as String?,
      );
}

abstract class BrowserAudioService {
  Stream<BrowserAudioStatus> get changes;
  Future<List<BrowserAudioEntry>> list();
  Future<BrowserAudioEntry> download({
    required String url,
    required String readerName,
    required int surahNumber,
    required String surahName,
  });
  Future<void> cancel();
  Future<void> remove(String url);
  void dispose();
}

class BrowserAudioFailure implements Exception {
  const BrowserAudioFailure(this.code);
  final String code;
  @override
  String toString() => 'Browser audio: $code';
}

BrowserAudioService createBrowserAudioService() =>
    platform.createBrowserAudioService();
