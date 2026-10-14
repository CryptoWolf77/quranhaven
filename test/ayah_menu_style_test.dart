import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_flutter/l10n/generated/app_localizations.dart';
import 'package:quran_library/quran_library.dart';

void main() {
  test('copyWith preserves optional selected-Ayah item builder', () {
    List<Widget> builder(BuildContext c, AyahModel a, VoidCallback close) => [
      const Icon(Icons.edit_note),
    ];
    final style = AyahMenuStyle(customMenuItemsBuilder: builder);
    expect(
      style.copyWith(playIconColor: Colors.green).customMenuItemsBuilder,
      same(builder),
    );
  });
  test('copyWith preserves localized menu labels when changing colors', () {
    const style = AyahMenuStyle(
      playLabel: 'Play ayah',
      playAllLabel: 'Play from this ayah',
      tafsirLabel: 'Tafsir',
      copyLabel: 'Copy ayah',
      bookmarkLabels: {0xAAFFD354: 'Save a yellow bookmark'},
    );
    final changed = style.copyWith(playIconColor: Colors.green);
    expect(changed.playLabel, style.playLabel);
    expect(changed.playAllLabel, style.playAllLabel);
    expect(changed.tafsirLabel, style.tafsirLabel);
    expect(changed.copyLabel, style.copyLabel);
    expect(changed.bookmarkLabels, style.bookmarkLabels);
    expect(changed.copyWith(copyLabel: 'Copy').copyLabel, 'Copy');
  });

  for (final language in ['ar', 'en', 'es']) {
    test('all visible ayah actions have distinct names in $language', () async {
      final l10n = await AppLocalizations.delegate.load(Locale(language));
      final labels = {
        l10n.playAyah,
        l10n.tafsir,
        l10n.copyAyah,
        l10n.saveYellowBookmark,
        l10n.saveRedBookmark,
        l10n.saveGreenBookmark,
      };
      expect(labels.length, 6);
      expect(labels.every((label) => label.trim().isNotEmpty), isTrue);
    });
  }
}
