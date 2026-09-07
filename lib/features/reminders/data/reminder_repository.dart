import 'package:shared_preferences/shared_preferences.dart';

class ReminderSettings {
  const ReminderSettings({
    required this.enabled,
    required this.hour,
    required this.minute,
  });

  final bool enabled;
  final int hour;
  final int minute;

  ReminderSettings copyWith({bool? enabled, int? hour, int? minute}) {
    return ReminderSettings(
      enabled: enabled ?? this.enabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
    );
  }
}

class ReminderRepository {
  ReminderRepository({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const _enabledKey = 'reminders.daily.enabled.v1';
  static const _hourKey = 'reminders.daily.hour.v1';
  static const _minuteKey = 'reminders.daily.minute.v1';

  final SharedPreferencesAsync _preferences;

  Future<ReminderSettings> load() async {
    return ReminderSettings(
      enabled: await _preferences.getBool(_enabledKey) ?? false,
      hour: await _preferences.getInt(_hourKey) ?? 19,
      minute: await _preferences.getInt(_minuteKey) ?? 0,
    );
  }

  Future<void> save(ReminderSettings settings) async {
    await Future.wait([
      _preferences.setBool(_enabledKey, settings.enabled),
      _preferences.setInt(_hourKey, settings.hour),
      _preferences.setInt(_minuteKey, settings.minute),
    ]);
  }
}
