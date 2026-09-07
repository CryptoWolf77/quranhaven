import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_flutter/features/home/presentation/home_page.dart';
import 'package:quran_flutter/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('home opens the Quran reader', (tester) async {
    var openedReader = false;
    var openedLibrary = false;
    var browsedSurahs = false;
    var searched = false;
    var openedBookmarks = false;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: HomePage(
          currentPage: 42,
          onOpenReader: () => openedReader = true,
          onOpenLibrary: () => openedLibrary = true,
          onBrowseSurahs: () => browsedSurahs = true,
          onSearch: () => searched = true,
          onBookmarks: () => openedBookmarks = true,
        ),
      ),
    );

    expect(find.text('A quiet place for the Quran'), findsOneWidget);
    expect(find.text('Last read · Page 42'), findsOneWidget);
    await tester.tap(find.text('Open the Mushaf'));
    expect(openedReader, isTrue);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Downloads'));
    expect(openedLibrary, isTrue);
    openedReader = false;
    await tester.tap(find.text('Browse Surahs'));
    await tester.tap(find.text('Search Quran'));
    await tester.tap(find.text('Bookmarks'));
    expect(browsedSurahs, isTrue);
    expect(searched, isTrue);
    expect(openedBookmarks, isTrue);
    expect(openedReader, isFalse);
  });
}
