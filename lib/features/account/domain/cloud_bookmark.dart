/// A portable bookmark. Quran identity is checked before any restore writes.
class CloudBookmark {
  const CloudBookmark({
    required this.id,
    required this.color,
    required this.name,
    required this.ayahId,
    required this.ayahNumber,
    required this.page,
  });

  final int id;
  final int color;
  final String name;
  final int ayahId;
  final int ayahNumber;
  final int page;

  Map<String, Object?> toJson() => {
    'id': id,
    'color': color,
    'name': name,
    'ayah_id': ayahId,
    'ayah_number': ayahNumber,
    'page': page,
  };

  static List<CloudBookmark> parseList(
    Object? raw, {
    required int Function(int surah) ayahsInSurah,
    int Function(int ayahId)? pageForAyah,
  }) {
    if (raw is! List<Object?> || raw.length > 20000) {
      throw const FormatException('Invalid bookmark collection');
    }
    final ids = <int>{};
    final ayahNumbers = <int>[];
    for (var surah = 1; surah <= 114; surah++) {
      for (var ayah = 1; ayah <= ayahsInSurah(surah); ayah++) {
        ayahNumbers.add(ayah);
      }
    }
    return raw
        .map((item) {
          if (item is! Map<String, Object?>) {
            throw const FormatException('Invalid bookmark');
          }
          int number(String key, int min, int max) {
            final value = item[key];
            if (value is! int || value < min || value > max) {
              throw const FormatException('Invalid bookmark number');
            }
            return value;
          }

          final id = number('id', 0, 9007199254740991);
          if (!ids.add(id)) {
            throw const FormatException('Duplicate bookmark ID');
          }
          final ayahId = number('ayah_id', 1, ayahNumbers.length);
          final ayahNumber = number('ayah_number', 1, 286);
          final page = number('page', 1, 604);
          if (ayahNumbers[ayahId - 1] != ayahNumber ||
              (pageForAyah != null && pageForAyah(ayahId) != page)) {
            throw const FormatException(
              'Bookmark Quran reference does not match',
            );
          }
          final name = item['name'];
          if (name is! String || name.trim().isEmpty || name.length > 200) {
            throw const FormatException('Invalid bookmark name');
          }
          return CloudBookmark(
            id: id,
            color: number('color', 0, 0xffffffff),
            name: name,
            ayahId: ayahId,
            ayahNumber: ayahNumber,
            page: page,
          );
        })
        .toList(growable: false);
  }
}
