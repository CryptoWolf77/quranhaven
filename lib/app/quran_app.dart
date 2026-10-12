import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../features/settings/data/reading_preferences_repository.dart';
import '../features/settings/domain/reading_preferences.dart';
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
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final preferences = await _preferencesRepository.load();
      if (mounted) setState(() => _preferences = preferences);
    } catch (_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showStorageError(reading: true);
      });
    } finally {
      if (mounted) setState(() => _preferencesLoaded = true);
    }
  }

  void _showStorageError({bool reading = false}) {
    final context = _messengerKey.currentContext;
    if (context == null) return;
    final l10n = AppLocalizations.of(context);
    _messengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(reading ? l10n.localLoadFailed : l10n.localSaveFailed),
      ),
    );
  }

  Future<void> _savePreferences(ReadingPreferences preferences) async {
    if (!mounted) return;
    setState(() => _preferences = preferences);
    // Serialize rapid setting changes so the final on-screen choice wins.
    final write = _preferenceWrites
        .catchError((Object _) {})
        .then((_) => _preferencesRepository.save(preferences));
    _preferenceWrites = write;
    try {
      await write;
    } catch (_) {
      if (mounted) _showStorageError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: _messengerKey,
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
            ),
    );
  }
}
