import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import '../domain/offline_status.dart';
import 'offline_service.dart';

@JS('quranOffline')
external _OfflineBridge? get _bridge;

extension type _OfflineBridge._(JSObject _) implements JSObject {
  external JSPromise<JSAny?> status();
  external JSPromise<JSAny?> prepare();
  external JSPromise<JSAny?> cancel();
  external JSPromise<JSAny?> remove();
  external JSPromise<JSAny?> activateAndReload();
}

OfflineService createOfflineService() => _BrowserOfflineService();

class _BrowserOfflineService implements OfflineService {
  _BrowserOfflineService() {
    _listener = ((web.Event event) {
      final result = _decode((event as web.CustomEvent).detail);
      if (!_events.isClosed) _events.add(result);
    }).toJS;
    web.window.addEventListener('quran-offline-status', _listener);
  }

  final _events = StreamController<OfflineStatus>.broadcast();
  late final JSFunction _listener;

  OfflineStatus _decode(JSAny? value) {
    final decoded = value.dartify();
    return decoded is Map
        ? OfflineStatus.fromMap(decoded)
        : const OfflineStatus();
  }

  Future<OfflineStatus> _call(
    JSPromise<JSAny?> Function(_OfflineBridge) action,
  ) async {
    try {
      final bridge = _bridge;
      if (bridge == null) return const OfflineStatus();
      return _decode(await action(bridge).toDart);
    } catch (_) {
      return const OfflineStatus(
        supported: true,
        state: 'error',
        errorCode: 'unavailable',
      );
    }
  }

  @override
  Stream<OfflineStatus> get changes => _events.stream;
  @override
  Future<OfflineStatus> status() => _call((bridge) => bridge.status());
  @override
  Future<OfflineStatus> prepare() => _call((bridge) => bridge.prepare());
  @override
  Future<OfflineStatus> cancel() => _call((bridge) => bridge.cancel());
  @override
  Future<OfflineStatus> remove() => _call((bridge) => bridge.remove());
  @override
  Future<OfflineStatus> activateAndReload() =>
      _call((bridge) => bridge.activateAndReload());
  @override
  void dispose() {
    web.window.removeEventListener('quran-offline-status', _listener);
    _events.close();
  }
}
