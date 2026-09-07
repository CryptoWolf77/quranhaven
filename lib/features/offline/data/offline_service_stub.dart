import '../domain/offline_status.dart';
import 'offline_service.dart';

OfflineService createOfflineService() => _UnsupportedOfflineService();

class _UnsupportedOfflineService implements OfflineService {
  @override
  Stream<OfflineStatus> get changes => const Stream.empty();
  @override
  Future<OfflineStatus> status() async => const OfflineStatus();
  @override
  Future<OfflineStatus> prepare() => status();
  @override
  Future<OfflineStatus> cancel() => status();
  @override
  Future<OfflineStatus> remove() => status();
  @override
  Future<OfflineStatus> activateAndReload() => status();
  @override
  void dispose() {}
}
