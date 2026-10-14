import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'tutorial_video_controller.dart';

const tutorialTopicIds = <String>[
  'reader',
  'search',
  'library',
  'audio',
  'offline',
  'plans',
  'settings',
  'storage',
  'personal',
  'backup',
  'share-search',
  'saved-audio',
  'morphology',
];

class UserGuidePage extends StatefulWidget {
  const UserGuidePage({super.key, this.videoFactory = createTutorialVideo});
  final TutorialVideoFactory videoFactory;
  @override
  State<UserGuidePage> createState() => _UserGuidePageState();
}

class _UserGuidePageState extends State<UserGuidePage> {
  int _selected = 0;
  // Retain the decoder when the underlying lesson layout changes while a
  // full-screen route is open (desktop rail to phone/landscape reflow).
  final _videoKey = GlobalKey<_TutorialVideoState>();
  final _scroll = ScrollController();
  void _selectLesson(int value) {
    setState(() => _selected = value);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      if (MediaQuery.disableAnimationsOf(context)) {
        _scroll.jumpTo(0);
      } else {
        unawaited(
          _scroll.animateTo(
            0,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context), s = Theme.of(context).colorScheme;
    final topics = _topics(l), topic = topics[_selected];
    final language = Localizations.localeOf(context).languageCode;
    return Scaffold(
      appBar: AppBar(title: Text(l.guideTitle)),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          key: const ValueKey('guide-scroll'),
          controller: _scroll,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1240),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsetsDirectional.only(start: 18),
                    decoration: BoxDecoration(
                      border: BorderDirectional(
                        start: BorderSide(color: s.primary, width: 3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.guideStartHere,
                          style: TextStyle(
                            color: s.primary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l.guideIntroTitle,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          l.guideVideoHint,
                          style: const TextStyle(height: 1.6),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  LayoutBuilder(
                    builder: (context, bounds) {
                      final wide =
                          bounds.maxWidth >= 1000 &&
                          MediaQuery.textScalerOf(context).scale(16) <= 24;
                      final navigation = _LessonNavigation(
                        topics: topics,
                        selected: _selected,
                        onSelect: _selectLesson,
                      );
                      final detail = _LessonDetail(
                        key: ValueKey('lesson-$language-${topic.id}'),
                        topic: topic,
                        number: _selected + 1,
                        factory: widget.videoFactory,
                        videoKey: _videoKey,
                      );
                      if (wide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 280, child: navigation),
                            const SizedBox(width: 28),
                            Expanded(child: detail),
                          ],
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          InputDecorator(
                            decoration: InputDecoration(
                              labelText: l.guideChooseLesson,
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                key: const ValueKey('guide-lesson-picker'),
                                value: _selected,
                                isExpanded: true,
                                items: [
                                  for (var i = 0; i < topics.length; i++)
                                    DropdownMenuItem(
                                      value: i,
                                      child: Text(
                                        topics[i].title,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                ],
                                onChanged: (value) {
                                  if (value != null) _selectLesson(value);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          detail,
                          const SizedBox(height: 28),
                          navigation,
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

class _Topic {
  const _Topic(this.id, this.icon, this.title, this.steps, this.tip);
  final String id, title, tip;
  final IconData icon;
  final List<String> steps;
}

List<_Topic> _topics(AppLocalizations l) => [
  _Topic('reader', Icons.menu_book_outlined, l.guideReadingTitle, [
    l.guideReadingStep1,
    l.guideReadingStep2,
    l.guideReadingStep3,
  ], l.guideReadingTip),
  _Topic('search', Icons.bookmark_border_rounded, l.guideSearchTitle, [
    l.guideSearchStep1,
    l.guideSearchStep2,
    l.guideSearchStep3,
  ], l.guideSearchTip),
  _Topic('library', Icons.auto_stories_outlined, l.guideLibraryTitle, [
    l.guideLibraryStep1,
    l.guideLibraryStep2,
    l.guideLibraryStep3,
  ], l.guideLibraryTip),
  _Topic('audio', Icons.headphones_rounded, l.guideAudioTitle, [
    l.guideAudioStep1,
    l.guideAudioStep2,
    l.guideAudioStep3,
  ], l.guideAudioTip),
  _Topic('offline', Icons.offline_pin_outlined, l.guideOfflineTitle, [
    l.guideOfflineStep1,
    l.guideOfflineStep2,
    l.guideOfflineStep3,
  ], l.guideOfflineTip),
  _Topic('plans', Icons.track_changes_rounded, l.guidePlansTitle, [
    l.guidePlansStep1,
    l.guidePlansStep2,
    l.guidePlansStep3,
  ], l.guidePlansTip),
  _Topic('settings', Icons.tune_rounded, l.guideSettingsTitle, [
    l.guideSettingsStep1,
    l.guideSettingsStep2,
    l.guideSettingsStep3,
  ], l.guideSettingsTip),
  _Topic('storage', Icons.phone_android_rounded, l.guideStorageTitle, [
    l.guideStorageStep1,
    l.guideStorageStep2,
  ], l.guideStorageTip),
  _Topic('personal', Icons.edit_note, l.guidePersonalTitle, [
    l.guidePersonalStep1,
    l.guidePersonalStep2,
    l.guidePersonalStep3,
  ], l.personalToolsBody),
  _Topic('backup', Icons.save_alt, l.backupTitle, [
    l.guideBackupStep1,
    l.guideBackupStep2,
    l.guideBackupStep3,
  ], l.backupBody),
  _Topic('share-search', Icons.ios_share, l.guideShareSearchTitle, [
    l.guideShareSearchStep1,
    l.guideShareSearchStep2,
    l.guideShareSearchStep3,
  ], l.searchSavedOnly),
  _Topic(
    'saved-audio',
    Icons.download_for_offline_outlined,
    l.browserAudioTitle,
    [l.guideSavedAudioStep1, l.guideSavedAudioStep2, l.guideSavedAudioStep3],
    l.browserAudioBody,
  ),
  _Topic('morphology', Icons.school_outlined, l.corpusLearning, [
    l.corpusGuideStep1,
    l.corpusGuideStep2,
    l.corpusGuideStep3,
  ], l.corpusSourceBody),
];

class _LessonNavigation extends StatelessWidget {
  const _LessonNavigation({
    required this.topics,
    required this.selected,
    required this.onSelect,
  });
  final List<_Topic> topics;
  final int selected;
  final ValueChanged<int> onSelect;
  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppLocalizations.of(context).guideChooseLesson,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < topics.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Material(
              color: i == selected
                  ? s.primary.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: ListTile(
                key: ValueKey('guide-topic-${topics[i].id}'),
                selected: i == selected,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                leading: Icon(
                  topics[i].icon,
                  color: i == selected ? s.primary : s.onSurfaceVariant,
                ),
                title: Text(
                  topics[i].title,
                  style: TextStyle(
                    fontWeight: i == selected
                        ? FontWeight.w800
                        : FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                trailing: i == selected
                    ? Icon(Icons.play_circle_outline, color: s.primary)
                    : null,
                onTap: () => onSelect(i),
              ),
            ),
          ),
      ],
    );
  }
}

class _LessonDetail extends StatelessWidget {
  const _LessonDetail({
    required this.topic,
    required this.number,
    required this.factory,
    required this.videoKey,
    super.key,
  });
  final _Topic topic;
  final int number;
  final TutorialVideoFactory factory;
  final GlobalKey<_TutorialVideoState> videoKey;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context), s = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l.guideLesson(number, tutorialTopicIds.length),
          style: TextStyle(color: s.primary, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Semantics(
          header: true,
          child: Text(
            topic.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 16),
        TutorialVideo(
          key: videoKey,
          topic: topic.id,
          title: topic.title,
          factory: factory,
        ),
        const SizedBox(height: 24),
        Text(
          l.guideWrittenSteps,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < topic.steps.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: s.primary,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    MaterialLocalizations.of(context).formatDecimal(i + 1),
                    textScaler: const TextScaler.linear(1),
                    style: TextStyle(
                      color: s.onPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    topic.steps[i],
                    style: const TextStyle(height: 1.7),
                  ),
                ),
              ],
            ),
          ),
        Divider(color: s.outline.withValues(alpha: 0.25)),
        const SizedBox(height: 8),
        Text(
          l.guideGoodToKnow,
          style: TextStyle(color: s.primary, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(topic.tip, style: const TextStyle(height: 1.7)),
        if (!kIsWeb && ['backup', 'share-search'].contains(topic.id)) ...[
          const SizedBox(height: 12),
          Text(l.guideNativeFiles, style: const TextStyle(height: 1.7)),
        ],
      ],
    );
  }
}

class TutorialVideo extends StatefulWidget {
  const TutorialVideo({
    required this.topic,
    required this.title,
    this.factory = createTutorialVideo,
    super.key,
  });
  final String topic, title;
  final TutorialVideoFactory factory;
  @override
  State<TutorialVideo> createState() => _TutorialVideoState();
}

class _TutorialVideoState extends State<TutorialVideo>
    with WidgetsBindingObserver {
  TutorialVideoController? _controller;
  bool _loading = false,
      _error = false,
      _fullScreen = false,
      _posterFailed = false;
  String _language = 'en';
  int _epoch = 0;
  final _modalUpdates = ValueNotifier<int>(0);
  final _zoom = TransformationController();
  Size _zoomViewport = Size.zero;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final language = Localizations.localeOf(context).languageCode;
    if (_language != language) {
      _release();
      _language = language;
    }
    if (MediaQuery.disableAnimationsOf(context)) unawaited(_pause());
  }

  @override
  void didUpdateWidget(TutorialVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.topic != widget.topic ||
        oldWidget.factory != widget.factory) {
      _release();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) unawaited(_pause());
  }

  void _changed() {
    if (mounted) {
      setState(() {});
      _modalUpdates.value++;
    }
  }

  Future<void> _pause() async {
    try {
      await _controller?.pause();
    } catch (_) {
      if (mounted) {
        _error = true;
        _changed();
      }
    }
  }

  void _release() {
    _epoch++;
    final old = _controller;
    _controller = null;
    _loading = false;
    _error = false;
    _posterFailed = false;
    _zoom.value = Matrix4.identity();
    old?.removeListener(_changed);
    if (old != null) unawaited(old.release().catchError((Object _) {}));
  }

  Future<void> _play({bool restart = false}) async {
    if (_loading) return;
    if (_error || _controller?.hasError == true) _release();
    final epoch = _epoch;
    try {
      if (_controller == null) {
        _loading = true;
        _changed();
        final controller = widget.factory(
          'assets/tutorials/$_language/${widget.topic}.mp4',
        );
        _controller = controller;
        controller.addListener(_changed);
        await controller.initialize();
        if (!mounted || epoch != _epoch) return;
      }
      final controller = _controller!;
      if (controller.hasError) throw StateError('Video unavailable');
      if (restart || controller.ended) await controller.seek(Duration.zero);
      if (!mounted || epoch != _epoch) return;
      await controller.play();
    } catch (_) {
      if (mounted && epoch == _epoch) _error = true;
    } finally {
      if (mounted && epoch == _epoch) {
        _loading = false;
        _changed();
      }
    }
  }

  Future<void> _seek(double milliseconds) async {
    try {
      await _controller?.seek(Duration(milliseconds: milliseconds.round()));
    } catch (_) {
      if (mounted) {
        _error = true;
        _changed();
      }
    }
  }

  Future<void> _enlarge() async {
    await _pause();
    if (!mounted) return;
    setState(() => _fullScreen = true);
    try {
      await showDialog<void>(
        context: context,
        builder: (c) => CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.escape): () =>
                Navigator.of(c).pop(),
          },
          child: Focus(
            autofocus: true,
            child: Dialog.fullscreen(
              child: SafeArea(
                child: AnimatedBuilder(
                  animation: _modalUpdates,
                  builder: (_, _) => _fullscreen(c),
                ),
              ),
            ),
          ),
        ),
      );
    } finally {
      await _pause();
      if (mounted) setState(() => _fullScreen = false);
    }
  }

  Widget _fullscreen(BuildContext c) => Scaffold(
    appBar: AppBar(
      title: Text(widget.title),
      leading: IconButton(
        key: const ValueKey('guide-larger-close'),
        tooltip: MaterialLocalizations.of(c).closeButtonLabel,
        onPressed: () => Navigator.of(c).pop(),
        icon: const Icon(Icons.close),
      ),
    ),
    body: LayoutBuilder(
      builder: (c, constraints) {
        final l = AppLocalizations.of(c);
        final shortLandscape =
            constraints.maxWidth >= 700 && constraints.maxHeight < 650;
        if (shortLandscape) {
          final controlWidth = (constraints.maxWidth * .27).clamp(190.0, 260.0);
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _zoomSurface(c)),
                const SizedBox(width: 16),
                SizedBox(
                  width: controlWidth,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _controls(c, full: true),
                        const SizedBox(height: 12),
                        _zoomControls(c),
                        const SizedBox(height: 12),
                        Text(
                          l.guideZoomHint,
                          style: const TextStyle(height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (constraints.maxWidth < 700) ...[
                  Text(l.guideRotateHint, style: const TextStyle(height: 1.5)),
                  const SizedBox(height: 12),
                ],
                SizedBox(
                  height: constraints.maxWidth < 700
                      ? (constraints.maxWidth - 32).clamp(220.0, 460.0)
                      : ((constraints.maxWidth - 32) * 9 / 16).clamp(
                          240.0,
                          720.0,
                        ),
                  child: _zoomSurface(c),
                ),
                const SizedBox(height: 12),
                _zoomControls(c),
                const SizedBox(height: 12),
                _controls(c, full: true),
                const SizedBox(height: 12),
                Text(l.guideZoomHint, style: const TextStyle(height: 1.5)),
              ],
            ),
          ),
        );
      },
    ),
  );
  Widget _zoomSurface(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      _zoomViewport = constraints.biggest;
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: ColoredBox(
          color: const Color(0xFF081E18),
          child: InteractiveViewer(
            key: const ValueKey('guide-video-zoom'),
            transformationController: _zoom,
            minScale: 1,
            maxScale: 4,
            boundaryMargin: EdgeInsets.zero,
            child: SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: Center(
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _surface(context, full: true),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
  void _zoomBy(double factor) {
    final previous = _zoom.value.getMaxScaleOnAxis();
    final scale = (previous * factor).clamp(1.0, 4.0), ratio = scale / previous;
    final center = _zoomViewport.center(Offset.zero);
    final tx = (center.dx - (center.dx - _zoom.value.storage[12]) * ratio)
        .clamp(_zoomViewport.width * (1 - scale), 0.0);
    final ty = (center.dy - (center.dy - _zoom.value.storage[13]) * ratio)
        .clamp(_zoomViewport.height * (1 - scale), 0.0);
    _zoom.value = Matrix4.identity()
      ..translateByDouble(tx, ty, 0, 1)
      ..scaleByDouble(scale, scale, 1, 1);
  }

  Widget _zoomControls(BuildContext context) => ListenableBuilder(
    listenable: _zoom,
    builder: (context, _) {
      final l = AppLocalizations.of(context),
          scale = _zoom.value.getMaxScaleOnAxis();
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          OutlinedButton.icon(
            key: const ValueKey('guide-zoom-in'),
            onPressed: scale < 4 ? () => _zoomBy(1.5) : null,
            icon: const Icon(Icons.zoom_in),
            label: Text(l.guideZoomIn),
          ),
          OutlinedButton.icon(
            key: const ValueKey('guide-zoom-out'),
            onPressed: scale > 1 ? () => _zoomBy(1 / 1.5) : null,
            icon: const Icon(Icons.zoom_out),
            label: Text(l.guideZoomOut),
          ),
          TextButton.icon(
            key: const ValueKey('guide-reset-zoom'),
            onPressed: () => _zoom.value = Matrix4.identity(),
            icon: const Icon(Icons.center_focus_strong),
            label: Text(l.guideResetZoom),
          ),
        ],
      );
    },
  );
  void _markPosterFailure(String asset) {
    final epoch = _epoch;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted &&
          epoch == _epoch &&
          !_posterFailed &&
          asset == 'assets/tutorials/$_language/${widget.topic}.png') {
        _posterFailed = true;
        _changed();
      }
    });
  }

  Widget _surface(BuildContext c, {bool full = false}) {
    final l = AppLocalizations.of(c),
        s = Theme.of(c).colorScheme,
        controller = _controller;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: ColoredBox(
        color: s.surfaceContainerHighest,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (controller?.initialized == true &&
                !_error &&
                !controller!.hasError &&
                (full || !_fullScreen))
              controller.video()
            else
              Image.asset(
                'assets/tutorials/$_language/${widget.topic}.png',
                key: ValueKey(
                  full
                      ? 'guide-larger-media-${widget.topic}'
                      : 'guide-media-${widget.topic}',
                ),
                fit: BoxFit.contain,
                semanticLabel: l.guideDemoDescription(widget.title),
                errorBuilder: (_, _, _) {
                  _markPosterFailure(
                    'assets/tutorials/$_language/${widget.topic}.png',
                  );
                  return Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 44,
                      color: s.onSurfaceVariant,
                    ),
                  );
                },
              ),
            if (_loading)
              Center(
                child: Semantics(
                  label: l.guideVideoLoading,
                  child: const CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _time(Duration d) =>
      '${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
  Widget _controls(BuildContext c, {bool full = false}) {
    final l = AppLocalizations.of(c), controller = _controller;
    final failed = _error || controller?.hasError == true,
        ready = controller?.initialized == true && !failed;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (failed || _posterFailed)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              l.guideMediaUnavailable,
              style: const TextStyle(height: 1.5),
            ),
          ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilledButton.icon(
              key: ValueKey(
                full ? 'guide-larger-play' : 'guide-play-${widget.topic}',
              ),
              onPressed: _loading
                  ? null
                  : () async {
                      if (!failed && controller?.playing == true) {
                        await _pause();
                      } else {
                        await _play();
                      }
                      _changed();
                    },
              icon: Icon(
                controller?.playing == true
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
              ),
              label: Text(
                failed
                    ? l.guideVideoRetry
                    : controller?.playing == true
                    ? l.guidePauseVideo
                    : l.guidePlayDemo,
              ),
            ),
            OutlinedButton.icon(
              onPressed: ready && !_loading ? () => _play(restart: true) : null,
              icon: const Icon(Icons.replay),
              label: Text(l.guideRestartVideo),
            ),
            if (!full)
              TextButton.icon(
                key: ValueKey('guide-larger-${widget.topic}'),
                onPressed: _enlarge,
                icon: const Icon(Icons.fullscreen),
                label: Text(l.guideFullScreen),
              ),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                '${_time(controller?.position ?? Duration.zero)} / ${_time(controller?.duration ?? Duration.zero)}',
                style: Theme.of(c).textTheme.bodySmall,
              ),
            ),
          ],
        ),
        if (ready)
          Semantics(
            label: l.guideSeekVideo,
            child: Slider(
              value: controller!.position.inMilliseconds.toDouble().clamp(
                0,
                controller.duration.inMilliseconds.toDouble(),
              ),
              max: controller.duration.inMilliseconds.toDouble().clamp(
                1,
                double.infinity,
              ),
              onChangeStart: (_) => unawaited(_pause()),
              onChanged: (value) => unawaited(_seek(value)),
              semanticFormatterCallback: (value) =>
                  _time(Duration(milliseconds: value.round())),
            ),
          ),
        if (controller?.ended == true)
          Text(l.guideVideoFinished, style: const TextStyle(height: 1.5)),
      ],
    );
  }

  @override
  Widget build(BuildContext c) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      AspectRatio(aspectRatio: 16 / 9, child: _surface(c)),
      const SizedBox(height: 12),
      _controls(c),
      if (MediaQuery.disableAnimationsOf(c))
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            AppLocalizations.of(c).guideReducedMotion,
            style: Theme.of(c).textTheme.bodySmall?.copyWith(height: 1.5),
          ),
        ),
    ],
  );
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _release();
    _modalUpdates.dispose();
    _zoom.dispose();
    super.dispose();
  }
}
