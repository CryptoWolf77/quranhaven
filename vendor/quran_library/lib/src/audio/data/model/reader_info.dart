part of '../../audio.dart';

/// موديل لبيانات القارئ
class ReaderInfo {
  /// رقم تعريف القارئ
  final int index;

  /// اسم القارئ بالعربية
  final String name;

  /// مسار اسم القارئ في الرابط
  final String readerNamePath;

  /// رابط المصدر الأساسي للصوتيات
  final String url;

  /// Migrated remote root; keep readerNamePath stable for existing downloads.
  final String? remoteBaseUrl;
  String get recordingRoot => remoteBaseUrl ?? '$url$readerNamePath';

  const ReaderInfo({
    required this.index,
    required this.name,
    required this.readerNamePath,
    required this.url,
    this.remoteBaseUrl,
  });

  /// إنشاء كائن من Map
  factory ReaderInfo.fromMap(Map<String, dynamic> map) {
    return ReaderInfo(
      index: map['index'] as int,
      name: map['name'] as String,
      readerNamePath: map['readerNamePath'] as String,
      url: map['url'] as String,
      remoteBaseUrl: map['remoteBaseUrl'] as String?,
    );
  }

  /// تحويل الكائن إلى Map
  Map<String, dynamic> toMap() {
    return {
      'index': index,
      'name': name,
      'readerNamePath': readerNamePath,
      'url': url,
      if (remoteBaseUrl != null) 'remoteBaseUrl': remoteBaseUrl,
    };
  }

  /// نسخ الكائن مع تعديل بعض الحقول
  ReaderInfo copyWith({
    int? index,
    String? name,
    String? readerNamePath,
    String? url,
    String? remoteBaseUrl,
  }) {
    return ReaderInfo(
      index: index ?? this.index,
      name: name ?? this.name,
      readerNamePath: readerNamePath ?? this.readerNamePath,
      url: url ?? this.url,
      remoteBaseUrl: remoteBaseUrl ?? this.remoteBaseUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReaderInfo &&
        other.index == index &&
        other.name == name &&
        other.readerNamePath == readerNamePath &&
        other.url == url &&
        other.remoteBaseUrl == remoteBaseUrl;
  }

  @override
  int get hashCode {
    return Object.hash(index, name, readerNamePath, url, remoteBaseUrl);
  }

  @override
  String toString() {
    return 'ReaderInfo(index: $index, name: $name, readerNamePath: $readerNamePath, url: $url)';
  }
}
