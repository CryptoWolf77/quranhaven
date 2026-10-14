import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:quran_library/quran_library.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/local_files.dart';
import '../domain/personal_models.dart';
import '../domain/saved_text_search.dart';
import 'personal_tools_page.dart';

class ShareAyahPage extends StatefulWidget {
  const ShareAyahPage({required this.reference, super.key});
  final AyahReference reference;
  @override
  State<ShareAyahPage> createState() => _ShareAyahPageState();
}

class _ShareAyahPageState extends State<ShareAyahPage> {
  final _capture = GlobalKey();
  List<int> _translations = [];
  int _translation = -1;
  String? _text, _source;
  bool _loading = true, _saving = false;
  static Future<void>? _fontReady;
  AyahModel get _ayah => resolvePersonalAyah(widget.reference);
  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    try {
      _fontReady ??=
          (FontLoader('packages/quran_library/hafs')..addFont(
                rootBundle.load(
                  'packages/quran_library/assets/fonts/UthmanicHafs_V20.ttf',
                ),
              ))
              .load();
      await _fontReady;
      await QuranLibrary().refreshTafsirDownloads();
      final resources = QuranLibrary().tafsirAndTraslationsCollection;
      if (mounted) {
        setState(
          () => _translations = [
            for (var i = 0; i < resources.length; i++)
              if (!resources[i].isCommentary &&
                  !resources[i].isCustom &&
                  QuranLibrary().getTafsirDownloaded(i))
                i,
          ],
        );
      }
    } catch (_) {
      if (mounted) {
        personalMessage(context, AppLocalizations.of(context).searchLoadFailed);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _choose(int value) async {
    setState(() {
      _translation = value;
      _text = null;
      _source = null;
      _loading = value >= 0;
    });
    if (value < 0) return;
    try {
      final entries = parseSavedBook(
        await TafsirCtrl.instance.readSavedResourceText(value),
      );
      final item = entries
          .where((e) => e.reference.key == widget.reference.key)
          .firstOrNull;
      final r = QuranLibrary().tafsirAndTraslationsCollection[value];
      if (item == null) throw StateError('Missing text');
      if (mounted) {
        setState(() {
          _text = item.text;
          _source = '${r.name} · ${r.bookName}'.trim();
        });
      }
    } catch (_) {
      if (mounted) {
        personalMessage(context, AppLocalizations.of(context).searchLoadFailed);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String get _shareText =>
      '${_ayah.text.trim()}\n\n${_ayah.arabicName ?? QuranCtrl.instance.getSurahDataByAyah(_ayah).arabicName} ${widget.reference.key}${_text == null ? '' : '\n\n$_text\n$_source'}\n\n${widget.reference.publicLink}';
  Future<void> _copy(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) {
        personalMessage(context, AppLocalizations.of(context).shareCopied);
      }
    } catch (_) {
      if (mounted) {
        personalMessage(context, AppLocalizations.of(context).shareFailed);
      }
    }
  }

  Future<void> _image() async {
    final box = context.findRenderObject() as RenderBox?;
    final origin = box == null
        ? null
        : (box.localToGlobal(Offset.zero) & box.size).intersect(
            Offset.zero & MediaQuery.sizeOf(context),
          );
    setState(() => _saving = true);
    try {
      await _fontReady;
      await WidgetsBinding.instance.endOfFrame;
      final boundary =
          _capture.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2);
      try {
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        if (bytes == null) throw StateError('Image unavailable');
        await downloadLocalFile(
          bytes.buffer.asUint8List(),
          'ayah-${widget.reference.surah}-${widget.reference.ayah}.png',
          'image/png',
          origin: origin,
        );
      } finally {
        image.dispose();
      }
    } catch (_) {
      if (mounted) {
        personalMessage(context, AppLocalizations.of(context).shareFailed);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext c) {
    final l = AppLocalizations.of(c),
        r = QuranLibrary().tafsirAndTraslationsCollection,
        s = Theme.of(c).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(l.shareAyah)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(l.shareBody, style: const TextStyle(height: 1.5)),
              const SizedBox(height: 20),
              DropdownButtonFormField<int>(
                initialValue: _translation,
                isExpanded: true,
                decoration: InputDecoration(labelText: l.includeTranslation),
                items: [
                  DropdownMenuItem(
                    value: -1,
                    child: Text(l.withoutTranslation),
                  ),
                  for (final i in _translations)
                    DropdownMenuItem(
                      value: i,
                      child: Text(
                        '${r[i].name} · ${r[i].bookName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: _loading || _saving
                    ? null
                    : (v) {
                        if (v != null) _choose(v);
                      },
              ),
              const SizedBox(height: 18),
              if (_loading) const LinearProgressIndicator(),
              if (!_loading)
                RepaintBoundary(
                  key: _capture,
                  child: AyahShareCard(
                    ayahText: _ayah.text.trim(),
                    reference: widget.reference,
                    surahName: QuranCtrl.instance
                        .getSurahDataByAyah(_ayah)
                        .arabicName,
                    translation: _text,
                    translationSource: _source,
                    sourceLabel: _text == null
                        ? l.shareArabicSource
                        : l.shareSource,
                  ),
                ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  if (supportsLocalFiles)
                    FilledButton.icon(
                      onPressed: _loading || _saving ? null : _image,
                      icon: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.image_outlined),
                      label: Text(
                        kIsWeb
                            ? l.downloadAyahImage
                            : localFilesUseShareSheet
                            ? l.guideNativeShareImage
                            : l.guideNativeSaveImage,
                      ),
                    ),
                  OutlinedButton.icon(
                    onPressed: _loading ? null : () => _copy(_shareText),
                    icon: const Icon(Icons.copy),
                    label: Text(l.copyShareText),
                  ),
                  TextButton.icon(
                    onPressed: () =>
                        _copy(widget.reference.publicLink.toString()),
                    icon: const Icon(Icons.link),
                    label: Text(l.copyAyahLink),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                widget.reference.publicLink.toString(),
                style: TextStyle(color: s.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Every character is laid out naturally. No maxLines/ellipsis on the image.
class AyahShareCard extends StatelessWidget {
  const AyahShareCard({
    required this.ayahText,
    required this.reference,
    required this.surahName,
    required this.sourceLabel,
    this.translation,
    this.translationSource,
    super.key,
  });
  final String ayahText, surahName, sourceLabel;
  final AyahReference reference;
  final String? translation, translationSource;
  @override
  Widget build(BuildContext c) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: const Color(0xFFF9F5EA),
      border: Border.all(color: const Color(0xFFD8C995), width: 2),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '$surahName · ${reference.key}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF214E41),
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          ayahText,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'hafs',
            package: 'quran_library',
            fontSize: 28,
            height: 1.9,
            color: Color(0xFF132D24),
          ),
        ),
        if (translation != null) ...[
          const SizedBox(height: 24),
          const Divider(color: Color(0xFFD8C995)),
          Text(
            translation!,
            textDirection: isRtlResourceText(translation!)
                ? TextDirection.rtl
                : TextDirection.ltr,
            textAlign: isRtlResourceText(translation!)
                ? TextAlign.right
                : TextAlign.left,
            style: const TextStyle(
              color: Color(0xFF273B33),
              height: 1.6,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            translationSource ?? '',
            style: const TextStyle(color: Color(0xFF486458), fontSize: 12),
          ),
        ],
        const SizedBox(height: 24),
        Text(
          sourceLabel,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF486458),
            fontSize: 11,
            height: 1.5,
          ),
        ),
      ],
    ),
  );
}
