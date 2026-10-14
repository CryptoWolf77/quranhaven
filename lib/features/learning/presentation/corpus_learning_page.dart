import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quran_library/quran_library.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../personal/domain/personal_models.dart';
import '../../personal/presentation/personal_tools_page.dart';
import '../data/corpus_repository.dart';
import '../data/source_links.dart';
import '../domain/corpus_morphology.dart';

/// SelectableText's web editable semantics otherwise expose an empty textbox.
/// Keep mouse selection/copy while giving screen readers the exact source text.
class CorpusSelectableText extends StatelessWidget {
  const CorpusSelectableText(
    this.data, {
    this.textDirection,
    this.textAlign,
    this.style,
    super.key,
  });
  final String data;
  final TextDirection? textDirection;
  final TextAlign? textAlign;
  final TextStyle? style;
  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: data,
    textDirection: textDirection,
    excludeSemantics: true,
    child: SelectableText(
      data,
      textDirection: textDirection,
      textAlign: textAlign,
      style: style,
    ),
  );
}

String corpusPosLabel(AppLocalizations l, String code) => switch (code) {
  'N' => l.corpusPosN,
  'PN' => l.corpusPosPN,
  'ADJ' => l.corpusPosADJ,
  'IMPN' => l.corpusPosIMPN,
  'PRON' => l.corpusPosPRON,
  'DEM' => l.corpusPosDEM,
  'REL' => l.corpusPosREL,
  'T' => l.corpusPosT,
  'LOC' => l.corpusPosLOC,
  'V' => l.corpusPosV,
  'P' => l.corpusPosP,
  'DET' => l.corpusPosDET,
  'EMPH' => l.corpusPosEMPH,
  'IMPV' => l.corpusPosIMPV,
  'PRP' => l.corpusPosPRP,
  'CONJ' => l.corpusPosCONJ,
  'SUB' => l.corpusPosSUB,
  'ACC' => l.corpusPosACC,
  'AMD' => l.corpusPosAMD,
  'ANS' => l.corpusPosANS,
  'AVR' => l.corpusPosAVR,
  'CAUS' => l.corpusPosCAUS,
  'CERT' => l.corpusPosCERT,
  'CIRC' => l.corpusPosCIRC,
  'COM' => l.corpusPosCOM,
  'COND' => l.corpusPosCOND,
  'EQ' => l.corpusPosEQ,
  'EXH' => l.corpusPosEXH,
  'EXL' => l.corpusPosEXL,
  'EXP' => l.corpusPosEXP,
  'FUT' => l.corpusPosFUT,
  'INC' => l.corpusPosINC,
  'INT' => l.corpusPosINT,
  'INTG' => l.corpusPosINTG,
  'NEG' => l.corpusPosNEG,
  'PREV' => l.corpusPosPREV,
  'PRO' => l.corpusPosPRO,
  'REM' => l.corpusPosREM,
  'RES' => l.corpusPosRES,
  'RET' => l.corpusPosRET,
  'RSLT' => l.corpusPosRSLT,
  'SUP' => l.corpusPosSUP,
  'SUR' => l.corpusPosSUR,
  'VOC' => l.corpusPosVOC,
  'INL' => l.corpusPosINL,
  _ => code,
};

class CorpusLearningPage extends StatefulWidget {
  const CorpusLearningPage({
    this.reference = const AyahReference(1, 1),
    this.onOpenAyah,
    this.repository,
    super.key,
  });
  final AyahReference reference;
  final ValueChanged<AyahReference>? onOpenAyah;
  final CorpusRepository? repository;
  @override
  State<CorpusLearningPage> createState() => _CorpusLearningPageState();
}

class _CorpusLearningPageState extends State<CorpusLearningPage> {
  late final _repo = widget.repository ?? CorpusRepository();
  late AyahReference _reference = widget.reference;
  CorpusIndex? _index;
  List<CorpusWord> _words = [];
  bool _loading = true, _failed = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
      _index = null;
      _words = [];
    });
    try {
      final index = await _repo.load();
      final words = index.wordsFor(_reference);
      if (mounted) {
        setState(() {
          _index = index;
          _words = words;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _select(AyahReference ref) {
    if (!ref.isValid) return;
    try {
      final words = _index?.wordsFor(ref) ?? <CorpusWord>[];
      setState(() {
        _reference = ref;
        _words = words;
      });
    } catch (_) {
      setState(() {
        _words = [];
        _failed = true;
      });
    }
  }

  void _move(int direction) =>
      _select(adjacentCorpusAyah(_reference, direction)!);
  void _openReader() {
    Navigator.pop(context);
    if (widget.onOpenAyah != null) {
      widget.onOpenAyah!(_reference);
    } else {
      final ayah = resolvePersonalAyah(_reference);
      QuranLibrary().jumpToAyah(ayah.page, ayah.ayahUQNumber);
    }
  }

  @override
  Widget build(BuildContext c) {
    final l = AppLocalizations.of(c), s = Theme.of(c).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.corpusLearning),
        actions: [
          IconButton(
            tooltip: l.corpusSource,
            onPressed: _index == null
                ? null
                : () => showDialog<void>(
                    context: c,
                    builder: (_) =>
                        CorpusSourceDialog(index: _index!, repository: _repo),
                  ),
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1040),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: s.primary.withValues(alpha: .07),
                          border: Border.all(
                            color: s.primary.withValues(alpha: .15),
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.corpusOffline,
                              style: TextStyle(
                                color: s.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l.corpusLearningBody,
                              style: const TextStyle(height: 1.5),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Quranic Arabic Corpus · v0.4',
                              textDirection: TextDirection.ltr,
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      AyahPicker(
                        key: ValueKey(_reference.key),
                        initial: _reference,
                        onChanged: _select,
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          OutlinedButton.icon(
                            onPressed:
                                adjacentCorpusAyah(_reference, -1) == null ||
                                    _loading
                                ? null
                                : () => _move(-1),
                            icon: const Icon(Icons.navigate_before),
                            label: Text(l.corpusPreviousAyah),
                          ),
                          OutlinedButton.icon(
                            onPressed:
                                adjacentCorpusAyah(_reference, 1) == null ||
                                    _loading
                                ? null
                                : () => _move(1),
                            icon: const Icon(Icons.navigate_next),
                            label: Text(l.corpusNextAyah),
                          ),
                          TextButton.icon(
                            onPressed: _loading ? null : _openReader,
                            icon: const Icon(Icons.menu_book),
                            label: Text('${l.openAyah} · ${_reference.key}'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (_loading)
                        const LinearProgressIndicator()
                      else if (_failed) ...[
                        Text(
                          l.corpusLoadFailed,
                          style: TextStyle(color: s.error),
                        ),
                        TextButton.icon(
                          onPressed: _load,
                          icon: const Icon(Icons.refresh),
                          label: Text(l.retry),
                        ),
                      ] else
                        Text(
                          '${l.corpusWord}: ${_words.length} · ${l.ayahSingular} ${_reference.key}',
                          style: Theme.of(c).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (!_loading && !_failed)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (c, i) => CorpusWordCard(word: _words[i]),
                      childCount: _words.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

AyahReference? adjacentCorpusAyah(AyahReference ref, int direction) {
  if (direction == -1) {
    if (ref.surah == 1 && ref.ayah == 1) return null;
    if (ref.ayah > 1) return AyahReference(ref.surah, ref.ayah - 1);
    return AyahReference(ref.surah - 1, hafsAyahCounts[ref.surah - 2]);
  }
  if (direction == 1) {
    if (ref.surah == 114 && ref.ayah == 6) return null;
    if (ref.ayah < hafsAyahCounts[ref.surah - 1]) {
      return AyahReference(ref.surah, ref.ayah + 1);
    }
    return AyahReference(ref.surah + 1, 1);
  }
  throw ArgumentError('Direction must be -1 or 1');
}

class CorpusWordCard extends StatelessWidget {
  const CorpusWordCard({required this.word, super.key});
  final CorpusWord word;
  @override
  Widget build(BuildContext c) {
    final l = AppLocalizations.of(c), s = Theme.of(c).colorScheme;
    return Card(
      semanticContainer: false,
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: s.primary.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${l.corpusWord} ${word.number}',
                    style: TextStyle(
                      color: s.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CorpusSelectableText(
                    word.arabic,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: 'hafs',
                      package: 'quran_library',
                      fontSize: 30,
                      height: 1.7,
                      color: s.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            for (final segment in word.segments)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: s.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: s.outline.withValues(alpha: .15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            '${l.corpusSegment} ${segment.segmentNumber}',
                            style: TextStyle(
                              color: s.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          CorpusSelectableText(
                            segment.arabic,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontFamily: 'hafs',
                              package: 'quran_library',
                              fontSize: 25,
                              height: 1.7,
                              color: s.onSurface,
                            ),
                          ),
                          Text(
                            '${l.corpusPartOfSpeech}: ${corpusPosLabel(l, segment.tag)} (${segment.tag})',
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        segment.codes.contains('PREFIX')
                            ? l.corpusPrefix
                            : segment.codes.contains('SUFFIX')
                            ? l.corpusSuffix
                            : segment.codes.contains('STEM')
                            ? l.corpusStem
                            : segment.codes.first,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      if (segment.root != null)
                        CorpusFeatureLine(
                          label: l.corpusRoot,
                          raw: segment.root!,
                          arabic: decodeCorpusForm(segment.root!),
                        ),
                      if (segment.lemma != null)
                        CorpusFeatureLine(
                          label: l.corpusLemma,
                          raw: segment.lemma!,
                          arabic: decodeCorpusForm(segment.lemma!),
                        ),
                      Text(
                        l.corpusOriginalForm,
                        style: TextStyle(
                          color: s.onSurface.withValues(alpha: .75),
                          fontSize: 12,
                        ),
                      ),
                      CorpusSelectableText(
                        segment.form,
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                        ),
                      ),
                      if (segment.form.isEmpty) Text(l.corpusEmptyForm),
                      const SizedBox(height: 8),
                      Text(
                        l.corpusOriginalCodes,
                        style: TextStyle(
                          color: s.onSurface.withValues(alpha: .75),
                          fontSize: 12,
                        ),
                      ),
                      CorpusSelectableText(
                        segment.features,
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CorpusFeatureLine extends StatelessWidget {
  const CorpusFeatureLine({
    required this.label,
    required this.raw,
    required this.arabic,
    super.key,
  });
  final String label, raw, arabic;
  @override
  Widget build(BuildContext c) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Wrap(
      spacing: 12,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text('$label:', style: const TextStyle(fontWeight: FontWeight.w700)),
        CorpusSelectableText(
          arabic,
          textDirection: TextDirection.rtl,
          style: const TextStyle(
            fontFamily: 'hafs',
            package: 'quran_library',
            fontSize: 22,
          ),
        ),
        CorpusSelectableText(
          raw,
          textDirection: TextDirection.ltr,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
        ),
      ],
    ),
  );
}

class CorpusSourceDialog extends StatefulWidget {
  const CorpusSourceDialog({
    required this.index,
    required this.repository,
    super.key,
  });
  final CorpusIndex index;
  final CorpusRepository repository;
  @override
  State<CorpusSourceDialog> createState() => _CorpusSourceDialogState();
}

class _CorpusSourceDialogState extends State<CorpusSourceDialog> {
  late Future<String> _license = widget.repository.licenseText();
  late final Future<String> _provenance = widget.repository.provenanceText();
  Future<void> _link(String url) async {
    if (!await openLearningSource(url)) {
      await Clipboard.setData(ClipboardData(text: url));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).corpusLinkCopied),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext c) {
    final l = AppLocalizations.of(c);
    return Dialog(
      child: SizedBox(
        width: 850,
        height: MediaQuery.sizeOf(c).height * .85,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l.corpusSource,
                      style: Theme.of(c).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: MaterialLocalizations.of(c).closeButtonLabel,
                    onPressed: () => Navigator.pop(c),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l.corpusSourceBody,
                      style: const TextStyle(height: 1.5),
                    ),
                    const SizedBox(height: 16),
                    for (final source in [
                      (
                        l.corpusSourceDownload,
                        'https://corpus.quran.com/download/',
                      ),
                      (
                        l.corpusTagsetDocs,
                        'https://corpus.quran.com/documentation/tagset.jsp',
                      ),
                      (
                        l.corpusFeaturesDocs,
                        'https://corpus.quran.com/documentation/morphologicalfeatures.jsp',
                      ),
                      (
                        l.corpusBuckwalterDocs,
                        'https://corpus.quran.com/java/buckwalter.jsp',
                      ),
                      (l.corpusTanzilSource, 'https://tanzil.info/updates/'),
                    ])
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: TextButton.icon(
                          onPressed: () => _link(source.$2),
                          icon: const Icon(Icons.open_in_new, size: 18),
                          label: Text(source.$1),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      l.corpusIdentity,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    const CorpusSelectableText(
                      'Quranic Arabic Corpus v0.4\nSHA256: $corpusSha256\n6,309,503 bytes · 6,236 Ayahs · 77,429 words · 128,219 segments',
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l.corpusAcquisition,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<String>(
                      future: _provenance,
                      builder: (c, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return const LinearProgressIndicator();
                        }
                        if (snapshot.hasError) return Text(l.corpusLoadFailed);
                        return CorpusSelectableText(
                          snapshot.data!,
                          textDirection: TextDirection.ltr,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            height: 1.6,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    CorpusSelectableText(
                      widget.index.notices,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l.corpusLicense,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    FutureBuilder<String>(
                      future: _license,
                      builder: (c, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return const LinearProgressIndicator();
                        }
                        if (snapshot.hasError) {
                          return Column(
                            children: [
                              Text(l.corpusLoadFailed),
                              TextButton(
                                onPressed: () => setState(
                                  () => _license = widget.repository
                                      .licenseText(),
                                ),
                                child: Text(l.retry),
                              ),
                            ],
                          );
                        }
                        return CorpusSelectableText(
                          snapshot.data!,
                          textDirection: TextDirection.ltr,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            height: 1.6,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
