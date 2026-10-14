import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_storage/get_storage.dart';
import 'package:quran_library/quran_library.dart';
import 'dart:convert';

import '../features/settings/data/reading_preferences_repository.dart';
import '../features/settings/domain/reading_preferences.dart';
import '../features/shell/presentation/app_shell.dart';
import '../l10n/generated/app_localizations.dart';
import 'theme/app_theme.dart';
import '../features/personal/data/local_restore_lifecycle.dart';

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
  int _restoreGeneration = 0;

  @override
  void initState() {
    super.initState();
    LocalRestoreLifecycle.beforeRestore = _beforeRestore;
    LocalRestoreLifecycle.refreshAfterRestore = _refreshRestoredState;
    _loadPreferences();
  }

  Future<void> _beforeRestore() async {
    // Drain already-requested preference writes before the transaction begins.
    await _preferenceWrites;
    await AudioCtrl.instance.state.stopAllAudio();
    await WordAudioService.instance.stop();
  }

  Future<void> _refreshRestoredState() async {
    if (!mounted) throw StateError('Restart required');
    setState(() => _preferencesLoaded = false);
    // Dispose pages/routes before updating their retained library controllers.
    await WidgetsBinding.instance.endOfFrame;
    try {
      final box = GetStorage(),
          q = QuranCtrl.instance,
          a = AudioCtrl.instance,
          t = TafsirCtrl.instance;
      final marks = (box.read<List>('bookmarks') ?? []).map((value) {
        final item = value is String ? jsonDecode(value) as Map : value as Map;
        return BookmarkModel(
          id: item['id'] as int,
          colorCode: item['color'] as int,
          name: item['name'] as String,
          ayahId: item['ayahId'] as int,
          ayahNumber: item['ayahNumber'] as int,
          page: item['page'] as int,
        );
      }).toList();
      await BookmarksCtrl.instance.replaceBookmarks(marks);
      q.lastPage = (box.read<int>('last_page') ?? 1).clamp(1, 604);
      q.state.isBold.value = box.read<bool>('IS_BOLD_BOOL') ?? false;
      q.state.fontsSelected.value = box.read<int>('fontsSelected2') ?? 0;
      q.state.displayMode.value = QuranDisplayModeExtension.fromStorageIndex(
        box.read<int>('DISPLAY_MODE') ?? 0,
      );
      q.selectedAyahsByUnequeNumber.clear();
      q.externallyHighlightedAyahs.clear();
      // Detached pages need an exact controller, not the previous dual fraction.
      q.animateToPage(q.lastPage - 1);
      q.update();
      t.fontSizeArabic.value = (box.read<num>('FONT_SIZE') ?? 20).toDouble();
      t.radioValue.value =
          box.read<int>('TAFSEER_VAL') ??
          t.tafsirAndTranslationsItems.indexWhere(
            (r) => r.databaseName == 'saadi.json.gz',
          );
      t.translationLangCode = box.read<String>('TRANS') ?? 'en';
      t.selectedDBName = t.selectedTafsir.databaseName;
      t.tafseerList.clear();
      t.translationList.clear();
      a.state.ayahPlaylistsCache.clear();
      a.loadReaderIndex();
      a.loadLastSurahAndPosition();
      a.state.isPlaying.value = false;
      a.state.isPlayingSurahsMode = false;
      a.state.activeButton.value = '';
      final preferences = await _preferencesRepository.load();
      if (mounted) {
        setState(() {
          _preferences = preferences;
          _restoreGeneration++;
        });
      }
    } catch (_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final context = _messengerKey.currentContext;
        if (mounted && context != null) {
          _messengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).backupRefreshFailed),
            ),
          );
        }
      });
      rethrow;
    } finally {
      if (mounted) setState(() => _preferencesLoaded = true);
    }
  }

  @override
  void dispose() {
    if (LocalRestoreLifecycle.beforeRestore == _beforeRestore) {
      LocalRestoreLifecycle.beforeRestore = null;
    }
    if (LocalRestoreLifecycle.refreshAfterRestore == _refreshRestoredState) {
      LocalRestoreLifecycle.refreshAfterRestore = null;
    }
    super.dispose();
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
      // The selected locale is applied on the next frame. Read its strings
      // after that frame so a failed language write is explained in that language.
      await WidgetsBinding.instance.endOfFrame;
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
              key: ValueKey('app-shell-$_restoreGeneration'),
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
