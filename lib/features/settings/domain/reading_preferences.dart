import 'package:flutter/material.dart';

class ReadingPreferences {
  const ReadingPreferences({this.locale, this.themeMode = ThemeMode.system});

  final Locale? locale;
  final ThemeMode themeMode;

  factory ReadingPreferences.fromJson(
    Map<String, Object?> json, {
    ReadingPreferences fallback = const ReadingPreferences(),
  }) {
    var locale = fallback.locale;
    var theme = fallback.themeMode;
    if (json.containsKey('locale')) {
      final value = json['locale'];
      if (value != null && !const {'ar', 'en', 'es'}.contains(value)) {
        throw const FormatException('Unsupported reading language');
      }
      locale = value == null ? null : Locale(value as String);
    }
    if (json.containsKey('theme_mode')) {
      final value = json['theme_mode'];
      theme = switch (value) {
        'system' => ThemeMode.system,
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => throw const FormatException('Unsupported reading appearance'),
      };
    }
    return ReadingPreferences(locale: locale, themeMode: theme);
  }

  Map<String, Object?> toJson() => {
    'locale': locale?.languageCode,
    'theme_mode': themeMode.name,
  };
}
