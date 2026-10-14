import 'dart:convert';

/// Hafs verse limits; kept independent of UI/controller initialization.
const hafsAyahCounts = <int>[
  7,
  286,
  200,
  176,
  120,
  165,
  206,
  75,
  129,
  109,
  123,
  111,
  43,
  52,
  99,
  128,
  111,
  110,
  98,
  135,
  112,
  78,
  118,
  64,
  77,
  227,
  93,
  88,
  69,
  60,
  34,
  30,
  73,
  54,
  45,
  83,
  182,
  88,
  75,
  85,
  54,
  53,
  89,
  59,
  37,
  35,
  38,
  29,
  18,
  45,
  60,
  49,
  62,
  55,
  78,
  96,
  29,
  22,
  24,
  13,
  14,
  11,
  11,
  18,
  12,
  12,
  30,
  52,
  52,
  44,
  28,
  28,
  20,
  56,
  40,
  31,
  50,
  40,
  46,
  42,
  29,
  19,
  36,
  25,
  22,
  17,
  19,
  26,
  30,
  20,
  15,
  21,
  11,
  8,
  8,
  19,
  5,
  8,
  8,
  11,
  11,
  8,
  3,
  9,
  5,
  4,
  7,
  3,
  6,
  3,
  5,
  4,
  5,
  6,
];

class AyahReference {
  const AyahReference(this.surah, this.ayah);
  final int surah;
  final int ayah;
  bool get isValid =>
      surah >= 1 &&
      surah <= 114 &&
      ayah >= 1 &&
      ayah <= hafsAyahCounts[surah - 1];
  String get key => '$surah:$ayah';
  Uri get publicLink =>
      Uri.https('quranhaven.org', '/', {'surah': '$surah', 'ayah': '$ayah'});
  Map<String, Object> toJson() => {'surah': surah, 'ayah': ayah};
  factory AyahReference.fromJson(Map<String, Object?> json) {
    final s = json['surah'], a = json['ayah'];
    if (s is! int || a is! int) throw const FormatException('Invalid Ayah');
    final ref = AyahReference(s, a);
    if (!ref.isValid) throw const FormatException('Invalid Ayah');
    return ref;
  }
  static AyahReference? fromUri(Uri uri) {
    if (!uri.queryParameters.containsKey('surah') &&
        !uri.queryParameters.containsKey('ayah')) {
      return null;
    }
    if (uri.queryParametersAll['surah']?.length != 1 ||
        uri.queryParametersAll['ayah']?.length != 1) {
      throw const FormatException('Invalid link');
    }
    final s = int.tryParse(uri.queryParameters['surah'] ?? ''),
        a = int.tryParse(uri.queryParameters['ayah'] ?? '');
    if (s == null || a == null) throw const FormatException('Invalid link');
    return AyahReference.fromJson({'surah': s, 'ayah': a});
  }
}

String boundedString(Object? value, int max, {bool empty = false}) {
  if (value is! String ||
      value.length > max ||
      (!empty && value.trim().isEmpty)) {
    throw const FormatException('Invalid text');
  }
  return value;
}

void exactKeys(
  Map<String, Object?> map,
  Set<String> required, {
  Set<String> optional = const {},
}) {
  if (!map.keys.toSet().containsAll(required) ||
      map.keys.any((k) => !required.contains(k) && !optional.contains(k))) {
    throw const FormatException('Invalid fields');
  }
}

Map<String, Object?> objectMap(Object? value) {
  if (value is! Map<String, Object?>) {
    throw const FormatException('Invalid object');
  }
  return value;
}

List<Object?> boundedList(Object? value, int max) {
  if (value is! List<Object?> || value.length > max) {
    throw const FormatException('Invalid list');
  }
  return value;
}

DateTime strictBackupDate(Object? value) {
  final text = boundedString(value, 40);
  if (!RegExp(
    r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d{1,6})?Z?$',
  ).hasMatch(text)) {
    throw const FormatException('Invalid date');
  }
  final d = DateTime.tryParse(text);
  if (d == null ||
      d.year < 2000 ||
      d.year > 2200 ||
      d.toIso8601String().substring(0, 10) != text.substring(0, 10) ||
      d.hour != int.parse(text.substring(11, 13)) ||
      d.minute != int.parse(text.substring(14, 16)) ||
      d.second != int.parse(text.substring(17, 19))) {
    throw const FormatException('Invalid date');
  }
  return d;
}

class AyahNote {
  const AyahNote({
    required this.id,
    required this.reference,
    required this.title,
    required this.body,
    required this.updatedAt,
  });
  final String id, title, body;
  final AyahReference reference;
  final DateTime updatedAt;
  Map<String, Object> toJson() => {
    'id': id,
    ...reference.toJson(),
    'title': title,
    'body': body,
    'updatedAt': updatedAt.toUtc().toIso8601String(),
  };
  factory AyahNote.fromJson(Map<String, Object?> json) {
    exactKeys(json, {'id', 'surah', 'ayah', 'title', 'body', 'updatedAt'});
    final date = strictBackupDate(json['updatedAt']);
    return AyahNote(
      id: boundedString(json['id'], 80),
      reference: AyahReference.fromJson(json),
      title: boundedString(json['title'], 120, empty: true),
      body: boundedString(json['body'], 10000),
      updatedAt: date,
    );
  }
}

class AyahCollection {
  const AyahCollection({
    required this.id,
    required this.name,
    required this.ayahs,
  });
  final String id, name;
  final List<AyahReference> ayahs;
  Map<String, Object> toJson() => {
    'id': id,
    'name': name,
    'ayahs': ayahs.map((a) => a.toJson()).toList(),
  };
  factory AyahCollection.fromJson(Map<String, Object?> json) {
    exactKeys(json, {'id', 'name', 'ayahs'});
    final refs = boundedList(json['ayahs'], 6236).map((e) {
      final map = objectMap(e);
      exactKeys(map, {'surah', 'ayah'});
      return AyahReference.fromJson(map);
    }).toList();
    if (refs.map((e) => e.key).toSet().length != refs.length) {
      throw const FormatException('Duplicate Ayah');
    }
    return AyahCollection(
      id: boundedString(json['id'], 80),
      name: boundedString(json['name'], 80),
      ayahs: refs,
    );
  }
}

class PersonalData {
  const PersonalData({this.notes = const [], this.collections = const []});
  final List<AyahNote> notes;
  final List<AyahCollection> collections;
  Map<String, Object> toJson() => {
    'notes': notes.map((e) => e.toJson()).toList(),
    'collections': collections.map((e) => e.toJson()).toList(),
  };
  factory PersonalData.fromJson(Map<String, Object?> json) {
    if (utf8.encode(jsonEncode(json)).length > 2 * 1024 * 1024) {
      throw const FormatException(
        'Personal storage exceeds its safe backup limit',
      );
    }
    exactKeys(json, {'notes', 'collections'});
    final notes = boundedList(
      json['notes'],
      2000,
    ).map((e) => AyahNote.fromJson(objectMap(e))).toList();
    final collections = boundedList(
      json['collections'],
      100,
    ).map((e) => AyahCollection.fromJson(objectMap(e))).toList();
    if (notes.map((n) => n.id).toSet().length != notes.length ||
        collections.map((c) => c.id).toSet().length != collections.length) {
      throw const FormatException('Duplicate ID');
    }
    return PersonalData(notes: notes, collections: collections);
  }
  PersonalData copyWith({
    List<AyahNote>? notes,
    List<AyahCollection>? collections,
  }) => PersonalData(
    notes: notes ?? this.notes,
    collections: collections ?? this.collections,
  );
  static int _sequence = 0;
  static String newId() =>
      '${DateTime.now().microsecondsSinceEpoch}-${_sequence++}';
}
