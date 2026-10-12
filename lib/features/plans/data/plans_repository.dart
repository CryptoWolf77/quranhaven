import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/plans_models.dart';

class PlansRepository {
  PlansRepository({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const _khatmahKey = 'plans.khatmah.v1';
  static const _memorizationKey = 'plans.memorization.v1';

  final SharedPreferencesAsync _preferences;

  Future<KhatmahPlan?> loadKhatmah() async {
    final stored = await _preferences.getString(_khatmahKey);
    if (stored == null) return null;
    try {
      return KhatmahPlan.fromJson(jsonDecode(stored) as Map<String, Object?>);
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  Future<void> saveKhatmah(KhatmahPlan plan) {
    return _preferences.setString(_khatmahKey, jsonEncode(plan.toJson()));
  }

  Future<void> deleteKhatmah() => _preferences.remove(_khatmahKey);

  Future<List<MemorizationPlan>> loadMemorizationPlans() async {
    final stored = await _preferences.getString(_memorizationKey);
    if (stored == null) return [];
    try {
      final values = jsonDecode(stored) as List<Object?>;
      return values
          .map(
            (value) =>
                MemorizationPlan.fromJson(value! as Map<String, Object?>),
          )
          .toList();
    } on FormatException {
      return [];
    } on TypeError {
      return [];
    }
  }

  Future<void> saveMemorizationPlans(List<MemorizationPlan> plans) {
    return _preferences.setString(
      _memorizationKey,
      jsonEncode(plans.map((plan) => plan.toJson()).toList()),
    );
  }
}
