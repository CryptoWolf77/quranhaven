class OfflineStatus {
  const OfflineStatus({
    this.supported = false,
    this.state = 'unsupported',
    this.offlineReady = false,
    this.completedBytes = 0,
    this.totalBytes = 0,
    this.persisted,
    this.errorCode,
  });

  factory OfflineStatus.fromMap(Map<Object?, Object?> value) {
    int bytes(String key) {
      final number = value[key];
      return number is num && number.isFinite && number >= 0
          ? number.toInt()
          : 0;
    }

    return OfflineStatus(
      supported: value['supported'] == true,
      state: value['state'] is String ? value['state'] as String : 'error',
      offlineReady: value['offlineReady'] == true,
      completedBytes: bytes('completedBytes'),
      totalBytes: bytes('totalBytes'),
      persisted: value['persisted'] is bool ? value['persisted'] as bool : null,
      errorCode: value['errorCode'] is String
          ? value['errorCode'] as String
          : null,
    );
  }

  final bool supported;
  final String state;
  final bool offlineReady;
  final int completedBytes;
  final int totalBytes;
  final bool? persisted;
  final String? errorCode;

  bool get preparing => state == 'preparing';
  double? get progress => totalBytes > 0
      ? (completedBytes / totalBytes).clamp(0, 1).toDouble()
      : null;
}
