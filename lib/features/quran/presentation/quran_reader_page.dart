import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quran_library/quran_library.dart';

import '../../../l10n/generated/app_localizations.dart';

class QuranReaderPage extends StatelessWidget {
  const QuranReaderPage({required this.onPageChanged, super.key});

  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = scheme.onSurface;

    return QuranLibraryScreen(
      parentContext: context,
      withPageView: true,
      useDefaultAppBar: true,
      isShowAudioSlider: true,
      isShowTabBar: true,
      isShowDisplayModeBar: true,
      showAyahBookmarkedIcon: true,
      enableWordSelection: true,
      isDark: isDark,
      appLanguageCode: locale.languageCode,
      backgroundColor: scheme.surface,
      textColor: textColor,
      bookmarksColor: scheme.secondary,
      ayahSelectedBackgroundColor: scheme.primary.withValues(alpha: 0.16),
      ayahSelectedFontColor: textColor,
      ayahIconColor: scheme.primary,
      onPageChanged: (pageIndex) => onPageChanged(pageIndex + 1),
      topBarStyle: QuranTopBarStyle.defaults(isDark: isDark, context: context)
          .copyWith(
            backgroundColor: scheme.surface,
            textColor: textColor,
            accentColor: scheme.primary,
            iconColor: scheme.primary,
            elevation: 0,
            borderRadius: 20,
            tabIndexLabel: l10n.index,
            tabSearchLabel: l10n.search,
            tabBookmarksLabel: l10n.bookmarks,
            tabSurahsLabel: l10n.surahs,
            tabJozzLabel: l10n.juz,
            customTopBarWidgets: [
              IconButton(
                tooltip: l10n.quickNavigate,
                onPressed: () => _showQuickNavigator(context),
                icon: const Icon(Icons.grid_view_rounded),
              ),
            ],
          ),
      indexTabStyle: IndexTabStyle.defaults(isDark: isDark, context: context)
          .copyWith(
            textColor: textColor,
            accentColor: scheme.primary,
            tabSurahsLabel: l10n.surahs,
            tabJozzLabel: l10n.juz,
            listItemRadius: 14,
            tabBarRadius: 16,
            indicatorRadius: 13,
            surahNumberDecorationColor: scheme.primary.withValues(alpha: 0.72),
          ),
      searchTabStyle: SearchTabStyle.defaults(isDark: isDark, context: context)
          .copyWith(
            textColor: textColor,
            accentColor: scheme.primary,
            searchHintText: l10n.searchHint,
            searchBorderRadius: 16,
            searchFillAlpha: isDark ? 0.14 : 0.07,
            surahChipRadius: 14,
            resultsDividerColor: scheme.outline.withValues(alpha: 0.22),
          ),
      bookmarksTabStyle:
          BookmarksTabStyle.defaults(isDark: isDark, context: context).copyWith(
            textColor: textColor,
            subtitleTextColor: textColor.withValues(alpha: 0.7),
            groupBorderRadius: 18,
            itemBorderRadius: 14,
            emptyStateText: l10n.noBookmarks,
            emptyStateIconColor: scheme.primary.withValues(alpha: 0.62),
            yellowGroupText: l10n.yellowBookmarks,
            redGroupText: l10n.redBookmarks,
            greenGroupText: l10n.greenBookmarks,
          ),
      ayahMenuStyle: AyahMenuStyle.defaults(isDark: isDark, context: context)
          .copyWith(
            copySuccessMessage: l10n.ayahCopied,
            tafsirIconColor: scheme.primary,
            playIconColor: scheme.primary,
            playAllIconColor: scheme.primary,
          ),
      tafsirStyle: TafsirStyle.defaults(isDark: isDark, context: context)
          .copyWith(
            tafsirName: l10n.tafsir,
            translateName: l10n.translation,
            footnotesName: l10n.footnotes,
            tafsirIsEmptyNote: l10n.tafsirEmpty,
          ),
      ayahStyle: AyahAudioStyle.defaults(isDark: isDark, context: context)
          .copyWith(
            backgroundColor: scheme.surfaceContainer,
            playIconColor: scheme.primary,
            seekBarThumbColor: scheme.primary,
            seekBarActiveTrackColor: scheme.primary,
            dialogHeaderTitle: l10n.chooseReader,
            readersTabText: l10n.readers,
            downloadedSurahsTabText: l10n.downloadedSurahs,
            noInternetConnectionText: l10n.noInternet,
            dialogBorderRadius: 22,
          ),
      surahStyle: SurahAudioStyle.defaults(isDark: isDark, context: context)
          .copyWith(
            backgroundColor: scheme.surface,
            primaryColor: scheme.primary,
            playIconColor: scheme.primary,
            seekBarThumbColor: scheme.primary,
            seekBarActiveTrackColor: scheme.primary,
            dialogHeaderTitle: l10n.chooseReader,
            ayahSingularText: l10n.ayahSingular,
            ayahPluralText: l10n.ayahPlural,
            lastListenText: l10n.lastListen,
            noInternetConnectionText: l10n.noInternet,
            dialogBorderRadius: 22,
          ),
      topBottomQuranStyle:
          TopBottomQuranStyle.defaults(
            isDark: isDark,
            context: context,
          ).copyWith(
            juzName: l10n.juz,
            hizbName: l10n.hizb,
            sajdaName: l10n.sajda,
            surahNameColor: scheme.primary,
            juzTextColor: scheme.primary,
            hizbTextColor: scheme.primary,
            pageNumberColor: scheme.primary,
            sajdaNameColor: scheme.secondary,
          ),
    );
  }

  Future<void> _showQuickNavigator(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => const _QuickNavigatorSheet(),
    );
  }
}

class _QuickNavigatorSheet extends StatefulWidget {
  const _QuickNavigatorSheet();

  @override
  State<_QuickNavigatorSheet> createState() => _QuickNavigatorSheetState();
}

class _QuickNavigatorSheetState extends State<_QuickNavigatorSheet> {
  final _pageController = TextEditingController();
  String? _pageError;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToSurah(int surahNumber) {
    QuranLibrary().jumpToSurah(surahNumber);
    Navigator.of(context).pop();
  }

  void _goToJuz(int juzNumber) {
    if (juzNumber == 1) {
      QuranLibrary().jumpToPage(1);
    } else {
      QuranLibrary().jumpToJoz(juzNumber);
    }
    Navigator.of(context).pop();
  }

  void _goToPage() {
    final page = int.tryParse(_pageController.text.trim());
    if (page == null || page < 1 || page > 604) {
      setState(() => _pageError = AppLocalizations.of(context).invalidPage);
      return;
    }
    QuranLibrary().jumpToPage(page);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final surahs = QuranLibrary.getAllSurahs(isArabic: isArabic);
    final height = MediaQuery.sizeOf(context).height * 0.78;

    return DefaultTabController(
      length: 3,
      child: SizedBox(
        height: height.clamp(420, 720),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.onSurface.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 12, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.quickNavigate,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: MaterialLocalizations.of(context).closeButtonLabel,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                l10n.readerMenuHint,
                style: TextStyle(
                  color: scheme.onSurface.withValues(alpha: 0.68),
                  height: 1.4,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TabBar(
                  indicator: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: scheme.onPrimary,
                  unselectedLabelColor: scheme.onSurface,
                  tabs: [
                    Tab(text: l10n.surahs),
                    Tab(text: l10n.juz),
                    Tab(text: l10n.page),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: surahs.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      return ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        tileColor: index.isEven
                            ? scheme.primary.withValues(alpha: 0.055)
                            : Colors.transparent,
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundColor: scheme.primary.withValues(
                            alpha: 0.12,
                          ),
                          foregroundColor: scheme.primary,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        title: Text(
                          surahs[index],
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => _goToSurah(index + 1),
                      );
                    },
                  ),
                  GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 180,
                          mainAxisExtent: 74,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                        ),
                    itemCount: 30,
                    itemBuilder: (context, index) {
                      final juz = index + 1;
                      return Card(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () => _goToJuz(juz),
                          child: Center(
                            child: Text(
                              l10n.juzNumber(juz),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      Icon(
                        Icons.find_in_page_outlined,
                        size: 58,
                        color: scheme.primary,
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: _pageController,
                        autofocus: false,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.go,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        onSubmitted: (_) => _goToPage(),
                        decoration: InputDecoration(
                          labelText: l10n.page,
                          hintText: l10n.pageRangeHint,
                          errorText: _pageError,
                          filled: true,
                          fillColor: scheme.primary.withValues(alpha: 0.06),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      FilledButton.icon(
                        onPressed: _goToPage,
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: Text(l10n.goToPage),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
