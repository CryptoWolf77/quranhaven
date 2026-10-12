import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    builder: (_) => ReaderNavigationFrame(
      child: QuranNavigationSheet(
        initialTab: tab,
        isDark: dark,
        languageCode: Localizations.localeOf(context).languageCode,
        style: QuranTopBarStyle.defaults(isDark: dark, context: context)
            .copyWith(
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
        bookmarksStyle:
            BookmarksTabStyle.defaults(isDark: dark, context: context).copyWith(
              emptyStateText: l10n.noBookmarks,
              yellowGroupText: l10n.yellowBookmarks,
              redGroupText: l10n.redBookmarks,
              greenGroupText: l10n.greenBookmarks,
              textColor: scheme.onSurface,
            ),
      ),
    ),
  );
}

/// Accessible dismissal for the app's navigation sheets, including keyboard use.
class ReaderNavigationFrame extends StatefulWidget {
  const ReaderNavigationFrame({required this.child, super.key});

  final Widget child;

  @override
  State<ReaderNavigationFrame> createState() => _ReaderNavigationFrameState();
}

class _ReaderNavigationFrameState extends State<ReaderNavigationFrame> {
  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  bool _handleKeyEvent(KeyEvent event) {
    // An expanded bookmark group or web text field can move focus outside the
    // sheet's Shortcuts subtree. Listen while this popup is current, never
    // after dismissal or while another dialog is on top.
    if (!mounted ||
        event is! KeyDownEvent ||
        event.logicalKey != LogicalKeyboardKey.escape) {
      return false;
    }
    final route = ModalRoute.of(context);
    if (route is! PopupRoute || !route.isCurrent) return false;
    Navigator.of(context).maybePop();
    return true;
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.94,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton.icon(
                  key: const ValueKey('reader-navigation-close'),
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  label: Text(
                    MaterialLocalizations.of(context).closeButtonLabel,
                  ),
                ),
              ),
            ),
            Flexible(child: widget.child),
          ],
        ),
      ),
    );
  }
}
