import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_flutter/app/theme/app_theme.dart';
import 'package:quran_flutter/features/guide/presentation/user_guide_page.dart';
import 'package:quran_flutter/features/quran/presentation/reader_navigation.dart';
import 'package:quran_flutter/features/settings/presentation/settings_page.dart';
import 'package:quran_flutter/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

Widget _host({
  String locale = 'en',
  double textScale = 1,
  bool reducedMotion = false,
  bool mediaMissing = false,
  Widget? home,
}) {
  final bundle = _GuideBundle(missing: mediaMissing);
  return MaterialApp(
    theme: AppTheme.light(),
    locale: Locale(locale),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => DefaultAssetBundle(
      bundle: bundle,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
          disableAnimations: reducedMotion,
        ),
        child: child!,
      ),
    ),
    home: home ?? const UserGuidePage(),
  );
}

String _mediaAsset(WidgetTester tester, String demo) =>
    (tester.widget<Image>(find.byKey(ValueKey('guide-media-$demo'))).image
            as AssetImage)
        .assetName;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final locale in ['ar', 'en', 'es']) {
    testWidgets('$locale guide fits a narrow screen at 2x text', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(360, 760));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(_host(locale: locale, textScale: 2));
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(UserGuidePage));
      final l10n = AppLocalizations.of(context);
      expect(
        Directionality.of(context),
        locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      );
      expect(find.text(l10n.guideTitle), findsOneWidget);
      for (final topic in [
        'reader',
        'search',
        'library',
        'audio',
        'offline',
        'plans',
        'settings',
        'storage',
      ]) {
        expect(find.byKey(ValueKey('guide-topic-$topic')), findsOneWidget);
      }
      for (final demo in ['reader', 'library', 'plans', 'offline']) {
        expect(_mediaAsset(tester, demo), 'assets/guides/$locale/$demo.png');
      }
      await tester.ensureVisible(find.text(l10n.guideStorageTip));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('the desktop guide has two spacious columns', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1240, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();
    final reader = tester.getTopLeft(
      find.byKey(const ValueKey('guide-topic-reader')),
    );
    final search = tester.getTopLeft(
      find.byKey(const ValueKey('guide-topic-search')),
    );
    expect(reader.dy, search.dy);
    expect(search.dx, greaterThan(reader.dx));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'GIF playback requires an explicit click and Stop restores the poster',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1120, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(_host());
      await tester.pumpAndSettle();
      expect(_mediaAsset(tester, 'reader'), endsWith('.png'));
      final play = find.byKey(const ValueKey('guide-play-reader'));
      await tester.ensureVisible(play);
      await tester.tap(play);
      await tester.pumpAndSettle();
      expect(_mediaAsset(tester, 'reader'), 'assets/guides/en/reader.gif');
      expect(find.text('Stop demonstration'), findsOneWidget);
      await tester.tap(play);
      await tester.pumpAndSettle();
      expect(_mediaAsset(tester, 'reader'), 'assets/guides/en/reader.png');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('reduced motion keeps all posters and disables animation', (
    tester,
  ) async {
    await tester.pumpWidget(_host(reducedMotion: true));
    await tester.pumpAndSettle();
    for (final demo in ['reader', 'library', 'plans', 'offline']) {
      expect(_mediaAsset(tester, demo), endsWith('.png'));
      final play = tester.widget<OutlinedButton>(
        find.byKey(ValueKey('guide-play-$demo')),
      );
      expect(play.onPressed, isNull);
    }
    expect(find.textContaining('reduced motion'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('missing media falls back to readable steps without crashing', (
    tester,
  ) async {
    await tester.pumpWidget(_host(mediaMissing: true));
    await tester.pumpAndSettle();
    expect(find.textContaining('Follow the written steps'), findsWidgets);
    expect(find.textContaining('Swipe between pages'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Settings opens a local guide route and Back returns to Settings',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final previous = SharedPreferencesAsyncPlatform.instance;
      SharedPreferencesAsyncPlatform.instance = _ReminderPreferences();
      addTearDown(() => SharedPreferencesAsyncPlatform.instance = previous);
      await tester.pumpWidget(
        _host(
          home: Scaffold(
            body: SettingsPage(
              locale: const Locale('en'),
              themeMode: ThemeMode.system,
              onLocaleChanged: (_) {},
              onThemeModeChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open the guide'));
      await tester.pumpAndSettle();
      expect(find.byType(UserGuidePage), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.byType(UserGuidePage), findsNothing);
      expect(find.byType(SettingsPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  for (final locale in ['ar', 'en', 'es']) {
    testWidgets('$locale navigation sheet has a translated Close control', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(locale: locale, home: const _NavigationHost()),
      );
      await tester.tap(find.text('Open test panel'));
      await tester.pumpAndSettle();
      final close = find.byKey(const ValueKey('reader-navigation-close'));
      final context = tester.element(close);
      expect(
        find.text(MaterialLocalizations.of(context).closeButtonLabel),
        findsOneWidget,
      );
      await tester.tap(close);
      await tester.pumpAndSettle();
      expect(find.byType(ReaderNavigationFrame), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Escape dismisses the navigation sheet', (tester) async {
    await tester.pumpWidget(_host(home: const _NavigationHost()));
    await tester.tap(find.text('Open test panel'));
    await tester.pumpAndSettle();
    expect(find.byType(ReaderNavigationFrame), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(ReaderNavigationFrame), findsNothing);
  });

  testWidgets(
    'Escape dismisses an expanded group after focus leaves the frame',
    (tester) async {
      await tester.pumpWidget(_host(home: const _NavigationHost()));
      await tester.tap(find.text('Open test panel'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bookmark group'));
      await tester.pumpAndSettle();
      expect(find.text('Saved Ayah'), findsOneWidget);
      final frameFocus = Focus.of(
        tester.element(find.byKey(const ValueKey('navigation-test-content'))),
      );
      frameFocus.unfocus();
      await tester.pump();
      expect(frameFocus.hasFocus, isFalse);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await tester.pumpAndSettle();
      expect(find.byType(ReaderNavigationFrame), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(ReaderNavigationFrame), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Escape cannot dismiss a sheet underneath another dialog', (
    tester,
  ) async {
    await tester.pumpWidget(_host(home: const _NavigationHost()));
    await tester.tap(find.text('Open test panel'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bookmark group'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open nested dialog'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.byType(ReaderNavigationFrame), findsOneWidget);
    await tester.tap(find.text('Close nested dialog'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(ReaderNavigationFrame), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final locale in ['ar', 'en', 'es']) {
    testWidgets('$locale enlarged demo fits at 2x text and closes explicitly', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(360, 760));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(_host(locale: locale, textScale: 2));
      await tester.pumpAndSettle();
      final larger = find.byKey(const ValueKey('guide-larger-reader'));
      await tester.ensureVisible(larger);
      await tester.tap(larger);
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsOneWidget);
      final image = tester.widget<Image>(
        find.byKey(const ValueKey('guide-larger-media-reader')),
      );
      expect(
        (image.image as AssetImage).assetName,
        'assets/guides/$locale/reader.png',
      );
      expect(find.byType(InteractiveViewer), findsOneWidget);
      expect(find.byKey(const ValueKey('guide-reset-zoom')), findsOneWidget);
      final close = find.byKey(const ValueKey('guide-larger-close'));
      expect(
        tester.widget<IconButton>(close).tooltip,
        MaterialLocalizations.of(tester.element(close)).closeButtonLabel,
      );
      expect(tester.takeException(), isNull);
      await tester.tap(close);
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);
      expect(find.byType(UserGuidePage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'enlarging stops the small GIF and never starts the large one automatically',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1120, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(_host());
      await tester.pumpAndSettle();
      final smallPlay = find.byKey(const ValueKey('guide-play-reader'));
      await tester.ensureVisible(smallPlay);
      await tester.tap(smallPlay);
      await tester.pumpAndSettle();
      expect(_mediaAsset(tester, 'reader'), endsWith('.gif'));
      await tester.tap(find.byKey(const ValueKey('guide-larger-reader')));
      await tester.pumpAndSettle();
      final largeImage = find.byKey(
        const ValueKey('guide-larger-media-reader'),
      );
      String asset() =>
          (tester.widget<Image>(largeImage).image as AssetImage).assetName;
      expect(asset(), endsWith('.png'));
      final play = find.byKey(const ValueKey('guide-larger-play'));
      await tester.ensureVisible(play);
      await tester.tap(play);
      await tester.pumpAndSettle();
      expect(asset(), endsWith('.gif'));
      await tester.tap(play);
      await tester.pumpAndSettle();
      expect(asset(), endsWith('.png'));
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);
      expect(_mediaAsset(tester, 'reader'), endsWith('.png'));
    },
  );

  testWidgets('enlarged demo zoom resets and respects reduced motion', (
    tester,
  ) async {
    await tester.pumpWidget(_host(reducedMotion: true));
    await tester.pumpAndSettle();
    final larger = find.byKey(const ValueKey('guide-larger-reader'));
    await tester.ensureVisible(larger);
    await tester.tap(larger);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<OutlinedButton>(
            find.byKey(const ValueKey('guide-larger-play')),
          )
          .onPressed,
      isNull,
    );
    final viewer = tester.widget<InteractiveViewer>(
      find.byType(InteractiveViewer),
    );
    expect(viewer.maxScale, greaterThan(1));
    viewer.transformationController!.value = Matrix4.diagonal3Values(2, 2, 1);
    final reset = find.byKey(const ValueKey('guide-reset-zoom'));
    await tester.ensureVisible(reset);
    await tester.tap(reset);
    await tester.pumpAndSettle();
    expect(viewer.transformationController!.value, Matrix4.identity());
    expect(tester.takeException(), isNull);
  });
}

class _NavigationHost extends StatelessWidget {
  const _NavigationHost();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: TextButton(
      onPressed: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => const ReaderNavigationFrame(
          child: SizedBox(height: 300, child: _NavigationTestContent()),
        ),
      ),
      child: const Text('Open test panel'),
    ),
  );
}

class _NavigationTestContent extends StatelessWidget {
  const _NavigationTestContent();

  @override
  Widget build(BuildContext context) => ListView(
    key: const ValueKey('navigation-test-content'),
    children: [
      const Text('Test panel'),
      ExpansionTile(
        title: const Text('Bookmark group'),
        children: [
          const ListTile(title: Text('Saved Ayah')),
          TextButton(
            onPressed: () => showDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                content: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close nested dialog'),
                ),
              ),
            ),
            child: const Text('Open nested dialog'),
          ),
        ],
      ),
    ],
  );
}

class _GuideBundle extends CachingAssetBundle {
  _GuideBundle({required this.missing});
  final bool missing;

  @override
  Future<ByteData> load(String key) async {
    if (key.startsWith('assets/guides/')) {
      if (missing) throw FlutterError('Demo not available in test bundle');
      // A real one-frame GIF is sufficient to test asset selection without timers.
      final bytes = base64Decode(
        'R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7',
      );
      return ByteData.sublistView(bytes);
    }
    return rootBundle.load(key);
  }
}

final class _ReminderPreferences extends SharedPreferencesAsyncPlatform {
  @override
  Future<bool?> getBool(String key, SharedPreferencesOptions options) async =>
      false;
  @override
  Future<int?> getInt(String key, SharedPreferencesOptions options) async =>
      null;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
