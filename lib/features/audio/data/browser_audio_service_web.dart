import 'dart:async';
import 'dart:js_interop';
import 'package:quran_library/quran_library.dart';
import 'package:web/web.dart' as web;
import 'browser_audio_service.dart';

@JS('quranAudio')
external _AudioBridge? get _bridge;
extension type _AudioBridge._(JSObject _) implements JSObject {
  external JSPromise<JSAny?> list();
  external JSPromise<JSAny?> download(JSObject details);
  external JSPromise<JSAny?> cancel();
  external JSPromise<JSAny?> remove(JSString url);
  external JSPromise<JSAny?> playableUrl(JSString url);
}

BrowserAudioService createBrowserAudioService() => _WebAudioService();

class _WebAudioService implements BrowserAudioService {
  _WebAudioService() {
    _listener = ((web.Event event) {
      final result = (event as web.CustomEvent).detail.dartify();
      if (result is Map && !_events.isClosed) {
        _events.add(BrowserAudioStatus.fromMap(result));
      }
    }).toJS;
    web.window.addEventListener('quran-audio-status', _listener);
    _resolver = (url) async {
      try {
        final bridge = _bridge;
        if (bridge == null) return null;
        return (await bridge.playableUrl(url.toJS).toDart).dartify() as String?;
      } catch (_) {
        return null;
      }
    };
    AudioCtrl.webSurahAudioResolver = _resolver;
  }
  final _events = StreamController<BrowserAudioStatus>.broadcast();
  late final JSFunction _listener;
  late final Future<String?> Function(String) _resolver;
  Future<Map<dynamic, dynamic>> _call(
    JSPromise<JSAny?> Function(_AudioBridge) call,
  ) async {
    try {
      final bridge = _bridge;
      if (bridge == null) throw const BrowserAudioFailure('unavailable');
      final value = (await call(bridge).toDart).dartify();
      if (value is! Map) throw const BrowserAudioFailure('unavailable');
      if (value['state'] == 'error' || value['supported'] != true) {
        throw BrowserAudioFailure(
          value['errorCode'] as String? ?? 'unavailable',
        );
      }
      return value;
    } on BrowserAudioFailure {
      rethrow;
    } catch (_) {
      throw const BrowserAudioFailure('unavailable');
    }
  }

  @override
  Stream<BrowserAudioStatus> get changes => _events.stream;
  @override
  Future<List<BrowserAudioEntry>> list() async {
    final result = await _call((bridge) => bridge.list());
    return (result['entries'] as List? ?? [])
        .map((value) => BrowserAudioEntry.fromMap(value as Map))
        .toList();
  }

  @override
  Future<BrowserAudioEntry> download({
    required String url,
    required String readerName,
    required int surahNumber,
    required String surahName,
  }) async {
    final details =
        {
              'url': url,
              'readerName': readerName,
              'surahNumber': surahNumber,
              'surahName': surahName,
            }.jsify()
            as JSObject;
    final result = await _call((bridge) => bridge.download(details));
    if (result['state'] == 'cancelled') {
      throw const BrowserAudioFailure('cancelled');
    }
    if (result['entry'] is! Map) {
      throw const BrowserAudioFailure('audio_download_failed');
    }
    return BrowserAudioEntry.fromMap(result['entry'] as Map);
  }

  @override
  Future<void> cancel() async {
    await _call((bridge) => bridge.cancel());
  }

  @override
  Future<void> remove(String url) async {
    await _call((bridge) => bridge.remove(url.toJS));
  }

  @override
  void dispose() {
    web.window.removeEventListener('quran-audio-status', _listener);
    if (AudioCtrl.webSurahAudioResolver == _resolver) {
      AudioCtrl.webSurahAudioResolver = null;
    }
    _events.close();
  }
}
