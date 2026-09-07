import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/reading_preferences.dart';

class ReadingPreferencesRepository {
  static const storageKey = 'reader.preferences.v1';

  Future<ReadingPreferences> load() async {
    final storage = await SharedPreferences.getInstance();
    try {
      final value = storage.getString(storageKey);
      if (value == null) return const ReadingPreferences();
      final json = jsonDecode(value);
      if (json is! Map<String, Object?>) return const ReadingPreferences();
      return ReadingPreferences.fromJson(json);
    } on FormatException {
      return const ReadingPreferences();
    } on TypeError {
      return const ReadingPreferences();
    }
  }

  Future<void> save(ReadingPreferences preferences) async {
    final storage = await SharedPreferences.getInstance();
    // Keep language and appearance in a single write, including system locale.
    final saved = await storage.setString(
      storageKey,
      jsonEncode(preferences.toJson()),
    );
    if (!saved) throw StateError('Reading preferences could not be saved');
  }
}
