import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/personal_models.dart';

class PersonalRepository {
  PersonalRepository({SharedPreferencesAsync? storage})
    : _storage = storage ?? SharedPreferencesAsync();
  static const storageKey = 'personal.tools.v1';
  final SharedPreferencesAsync _storage;
  Future<PersonalData> load() async {
    final raw = await _storage.getString(storageKey);
    if (raw == null) return const PersonalData();
    // Corrupt data must be reported, never silently replaced by an empty save.
    return PersonalData.fromJson(objectMap(jsonDecode(raw)));
  }

  Future<void> save(PersonalData data) async {
    final validated = PersonalData.fromJson(data.toJson());
    await _storage.setString(storageKey, jsonEncode(validated.toJson()));
  }
}
