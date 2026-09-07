import 'package:flutter/material.dart';
import 'package:quran_library/quran_library.dart';

import '../../../l10n/generated/app_localizations.dart';

Future<void> showReaderNavigation(
  BuildContext context,
  QuranNavigationTab tab,
) {
  final l10n = AppLocalizations.of(context);
  final scheme = Theme.of(context).colorScheme;
  final dark = Theme.of(context).brightness == Brightness.dark;
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: scheme.surface,
    builder: (_) => QuranNavigationSheet(
      initialTab: tab,
      isDark: dark,
      languageCode: Localizations.localeOf(context).languageCode,
      style: QuranTopBarStyle.defaults(isDark: dark, context: context).copyWith(
        tabIndexLabel: l10n.index,
        tabSearchLabel: l10n.search,
        tabBookmarksLabel: l10n.bookmarks,
        textColor: scheme.onSurface,
        accentColor: scheme.primary,
      ),
      indexStyle: IndexTabStyle.defaults(isDark: dark, context: context)
          .copyWith(
            tabSurahsLabel: l10n.surahs,
            tabJozzLabel: l10n.juz,
            textColor: scheme.onSurface,
            accentColor: scheme.primary,
          ),
      searchStyle: SearchTabStyle.defaults(isDark: dark, context: context)
          .copyWith(
            searchHintText: l10n.searchHint,
            textColor: scheme.onSurface,
            accentColor: scheme.primary,
          ),
      bookmarksStyle: BookmarksTabStyle.defaults(isDark: dark, context: context)
          .copyWith(
            emptyStateText: l10n.noBookmarks,
            yellowGroupText: l10n.yellowBookmarks,
            redGroupText: l10n.redBookmarks,
            greenGroupText: l10n.greenBookmarks,
            textColor: scheme.onSurface,
          ),
    ),
  );
}
