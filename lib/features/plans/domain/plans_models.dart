import 'dart:math' as math;

const int quranPageCount = 604;

class KhatmahPlan {
  const KhatmahPlan({
    required this.startedAt,
    required this.targetDate,
    required this.completedPages,
    this.isPaused = false,
    this.isRamadanPlan = false,
  });

  final DateTime startedAt;
  final DateTime targetDate;
  final int completedPages;
  final bool isPaused;
  final bool isRamadanPlan;

  bool get isComplete => completedPages >= quranPageCount;

  double get progress => (completedPages / quranPageCount).clamp(0, 1);

  int get remainingPages => math.max(0, quranPageCount - completedPages);

  int remainingDaysOn(DateTime date) {
    final today = DateTime(date.year, date.month, date.day);
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
    return math.max(1, target.difference(today).inDays + 1);
  }

  int pagesPerDayOn(DateTime date) {
    if (isComplete) return 0;
    return (remainingPages / remainingDaysOn(date)).ceil();
  }

  KhatmahPlan copyWith({
    DateTime? targetDate,
    int? completedPages,
    bool? isPaused,
  }) {
    return KhatmahPlan(
      startedAt: startedAt,
      targetDate: targetDate ?? this.targetDate,
      completedPages: (completedPages ?? this.completedPages).clamp(
        0,
        quranPageCount,
      ),
      isPaused: isPaused ?? this.isPaused,
      isRamadanPlan: isRamadanPlan,
    );
  }

  Map<String, Object> toJson() => {
    'startedAt': startedAt.toIso8601String(),
    'targetDate': targetDate.toIso8601String(),
    'completedPages': completedPages,
    'isPaused': isPaused,
    'isRamadanPlan': isRamadanPlan,
  };

  factory KhatmahPlan.fromJson(Map<String, Object?> json) {
    return KhatmahPlan(
      startedAt: DateTime.parse(json['startedAt']! as String),
      targetDate: DateTime.parse(json['targetDate']! as String),
      completedPages: (json['completedPages']! as num).toInt(),
      isPaused: json['isPaused'] as bool? ?? false,
      isRamadanPlan: json['isRamadanPlan'] as bool? ?? false,
    );
  }
}

class MemorizationPlan {
  const MemorizationPlan({
    required this.id,
    required this.surahNumber,
    required this.startAyah,
    required this.endAyah,
    required this.currentAyah,
    required this.repetitions,
    required this.rangeRepetitions,
    required this.delaySeconds,
    required this.hideAyah,
    this.memorizedAyahs = const {},
    this.revisionAyahs = const {},
  });

  final String id;
  final int surahNumber;
  final int startAyah;
  final int endAyah;
  final int currentAyah;
  final int repetitions;
  final int rangeRepetitions;
  final int delaySeconds;
  final bool hideAyah;
  final Set<int> memorizedAyahs;
  final Set<int> revisionAyahs;

  int get ayahCount => endAyah - startAyah + 1;

  double get progress =>
      ayahCount == 0 ? 0 : (memorizedAyahs.length / ayahCount).clamp(0, 1);

  bool get isComplete => memorizedAyahs.length >= ayahCount;

  bool get isCurrentMemorized => memorizedAyahs.contains(currentAyah);

  bool get isCurrentForRevision => revisionAyahs.contains(currentAyah);

  MemorizationPlan copyWith({
    int? currentAyah,
    int? repetitions,
    int? rangeRepetitions,
    int? delaySeconds,
    bool? hideAyah,
    Set<int>? memorizedAyahs,
    Set<int>? revisionAyahs,
  }) {
    return MemorizationPlan(
      id: id,
      surahNumber: surahNumber,
      startAyah: startAyah,
      endAyah: endAyah,
      currentAyah: (currentAyah ?? this.currentAyah).clamp(startAyah, endAyah),
      repetitions: repetitions ?? this.repetitions,
      rangeRepetitions: rangeRepetitions ?? this.rangeRepetitions,
      delaySeconds: delaySeconds ?? this.delaySeconds,
      hideAyah: hideAyah ?? this.hideAyah,
      memorizedAyahs: memorizedAyahs ?? this.memorizedAyahs,
      revisionAyahs: revisionAyahs ?? this.revisionAyahs,
    );
  }

  MemorizationPlan markCurrentMemorized() {
    final updated = {...memorizedAyahs, currentAyah};
    final next = currentAyah < endAyah ? currentAyah + 1 : currentAyah;
    return copyWith(currentAyah: next, memorizedAyahs: updated);
  }

  MemorizationPlan toggleCurrentRevision() {
    final updated = {...revisionAyahs};
    if (!updated.add(currentAyah)) updated.remove(currentAyah);
    return copyWith(revisionAyahs: updated);
  }

  Map<String, Object> toJson() => {
    'id': id,
    'surahNumber': surahNumber,
    'startAyah': startAyah,
    'endAyah': endAyah,
    'currentAyah': currentAyah,
    'repetitions': repetitions,
    'rangeRepetitions': rangeRepetitions,
    'delaySeconds': delaySeconds,
    'hideAyah': hideAyah,
    'memorizedAyahs': memorizedAyahs.toList(),
    'revisionAyahs': revisionAyahs.toList(),
  };

  factory MemorizationPlan.fromJson(Map<String, Object?> json) {
    Set<int> readSet(String key) {
      return (json[key] as List<Object?>? ?? const [])
          .map((value) => (value as num).toInt())
          .toSet();
    }

    return MemorizationPlan(
      id: json['id']! as String,
      surahNumber: (json['surahNumber']! as num).toInt(),
      startAyah: (json['startAyah']! as num).toInt(),
      endAyah: (json['endAyah']! as num).toInt(),
      currentAyah: (json['currentAyah']! as num).toInt(),
      repetitions: (json['repetitions']! as num).toInt(),
      rangeRepetitions: (json['rangeRepetitions'] as num?)?.toInt() ?? 1,
      delaySeconds: (json['delaySeconds']! as num).toInt(),
      hideAyah: json['hideAyah'] as bool? ?? false,
      memorizedAyahs: readSet('memorizedAyahs'),
      revisionAyahs: readSet('revisionAyahs'),
    );
  }
}
