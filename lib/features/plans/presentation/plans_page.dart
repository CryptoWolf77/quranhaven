import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quran_library/quran_library.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../data/plans_repository.dart';
import '../domain/memorization_ayah_bounds.dart';
import '../domain/plans_models.dart';

class PlansPage extends StatefulWidget {
  const PlansPage({
    required this.currentPage,
    required this.onOpenReader,
    this.refreshToken = 0,
    super.key,
  });

  final int currentPage;
  final VoidCallback onOpenReader;
  final int refreshToken;

  @override
  State<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> {
  final PlansRepository _repository = PlansRepository();

  KhatmahPlan? _khatmah;
  List<MemorizationPlan> _memorizationPlans = [];
  bool _loading = true;
  int _section = 0;
  String? _expandedPlanId;
  String? _audioPlanId;
  bool _cancelAudio = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void didUpdateWidget(covariant PlansPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refreshToken != oldWidget.refreshToken) {
      unawaited(_load());
    }
  }

  @override
  void dispose() {
    _cancelAudio = true;
    unawaited(QuranLibrary().stopWordAudio());
    super.dispose();
  }

  Future<void> _load() async {
    final results = await Future.wait<Object?>([
      _repository.loadKhatmah(),
      _repository.loadMemorizationPlans(),
    ]);
    if (!mounted) return;
    setState(() {
      _khatmah = results[0] as KhatmahPlan?;
      _memorizationPlans = results[1] as List<MemorizationPlan>;
      _loading = false;
    });
  }

  Future<void> _createKhatmah() async {
    final draft = await showModalBottomSheet<_KhatmahDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) =>
          _CreateKhatmahSheet(currentPage: widget.currentPage),
    );
    if (draft == null || !mounted) return;

    final now = DateTime.now();
    final plan = KhatmahPlan(
      startedAt: now,
      targetDate: now.add(Duration(days: draft.days - 1)),
      completedPages: draft.startFromLastRead ? widget.currentPage - 1 : 0,
      isRamadanPlan: draft.isRamadan,
    );
    setState(() => _khatmah = plan);
    await _repository.saveKhatmah(plan);
  }

  Future<void> _saveKhatmah(KhatmahPlan plan) async {
    setState(() => _khatmah = plan);
    await _repository.saveKhatmah(plan);
  }

  Future<void> _completeDailyTarget() async {
    final plan = _khatmah;
    if (plan == null || plan.isPaused || plan.isComplete) return;
    await _saveKhatmah(
      plan.copyWith(
        completedPages:
            plan.completedPages + plan.pagesPerDayOn(DateTime.now()),
      ),
    );
  }

  Future<void> _adjustCompletedPages() async {
    final plan = _khatmah;
    if (plan == null) return;
    final controller = TextEditingController(text: '${plan.completedPages}');
    final value = await showDialog<int>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(l10n.updateProgress),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
            decoration: InputDecoration(
              labelText: l10n.pagesCompleted,
              helperText: '0–$quranPageCount',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                final pages = int.tryParse(controller.text);
                if (pages != null && pages >= 0 && pages <= quranPageCount) {
                  Navigator.pop(context, pages);
                }
              },
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (value != null) {
      await _saveKhatmah(plan.copyWith(completedPages: value));
    }
  }

  Future<void> _adjustTargetDate() async {
    final plan = _khatmah;
    if (plan == null) return;
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: plan.targetDate.isBefore(now) ? now : plan.targetDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 730)),
    );
    if (date != null) await _saveKhatmah(plan.copyWith(targetDate: date));
  }

  Future<void> _deleteKhatmah() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await _confirm(
      title: l10n.deletePlan,
      body: l10n.deletePlanBody,
    );
    if (!confirmed) return;
    setState(() => _khatmah = null);
    await _repository.deleteKhatmah();
  }

  Future<void> _createMemorizationPlan() async {
    final locale = Localizations.localeOf(context);
    final surahs = QuranLibrary.getAllSurahs(
      isArabic: locale.languageCode == 'ar',
    );
    final plan = await showModalBottomSheet<MemorizationPlan>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => _CreateMemorizationSheet(surahs: surahs),
    );
    if (plan == null || !mounted) return;
    setState(() {
      _memorizationPlans = [..._memorizationPlans, plan];
      _expandedPlanId = plan.id;
    });
    await _repository.saveMemorizationPlans(_memorizationPlans);
  }

  Future<void> _replaceMemorizationPlan(MemorizationPlan plan) async {
    setState(() {
      _memorizationPlans = [
        for (final item in _memorizationPlans)
          if (item.id == plan.id) plan else item,
      ];
    });
    await _repository.saveMemorizationPlans(_memorizationPlans);
  }

  Future<void> _deleteMemorizationPlan(MemorizationPlan plan) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await _confirm(
      title: l10n.deletePlan,
      body: l10n.deleteMemorizationBody,
    );
    if (!confirmed) return;
    if (_audioPlanId == plan.id) await _stopPracticeAudio();
    setState(() {
      _memorizationPlans = _memorizationPlans
          .where((item) => item.id != plan.id)
          .toList();
      if (_expandedPlanId == plan.id) _expandedPlanId = null;
    });
    await _repository.saveMemorizationPlans(_memorizationPlans);
  }

  Future<bool> _confirm({required String title, required String body}) async {
    final l10n = AppLocalizations.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(body),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.delete),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _playPractice(
    MemorizationPlan plan, {
    bool range = false,
  }) async {
    if (_audioPlanId != null) await _stopPracticeAudio();
    _cancelAudio = false;
    setState(() => _audioPlanId = plan.id);

    try {
      final firstAyah = range ? plan.startAyah : plan.currentAyah;
      final lastAyah = range ? plan.endAyah : plan.currentAyah;
      final rangeRepeats = range ? plan.rangeRepetitions : 1;
      for (var rangeRound = 0; rangeRound < rangeRepeats; rangeRound++) {
        for (var ayah = firstAyah; ayah <= lastAyah; ayah++) {
          for (var repeat = 0; repeat < plan.repetitions; repeat++) {
            if (_cancelAudio) return;
            await QuranLibrary().playAyahWordsAudioByNumbers(
              surahNumber: plan.surahNumber,
              ayahNumber: ayah,
            );
            if (plan.delaySeconds > 0 && !_cancelAudio) {
              await Future<void>.delayed(Duration(seconds: plan.delaySeconds));
            }
          }
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).audioFailed)),
        );
      }
    } finally {
      if (mounted && _audioPlanId == plan.id) {
        setState(() => _audioPlanId = null);
      }
    }
  }

  Future<void> _stopPracticeAudio() async {
    _cancelAudio = true;
    await QuranLibrary().stopWordAudio();
    if (mounted) setState(() => _audioPlanId = null);
  }

  void _openAyahInReader(MemorizationPlan plan) {
    final uniqueAyah = QuranLibrary.quranCtrl
        .getAyahUnqNumberBySurahAndAyahNumber(
          plan.surahNumber,
          plan.currentAyah,
        );
    final page = QuranLibrary.quranCtrl.getPageNumberByAyahUqNumber(uniqueAyah);
    QuranLibrary().jumpToAyah(page, uniqueAyah);
    widget.onOpenReader();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1040),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _PlansHeader(),
              const SizedBox(height: 22),
              SegmentedButton<int>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: 0,
                    icon: const Icon(Icons.auto_stories_outlined),
                    label: Text(l10n.khatmah),
                  ),
                  ButtonSegment(
                    value: 1,
                    icon: const Icon(Icons.psychology_alt_outlined),
                    label: Text(l10n.memorization),
                  ),
                ],
                selected: {_section},
                onSelectionChanged: (selection) {
                  setState(() => _section = selection.first);
                },
              ),
              const SizedBox(height: 20),
              if (_loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(48),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_section == 0)
                _KhatmahPanel(
                  plan: _khatmah,
                  onCreate: _createKhatmah,
                  onCompleteDailyTarget: _completeDailyTarget,
                  onUpdateProgress: _adjustCompletedPages,
                  onAdjustDate: _adjustTargetDate,
                  onTogglePause: () {
                    final plan = _khatmah;
                    if (plan != null) {
                      unawaited(
                        _saveKhatmah(plan.copyWith(isPaused: !plan.isPaused)),
                      );
                    }
                  },
                  onDelete: _deleteKhatmah,
                )
              else
                _MemorizationPanel(
                  plans: _memorizationPlans,
                  expandedPlanId: _expandedPlanId,
                  audioPlanId: _audioPlanId,
                  onCreate: _createMemorizationPlan,
                  onToggleExpanded: (plan) {
                    setState(() {
                      _expandedPlanId = _expandedPlanId == plan.id
                          ? null
                          : plan.id;
                    });
                  },
                  onChanged: _replaceMemorizationPlan,
                  onDelete: _deleteMemorizationPlan,
                  onPlayCurrent: (plan) => _playPractice(plan),
                  onPlayRange: (plan) => _playPractice(plan, range: true),
                  onStopAudio: _stopPracticeAudio,
                  onOpenReader: _openAyahInReader,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlansHeader extends StatelessWidget {
  const _PlansHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            scheme.primary,
            Color.lerp(scheme.primary, const Color(0xFF082E26), 0.62)!,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: scheme.onPrimary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.track_changes_rounded,
              color: scheme.onPrimary,
              size: 30,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.plansTitle,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  l10n.plansBody,
                  style: TextStyle(
                    color: scheme.onPrimary.withValues(alpha: 0.82),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KhatmahPanel extends StatelessWidget {
  const _KhatmahPanel({
    required this.plan,
    required this.onCreate,
    required this.onCompleteDailyTarget,
    required this.onUpdateProgress,
    required this.onAdjustDate,
    required this.onTogglePause,
    required this.onDelete,
  });

  final KhatmahPlan? plan;
  final VoidCallback onCreate;
  final VoidCallback onCompleteDailyTarget;
  final VoidCallback onUpdateProgress;
  final VoidCallback onAdjustDate;
  final VoidCallback onTogglePause;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final activePlan = plan;

    if (activePlan == null) {
      return _EmptyPlanCard(
        icon: Icons.calendar_month_outlined,
        title: l10n.noKhatmah,
        body: l10n.noKhatmahBody,
        buttonLabel: l10n.createKhatmah,
        onPressed: onCreate,
      );
    }

    final percent = (activePlan.progress * 100).round();
    final dailyPages = activePlan.pagesPerDayOn(DateTime.now());
    final targetDate = MaterialLocalizations.of(
      context,
    ).formatCompactDate(activePlan.targetDate);

    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                activePlan.isRamadanPlan
                                    ? l10n.ramadanKhatmah
                                    : l10n.activeKhatmah,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              if (activePlan.isPaused) ...[
                                const SizedBox(width: 8),
                                Chip(label: Text(l10n.paused)),
                              ],
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(l10n.targetDate(targetDate)),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'date') onAdjustDate();
                        if (value == 'delete') onDelete();
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'date',
                          child: Text(l10n.adjustDate),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(l10n.deletePlan),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$percent%',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          l10n.pagesOfTotal(
                            activePlan.completedPages,
                            quranPageCount,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: activePlan.progress,
                    minHeight: 11,
                    backgroundColor: scheme.primary.withValues(alpha: 0.1),
                  ),
                ),
                const SizedBox(height: 22),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final cards = [
                      _MetricCard(
                        icon: Icons.today_outlined,
                        value: '$dailyPages',
                        label: l10n.pagesToday,
                      ),
                      _MetricCard(
                        icon: Icons.menu_book_outlined,
                        value: '${activePlan.remainingPages}',
                        label: l10n.pagesRemaining,
                      ),
                      _MetricCard(
                        icon: Icons.event_available_outlined,
                        value: '${activePlan.remainingDaysOn(DateTime.now())}',
                        label: l10n.daysRemaining,
                      ),
                    ];
                    if (constraints.maxWidth < 580) {
                      return Column(
                        children: [
                          for (final card in cards) ...[
                            card,
                            if (card != cards.last) const SizedBox(height: 8),
                          ],
                        ],
                      );
                    }
                    return Row(
                      children: [
                        for (final card in cards)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: card,
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: activePlan.isPaused || activePlan.isComplete
                          ? null
                          : onCompleteDailyTarget,
                      icon: Icon(
                        activePlan.isComplete
                            ? Icons.celebration_rounded
                            : Icons.done_all_rounded,
                      ),
                      label: Text(
                        activePlan.isComplete
                            ? l10n.khatmahComplete
                            : l10n.completeToday,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: onUpdateProgress,
                      icon: const Icon(Icons.edit_outlined),
                      label: Text(l10n.updateProgress),
                    ),
                    TextButton.icon(
                      onPressed: activePlan.isComplete ? null : onTogglePause,
                      icon: Icon(
                        activePlan.isPaused
                            ? Icons.play_arrow_rounded
                            : Icons.pause_rounded,
                      ),
                      label: Text(
                        activePlan.isPaused ? l10n.resumePlan : l10n.pausePlan,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _PrivacyNote(),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.065),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          Icon(icon, color: scheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(label, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MemorizationPanel extends StatelessWidget {
  const _MemorizationPanel({
    required this.plans,
    required this.expandedPlanId,
    required this.audioPlanId,
    required this.onCreate,
    required this.onToggleExpanded,
    required this.onChanged,
    required this.onDelete,
    required this.onPlayCurrent,
    required this.onPlayRange,
    required this.onStopAudio,
    required this.onOpenReader,
  });

  final List<MemorizationPlan> plans;
  final String? expandedPlanId;
  final String? audioPlanId;
  final VoidCallback onCreate;
  final ValueChanged<MemorizationPlan> onToggleExpanded;
  final ValueChanged<MemorizationPlan> onChanged;
  final ValueChanged<MemorizationPlan> onDelete;
  final ValueChanged<MemorizationPlan> onPlayCurrent;
  final ValueChanged<MemorizationPlan> onPlayRange;
  final VoidCallback onStopAudio;
  final ValueChanged<MemorizationPlan> onOpenReader;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final surahs = QuranLibrary.getAllSurahs(isArabic: isArabic);

    if (plans.isEmpty) {
      return _EmptyPlanCard(
        icon: Icons.psychology_alt_outlined,
        title: l10n.noMemorization,
        body: l10n.noMemorizationBody,
        buttonLabel: l10n.createMemorization,
        onPressed: onCreate,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.newRange),
          ),
        ),
        const SizedBox(height: 12),
        for (final plan in plans) ...[
          _MemorizationCard(
            plan: plan,
            surahName: surahs[plan.surahNumber - 1],
            expanded: expandedPlanId == plan.id,
            audioBusy: audioPlanId == plan.id,
            anotherAudioBusy: audioPlanId != null && audioPlanId != plan.id,
            onToggleExpanded: () => onToggleExpanded(plan),
            onChanged: onChanged,
            onDelete: () => onDelete(plan),
            onPlayCurrent: () => onPlayCurrent(plan),
            onPlayRange: () => onPlayRange(plan),
            onStopAudio: onStopAudio,
            onOpenReader: () => onOpenReader(plan),
          ),
          const SizedBox(height: 12),
        ],
        const _PrivacyNote(),
      ],
    );
  }
}

class _MemorizationCard extends StatelessWidget {
  const _MemorizationCard({
    required this.plan,
    required this.surahName,
    required this.expanded,
    required this.audioBusy,
    required this.anotherAudioBusy,
    required this.onToggleExpanded,
    required this.onChanged,
    required this.onDelete,
    required this.onPlayCurrent,
    required this.onPlayRange,
    required this.onStopAudio,
    required this.onOpenReader,
  });

  final MemorizationPlan plan;
  final String surahName;
  final bool expanded;
  final bool audioBusy;
  final bool anotherAudioBusy;
  final VoidCallback onToggleExpanded;
  final ValueChanged<MemorizationPlan> onChanged;
  final VoidCallback onDelete;
  final VoidCallback onPlayCurrent;
  final VoidCallback onPlayRange;
  final VoidCallback onStopAudio;
  final VoidCallback onOpenReader;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final percent = (plan.progress * 100).round();

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onToggleExpanded,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: scheme.secondary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      plan.isComplete
                          ? Icons.workspace_premium_outlined
                          : Icons.auto_awesome_outlined,
                      color: scheme.secondary,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          surahName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(l10n.ayahRange(plan.startAyah, plan.endAyah)),
                      ],
                    ),
                  ),
                  Text(
                    '$percent%',
                    style: TextStyle(
                      color: scheme.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Icon(
                    expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              LinearProgressIndicator(
                value: plan.progress,
                minHeight: 7,
                borderRadius: BorderRadius.circular(999),
                backgroundColor: scheme.primary.withValues(alpha: 0.1),
              ),
              if (expanded) ...[
                const SizedBox(height: 20),
                Divider(color: scheme.outline.withValues(alpha: 0.18)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.currentAyah(plan.currentAyah),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.deletePlan,
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 112),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: scheme.surface.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: plan.hideAyah
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.visibility_off_outlined,
                              color: scheme.primary,
                            ),
                            const SizedBox(height: 8),
                            Text(l10n.ayahHidden),
                          ],
                        )
                      : GetSingleAyah(
                          surahNumber: plan.surahNumber,
                          ayahNumber: plan.currentAyah,
                          textColor: scheme.onSurface,
                          isDark: isDark,
                          fontSize: 25,
                          showAyahNumber: true,
                        ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      selected: plan.hideAyah,
                      onSelected: (hidden) {
                        onChanged(plan.copyWith(hideAyah: hidden));
                      },
                      avatar: Icon(
                        plan.hideAyah
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 18,
                      ),
                      label: Text(
                        plan.hideAyah ? l10n.revealAyah : l10n.hideAyah,
                      ),
                    ),
                    Chip(
                      avatar: const Icon(Icons.repeat_rounded, size: 18),
                      label: Text(l10n.repeatCount(plan.repetitions)),
                    ),
                    Chip(
                      avatar: const Icon(Icons.timer_outlined, size: 18),
                      label: Text(l10n.delayCount(plan.delaySeconds)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 9,
                  runSpacing: 9,
                  children: [
                    FilledButton.icon(
                      onPressed: anotherAudioBusy
                          ? null
                          : audioBusy
                          ? onStopAudio
                          : onPlayCurrent,
                      icon: Icon(
                        audioBusy
                            ? Icons.stop_rounded
                            : Icons.volume_up_outlined,
                      ),
                      label: Text(audioBusy ? l10n.stop : l10n.repeatCurrent),
                    ),
                    OutlinedButton.icon(
                      onPressed: audioBusy || anotherAudioBusy
                          ? null
                          : onPlayRange,
                      icon: const Icon(Icons.playlist_play_rounded),
                      label: Text(l10n.repeatRange),
                    ),
                    OutlinedButton.icon(
                      onPressed: onOpenReader,
                      icon: const Icon(Icons.menu_book_outlined),
                      label: Text(l10n.openInMushaf),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                MemorizationAyahControls(plan: plan, onChanged: onChanged),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class MemorizationAyahControls extends StatelessWidget {
  const MemorizationAyahControls({
    required this.plan,
    required this.onChanged,
    super.key,
  });

  final MemorizationPlan plan;
  final ValueChanged<MemorizationPlan> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return OverflowBar(
      alignment: MainAxisAlignment.spaceBetween,
      spacing: 12,
      overflowSpacing: 12,
      overflowAlignment: OverflowBarAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton.filledTonal(
              tooltip: l10n.previousAyah,
              onPressed: plan.currentAyah > plan.startAyah
                  ? () => onChanged(
                      plan.copyWith(currentAyah: plan.currentAyah - 1),
                    )
                  : null,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              tooltip: l10n.nextAyah,
              onPressed: plan.currentAyah < plan.endAyah
                  ? () => onChanged(
                      plan.copyWith(currentAyah: plan.currentAyah + 1),
                    )
                  : null,
              icon: const Icon(Icons.arrow_forward_rounded),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: plan.isCurrentForRevision
                  ? l10n.removeRevisionMarker
                  : l10n.markForRevision,
              isSelected: plan.isCurrentForRevision,
              onPressed: () => onChanged(plan.toggleCurrentRevision()),
              color: plan.isCurrentForRevision ? scheme.secondary : null,
              icon: Icon(
                plan.isCurrentForRevision
                    ? Icons.history_edu_rounded
                    : Icons.history_edu_outlined,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: FilledButton.tonalIcon(
                onPressed: plan.isCurrentMemorized
                    ? null
                    : () => onChanged(plan.markCurrentMemorized()),
                icon: const Icon(Icons.check_rounded),
                label: Text(
                  plan.isCurrentMemorized ? l10n.memorized : l10n.markMemorized,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EmptyPlanCard extends StatelessWidget {
  const _EmptyPlanCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.buttonLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String body;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 34, color: scheme.primary),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 9),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Text(body, textAlign: TextAlign.center),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.add_rounded),
              label: Text(buttonLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.065),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          Icon(Icons.offline_pin_outlined, color: scheme.primary),
          const SizedBox(width: 11),
          Expanded(child: Text(l10n.progressSavedLocally)),
        ],
      ),
    );
  }
}

class _KhatmahDraft {
  const _KhatmahDraft({
    required this.days,
    required this.startFromLastRead,
    required this.isRamadan,
  });

  final int days;
  final bool startFromLastRead;
  final bool isRamadan;
}

class _CreateKhatmahSheet extends StatefulWidget {
  const _CreateKhatmahSheet({required this.currentPage});

  final int currentPage;

  @override
  State<_CreateKhatmahSheet> createState() => _CreateKhatmahSheetState();
}

class _CreateKhatmahSheetState extends State<_CreateKhatmahSheet> {
  int _days = 30;
  bool _startFromLastRead = false;
  bool _ramadan = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 18, 24, 24 + bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.onSurface.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.createKhatmah,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 7),
          Text(l10n.createKhatmahBody),
          const SizedBox(height: 24),
          Text(
            l10n.completionPeriod,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              for (final days in [30, 60, 90])
                ChoiceChip(
                  selected: _days == days,
                  onSelected: (_) => setState(() {
                    _days = days;
                    _ramadan = false;
                  }),
                  label: Text(l10n.daysCount(days)),
                ),
            ],
          ),
          const SizedBox(height: 14),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _ramadan,
            title: Text(l10n.ramadanPlan),
            subtitle: Text(l10n.ramadanPlanBody),
            onChanged: (value) => setState(() {
              _ramadan = value;
              if (value) _days = 30;
            }),
          ),
          if (widget.currentPage > 1)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _startFromLastRead,
              title: Text(l10n.continueFromLastRead),
              subtitle: Text(l10n.startAtPage(widget.currentPage)),
              onChanged: (value) {
                setState(() => _startFromLastRead = value);
              },
            ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => Navigator.pop(
                context,
                _KhatmahDraft(
                  days: _days,
                  startFromLastRead: _startFromLastRead,
                  isRamadan: _ramadan,
                ),
              ),
              icon: const Icon(Icons.auto_stories_outlined),
              label: Text(l10n.startPlan),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateMemorizationSheet extends StatefulWidget {
  const _CreateMemorizationSheet({required this.surahs});

  final List<String> surahs;

  @override
  State<_CreateMemorizationSheet> createState() =>
      _CreateMemorizationSheetState();
}

class _CreateMemorizationSheetState extends State<_CreateMemorizationSheet> {
  final _formKey = GlobalKey<FormState>();
  final _startController = TextEditingController(text: '1');
  final _endController = TextEditingController(text: '7');
  int _surah = 1;
  int _repetitions = 5;
  int _rangeRepetitions = 1;
  int _delay = 2;
  bool _hideAyah = false;

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  MemorizationAyahBounds get _ayahBounds => MemorizationAyahBounds.forSurah(
    surahNumber: _surah,
    surahs: QuranCtrl.instance.surahsList,
  );

  String? _validateAyah(String? text) {
    final l10n = AppLocalizations.of(context);
    final value = int.tryParse(text ?? '');
    final bounds = _ayahBounds;
    if (!bounds.contains(value)) {
      return l10n.ayahRangeError(bounds.ayahCount);
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final start = int.parse(_startController.text);
    final end = int.parse(_endController.text);
    if (end < start) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).endBeforeStart)),
      );
      return;
    }
    Navigator.pop(
      context,
      MemorizationPlan(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        surahNumber: _surah,
        startAyah: start,
        endAyah: end,
        currentAyah: start,
        repetitions: _repetitions,
        rangeRepetitions: _rangeRepetitions,
        delaySeconds: _delay,
        hideAyah: _hideAyah,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 18, 24, 24 + bottom),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.onSurface.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.createMemorization,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 7),
            Text(l10n.createMemorizationBody),
            const SizedBox(height: 22),
            DropdownButtonFormField<int>(
              initialValue: _surah,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.chooseSurah,
                filled: true,
                fillColor: scheme.primary.withValues(alpha: 0.06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              items: [
                for (var index = 0; index < widget.surahs.length; index++)
                  DropdownMenuItem(
                    value: index + 1,
                    child: Text('${index + 1}. ${widget.surahs[index]}'),
                  ),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _surah = value;
                  _startController.text = '1';
                  _endController.text = _ayahBounds.defaultEndAyah.toString();
                });
              },
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _startController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: _validateAyah,
                    decoration: InputDecoration(
                      labelText: l10n.startAyah,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _endController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: _validateAyah,
                    decoration: InputDecoration(
                      labelText: l10n.endAyah,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              l10n.repetitionsPerAyah,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final count in [3, 5, 10])
                  ChoiceChip(
                    selected: _repetitions == count,
                    onSelected: (_) {
                      setState(() => _repetitions = count);
                    },
                    label: Text('×$count'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.rangeRepetitions,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final count in [1, 2, 3])
                  ChoiceChip(
                    selected: _rangeRepetitions == count,
                    onSelected: (_) {
                      setState(() => _rangeRepetitions = count);
                    },
                    label: Text('×$count'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.delayBetween,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final seconds in [0, 2, 5])
                  ChoiceChip(
                    selected: _delay == seconds,
                    onSelected: (_) => setState(() => _delay = seconds),
                    label: Text(l10n.secondsCount(seconds)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _hideAyah,
              title: Text(l10n.startWithAyahHidden),
              onChanged: (value) => setState(() => _hideAyah = value),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.auto_awesome_outlined),
                label: Text(l10n.startMemorizing),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
