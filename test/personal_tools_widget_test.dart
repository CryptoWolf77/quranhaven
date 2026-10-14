import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_flutter/features/personal/data/personal_repository.dart';
import 'package:quran_flutter/features/personal/domain/personal_models.dart';
import 'package:quran_flutter/features/personal/presentation/personal_tools_page.dart';
import 'package:quran_flutter/features/personal/presentation/share_ayah_page.dart';
import 'package:quran_flutter/l10n/generated/app_localizations.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

final class _UnusedPreferences extends SharedPreferencesAsyncPlatform {
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _FakePersonal extends PersonalRepository {
  PersonalData value = const PersonalData();
  bool rejectLoad = false, rejectSave = false;
  @override
  Future<PersonalData> load() async {
    if (rejectLoad) throw StateError('read');
    return value;
  }

  @override
  Future<void> save(PersonalData d) async {
    if (rejectSave) throw StateError('write');
    value = d;
  }
}

Widget host(Widget child, {String language = 'en'}) => MaterialApp(
  locale: Locale(language),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  home: child,
);
void main() {
  SharedPreferencesAsyncPlatform? original;
  setUp(() {
    original = SharedPreferencesAsyncPlatform.instance;
    SharedPreferencesAsyncPlatform.instance = _UnusedPreferences();
  });
  tearDown(() => SharedPreferencesAsyncPlatform.instance = original);
  for (final language in ['ar', 'en', 'es']) {
    testWidgets('personal empty state fits 375px in $language', (t) async {
      await t.binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => t.binding.setSurfaceSize(null));
      final l = await AppLocalizations.delegate.load(Locale(language));
      await t.pumpWidget(
        host(
          PersonalToolsPage(onOpenAyah: (_) {}, repository: _FakePersonal()),
          language: language,
        ),
      );
      await t.pumpAndSettle();
      expect(find.text(l.notesEmpty), findsOneWidget);
      await t.tap(find.text(l.personalCollections));
      await t.pumpAndSettle();
      expect(find.text(l.collectionsEmpty), findsOneWidget);
      expect(t.takeException(), null);
    });
  }
  testWidgets('load error blocks writes and exposes retry', (t) async {
    final repo = _FakePersonal()..rejectLoad = true;
    await t.pumpWidget(
      host(PersonalToolsPage(onOpenAyah: (_) {}, repository: repo)),
    );
    await t.pumpAndSettle();
    expect(find.text('Add a note'), findsNothing);
    expect(find.text('Try again'), findsOneWidget);
    repo.rejectLoad = false;
    await t.tap(find.text('Try again'));
    await t.pumpAndSettle();
    expect(find.text('Add a note'), findsOneWidget);
  });
  testWidgets('failed collection creation preserves last durable state', (
    t,
  ) async {
    final repo = _FakePersonal()..rejectSave = true;
    await t.pumpWidget(
      host(PersonalToolsPage(onOpenAyah: (_) {}, repository: repo)),
    );
    await t.pumpAndSettle();
    await t.tap(find.text('Collections'));
    await t.pumpAndSettle();
    await t.tap(find.text('Create collection'));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextFormField), 'Daily reflection');
    await t.tap(find.text('Save'));
    await t.pumpAndSettle();
    expect(repo.value.collections, isEmpty);
    expect(find.text('Daily reflection'), findsNothing);
    expect(
      find.textContaining('Your change could not be saved'),
      findsOneWidget,
    );
  });
  testWidgets('collection rename and confirmed deletion persist', (t) async {
    final repo = _FakePersonal()
      ..value = const PersonalData(
        collections: [AyahCollection(id: 'c1', name: 'Old name', ayahs: [])],
      );
    await t.pumpWidget(
      host(PersonalToolsPage(onOpenAyah: (_) {}, repository: repo)),
    );
    await t.pumpAndSettle();
    await t.tap(find.text('Collections'));
    await t.pumpAndSettle();
    await t.tap(find.byTooltip('Rename collection'));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextFormField), 'New name');
    await t.tap(find.text('Save'));
    await t.pumpAndSettle();
    expect(repo.value.collections.single.name, 'New name');
    await t.tap(find.byTooltip('Delete'));
    await t.pumpAndSettle();
    await t.tap(find.text('Cancel'));
    await t.pumpAndSettle();
    expect(repo.value.collections.length, 1);
    await t.tap(find.byTooltip('Delete'));
    await t.pumpAndSettle();
    await t.tap(find.widgetWithText(TextButton, 'Delete'));
    await t.pumpAndSettle();
    expect(repo.value.collections, isEmpty);
  });
  testWidgets('complete long Ayah image card never truncates text', (t) async {
    final source = List.filled(80, 'نصٌّ كاملٌ للآية').join(' ');
    await t.pumpWidget(
      host(
        Scaffold(
          body: SingleChildScrollView(
            child: AyahShareCard(
              ayahText: source,
              reference: const AyahReference(2, 282),
              surahName: 'البقرة',
              sourceLabel: 'Source',
              translation: 'Full translation',
              translationSource: 'Translator',
            ),
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    final text = t.widget<Text>(find.text(source));
    expect(text.maxLines, null);
    expect(text.overflow, null);
    expect(text.data, source);
    expect(t.takeException(), null);
  });
}
