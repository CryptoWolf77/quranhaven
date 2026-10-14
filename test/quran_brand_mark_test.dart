import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_flutter/core/widgets/creator_credit.dart';
import 'package:quran_flutter/core/widgets/quran_brand_mark.dart';
import 'package:quran_flutter/features/home/presentation/home_page.dart';
import 'package:quran_flutter/l10n/generated/app_localizations.dart';

Widget _host(Widget child, {String language = 'en', double textScale = 1}) =>
    MaterialApp(
      locale: Locale(language),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: Scaffold(body: child),
    );

void main() {
  for (final language in ['ar', 'en', 'es']) {
    testWidgets(
      '$language book identity is accessible at shell and Home sizes',
      (tester) async {
        final semantics = tester.ensureSemantics();
        try {
          await tester.pumpWidget(
            _host(
              const Row(children: [QuranBrandMark(size: 46), QuranBrandMark()]),
              language: language,
            ),
          );
          await tester.pumpAndSettle();
          final l = await AppLocalizations.delegate.load(Locale(language));
          expect(find.bySemanticsLabel(l.quranBrandLabel), findsNWidgets(2));
          final images = tester.widgetList<Image>(find.byType(Image)).toList();
          expect(images, hasLength(2));
          expect(
            images.map((image) => (image.image as AssetImage).assetName),
            everyElement(quranBrandAsset),
          );
          expect(images.map((image) => image.color), everyElement(isNull));
          expect(images.first.width, 46);
          expect(images.first.height, 46);
          expect(images.last.width, 48);
          expect(images.last.height, 48);
          expect(
            images.map((image) => image.fit),
            everyElement(BoxFit.contain),
          );
          expect(tester.takeException(), isNull);
        } finally {
          semantics.dispose();
        }
      },
    );

    testWidgets(
      '$language mobile Home uses book, retains guide and original credit',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 812));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(
          _host(
            HomePage(
              currentPage: 3,
              onOpenReader: () {},
              onOpenLibrary: () {},
              onBrowseSurahs: () {},
              onSearch: () {},
              onBookmarks: () {},
            ),
            language: language,
            textScale: 2,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(QuranBrandMark), findsOneWidget);
        expect(find.byIcon(Icons.nights_stay_outlined), findsNothing);
        expect(find.byKey(const ValueKey('home-guide-open')), findsOneWidget);
        await tester.scrollUntilVisible(
          find.byKey(const ValueKey('creator-credit-link')),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        expect(find.byType(CreatorCredit), findsOneWidget);
        final credit = tester.widget<Image>(
          find.byKey(const ValueKey('creator-logo')),
        );
        expect((credit.image as AssetImage).assetName, creatorLogoAsset);
        expect(credit.color, isNull);
        expect(tester.takeException(), isNull);
      },
    );
  }

  test(
    'new exact book master is declared once and has stable source identity',
    () {
      final source =
          jsonDecode(
                File(
                  'assets/brand/quran-haven-book-v2.source.json',
                ).readAsStringSync(),
              )
              as Map;
      expect(source['output']['workspacePath'], quranBrandAsset);
      expect(source['output']['size'], [1254, 1254]);
      expect(source['output']['opaque'], isTrue);
      expect(
        source['output']['sha256'],
        '01c29aafee831d03d79682a4aae67afd541a5323e0983ce3125f2df9b9152821',
      );
      final image = File(quranBrandAsset).readAsBytesSync();
      expect(image.take(8), [137, 80, 78, 71, 13, 10, 26, 10]);
      final dimensions = image.buffer.asByteData();
      expect(dimensions.getUint32(16), 1254);
      expect(dimensions.getUint32(20), 1254);
      final yaml = File('pubspec.yaml').readAsStringSync();
      expect(yaml.split(quranBrandAsset), hasLength(2));
      expect(File('assets/brand/app-icon-1024.png').existsSync(), isTrue);
      final shell = File(
        'lib/features/shell/presentation/app_shell.dart',
      ).readAsStringSync();
      expect(shell, contains('const QuranBrandMark(size: 46)'));
      expect(shell, isNot(contains("'ق'")));
    },
  );
}
