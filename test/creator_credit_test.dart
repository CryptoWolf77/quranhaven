import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_flutter/core/widgets/creator_credit.dart';
import 'package:quran_flutter/features/home/presentation/home_page.dart';
import 'package:quran_flutter/features/settings/presentation/settings_page.dart';
import 'package:quran_flutter/l10n/generated/app_localizations.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'local_storage_test.dart' show MemoryPreferences;

Widget _host(
  Widget child, {
  String language = 'en',
  Brightness brightness = Brightness.light,
  double textScale = 1,
}) => MaterialApp(
  locale: Locale(language),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF176B55),
      brightness: brightness,
    ),
  ),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: TextScaler.linear(textScale)),
    child: child!,
  ),
  home: Scaffold(body: child),
);

void main() {
  const credit = ValueKey('creator-credit-link');
  const proceed = ValueKey('creator-external-continue');
  const cancel = ValueKey('creator-external-cancel');
  for (final language in ['ar', 'en', 'es']) {
    for (final brightness in Brightness.values) {
      testWidgets(
        '$language $brightness credit and confirmation fit320px/200%',
        (tester) async {
          await tester.binding.setSurfaceSize(const Size(320, 812));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          final semantics = tester.ensureSemantics();
          try {
            final opened = <Uri>[];
            final l = await AppLocalizations.delegate.load(Locale(language));
            await tester.pumpWidget(
              _host(
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: CreatorCredit(
                      openLink: (uri) async {
                        opened.add(uri);
                        return true;
                      },
                    ),
                  ),
                ),
                language: language,
                brightness: brightness,
                textScale: 2,
              ),
            );
            await tester.pumpAndSettle();
            expect(opened, isEmpty);
            expect(find.text(l.creatorCreditTitle), findsOneWidget);
            expect(
              find.bySemanticsLabel(l.creatorCreditSemantics),
              findsOneWidget,
            );
            final target = tester.getSize(find.byKey(credit));
            expect(target.width, greaterThanOrEqualTo(48));
            expect(target.height, greaterThanOrEqualTo(48));
            final image = tester.widget<Image>(
              find.byKey(const ValueKey('creator-logo')),
            );
            expect((image.image as AssetImage).assetName, creatorLogoAsset);
            expect(image.color, isNull);
            expect(image.fit, BoxFit.contain);
            final size = tester.getSize(
              find.byKey(const ValueKey('creator-logo')),
            );
            expect(size.width / size.height, closeTo(1228 / 596, 0.0001));
            await tester.tap(find.byKey(credit));
            await tester.pumpAndSettle();
            expect(opened, isEmpty);
            expect(find.text(l.creatorExternalTitle), findsOneWidget);
            expect(find.text(l.creatorExternalBody), findsOneWidget);
            expect(find.text(l.creatorGuardianReminder), findsOneWidget);
            expect(find.text('yahyazlab.com'), findsNWidgets(2));
            expect(find.byType(TextField), findsNothing);
            await tester.tap(find.byKey(cancel));
            await tester.pumpAndSettle();
            expect(opened, isEmpty);
            expect(find.byType(AlertDialog), findsNothing);
            expect(tester.takeException(), isNull);
          } finally {
            semantics.dispose();
          }
        },
      );
    }
  }

  testWidgets(
    'Continue launches exact HTTPS URL once with duplicate protection',
    (tester) async {
      final opened = <Uri>[];
      final pending = Completer<bool>();
      await tester.pumpWidget(
        _host(
          CreatorCredit(
            openLink: (uri) {
              opened.add(uri);
              return pending.future;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(opened, isEmpty);
      await tester.tap(find.byKey(credit));
      await tester.pumpAndSettle();
      expect(opened, isEmpty);
      await tester.tap(find.byKey(proceed));
      await tester.pumpAndSettle();
      expect(opened.map((uri) => uri.toString()), [creatorWebsiteUrl]);
      final button = tester.widget<InkWell>(find.byKey(credit));
      expect(button.onTap, isNull);
      await tester.tap(find.byKey(credit));
      await tester.pump();
      expect(opened, hasLength(1));
      pending.complete(true);
      await tester.pumpAndSettle();
      expect(tester.widget<InkWell>(find.byKey(credit)).onTap, isNotNull);
      expect(find.byType(AlertDialog), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  for (final action in ['escape', 'back', 'outside']) {
    testWidgets('$action dismissal never opens the external URL', (
      tester,
    ) async {
      var opens = 0;
      await tester.pumpWidget(
        _host(
          CreatorCredit(
            openLink: (_) async {
              opens++;
              return true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(credit));
      await tester.pumpAndSettle();
      switch (action) {
        case 'escape':
          await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        case 'back':
          await tester.binding.handlePopRoute();
        case 'outside':
          await tester.tapAt(const Offset(5, 5));
      }
      await tester.pumpAndSettle();
      expect(opens, 0);
      expect(find.byType(AlertDialog), findsNothing);
      expect(tester.widget<InkWell>(find.byKey(credit)).onTap, isNotNull);
    });
  }

  for (final shouldThrow in [false, true]) {
    testWidgets(
      'failed launcher ${shouldThrow ? 'exception' : 'false'} preserves app',
      (tester) async {
        await tester.pumpWidget(
          _host(
            CreatorCredit(
              openLink: (_) async {
                if (shouldThrow) throw StateError('unavailable');
                return false;
              },
            ),
            language: 'es',
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(credit));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(proceed));
        await tester.pumpAndSettle();
        final l = await AppLocalizations.delegate.load(const Locale('es'));
        expect(find.text(l.creatorOpenFailed), findsOneWidget);
        expect(find.byType(CreatorCredit), findsOneWidget);
        expect(tester.widget<InkWell>(find.byKey(credit)).onTap, isNotNull);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('keyboard activation opens confirmation, not the URL', (
    tester,
  ) async {
    var opens = 0;
    await tester.pumpWidget(
      _host(
        CreatorCredit(
          openLink: (_) async {
            opens++;
            return true;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(opens, 0);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(opens, 0);
  });

  testWidgets('Home retains usage guide before the creator footer', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(960, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _host(
        HomePage(
          currentPage: 42,
          onOpenReader: () {},
          onOpenLibrary: () {},
          onBrowseSurahs: () {},
          onSearch: () {},
          onBookmarks: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('home-guide-open')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(credit),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.byType(CreatorCredit), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Settings includes the same creator credit after privacy', (
    tester,
  ) async {
    final previous = SharedPreferencesAsyncPlatform.instance;
    SharedPreferencesAsyncPlatform.instance = MemoryPreferences();
    addTearDown(() => SharedPreferencesAsyncPlatform.instance = previous);
    await tester.pumpWidget(
      _host(
        SettingsPage(
          locale: const Locale('en'),
          themeMode: ThemeMode.light,
          onLocaleChanged: (_) {},
          onThemeModeChanged: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(credit),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.byType(CreatorCredit), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('only the exact supplied PNG is declared as a creator asset', () {
    final yaml = File('pubspec.yaml').readAsStringSync();
    expect(yaml.split(creatorLogoAsset), hasLength(2));
    expect(yaml, isNot(contains('- assets/brand/\n')));
    final image = File(creatorLogoAsset).readAsBytesSync();
    expect(image.take(8), [137, 80, 78, 71, 13, 10, 26, 10]);
    final dimensions = image.buffer.asByteData();
    expect(dimensions.getUint32(16), 1228);
    expect(dimensions.getUint32(20), 596);
  });
}
