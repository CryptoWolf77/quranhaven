import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_flutter/features/learning/domain/corpus_morphology.dart';
import 'package:quran_flutter/features/learning/data/corpus_repository.dart';
import 'package:quran_flutter/features/learning/presentation/corpus_learning_page.dart';
import 'package:quran_flutter/features/personal/domain/personal_models.dart';
import 'package:quran_flutter/features/personal/domain/saved_text_search.dart';
import 'package:quran_flutter/l10n/generated/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late List<int> bytes;
  late String raw;
  late CorpusIndex index;
  setUpAll(() {
    bytes = File(corpusAsset).readAsBytesSync();
    raw = utf8.decode(bytes);
    index = CorpusIndex.parse(raw);
  });
  test('original dataset bytes and SHA256 remain unmodified', () {
    expect(bytes.length, corpusByteCount);
    expect(sha256.convert(bytes).toString(), corpusSha256);
  });
  test(
    'runtime verifies bundled original source and refuses modified/truncated bytes',
    () async {
      final loaded = await CorpusRepository().load();
      expect(loaded.ayahCount, 6236);
      final modified = Uint8List.fromList(bytes)..[100] ^= 1;
      expect(() => verifyCorpusBytes(modified), throwsFormatException);
      expect(
        () => verifyCorpusBytes(
          Uint8List.fromList(bytes.sublist(0, bytes.length - 1)),
        ),
        throwsFormatException,
      );
    },
  );
  test(
    'all original copyright and Tanzil terms remain in dataset and notices',
    () {
      for (final phrase in [
        'Copyright (C) 2011 Kais Dukes',
        'Copyright (C) 2008-2009 Tanzil.info',
        'Creative Commons BY-ND 3.0 Unported',
        'CHANGING IT IS NOT ALLOWED',
        'http://corpus.quran.com',
        'http://tanzil.info/updates/',
      ]) {
        expect(raw, contains(phrase));
        expect(index.notices, contains(phrase));
      }
      expect(
        index.notices,
        startsWith('# PLEASE DO NOT REMOVE OR CHANGE THIS COPYRIGHT BLOCK'),
      );
      final license = File(corpusLicenseAsset).readAsStringSync();
      expect(license, contains('GNU GENERAL PUBLIC LICENSE'));
      expect(license, contains('Version 3, 29 June 2007'));
      expect(license, contains('END OF TERMS AND CONDITIONS'));
    },
  );
  test('validated whole index covers all 114 Surahs and 6236 Ayahs', () {
    expect(index.ayahCount, 6236);
    expect(index.segmentCount, 128219);
    expect(index.wordCount, 77429);
    for (var s = 1; s <= 114; s++) {
      for (var a = 1; a <= hafsAyahCounts[s - 1]; a++) {
        final words = index.wordsFor(AyahReference(s, a));
        expect(words.first.number, 1);
        expect(words.last.number, words.length);
        for (final w in words) {
          expect(w.segments.first.segmentNumber, 1);
          expect(w.segments.last.segmentNumber, w.segments.length);
        }
      }
    }
  });
  test('fixed source samples 1:1, 1:5, 2:282 and 114:6 are exact', () {
    final first = index.wordsFor(const AyahReference(1, 1));
    expect(first.length, 4);
    expect(first.first.form, 'bisomi');
    expect(first.first.arabic, 'بِسْمِ');
    expect(first.first.segments[1].root, 'smw');
    final worship = index.wordsFor(const AyahReference(1, 5));
    expect(worship.length, 4);
    expect(worship[1].segments.single.tag, 'V');
    expect(worship[1].segments.single.root, 'Ebd');
    expect(worship.last.segments.single.lemma, '{sotaEiynu');
    final longest = index.wordsFor(const AyahReference(2, 282));
    expect(longest.length, 128);
    expect(longest.last.form, 'EaliymN');
    final last = index.wordsFor(const AyahReference(114, 6));
    expect(last.length, 3);
    expect(last.last.form, 'wa{ln~aAsi');
    expect(last[1].segments.last.root, 'jnn');
  });
  test('extended Buckwalter is reversible for every documented symbol', () {
    final keys = extendedBuckwalter.keys.join();
    expect(encodeCorpusForm(decodeCorpusForm(keys)), keys);
    expect(decodeCorpusForm('^#:@"[;,.!-+%]'), 'ۣٓٔۜ۟۠ۢۥۦ۪ۭۨ۫۬');
  });
  test('unsupported notation and unknown tags remain visible unchanged', () {
    expect(decodeCorpusForm('?|PJVG'), '?|PJVG');
    final row = CorpusSegment.parse('(1:1:1:1)\t?P\tZZZ\tSTEM|UNKNOWN:code');
    expect(row.arabic, '?P');
    expect(row.tag, 'ZZZ');
    expect(row.features, 'STEM|UNKNOWN:code');
    expect(row.root, null);
  });
  test(
    'all 208 source null-form pronoun suffixes are retained without invented text',
    () {
      var count = 0;
      for (var s = 1; s <= 114; s++) {
        for (var a = 1; a <= hafsAyahCounts[s - 1]; a++) {
          for (final word in index.wordsFor(AyahReference(s, a))) {
            for (final segment in word.segments) {
              if (segment.form.isEmpty) {
                count++;
                expect(segment.tag, 'PRON');
                expect(segment.features, 'SUFFIX|PRON:1S');
                expect(segment.arabic, '');
              }
            }
          }
        }
      }
      expect(count, 208);
    },
  );
  test('invalid locations and column structures rejected', () {
    for (final line in [
      '1:1:1:1\tbi\tP\tPREFIX|bi+',
      '(115:1:1:1)\tbi\tP\tPREFIX|bi+',
      '(1:8:1:1)\tbi\tP\tPREFIX|bi+',
      '(1:1:0:1)\tbi\tP\tPREFIX|bi+',
      '(1:1:1:0)\tbi\tP\tPREFIX|bi+',
      '(1:1:1:1)\tbi\tP',
      '(1:1:1:1)\t\tP\tPREFIX|bi+',
    ]) {
      expect(() => CorpusSegment.parse(line), throwsFormatException);
    }
  });
  test('no partial index is accepted as the complete learning resource', () {
    const partial =
        'LOCATION\tFORM\tTAG\tFEATURES\n(1:1:1:1)\tbi\tP\tPREFIX|bi+\n';
    expect(() => CorpusIndex.parse(partial), throwsFormatException);
    expect(CorpusIndex.parse(partial, requireComplete: false).wordCount, 1);
  });
  test(
    'duplicate segment and discontinuous word/segment numbering rejected',
    () {
      const header = 'LOCATION\tFORM\tTAG\tFEATURES\n',
          first = '(1:1:1:1)\tbi\tP\tPREFIX|bi+\n';
      for (final next in [
        first,
        '(1:1:1:3)\tsomi\tN\tSTEM\n',
        '(1:1:3:1)\tsomi\tN\tSTEM\n',
      ]) {
        expect(
          () => CorpusIndex.parse('$header$first$next', requireComplete: false),
          throwsFormatException,
        );
      }
    },
  );
  test('Ayah navigation follows canonical boundaries with exact endpoints', () {
    expect(adjacentCorpusAyah(const AyahReference(1, 1), -1), null);
    expect(adjacentCorpusAyah(const AyahReference(114, 6), 1), null);
    expect(adjacentCorpusAyah(const AyahReference(1, 7), 1)!.key, '2:1');
    expect(adjacentCorpusAyah(const AyahReference(2, 1), -1)!.key, '1:7');
    expect(adjacentCorpusAyah(const AyahReference(2, 282), 1)!.key, '2:283');
  });
  test(
    'content direction is independent of interface locale and numeric prefixes',
    () {
      expect(isRtlResourceText('1. نخصك وحدك بالعبادة'), true);
      expect(isRtlResourceText('2:1 Solo a Ti'), false);
      expect(isRtlResourceText('(5) اردو'), true);
      expect(isRtlResourceText('English followed by عربي'), false);
    },
  );
  for (final lang in ['ar', 'en', 'es']) {
    testWidgets(
      'Corpus selectable word and exact root codes expose semantics in $lang',
      (t) async {
        final semantics = t.ensureSemantics();
        final word = index.wordsFor(const AyahReference(1, 1)).first;
        await t.pumpWidget(
          MaterialApp(
            locale: Locale(lang),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: Scaffold(
              body: SingleChildScrollView(child: CorpusWordCard(word: word)),
            ),
          ),
        );
        await t.pumpAndSettle();
        expect(find.bySemanticsLabel(word.arabic), findsOneWidget);
        expect(find.bySemanticsLabel('smw'), findsOneWidget);
        expect(find.bySemanticsLabel(RegExp('ROOT:smw')), findsOneWidget);
        expect(find.byType(SelectableText), findsWidgets);
        semantics.dispose();
        expect(t.takeException(), null);
      },
    );
    test(
      'known POS labels are localized and unknown codes preserved in $lang',
      () async {
        final l = await AppLocalizations.delegate.load(Locale(lang));
        expect(corpusPosLabel(l, 'N'), isNot('N'));
        expect(corpusPosLabel(l, 'DET'), isNot('DET'));
        expect(corpusPosLabel(l, 'ZZZ'), 'ZZZ');
      },
    );
    testWidgets('Corpus word/segment card fits narrow screen in $lang', (
      t,
    ) async {
      await t.binding.setSurfaceSize(const Size(375, 812));
      addTearDown(() => t.binding.setSurfaceSize(null));
      final word = index.wordsFor(const AyahReference(1, 5))[2];
      await t.pumpWidget(
        MaterialApp(
          locale: Locale(lang),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: CorpusWordCard(word: word),
              ),
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(find.text('PREFIX|w:CONJ+'), findsOneWidget);
      expect(find.text(word.arabic), findsOneWidget);
      expect(t.takeException(), null);
    });
  }
  testWidgets(
    'source dialog exposes complete notices, bundled GPL and provenance',
    (t) async {
      await t.binding.setSurfaceSize(const Size(1280, 900));
      addTearDown(() => t.binding.setSurfaceSize(null));
      final repo = CorpusRepository();
      await t.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: CorpusSourceDialog(index: index, repository: repo),
          ),
        ),
      );
      await t.pumpAndSettle();
      final selectable = t
          .widgetList<SelectableText>(find.byType(SelectableText))
          .map((w) => w.data ?? '')
          .join('\n');
      expect(selectable, contains(index.notices));
      expect(selectable, contains('END OF TERMS AND CONDITIONS'));
      expect(
        selectable,
        contains('Not downloaded directly through the publisher'),
      );
      expect(selectable, contains(corpusSha256));
      final semantics = t.ensureSemantics();
      await t.pump();
      expect(
        find.bySemanticsLabel(RegExp('Quranic Arabic Corpus v0.4')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(index.notices),
        findsOneWidget,
      );
      semantics.dispose();
      expect(t.takeException(), null);
    },
  );
}
