import 'package:flutter/material.dart';

import '../../../core/widgets/creator_credit.dart';
import '../../../core/widgets/quran_brand_mark.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../guide/presentation/user_guide_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    required this.currentPage,
    required this.onOpenReader,
    required this.onOpenLibrary,
    required this.onBrowseSurahs,
    required this.onSearch,
    required this.onBookmarks,
    super.key,
  });

  final int currentPage;
  final VoidCallback onOpenReader;
  final VoidCallback onOpenLibrary;
  final VoidCallback onBrowseSurahs;
  final VoidCallback onSearch;
  final VoidCallback onBookmarks;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
          sliver: SliverToBoxAdapter(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.greeting,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.appName,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                      const QuranBrandMark(),
                    ],
                  ),
                  const SizedBox(height: 28),
                  _HeroCard(
                    currentPage: currentPage,
                    onOpenReader: onOpenReader,
                  ),
                  const SizedBox(height: 18),
                  _GuideEntry(),
                  const SizedBox(height: 30),
                  Text(
                    l10n.quickAccess,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverGrid(
            delegate: SliverChildListDelegate.fixed([
              _QuickAction(
                icon: Icons.format_list_bulleted_rounded,
                label: l10n.browseSurahs,
                onTap: onBrowseSurahs,
              ),
              _QuickAction(
                icon: Icons.search_rounded,
                label: l10n.searchQuran,
                onTap: onSearch,
              ),
              _QuickAction(
                icon: Icons.bookmark_border_rounded,
                label: l10n.bookmarks,
                onTap: onBookmarks,
              ),
              _QuickAction(
                icon: Icons.download_for_offline_outlined,
                label: l10n.downloads,
                onTap: onOpenLibrary,
              ),
            ]),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent:
                  MediaQuery.textScalerOf(context).scale(14) > 20 ? 470 : 270,
              mainAxisExtent:
                  140 +
                  (MediaQuery.textScalerOf(context).scale(14) - 14).clamp(
                        0,
                        28,
                      ) *
                      4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          sliver: SliverToBoxAdapter(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.auto_awesome, color: scheme.secondary),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.dailyJourney,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 6),
                            Text(l10n.dailyJourneyBody),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          sliver: SliverToBoxAdapter(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: const CreatorCredit(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GuideEntry extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context), s = Theme.of(context).colorScheme;
    return Material(
      color: s.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: s.primary.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        key: const ValueKey('home-guide-open'),
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const UserGuidePage())),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: s.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.play_lesson_outlined,
                  color: s.onPrimary,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.guideStartHere,
                      style: TextStyle(
                        color: s.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l.guideTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(l.guideEntryBody, style: const TextStyle(height: 1.5)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, color: s.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.currentPage, required this.onOpenReader});

  final int currentPage;
  final VoidCallback onOpenReader;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 250),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            scheme.primary,
            Color.lerp(scheme.primary, const Color(0xFF082E26), 0.64)!,
          ],
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            end: -18,
            top: -46,
            child: _DecorativeRing(color: scheme.onPrimary),
          ),
          PositionedDirectional(
            end: 80,
            bottom: -85,
            child: _DecorativeRing(color: scheme.secondary, size: 190),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.heroTitle,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: scheme.onPrimary,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.heroBody,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: scheme.onPrimary.withValues(alpha: 0.82),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.onPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: scheme.onPrimary.withValues(alpha: 0.16),
                    ),
                  ),
                  child: Text(
                    l10n.lastReadPage(currentPage),
                    style: TextStyle(
                      color: scheme.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: onOpenReader,
                  style: FilledButton.styleFrom(
                    backgroundColor: scheme.surface,
                    foregroundColor: scheme.primary,
                  ),
                  icon: const Icon(Icons.menu_book_rounded),
                  label: Text(l10n.startReading),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DecorativeRing extends StatelessWidget {
  const _DecorativeRing({required this.color, this.size = 150});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.12), width: 24),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap:
            onTap ??
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context).comingSoon),
                ),
              );
            },
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 210) {
              return Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: scheme.primary, size: 30),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: scheme.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
