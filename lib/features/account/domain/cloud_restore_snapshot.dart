import '../../plans/domain/plans_models.dart';
import 'reading_preferences.dart';
import 'cloud_bookmark.dart';

/// Fully validated data. Missing fields in earlier backups remain untouched.
class CloudRestoreSnapshot {
  const CloudRestoreSnapshot._({
    this.page,
    this.preferences,
    this.hasKhatmah = false,
    this.khatmah,
    this.memorization,
    this.bookmarks,
  });

  final int? page;
  final ReadingPreferences? preferences;
  final bool hasKhatmah;
  final KhatmahPlan? khatmah;
  final List<MemorizationPlan>? memorization;
  final List<CloudBookmark>? bookmarks;

  factory CloudRestoreSnapshot.parse(
    Map<String, Object?> data, {
    required ReadingPreferences currentPreferences,
    required int Function(int surah) ayahsInSurah,
    int Function(int ayahId)? pageForAyah,
  }) {
    if (data.containsKey('schema_version') && data['schema_version'] != 1) {
      throw const FormatException('Unsupported cloud backup version');
    }
    final page = data.containsKey('last_read_page')
        ? _integer(data['last_read_page'], 1, quranPageCount)
        : null;
    final bookmarks = data.containsKey('bookmarks')
        ? CloudBookmark.parseList(
            data['bookmarks'],
            ayahsInSurah: ayahsInSurah,
            pageForAyah: pageForAyah,
          )
        : null;
    ReadingPreferences? preferences;
    if (data.containsKey('preferences')) {
      preferences = ReadingPreferences.fromJson(
        _object(data['preferences']),
        fallback: currentPreferences,
      );
    }
    var hasKhatmah = false;
    KhatmahPlan? khatmah;
    List<MemorizationPlan>? memorization;
    if (data.containsKey('plans')) {
      final plans = _object(data['plans']);
      hasKhatmah = plans.containsKey('khatmah');
      if (hasKhatmah && plans['khatmah'] != null) {
        final raw = _object(plans['khatmah']);
        final startedAt = _date(raw['startedAt']);
        final targetDate = _date(raw['targetDate']);
        if (targetDate.isBefore(startedAt)) {
          throw const FormatException('Khatmah target precedes its start');
        }
        khatmah = KhatmahPlan(
          startedAt: startedAt,
          targetDate: targetDate,
          completedPages: _integer(raw['completedPages'], 0, quranPageCount),
          isPaused: _boolean(raw, 'isPaused'),
          isRamadanPlan: _boolean(raw, 'isRamadanPlan'),
        );
      }
      if (plans.containsKey('memorization')) {
        final raw = plans['memorization'];
        if (raw is! List<Object?>) {
          throw const FormatException('Invalid memorization list');
        }
        final ids = <String>{};
        memorization = raw
            .map((item) {
              final value = _object(item);
              final id = value['id'];
              if (id is! String || id.trim().isEmpty || !ids.add(id)) {
                throw const FormatException('Invalid or duplicate plan ID');
              }
              final surah = _integer(value['surahNumber'], 1, 114);
              final count = ayahsInSurah(surah);
              final start = _integer(value['startAyah'], 1, count);
              final end = _integer(value['endAyah'], start, count);
              return MemorizationPlan(
                id: id,
                surahNumber: surah,
                startAyah: start,
                endAyah: end,
                currentAyah: _integer(value['currentAyah'], start, end),
                repetitions: _integer(value['repetitions'], 1, 100),
                rangeRepetitions: value.containsKey('rangeRepetitions')
                    ? _integer(value['rangeRepetitions'], 1, 100)
                    : 1,
                delaySeconds: _integer(value['delaySeconds'], 0, 60),
                hideAyah: _boolean(value, 'hideAyah'),
                memorizedAyahs: _ayahSet(value, 'memorizedAyahs', start, end),
                revisionAyahs: _ayahSet(value, 'revisionAyahs', start, end),
              );
            })
            .toList(growable: false);
      }
    }
    return CloudRestoreSnapshot._(
      page: page,
      preferences: preferences,
      hasKhatmah: hasKhatmah,
      khatmah: khatmah,
      memorization: memorization,
      bookmarks: bookmarks,
    );
  }

  static Map<String, Object?> _object(Object? value) {
    if (value is Map<String, Object?>) return value;
    throw const FormatException('Expected a backup object');
  }

  static int _integer(Object? value, int minimum, int maximum) {
    if (value is int && value >= minimum && value <= maximum) return value;
    throw const FormatException('Invalid backup number');
  }

  static DateTime _date(Object? value) {
    final parsed = value is String ? DateTime.tryParse(value) : null;
    if (parsed == null) throw const FormatException('Invalid plan date');
    return parsed;
  }

  static bool _boolean(Map<String, Object?> data, String key) {
    if (!data.containsKey(key)) return false;
    if (data[key] is bool) return data[key]! as bool;
    throw const FormatException('Invalid backup flag');
  }

  static Set<int> _ayahSet(
    Map<String, Object?> data,
    String key,
    int start,
    int end,
  ) {
    if (!data.containsKey(key)) return {};
    final values = data[key];
    if (values is! List<Object?>) {
      throw const FormatException('Invalid saved Ayah markers');
    }
    return values.map((value) => _integer(value, start, end)).toSet();
  }
}
