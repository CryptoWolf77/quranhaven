import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quran_library/quran_library.dart';

import '../../../core/config/app_config.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../personal/domain/personal_models.dart';
import '../../personal/presentation/personal_tools_page.dart';
import '../../personal/presentation/saved_text_search_page.dart';
import '../../audio/data/browser_audio_service.dart';
import '../../learning/presentation/corpus_learning_page.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({
    required this.currentPage,
    required this.onOpenReader,
    required this.onOpenAyah,
    this.nativeOfflineDownload,
    this.cancelNativeOfflineDownload,
    super.key,
  });

  final int currentPage;
  final VoidCallback onOpenReader;
  final ValueChanged<AyahReference> onOpenAyah;
  final Future<bool> Function(int surahNumber)? nativeOfflineDownload;
  final FutureOr<void> Function()? cancelNativeOfflineDownload;

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  int _section = 0;
  int _selectedSurah = 1;
  int? _busyResourceIndex;
  bool _audioBusy = false;
  bool _audioDownloading = false;
  bool _audioCancelling = false;
  late final NativeSurahDownloadSession _nativeDownload;
  BrowserAudioService? _browserAudio;
  StreamSubscription<BrowserAudioStatus>? _audioEvents;
  StreamSubscription<dynamic>? _playerEvents;
  BrowserAudioStatus _browserStatus = const BrowserAudioStatus();
  List<BrowserAudioEntry> _savedAudio = [];
  bool _browserSupported = false;

  @override
  void initState() {
    super.initState();
    _nativeDownload = NativeSurahDownloadSession(
      downloadAdapter:
          widget.nativeOfflineDownload ??
          (surah) => QuranLibrary().downloadSurahForOffline(surahNumber: surah),
      cancelAdapter:
          widget.cancelNativeOfflineDownload ??
          () => QuranLibrary().cancelOfflineSurahDownload(),
    );
    final lastSurah = QuranLibrary().currentAndLastSurahNumber;
    if (lastSurah >= 1 && lastSurah <= 114) {
      _selectedSurah = lastSurah;
    }
    if (kIsWeb) {
      _refreshResources();
      _browserAudio = createBrowserAudioService();
      _audioEvents = _browserAudio!.changes.listen((status) {
        if (mounted) setState(() => _browserStatus = status);
      });
      _playerEvents = AudioCtrl.instance.state.audioPlayer.playerStateStream
          .listen((state) {
            if (mounted && state.playing && _audioBusy) {
              setState(() => _audioBusy = false);
            }
          });
      _refreshBrowserAudio();
    }
  }

  @override
  void dispose() {
    _audioEvents?.cancel();
    _playerEvents?.cancel();
    _browserAudio?.dispose();
    super.dispose();
  }

  Future<void> _refreshBrowserAudio() async {
    try {
      final entries = await _browserAudio!.list();
      if (mounted) {
        setState(() {
          _savedAudio = entries;
          _browserSupported = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _browserSupported = false);
    }
  }

  String _audioFailure(Object error) {
    final l = AppLocalizations.of(context);
    final code = error is BrowserAudioFailure ? error.code : '';
    return switch (code) {
      'cancelled' => l.browserAudioCancelled,
      'storage_full' => l.browserAudioStorageFull,
      'unavailable' => l.browserAudioUnavailable,
      'audio_busy' => l.browserAudioBusy,
      'audio_too_large' => l.browserAudioTooLarge,
      _ => l.downloadFailed,
    };
  }

  Future<void> _playSavedAudio(BrowserAudioEntry entry) async {
    final readers = ReadersConstants.activeSurahReaders;
    final index = readers.indexWhere(
      (r) =>
          '${r.recordingRoot.replaceFirst(RegExp(r'/+$'), '')}/${entry.surahNumber.toString().padLeft(3, '0')}.mp3' ==
          entry.url,
    );
    if (index < 0) {
      _showMessage(AppLocalizations.of(context).downloadFailed);
      return;
    }
    setState(() => _audioBusy = true);
    try {
      final ctrl = AudioCtrl.instance;
      await ctrl.state.audioPlayer.stop();
      await ctrl.state.box.write(StorageConstants.surahReaderIndex, index);
      ctrl.state.surahReaderIndex.value = index;
      if (!mounted) return;
      await QuranLibrary().playSurah(
        context: context,
        surahNumber: entry.surahNumber,
      );
    } catch (_) {
      if (mounted) _showMessage(AppLocalizations.of(context).noInternet);
    } finally {
      if (mounted) setState(() => _audioBusy = false);
    }
  }

  Future<void> _removeSavedAudio(BrowserAudioEntry entry) async {
    final l = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l.delete),
        content: Text(l.browserAudioDelete),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(l.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      final ctrl = AudioCtrl.instance;
      if (ctrl.state.isPlayingSurahsMode &&
          ctrl.urlSurahFilePath == entry.url) {
        await ctrl.state.audioPlayer.stop();
        ctrl.state.isPlaying.value = false;
      }
      await _browserAudio!.remove(entry.url);
      await _refreshBrowserAudio();
    } catch (e) {
      if (mounted) _showMessage(_audioFailure(e));
    }
  }

  Future<void> _refreshResources() async {
    try {
      await QuranLibrary().refreshTafsirDownloads();
      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) _showMessage(AppLocalizations.of(context).resourceFailed);
    }
  }

  Future<void> _removeResource(int index) async {
    if (_busyResourceIndex != null) return;
    final l10n = AppLocalizations.of(context);
    final remove = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(
          QuranLibrary().tafsirAndTraslationsCollection[index].name,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (remove != true || !mounted) return;
    setState(() => _busyResourceIndex = index);
    final success = await QuranLibrary().removeTafsirDownload(index);
    if (mounted) setState(() => _busyResourceIndex = null);
    if (!success) _showMessage(l10n.resourceFailed);
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _prepareResource(int index) async {
    final l10n = AppLocalizations.of(context);
    final library = QuranLibrary();
    final isAvailable = library.getTafsirDownloaded(index);
    final resource = library.tafsirAndTraslationsCollection[index];
    final isBundled = resource.fileName == 'saadi' || resource.fileName == 'en';
    if (kIsWeb && !isBundled && !library.canPersistWebTafsir) {
      _showMessage(l10n.webResourceStorageUnavailable);
      return;
    }
    if (AppConfig.contentBaseUri == null && !isBundled && !isAvailable) {
      _showMessage(l10n.contentServerNotConfigured);
      return;
    }

    setState(() => _busyResourceIndex = index);
    try {
      await library.prepareTafsir(index, pageNumber: widget.currentPage);
      if (mounted) {
        setState(() => _busyResourceIndex = null);
      }
      _showMessage(l10n.resourceReady);
    } catch (_) {
      if (mounted) {
        setState(() => _busyResourceIndex = null);
      }
      _showMessage(l10n.resourceFailed);
    }
  }

  Future<void> _playSelectedSurah() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _audioBusy = true);
    try {
      await QuranLibrary().playSurah(
        context: context,
        surahNumber: _selectedSurah,
      );
    } catch (_) {
      _showMessage(l10n.noInternet);
    } finally {
      if (mounted) setState(() => _audioBusy = false);
    }
  }

  Future<void> _resumeListening() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _audioBusy = true);
    try {
      await QuranLibrary().playLastPosition();
    } catch (_) {
      _showMessage(l10n.noInternet);
    } finally {
      if (mounted) setState(() => _audioBusy = false);
    }
  }

  Future<void> _downloadSelectedSurah() async {
    if (_audioDownloading || _audioBusy) return;
    final l10n = AppLocalizations.of(context);
    final surahNumber = _selectedSurah;
    setState(() {
      _audioDownloading = true;
      _audioCancelling = false;
    });
    try {
      bool completed = true;
      if (kIsWeb) {
        final reader =
            ReadersConstants.activeSurahReaders[AudioCtrl
                .instance
                .state
                .surahReaderIndex
                .value];
        final root = reader.recordingRoot.replaceFirst(RegExp(r'/$'), '');
        final names = QuranLibrary.getAllSurahs(
          isArabic: Localizations.localeOf(context).languageCode == 'ar',
        );
        await _browserAudio!.download(
          url: '$root/${surahNumber.toString().padLeft(3, '0')}.mp3',
          readerName: reader.name,
          surahNumber: surahNumber,
          surahName: names[surahNumber - 1],
        );
        await _refreshBrowserAudio();
      } else {
        completed = await _nativeDownload.download(surahNumber);
      }
      _showMessage(
        completed ? l10n.downloadComplete : l10n.browserAudioCancelled,
      );
    } catch (error) {
      if (mounted) {
        _showMessage(kIsWeb ? _audioFailure(error) : l10n.downloadFailed);
      }
    } finally {
      if (mounted) {
        setState(() {
          _audioDownloading = false;
          _audioCancelling = false;
        });
      }
    }
  }

  Future<void> _cancelAudioDownload() async {
    if (!_audioDownloading || _audioCancelling) return;
    setState(() => _audioCancelling = true);
    try {
      if (kIsWeb) {
        await _browserAudio?.cancel();
      } else {
        await _nativeDownload.cancel();
      }
      // Cancellation is only a request. Keep the download controls locked until
      // the original transfer settles, so a second request cannot race cleanup.
    } catch (error) {
      if (mounted) {
        setState(() => _audioCancelling = false);
        _showMessage(
          kIsWeb
              ? _audioFailure(error)
              : AppLocalizations.of(context).downloadFailed,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final resources = QuranLibrary().tafsirAndTraslationsCollection;
    final tafsirs = <_ResourceEntry>[];
    final translations = <_ResourceEntry>[];

    for (var index = 0; index < resources.length; index++) {
      final entry = _ResourceEntry(index, resources[index]);
      if (!entry.resource.isCommentary) {
        translations.add(entry);
      } else {
        tafsirs.add(entry);
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1040),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LibraryHeader(),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).push<void>(
                      MaterialPageRoute(
                        builder: (_) =>
                            PersonalToolsPage(onOpenAyah: widget.onOpenAyah),
                      ),
                    ),
                    icon: const Icon(Icons.edit_note),
                    label: Text(l10n.personalTools),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).push<void>(
                      MaterialPageRoute(
                        builder: (_) =>
                            SavedTextSearchPage(onOpenAyah: widget.onOpenAyah),
                      ),
                    ),
                    icon: const Icon(Icons.search),
                    label: Text(l10n.savedTextSearch),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).push<void>(
                      MaterialPageRoute(
                        builder: (_) =>
                            CorpusLearningPage(onOpenAyah: widget.onOpenAyah),
                      ),
                    ),
                    icon: const Icon(Icons.school_outlined),
                    label: Text(l10n.corpusLearning),
                  ),
                ],
              ),
              if (AppConfig.contentBaseUri == null) ...[
                const SizedBox(height: 16),
                Text(l10n.contentServerNotConfigured),
              ],
              if (kIsWeb && !QuranLibrary().canPersistWebTafsir) ...[
                const SizedBox(height: 16),
                Text(l10n.webResourceStorageUnavailable),
              ],
              const SizedBox(height: 22),
              SegmentedButton<int>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: 0,
                    icon: const Icon(Icons.auto_stories_outlined),
                    label: Text(l10n.tafsir),
                  ),
                  ButtonSegment(
                    value: 1,
                    icon: const Icon(Icons.translate_rounded),
                    label: Text(l10n.translations),
                  ),
                  ButtonSegment(
                    value: 2,
                    icon: const Icon(Icons.headphones_rounded),
                    label: Text(l10n.recitations),
                  ),
                ],
                selected: {_section},
                onSelectionChanged: (selection) {
                  setState(() => _section = selection.first);
                },
              ),
              const SizedBox(height: 20),
              if (_section == 0)
                _ResourceList(
                  entries: tafsirs,
                  busyIndex: _busyResourceIndex,
                  onPrepare: _prepareResource,
                  onRemove: _removeResource,
                )
              else if (_section == 1)
                _ResourceList(
                  entries: translations,
                  busyIndex: _busyResourceIndex,
                  onPrepare: _prepareResource,
                  onRemove: _removeResource,
                )
              else
                _RecitationsPanel(
                  selectedSurah: _selectedSurah,
                  audioBusy: _audioBusy,
                  audioDownloading: _audioDownloading,
                  audioCancelling: _audioCancelling,
                  onSurahChanged: (surah) {
                    if (surah != null && !_audioBusy && !_audioDownloading) {
                      setState(() => _selectedSurah = surah);
                    }
                  },
                  onPlay: _playSelectedSurah,
                  onResume: _resumeListening,
                  onDownload: _downloadSelectedSurah,
                  onCancelDownload: _cancelAudioDownload,
                  onOpenReader: () {
                    AutoScrollCtrl.instance.pauseAutoScroll();
                    final reader = QuranCtrl.instance;
                    reader.isShowControl.value = true;
                    reader.state.isPlayExpanded.value = true;
                    reader.update(['isShowControl']);
                    widget.onOpenReader();
                  },
                  browserSupported: _browserSupported,
                  browserStatus: _browserStatus,
                  savedAudio: _savedAudio,
                  onPlaySaved: _playSavedAudio,
                  onRemoveSaved: _removeSavedAudio,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LibraryHeader extends StatelessWidget {
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
            Color.lerp(scheme.primary, const Color(0xFF082E26), 0.6)!,
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
              Icons.local_library_outlined,
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
                  l10n.contentLibrary,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  l10n.contentLibraryBody,
                  style: TextStyle(
                    color: scheme.onPrimary.withValues(alpha: 0.8),
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

class _ResourceList extends StatelessWidget {
  const _ResourceList({
    required this.entries,
    required this.busyIndex,
    required this.onPrepare,
    required this.onRemove,
  });

  final List<_ResourceEntry> entries;
  final int? busyIndex;
  final ValueChanged<int> onPrepare;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final library = QuranLibrary();
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.offline_pin_outlined, color: scheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(kIsWeb ? l10n.webOfflineNote : l10n.resourceHint),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (entries.isEmpty)
          const Center(child: CircularProgressIndicator())
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: entries.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, listIndex) {
              final entry = entries[listIndex];
              final isSelected =
                  library.selectedTafsirIndex == entry.catalogIndex;
              final isAvailable = library.getTafsirDownloaded(
                entry.catalogIndex,
              );
              final isBusy = busyIndex == entry.catalogIndex;

              return Semantics(
                container: true,
                explicitChildNodes: true,
                label: '${entry.resource.name} ${entry.resource.bookName}'
                    .trim(),
                child: Card(
                  semanticContainer: false,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color:
                                (isSelected ? scheme.primary : scheme.secondary)
                                    .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            !entry.resource.isCommentary
                                ? Icons.translate_rounded
                                : Icons.auto_stories_outlined,
                            color: isSelected
                                ? scheme.primary
                                : scheme.secondary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: ExcludeSemantics(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.resource.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                if (entry.resource.bookName.isNotEmpty) ...[
                                  const SizedBox(height: 3),
                                  Text(
                                    entry.resource.bookName,
                                    style: TextStyle(
                                      color: scheme.onSurface.withValues(
                                        alpha: 0.65,
                                      ),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (isBusy)
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        else if (isSelected && isAvailable)
                          Chip(
                            avatar: const Icon(Icons.check_rounded, size: 16),
                            label: Text(l10n.selected),
                          )
                        else
                          TextButton.icon(
                            onPressed: busyIndex == null
                                ? () => onPrepare(entry.catalogIndex)
                                : null,
                            icon: Icon(
                              isAvailable
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.download_rounded,
                            ),
                            label: Text(
                              isAvailable ? l10n.select : l10n.download,
                            ),
                          ),
                        if (!isBusy &&
                            library.canRemoveTafsir(entry.catalogIndex))
                          IconButton(
                            tooltip: l10n.delete,
                            onPressed: busyIndex == null
                                ? () => onRemove(entry.catalogIndex)
                                : null,
                            icon: const Icon(Icons.delete_outline_rounded),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _RecitationsPanel extends StatelessWidget {
  const _RecitationsPanel({
    required this.selectedSurah,
    required this.audioBusy,
    required this.audioDownloading,
    required this.audioCancelling,
    required this.onSurahChanged,
    required this.onPlay,
    required this.onResume,
    required this.onDownload,
    required this.onCancelDownload,
    required this.onOpenReader,
    required this.browserSupported,
    required this.browserStatus,
    required this.savedAudio,
    required this.onPlaySaved,
    required this.onRemoveSaved,
  });

  final int selectedSurah;
  final bool audioBusy;
  final bool audioDownloading;
  final bool audioCancelling;
  final ValueChanged<int?> onSurahChanged;
  final VoidCallback onPlay;
  final VoidCallback onResume;
  final VoidCallback onDownload;
  final VoidCallback onCancelDownload;
  final VoidCallback onOpenReader;
  final bool browserSupported;
  final BrowserAudioStatus browserStatus;
  final List<BrowserAudioEntry> savedAudio;
  final ValueChanged<BrowserAudioEntry> onPlaySaved;
  final ValueChanged<BrowserAudioEntry> onRemoveSaved;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context);
    final surahs = QuranLibrary.getAllSurahs(
      isArabic: locale.languageCode == 'ar',
    );
    final lastSurah = QuranLibrary().currentAndLastSurahNumber;
    final lastPosition = QuranLibrary().formatLastPositionToTime;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          semanticContainer: false,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.graphic_eq_rounded, color: scheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.recitations,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                DropdownButtonFormField<int>(
                  initialValue: selectedSurah,
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
                    for (var index = 0; index < surahs.length; index++)
                      DropdownMenuItem(
                        value: index + 1,
                        child: Text('${index + 1}. ${surahs[index]}'),
                      ),
                  ],
                  onChanged: audioBusy || audioDownloading
                      ? null
                      : onSurahChanged,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: audioBusy || audioDownloading ? null : onPlay,
                      icon: audioBusy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.play_arrow_rounded),
                      label: Text(l10n.play),
                    ),
                    OutlinedButton.icon(
                      onPressed:
                          lastSurah > 0 && !audioBusy && !audioDownloading
                          ? onResume
                          : null,
                      icon: const Icon(Icons.history_rounded),
                      label: Text(l10n.resumeListening),
                    ),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await AudioCtrl.instance.state.audioPlayer.stop();
                        AudioCtrl.instance.state.isPlaying.value = false;
                      },
                      icon: const Icon(Icons.stop),
                      label: Text(l10n.stop),
                    ),
                  ],
                ),
                if (lastSurah > 0) ...[
                  const SizedBox(height: 14),
                  Text(
                    '${l10n.lastListen}: ${surahs[lastSurah - 1]} · $lastPosition',
                    style: TextStyle(
                      color: scheme.onSurface.withValues(alpha: 0.66),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          semanticContainer: false,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kIsWeb ? l10n.browserAudioTitle : l10n.downloadedSurahs,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(kIsWeb ? l10n.browserAudioBody : l10n.resourceHint),
                const SizedBox(height: 16),
                if (kIsWeb) ...[
                  Text(
                    l10n.audioDownloadSelection,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    '${ReadersConstants.activeSurahReaders[AudioCtrl.instance.state.surahReaderIndex.value].name} · $selectedSurah. ${surahs[selectedSurah - 1]}',
                  ),
                  const SizedBox(height: 12),
                ],
                if (!kIsWeb || browserSupported)
                  audioDownloading
                      ? OutlinedButton.icon(
                          onPressed: audioCancelling ? null : onCancelDownload,
                          icon: const Icon(Icons.close_rounded),
                          label: Text(l10n.cancelDownload),
                        )
                      : FilledButton.tonalIcon(
                          onPressed: audioBusy ? null : onDownload,
                          icon: const Icon(Icons.download_for_offline_outlined),
                          label: Text(l10n.downloadForOffline),
                        ),
                if (kIsWeb && audioDownloading) ...[
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: browserStatus.totalBytes > 0
                        ? (browserStatus.completedBytes /
                                  browserStatus.totalBytes)
                              .clamp(0, 1)
                        : null,
                  ),
                  Text(
                    '${(browserStatus.completedBytes / 1048576).toStringAsFixed(1)} MB${browserStatus.totalBytes > 0 ? ' / ${(browserStatus.totalBytes / 1048576).toStringAsFixed(1)} MB' : ''}',
                  ),
                ],
                if (kIsWeb && !browserSupported)
                  Text(l10n.browserAudioUnavailable),
                if (kIsWeb && browserSupported && savedAudio.isEmpty) ...[
                  const SizedBox(height: 12),
                  Text(l10n.browserAudioEmpty),
                ],
                if (kIsWeb)
                  for (final entry in savedAudio)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${entry.surahNumber}. ${entry.surahName} · ${entry.readerName}',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            '${(entry.bytes / 1048576).toStringAsFixed(1)} MB',
                          ),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              OutlinedButton.icon(
                                onPressed: audioBusy || audioDownloading
                                    ? null
                                    : () => onPlaySaved(entry),
                                icon: const Icon(Icons.play_arrow),
                                label: Text(l10n.play),
                              ),
                              IconButton(
                                tooltip: l10n.delete,
                                onPressed: audioDownloading
                                    ? null
                                    : () => onRemoveSaved(entry),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          semanticContainer: false,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.record_voice_over_outlined, color: scheme.secondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.chooseReader,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(l10n.readerAudioHint),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: audioDownloading ? null : onOpenReader,
                        icon: const Icon(Icons.menu_book_rounded),
                        label: Text(l10n.openReaderControls),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A download-only request boundary. The native adapter returns false on
/// cancellation and throws on failure; neither path is converted to success.
class NativeSurahDownloadSession {
  NativeSurahDownloadSession({
    required this.downloadAdapter,
    required this.cancelAdapter,
  });

  final Future<bool> Function(int surahNumber) downloadAdapter;
  final FutureOr<void> Function() cancelAdapter;
  bool _busy = false;
  bool _cancelling = false;

  bool get isBusy => _busy;

  Future<bool> download(int surahNumber) async {
    if (_busy) throw StateError('An offline download is already active');
    if (surahNumber < 1 || surahNumber > 114) {
      throw RangeError.range(surahNumber, 1, 114, 'surahNumber');
    }
    _busy = true;
    _cancelling = false;
    try {
      return await downloadAdapter(surahNumber);
    } finally {
      _busy = false;
      _cancelling = false;
    }
  }

  Future<void> cancel() async {
    if (!_busy || _cancelling) return;
    _cancelling = true;
    try {
      await cancelAdapter();
    } catch (_) {
      _cancelling = false;
      rethrow;
    }
  }
}

class _ResourceEntry {
  const _ResourceEntry(this.catalogIndex, this.resource);

  final int catalogIndex;
  final TafsirNameModel resource;
}
