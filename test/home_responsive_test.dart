import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_flutter/features/home/presentation/home_page.dart';
import 'package:quran_flutter/l10n/generated/app_localizations.dart';

void main() {
  for (final language in ['en', 'ar', 'es']) {
    testWidgets('Home shortcuts fit $language at 360px and 2x text', (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(MaterialApp(
        locale: Locale(language),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(2)),
          child: child!,
        ),
        home: Scaffold(body: HomePage(
          currentPage: 42, onOpenReader: () {}, onOpenLibrary: () {},
          onBrowseSurahs: () {}, onSearch: () {}, onBookmarks: () {},
        )),
      ));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
