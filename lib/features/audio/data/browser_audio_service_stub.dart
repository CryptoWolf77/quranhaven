import 'browser_audio_service.dart';

BrowserAudioService createBrowserAudioService() => _UnavailableAudioService();

class _UnavailableAudioService implements BrowserAudioService {
  @override
  Stream<BrowserAudioStatus> get changes => const Stream.empty();
  @override
  Future<List<BrowserAudioEntry>> list() async => [];
  @override
  Future<BrowserAudioEntry> download({
    required String url,
    required String readerName,
    required int surahNumber,
    required String surahName,
  }) async => throw const BrowserAudioFailure('unavailable');
  @override
  Future<void> cancel() async {}
  @override
  Future<void> remove(String url) async =>
      throw const BrowserAudioFailure('unavailable');
  @override
  void dispose() {}
}
