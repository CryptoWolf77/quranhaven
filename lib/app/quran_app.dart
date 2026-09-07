import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../features/account/data/reading_preferences_repository.dart';
import '../features/account/domain/reading_preferences.dart';
import '../features/shell/presentation/app_shell.dart';
import '../l10n/generated/app_localizations.dart';
import 'theme/app_theme.dart';

class QuranApp extends StatefulWidget {
  const QuranApp({super.key});

  @override
  State<QuranApp> createState() => _QuranAppState();
}

class _QuranAppState extends State<QuranApp> {
  final _preferencesRepository = ReadingPreferencesRepository();
  ReadingPreferences _preferences = const ReadingPreferences();
  Future<void> _preferenceWrites = Future<void>.value();
  bool _preferencesLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final preferences = await _preferencesRepository.load();
    if (!mounted) return;
    setState(() {
      _preferences = preferences;
      _preferencesLoaded = true;
    });
  }

  Future<void> _savePreferences(ReadingPreferences preferences) async {
    if (!mounted) return;
    setState(() => _preferences = preferences);
    // Serialize rapid setting changes so the final on-screen choice wins.
    final write = _preferenceWrites
        .catchError((Object _) {})
        .then((_) => _preferencesRepository.save(preferences));
    _preferenceWrites = write;
    await write;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      locale: _preferences.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (final supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return const Locale('ar');
      },
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _preferences.themeMode,
      home: !_preferencesLoaded
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : AppShell(
              locale: _preferences.locale,
              themeMode: _preferences.themeMode,
              onLocaleChanged: (locale) => _savePreferences(
                ReadingPreferences(
                  locale: locale,
                  themeMode: _preferences.themeMode,
                ),
              ),
              onThemeModeChanged: (mode) => _savePreferences(
                ReadingPreferences(
                  locale: _preferences.locale,
                  themeMode: mode,
                ),
              ),
              onPreferencesRestored: _savePreferences,
            ),
    );
  }
}
