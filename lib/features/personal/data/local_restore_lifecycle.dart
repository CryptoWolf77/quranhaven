/// Host-owned state refresh after a fully validated durable backup restore.
/// It never writes the backup or interprets a UI refresh error as rollback.
abstract final class LocalRestoreLifecycle {
  static Future<void> Function()? beforeRestore;
  static Future<void> Function()? refreshAfterRestore;
  static Future<void> prepare() async => beforeRestore?.call();
  static Future<void> refresh() async {
    final callback = refreshAfterRestore;
    if (callback == null) {
      throw StateError('Restart the app to load restored data');
    }
    await callback();
  }
}
