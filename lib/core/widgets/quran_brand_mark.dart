import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

const quranBrandAsset = 'assets/brand/quran-haven-book-v2.png';

/// The same unaltered book identity used by Quran Haven's app and site icons.
class QuranBrandMark extends StatelessWidget {
  const QuranBrandMark({super.key, this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: AppLocalizations.of(context).quranBrandLabel,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.27),
      child: Image.asset(
        quranBrandAsset,
        width: size,
        height: size,
        fit: BoxFit.contain,
        excludeFromSemantics: true,
      ),
    ),
  );
}
