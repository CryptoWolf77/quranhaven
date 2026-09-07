import 'package:flutter/material.dart';
import 'package:quran_library/quran_library.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../home/presentation/home_page.dart';
import '../../library/presentation/library_page.dart';
import '../../plans/presentation/plans_page.dart';
import '../../quran/presentation/quran_reader_page.dart';
import '../../settings/presentation/settings_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    required this.locale,
    required this.themeMode,
    required this.onLocaleChanged,
    required this.onThemeModeChanged,
    super.key,
  });

  final Locale? locale;
  final ThemeMode themeMode;
  final ValueChanged<Locale> onLocaleChanged;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  late int _currentPage;
  int _plansRefreshToken = 0;

  @override
  void initState() {
    super.initState();
    _currentPage = QuranLibrary().currentPageNumber.clamp(1, 604);
  }

  void _selectPage(int index) => setState(() => _selectedIndex = index);

  void _updateCurrentPage(int page) {
    if (page == _currentPage || !mounted) return;
    setState(() => _currentPage = page.clamp(1, 604));
  }

  void _handleCloudRestored(int page) {
    final restoredPage = page.clamp(1, 604);
    QuranLibrary().jumpToPage(restoredPage);
    setState(() {
      _currentPage = restoredPage;
      _plansRefreshToken++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final destinations = [
      _Destination(l10n.home, Icons.home_outlined, Icons.home_rounded),
      _Destination(l10n.quran, Icons.menu_book_outlined, Icons.menu_book),
      _Destination(
        l10n.library,
        Icons.local_library_outlined,
        Icons.local_library_rounded,
      ),
      _Destination(
        l10n.plans,
        Icons.track_changes_outlined,
        Icons.track_changes,
      ),
      _Destination(l10n.settings, Icons.tune_outlined, Icons.tune),
    ];
    final pages = [
      HomePage(
        currentPage: _currentPage,
        onOpenReader: () => _selectPage(1),
        onOpenLibrary: () => _selectPage(2),
      ),
      QuranReaderPage(onPageChanged: _updateCurrentPage),
      LibraryPage(
        currentPage: _currentPage,
        onOpenReader: () => _selectPage(1),
      ),
      PlansPage(
        currentPage: _currentPage,
        refreshToken: _plansRefreshToken,
        onOpenReader: () => _selectPage(1),
      ),
      SettingsPage(
        currentPage: _currentPage,
        locale: widget.locale,
        themeMode: widget.themeMode,
        onLocaleChanged: widget.onLocaleChanged,
        onThemeModeChanged: widget.onThemeModeChanged,
        onCloudRestored: _handleCloudRestored,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 840;
        final content = IndexedStack(index: _selectedIndex, children: pages);

        if (isWide) {
          return Scaffold(
            body: SafeArea(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
                    child: _DesktopNavigation(
                      destinations: destinations,
                      selectedIndex: _selectedIndex,
                      onDestinationSelected: _selectPage,
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: content),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          body: SafeArea(child: content),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _selectPage,
            destinations: [
              for (final destination in destinations)
                NavigationDestination(
                  icon: Icon(destination.icon),
                  selectedIcon: Icon(destination.selectedIcon),
                  label: destination.label,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _DesktopNavigation extends StatelessWidget {
  const _DesktopNavigation({
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final List<_Destination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: NavigationRail(
        backgroundColor: Colors.transparent,
        extended: MediaQuery.sizeOf(context).width >= 1120,
        minExtendedWidth: 208,
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        leading: Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 24),
          child: Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              'ق',
              style: TextStyle(
                color: scheme.onPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        destinations: [
          for (final destination in destinations)
            NavigationRailDestination(
              icon: Icon(destination.icon),
              selectedIcon: Icon(destination.selectedIcon),
              label: Text(destination.label),
            ),
        ],
      ),
    );
  }
}

class _Destination {
  const _Destination(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
