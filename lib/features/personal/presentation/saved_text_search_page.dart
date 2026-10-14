import 'package:flutter/material.dart';
import 'package:quran_library/quran_library.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/personal_models.dart';
import '../domain/saved_text_search.dart';

class SavedTextSearchPage extends StatefulWidget {
  const SavedTextSearchPage({required this.onOpenAyah, super.key});
  final ValueChanged<AyahReference> onOpenAyah;
  @override
  State<SavedTextSearchPage> createState() => _SavedTextSearchPageState();
}

class _SavedTextSearchPageState extends State<SavedTextSearchPage> {
  final _query = TextEditingController();
  List<int> _books = [];
  int? _book;
  bool _loading = true;
  String? _error;
  List<SavedTextEntry> _results = [];
  int _page = 0;
  bool _searched = false;
  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _loadBooks() async {
    try {
      await QuranLibrary().refreshTafsirDownloads();
      final all = QuranLibrary().tafsirAndTraslationsCollection;
      final books = [
        for (var i = 0; i < all.length; i++)
          if (!all[i].isCustom && QuranLibrary().getTafsirDownloaded(i)) i,
      ];
      if (mounted) {
        setState(() {
          _books = books;
          _book = books.firstOrNull;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = AppLocalizations.of(context).searchLoadFailed);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _search() async {
    final l = AppLocalizations.of(context);
    if (normalizeSearch(_query.text).length < 2) {
      setState(() => _error = l.searchMinimum);
      return;
    }
    if (_book == null) return;
    setState(() {
      _loading = true;
      _error = null;
      _searched = false;
    });
    try {
      final raw = await TafsirCtrl.instance.readSavedResourceText(_book!);
      final corpus = parseSavedBook(raw);
      final found = searchSavedBook(corpus, _query.text);
      if (mounted) {
        setState(() {
          _results = found;
          _page = 0;
          _searched = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _error = l.searchLoadFailed);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext c) {
    final l = AppLocalizations.of(c),
        all = QuranLibrary().tafsirAndTraslationsCollection,
        s = Theme.of(c).colorScheme;
    final start = _page * 40, end = (start + 40).clamp(0, _results.length);
    return Scaffold(
      appBar: AppBar(title: Text(l.savedTextSearch)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(l.savedTextSearchBody, style: const TextStyle(height: 1.5)),
              const SizedBox(height: 10),
              Text(l.searchSavedOnly, style: TextStyle(color: s.primary)),
              const SizedBox(height: 22),
              if (_books.isNotEmpty)
                DropdownButtonFormField<int>(
                  initialValue: _book,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: l.searchBook),
                  items: [
                    for (final i in _books)
                      DropdownMenuItem(
                        value: i,
                        child: Text(
                          '${all[i].name} · ${all[i].bookName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: _loading
                      ? null
                      : (v) => setState(() {
                          _book = v;
                          _results = [];
                          _searched = false;
                          _error = null;
                        }),
                ),
              const SizedBox(height: 16),
              TextField(
                controller: _query,
                maxLength: 200,
                decoration: InputDecoration(
                  labelText: l.searchPhrase,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onSubmitted: (_) => _loading ? null : _search(),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: FilledButton.icon(
                  onPressed: _loading || _book == null ? null : _search,
                  icon: const Icon(Icons.search),
                  label: Text(l.search),
                ),
              ),
              const SizedBox(height: 20),
              if (_loading) const LinearProgressIndicator(),
              if (_error != null)
                Text(_error!, style: TextStyle(color: s.error)),
              if (_searched) ...[
                Text(
                  '${l.searchResults}: ${_results.length}',
                  style: Theme.of(c).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                if (_results.isEmpty) Text(l.searchNoResults),
                for (final result in _results.sublist(start, end))
                  Card(
                    semanticContainer: false,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${l.ayahSingular} ${result.reference.key}',
                            style: TextStyle(
                              color: s.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            result.text,
                            textDirection: isRtlResourceText(result.text)
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            textAlign: isRtlResourceText(result.text)
                                ? TextAlign.right
                                : TextAlign.left,
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(height: 1.5),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.pop(c);
                              widget.onOpenAyah(result.reference);
                            },
                            icon: const Icon(Icons.menu_book),
                            label: Text(
                              '${l.openAyah} · ${result.reference.key}',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (_results.isNotEmpty)
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: _page > 0
                            ? () => setState(() => _page--)
                            : null,
                        child: Text(l.previousResults),
                      ),
                      Text('${start + 1}–$end / ${_results.length}'),
                      OutlinedButton(
                        onPressed: end < _results.length
                            ? () => setState(() => _page++)
                            : null,
                        child: Text(l.nextResults),
                      ),
                    ],
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
