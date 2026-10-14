import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_flutter/app/theme/app_theme.dart';
import 'package:quran_flutter/features/guide/presentation/user_guide_page.dart';
import 'package:quran_flutter/l10n/generated/app_localizations.dart';

const _primary = 'packages/quran_library/cairo';
const _fallbacks = <String>[
  'packages/quran_library/naskh',
  'NotoSansBengali',
  'NotoSansSymbols',
];

Iterable<TextStyle?> _styles(TextTheme theme) => [
  theme.displayLarge,
  theme.displayMedium,
  theme.displaySmall,
  theme.headlineLarge,
  theme.headlineMedium,
  theme.headlineSmall,
  theme.titleLarge,
  theme.titleMedium,
  theme.titleSmall,
  theme.bodyLarge,
  theme.bodyMedium,
  theme.bodySmall,
  theme.labelLarge,
  theme.labelMedium,
  theme.labelSmall,
];

// Inspect the original TTF's Unicode cmap rather than relying on a platform
// fallback which could silently render an arrow from a remote/system font.
bool _hasGlyph(ByteData font, int codepoint) {
  int u16(int offset) => font.getUint16(offset, Endian.big);
  int u32(int offset) => font.getUint32(offset, Endian.big);
  var cmap = 0;
  for (var table = 0; table < u16(4); table++) {
    final offset = 12 + table * 16;
    if (u32(offset) == 0x636d6170) cmap = u32(offset + 8);
  }
  if (cmap == 0) return false;
  for (var table = 0; table < u16(cmap + 2); table++) {
    final record = cmap + 4 + table * 8;
    final platform = u16(record), encoding = u16(record + 2);
    if (platform != 0 && !(platform == 3 && [1, 10].contains(encoding))) {
      continue;
    }
    final offset = cmap + u32(record + 4), format = u16(offset);
    if (format == 4 && codepoint <= 0xffff) {
      final count = u16(offset + 6) ~/ 2;
      final ends = offset + 14, starts = ends + count * 2 + 2;
      final deltas = starts + count * 2, ranges = deltas + count * 2;
      for (var segment = 0; segment < count; segment++) {
        final start = u16(starts + segment * 2);
        if (codepoint < start || codepoint > u16(ends + segment * 2)) continue;
        final delta = font.getInt16(deltas + segment * 2, Endian.big);
        final range = u16(ranges + segment * 2);
        final glyph = range == 0
            ? (codepoint + delta) & 0xffff
            : u16(ranges + segment * 2 + range + (codepoint - start) * 2);
        if (glyph != 0 && (range == 0 || ((glyph + delta) & 0xffff) != 0)) {
          return true;
        }
        break;
      }
    } else if (format == 12 || format == 13) {
      for (var group = 0; group < u32(offset + 12); group++) {
        final record = offset + 16 + group * 12;
        final start = u32(record), end = u32(record + 4);
        final glyph = u32(record + 8);
        if (start <= codepoint &&
            codepoint <= end &&
            (format == 13 ? glyph : glyph + codepoint - start) != 0) {
          return true;
        }
      }
    }
  }
  return false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final entry in {
    'light': AppTheme.light(),
    'dark': AppTheme.dark(),
  }.entries) {
    test(
      '${entry.key} interface keeps primary font and local symbol fallback',
      () {
        for (final style in _styles(entry.value.textTheme)) {
          expect(style?.fontFamily, _primary);
          expect(style?.fontFamilyFallback, _fallbacks);
        }
        expect(
          entry.value.navigationRailTheme.selectedLabelTextStyle?.fontFamily,
          _primary,
        );
        expect(
          entry
              .value
              .navigationRailTheme
              .selectedLabelTextStyle
              ?.fontFamilyFallback,
          _fallbacks,
        );
      },
    );
  }

  test(
    'symbol font and license are available in the local asset bundle',
    () async {
      final manifest =
          jsonDecode(await rootBundle.loadString('FontManifest.json'))
              as List<dynamic>;
      final family = manifest.cast<Map<String, dynamic>>().singleWhere(
        (entry) => entry['family'] == 'NotoSansSymbols',
      );
      expect(
        (family['fonts'] as List).single['asset'],
        'assets/fonts/NotoSansSymbols.ttf',
      );
      final font = await rootBundle.load('assets/fonts/NotoSansSymbols.ttf');
      expect(font.lengthInBytes, greaterThan(100000));
      // TrueType sfnt version 1.0, not an error page saved as a font.
      expect(font.buffer.asUint8List(font.offsetInBytes, 4), [0, 1, 0, 0]);
      expect(_hasGlyph(font, 0x2190), isTrue, reason: 'Local leftwards arrow');
      expect(_hasGlyph(font, 0x2192), isTrue, reason: 'Local rightwards arrow');
      final license = await rootBundle.loadString(
        'assets/fonts/OFL-NotoSansSymbols.txt',
      );
      expect(license, contains('SIL Open Font License, Version 1.1'));
      expect(license, contains('Copyright 2022 The Noto Project Authors'));
    },
  );

  for (final language in ['ar', 'en', 'es']) {
    testWidgets('$language guide text inherits local symbol fallback at 2x', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(360, 760));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          locale: Locale(language),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(2)),
            child: child!,
          ),
          home: const UserGuidePage(),
        ),
      );
      await tester.pumpAndSettle();
      final guide = find.byType(UserGuidePage);
      final texts = find.descendant(of: guide, matching: find.byType(Text));
      expect(texts, findsWidgets);
      for (final element in texts.evaluate()) {
        final text = element.widget as Text;
        final inherited = DefaultTextStyle.of(element).style;
        final effective = text.style?.inherit == false
            ? text.style!
            : inherited.merge(text.style);
        expect(effective.fontFamily, _primary, reason: text.data);
        expect(effective.fontFamilyFallback, _fallbacks, reason: text.data);
      }
      expect(tester.takeException(), isNull);
    });
  }
}
