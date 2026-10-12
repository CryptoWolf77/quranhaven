import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';

/// A local guide. Opening it neither starts media nor changes personal data.
class UserGuidePage extends StatelessWidget {
  const UserGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final topics = [
      _GuideTopic(
        id: 'reader',
        icon: Icons.menu_book_outlined,
        title: l10n.guideReadingTitle,
        steps: [
          l10n.guideReadingStep1,
          l10n.guideReadingStep2,
          l10n.guideReadingStep3,
        ],
        tip: l10n.guideReadingTip,
        demo: 'reader',
      ),
      _GuideTopic(
        id: 'search',
        icon: Icons.bookmark_border_rounded,
        title: l10n.guideSearchTitle,
        steps: [
          l10n.guideSearchStep1,
          l10n.guideSearchStep2,
          l10n.guideSearchStep3,
        ],
        tip: l10n.guideSearchTip,
      ),
      _GuideTopic(
        id: 'library',
        icon: Icons.auto_stories_outlined,
        title: l10n.guideLibraryTitle,
        steps: [
          l10n.guideLibraryStep1,
          l10n.guideLibraryStep2,
          l10n.guideLibraryStep3,
        ],
        tip: l10n.guideLibraryTip,
        demo: 'library',
      ),
      _GuideTopic(
        id: 'audio',
        icon: Icons.headphones_rounded,
        title: l10n.guideAudioTitle,
        steps: [
          l10n.guideAudioStep1,
          l10n.guideAudioStep2,
          l10n.guideAudioStep3,
        ],
        tip: l10n.guideAudioTip,
      ),
      _GuideTopic(
        id: 'offline',
        icon: Icons.offline_pin_outlined,
        title: l10n.guideOfflineTitle,
        steps: [
          l10n.guideOfflineStep1,
          l10n.guideOfflineStep2,
          l10n.guideOfflineStep3,
        ],
        tip: l10n.guideOfflineTip,
        demo: 'offline',
      ),
      _GuideTopic(
        id: 'plans',
        icon: Icons.track_changes_rounded,
        title: l10n.guidePlansTitle,
        steps: [
          l10n.guidePlansStep1,
          l10n.guidePlansStep2,
          l10n.guidePlansStep3,
        ],
        tip: l10n.guidePlansTip,
        demo: 'plans',
      ),
      _GuideTopic(
        id: 'settings',
        icon: Icons.tune_rounded,
        title: l10n.guideSettingsTitle,
        steps: [
          l10n.guideSettingsStep1,
          l10n.guideSettingsStep2,
          l10n.guideSettingsStep3,
        ],
        tip: l10n.guideSettingsTip,
      ),
      _GuideTopic(
        id: 'storage',
        icon: Icons.phone_android_rounded,
        title: l10n.guideStorageTitle,
        steps: [l10n.guideStorageStep1, l10n.guideStorageStep2],
        tip: l10n.guideStorageTip,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.guideTitle)),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          key: const ValueKey('guide-scroll'),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsetsDirectional.only(start: 16),
                    decoration: BoxDecoration(
                      border: BorderDirectional(
                        start: BorderSide(color: scheme.primary, width: 3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.guideIntroTitle,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          l10n.guideIntro,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(height: 1.6),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.guideMediaHint,
                          style: TextStyle(color: scheme.primary, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final largeText =
                          MediaQuery.textScalerOf(context).scale(16) > 24;
                      final columns = constraints.maxWidth >= 900 && !largeText
                          ? 2
                          : 1;
                      final width =
                          (constraints.maxWidth - (columns - 1) * 20) / columns;
                      return Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        children: [
                          for (var index = 0; index < topics.length; index++)
                            SizedBox(
                              width: width,
                              child: _TopicCard(
                                topic: topics[index],
                                number: index + 1,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GuideTopic {
  const _GuideTopic({
    required this.id,
    required this.icon,
    required this.title,
    required this.steps,
    required this.tip,
    this.demo,
  });

  final String id;
  final IconData icon;
  final String title;
  final List<String> steps;
  final String tip;
  final String? demo;
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({required this.topic, required this.number});

  final _GuideTopic topic;
  final int number;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return Card(
      key: ValueKey('guide-topic-${topic.id}'),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    MaterialLocalizations.of(context).formatDecimal(number),
                    textScaler: const TextScaler.linear(1),
                    style: TextStyle(
                      color: scheme.onPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      topic.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.35,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(topic.icon, size: 22, color: scheme.primary),
              ],
            ),
            if (topic.demo != null) ...[
              const SizedBox(height: 18),
              _GuideDemo(demo: topic.demo!, title: topic.title),
            ],
            const SizedBox(height: 18),
            for (var index = 0; index < topic.steps.length; index++) ...[
              if (index > 0) const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 28,
                    child: Text(
                      '${MaterialLocalizations.of(context).formatDecimal(index + 1)}.',
                      style: TextStyle(
                        color: scheme.primary,
                        fontWeight: FontWeight.w800,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      topic.steps[index],
                      style: const TextStyle(height: 1.6),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 18),
            Divider(height: 1, color: scheme.outline.withValues(alpha: 0.22)),
            const SizedBox(height: 12),
            Text(
              l10n.guideGoodToKnow,
              style: TextStyle(
                color: scheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(topic.tip, style: const TextStyle(height: 1.6)),
          ],
        ),
      ),
    );
  }
}

class _GuideDemo extends StatefulWidget {
  const _GuideDemo({required this.demo, required this.title});

  final String demo;
  final String title;

  @override
  State<_GuideDemo> createState() => _GuideDemoState();
}

class _GuideDemoState extends State<_GuideDemo> {
  bool _playing = false;
  String? _locale;

  void _showLarger() {
    // Opening a larger view always starts with a poster, including when the
    // small preview was playing, so this demo is not duplicated in motion.
    setState(() => _playing = false);
    showDialog<void>(
      context: context,
      builder: (_) => _LargeDemoDialog(demo: widget.demo, title: widget.title),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context).languageCode;
    if (_locale != locale || MediaQuery.disableAnimationsOf(context)) {
      _playing = false;
    }
    _locale = locale;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    final locale = ['ar', 'en', 'es'].contains(_locale) ? _locale! : 'en';
    final path =
        'assets/guides/$locale/${widget.demo}.${_playing ? 'gif' : 'png'}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: ColoredBox(
              color: scheme.surface,
              child: Image.asset(
                path,
                key: ValueKey('guide-media-${widget.demo}'),
                fit: BoxFit.contain,
                semanticLabel: l10n.guideDemoDescription(widget.title),
                errorBuilder: (context, error, stackTrace) => Padding(
                  padding: const EdgeInsets.all(12),
                  child: Center(
                    child: Text(
                      l10n.guideMediaUnavailable,
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(height: 1.5),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              key: ValueKey('guide-play-${widget.demo}'),
              onPressed: reducedMotion
                  ? null
                  : () => setState(() => _playing = !_playing),
              icon: Icon(
                _playing ? Icons.stop_rounded : Icons.play_arrow_rounded,
              ),
              label: Text(_playing ? l10n.guideStopDemo : l10n.guidePlayDemo),
            ),
            TextButton.icon(
              key: ValueKey('guide-larger-${widget.demo}'),
              onPressed: _showLarger,
              icon: const Icon(Icons.zoom_in_rounded),
              label: Text(l10n.guideViewLarger),
            ),
          ],
        ),
        if (reducedMotion) ...[
          const SizedBox(height: 4),
          Text(
            l10n.guideReducedMotion,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.5),
          ),
        ],
      ],
    );
  }
}

class _LargeDemoDialog extends StatefulWidget {
  const _LargeDemoDialog({required this.demo, required this.title});

  final String demo;
  final String title;

  @override
  State<_LargeDemoDialog> createState() => _LargeDemoDialogState();
}

class _LargeDemoDialogState extends State<_LargeDemoDialog> {
  final _transformation = TransformationController();
  bool _playing = false;
  String? _locale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context).languageCode;
    if (_locale != locale || MediaQuery.disableAnimationsOf(context)) {
      _playing = false;
    }
    _locale = locale;
  }

  @override
  void dispose() {
    _transformation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    final locale = ['ar', 'en', 'es'].contains(_locale) ? _locale! : 'en';
    final path =
        'assets/guides/$locale/${widget.demo}.${_playing ? 'gif' : 'png'}';
    return Dialog(
      insetPadding: const EdgeInsets.all(12),
      backgroundColor: scheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    key: const ValueKey('guide-larger-close'),
                    tooltip: MaterialLocalizations.of(context).closeButtonLabel,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(l10n.guideZoomHint, style: const TextStyle(height: 1.5)),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  final height = (constraints.maxWidth * 9 / 16).clamp(
                    1.0,
                    MediaQuery.sizeOf(context).height * 0.56,
                  );
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: double.infinity,
                      height: height,
                      child: ColoredBox(
                        color: scheme.surfaceContainer,
                        child: InteractiveViewer(
                          key: const ValueKey('guide-zoom-viewer'),
                          transformationController: _transformation,
                          minScale: 1,
                          maxScale: 5,
                          child: Image.asset(
                            path,
                            key: ValueKey('guide-larger-media-${widget.demo}'),
                            width: constraints.maxWidth,
                            height: height,
                            fit: BoxFit.contain,
                            semanticLabel: l10n.guideDemoDescription(
                              widget.title,
                            ),
                            errorBuilder: (_, error, stackTrace) => Center(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text(
                                  l10n.guideMediaUnavailable,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    key: const ValueKey('guide-larger-play'),
                    onPressed: reducedMotion
                        ? null
                        : () => setState(() => _playing = !_playing),
                    icon: Icon(
                      _playing ? Icons.stop_rounded : Icons.play_arrow_rounded,
                    ),
                    label: Text(
                      _playing ? l10n.guideStopDemo : l10n.guidePlayDemo,
                    ),
                  ),
                  TextButton.icon(
                    key: const ValueKey('guide-reset-zoom'),
                    onPressed: () => _transformation.value = Matrix4.identity(),
                    icon: const Icon(Icons.fit_screen_rounded),
                    label: Text(l10n.guideResetZoom),
                  ),
                ],
              ),
              if (reducedMotion) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.guideReducedMotion,
                  style: const TextStyle(height: 1.5),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
