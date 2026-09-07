import '../domain/offline_status.dart';
import 'offline_service_stub.dart'
    if (dart.library.js_interop) 'offline_service_web.dart'
    as platform;

abstract class OfflineService {
  factory OfflineService() => platform.createOfflineService();

  Stream<OfflineStatus> get changes;
  Future<OfflineStatus> status();
  Future<OfflineStatus> prepare();
  Future<OfflineStatus> cancel();
  Future<OfflineStatus> remove();
  Future<OfflineStatus> activateAndReload();
  void dispose();
}
