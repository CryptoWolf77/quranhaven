import 'package:flutter/material.dart';
import 'package:quran_library/quran_library.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/personal_repository.dart';
import '../domain/personal_models.dart';
import '../domain/saved_text_search.dart';

AyahModel resolvePersonalAyah(AyahReference r) =>
    QuranCtrl.instance.getAyahByUq(
      QuranCtrl.instance.resolveAyahUq(
        surahNumber: r.surah,
        ayahNumber: r.ayah,
      ),
    );
AyahReference referenceForAyah(AyahModel a) => AyahReference(
  QuranCtrl.instance.getSurahDataByAyah(a).surahNumber,
  a.ayahNumber,
);
void personalMessage(BuildContext c, String text) {
  if (c.mounted) {
    ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(text)));
  }
}

Future<bool> confirmPersonalDelete(BuildContext context) async =>
    await showDialog<bool>(
      context: context,
      builder: (c) {
        final l = AppLocalizations.of(c);
        return AlertDialog(
          title: Text(l.delete),
          content: Text(l.deletePersonalConfirm),
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
        );
      },
    ) ??
    false;

class PersonalToolsPage extends StatefulWidget {
  const PersonalToolsPage({
    required this.onOpenAyah,
    this.repository,
    super.key,
  });
  final ValueChanged<AyahReference> onOpenAyah;
  final PersonalRepository? repository;
  @override
  State<PersonalToolsPage> createState() => _PersonalToolsPageState();
}

class _PersonalToolsPageState extends State<PersonalToolsPage> {
  late final _repo = widget.repository ?? PersonalRepository();
  PersonalData _data = const PersonalData();
  bool _loading = true, _failed = false, _saving = false;
  int _tab = 0;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final d = await _repo.load();
      if (mounted) setState(() => _data = d);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save(PersonalData next) async {
    if (_saving || _failed) return;
    setState(() => _saving = true);
    try {
      await _repo.save(next);
      if (mounted) {
        setState(() => _data = next);
        personalMessage(context, AppLocalizations.of(context).personalSaved);
      }
    } catch (_) {
      if (mounted) {
        personalMessage(context, AppLocalizations.of(context).localSaveFailed);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _note([AyahNote? existing]) async {
    if (existing == null && _data.notes.length >= 2000) {
      personalMessage(context, AppLocalizations.of(context).personalLimit);
      return;
    }
    final result = await showNoteEditor(context, note: existing);
    if (result != null) {
      await _save(
        _data.copyWith(
          notes: [
            for (final n in _data.notes)
              if (n.id != result.id) n,
            result,
          ],
        ),
      );
    }
  }

  Future<void> _collection([AyahCollection? existing]) async {
    if (existing == null && _data.collections.length >= 100) {
      personalMessage(context, AppLocalizations.of(context).personalLimit);
      return;
    }
    final name = await showCollectionName(context, initial: existing?.name);
    if (name == null) return;
    final next = AyahCollection(
      id: existing?.id ?? PersonalData.newId(),
      name: name,
      ayahs: existing?.ayahs ?? [],
    );
    await _save(
      _data.copyWith(
        collections: [
          for (final c in _data.collections)
            if (c.id != next.id) c,
          next,
        ],
      ),
    );
  }

  PersonalData _replace(AyahCollection next) => _data.copyWith(
    collections: [
      for (final c in _data.collections) c.id == next.id ? next : c,
    ],
  );
  Future<void> _add(AyahCollection c) async {
    final ref = await showDialog<AyahReference>(
      context: context,
      builder: (_) => const _AyahPickerDialog(),
    );
    if (ref == null || !mounted) return;
    if (c.ayahs.any((a) => a.key == ref.key)) {
      personalMessage(context, AppLocalizations.of(context).personalDuplicate);
      return;
    }
    await _save(
      _replace(
        AyahCollection(id: c.id, name: c.name, ayahs: [...c.ayahs, ref]),
      ),
    );
  }

  void _open(AyahReference r) {
    Navigator.pop(context);
    widget.onOpenAyah(r);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context), s = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(l.personalTools)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1040),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                l.personalToolsBody,
                style: TextStyle(
                  color: s.onSurface.withValues(alpha: .75),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              SegmentedButton<int>(
                segments: [
                  ButtonSegment(
                    value: 0,
                    icon: const Icon(Icons.edit_note),
                    label: Text(l.personalNotes),
                  ),
                  ButtonSegment(
                    value: 1,
                    icon: const Icon(Icons.folder_outlined),
                    label: Text(l.personalCollections),
                  ),
                ],
                selected: {_tab},
                onSelectionChanged: (v) => setState(() => _tab = v.first),
              ),
              const SizedBox(height: 20),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else if (_failed) ...[
                Text(l.localLoadFailed),
                TextButton.icon(
                  onPressed: _load,
                  icon: const Icon(Icons.refresh),
                  label: Text(l.retry),
                ),
              ] else ...[
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: FilledButton.icon(
                    onPressed: _saving
                        ? null
                        : () => _tab == 0 ? _note() : _collection(),
                    icon: Icon(
                      _tab == 0
                          ? Icons.note_add_outlined
                          : Icons.create_new_folder_outlined,
                    ),
                    label: Text(_tab == 0 ? l.addNote : l.createCollection),
                  ),
                ),
                const SizedBox(height: 18),
                if (_saving) const LinearProgressIndicator(),
                if (_tab == 0 && _data.notes.isEmpty)
                  _EmptyPanel(icon: Icons.edit_note, text: l.notesEmpty),
                if (_tab == 1 && _data.collections.isEmpty)
                  _EmptyPanel(
                    icon: Icons.folder_outlined,
                    text: l.collectionsEmpty,
                  ),
                if (_tab == 0)
                  for (final n in _data.notes.reversed)
                    Card(
                      semanticContainer: false,
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    n.title.isEmpty
                                        ? '${l.ayahSingular} ${n.reference.key}'
                                        : n.title,
                                    textDirection: isRtlResourceText(n.title)
                                        ? TextDirection.rtl
                                        : TextDirection.ltr,
                                    textAlign: isRtlResourceText(n.title)
                                        ? TextAlign.right
                                        : TextAlign.left,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                ),
                                IconButton(
                                  tooltip: l.editNote,
                                  onPressed: _saving ? null : () => _note(n),
                                  icon: const Icon(Icons.edit_outlined),
                                ),
                                IconButton(
                                  tooltip: l.delete,
                                  onPressed: _saving
                                      ? null
                                      : () async {
                                          if (await confirmPersonalDelete(
                                            context,
                                          )) {
                                            await _save(
                                              _data.copyWith(
                                                notes: _data.notes
                                                    .where((v) => v.id != n.id)
                                                    .toList(),
                                              ),
                                            );
                                          }
                                        },
                                  icon: const Icon(Icons.delete_outline),
                                ),
                              ],
                            ),
                            Text(
                              n.body,
                              textDirection: isRtlResourceText(n.body)
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                              textAlign: isRtlResourceText(n.body)
                                  ? TextAlign.right
                                  : TextAlign.left,
                              style: const TextStyle(height: 1.6),
                            ),
                            const SizedBox(height: 10),
                            TextButton.icon(
                              onPressed: () => _open(n.reference),
                              icon: const Icon(Icons.menu_book),
                              label: Text('${l.openAyah} · ${n.reference.key}'),
                            ),
                          ],
                        ),
                      ),
                    ),
                if (_tab == 1)
                  for (final c in _data.collections)
                    Card(
                      semanticContainer: false,
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    c.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                ),
                                IconButton(
                                  tooltip: l.editCollection,
                                  onPressed: _saving
                                      ? null
                                      : () => _collection(c),
                                  icon: const Icon(Icons.edit_outlined),
                                ),
                                IconButton(
                                  tooltip: l.delete,
                                  onPressed: _saving
                                      ? null
                                      : () async {
                                          if (await confirmPersonalDelete(
                                            context,
                                          )) {
                                            await _save(
                                              _data.copyWith(
                                                collections: _data.collections
                                                    .where((v) => v.id != c.id)
                                                    .toList(),
                                              ),
                                            );
                                          }
                                        },
                                  icon: const Icon(Icons.delete_outline),
                                ),
                              ],
                            ),
                            if (c.ayahs.isEmpty) Text(l.collectionEmpty),
                            for (final r in c.ayahs)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text('${l.ayahSingular} ${r.key}'),
                                subtitle: Text(
                                  resolvePersonalAyah(r).ayaTextEmlaey,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textDirection: TextDirection.rtl,
                                ),
                                onTap: () => _open(r),
                                trailing: IconButton(
                                  tooltip: l.removeAyah,
                                  onPressed: _saving
                                      ? null
                                      : () async {
                                          if (await confirmPersonalDelete(
                                            context,
                                          )) {
                                            await _save(
                                              _replace(
                                                AyahCollection(
                                                  id: c.id,
                                                  name: c.name,
                                                  ayahs: c.ayahs
                                                      .where(
                                                        (a) => a.key != r.key,
                                                      )
                                                      .toList(),
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                  icon: const Icon(Icons.remove_circle_outline),
                                ),
                              ),
                            TextButton.icon(
                              onPressed: _saving ? null : () => _add(c),
                              icon: const Icon(Icons.add),
                              label: Text(l.addAyah),
                            ),
                          ],
                        ),
                      ),
                    ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext c) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Theme.of(c).colorScheme.primary.withValues(alpha: .06),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 30, color: Theme.of(c).colorScheme.primary),
        const SizedBox(width: 16),
        Expanded(child: Text(text, style: const TextStyle(height: 1.5))),
      ],
    ),
  );
}

Future<String?> showCollectionName(BuildContext context, {String? initial}) =>
    showDialog<String>(
      context: context,
      builder: (_) => _CollectionNameDialog(initial: initial),
    );

class _CollectionNameDialog extends StatefulWidget {
  const _CollectionNameDialog({this.initial});
  final String? initial;
  @override
  State<_CollectionNameDialog> createState() => _CollectionNameDialogState();
}

class _CollectionNameDialogState extends State<_CollectionNameDialog> {
  late final controller = TextEditingController(text: widget.initial);
  final key = GlobalKey<FormState>();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) {
    final l = AppLocalizations.of(c);
    return AlertDialog(
      title: Text(
        widget.initial == null ? l.createCollection : l.editCollection,
      ),
      content: Form(
        key: key,
        child: TextFormField(
          controller: controller,
          autofocus: true,
          maxLength: 80,
          decoration: InputDecoration(labelText: l.collectionName),
          validator: (v) =>
              v == null || v.trim().isEmpty ? l.requiredText : null,
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: Text(l.cancel)),
        FilledButton(
          onPressed: () {
            if (key.currentState!.validate()) {
              Navigator.pop(c, controller.text.trim());
            }
          },
          child: Text(l.save),
        ),
      ],
    );
  }
}

Future<AyahNote?> showNoteEditor(
  BuildContext c, {
  AyahNote? note,
  AyahReference? reference,
}) => showDialog<AyahNote>(
  context: c,
  builder: (_) => _NoteEditor(note: note, reference: reference),
);

class _NoteEditor extends StatefulWidget {
  const _NoteEditor({this.note, this.reference});
  final AyahNote? note;
  final AyahReference? reference;
  @override
  State<_NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<_NoteEditor> {
  late final _title = TextEditingController(text: widget.note?.title),
      _body = TextEditingController(text: widget.note?.body);
  late AyahReference _reference =
      widget.note?.reference ?? widget.reference ?? const AyahReference(1, 1);
  final _form = GlobalKey<FormState>();
  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) {
    final l = AppLocalizations.of(c);
    return AlertDialog(
      title: Text(widget.note == null ? l.addNote : l.editNote),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Form(
            key: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.reference == null)
                  AyahPicker(
                    initial: _reference,
                    onChanged: (r) => _reference = r,
                  )
                else
                  Text('${l.ayahSingular} ${_reference.key}'),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _title,
                  textDirection: isRtlResourceText(_title.text)
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  onChanged: (_) => setState(() {}),
                  maxLength: 120,
                  decoration: InputDecoration(labelText: l.noteTitle),
                ),
                TextFormField(
                  controller: _body,
                  textDirection: isRtlResourceText(_body.text)
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  onChanged: (_) => setState(() {}),
                  maxLines: 6,
                  minLines: 3,
                  maxLength: 10000,
                  decoration: InputDecoration(labelText: l.noteBody),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? l.requiredText : null,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: Text(l.cancel)),
        FilledButton(
          onPressed: () {
            if (_form.currentState!.validate()) {
              Navigator.pop(
                c,
                AyahNote(
                  id: widget.note?.id ?? PersonalData.newId(),
                  reference: _reference,
                  title: _title.text.trim(),
                  body: _body.text.trim(),
                  updatedAt: DateTime.now(),
                ),
              );
            }
          },
          child: Text(l.save),
        ),
      ],
    );
  }
}

class AyahPicker extends StatefulWidget {
  const AyahPicker({required this.initial, required this.onChanged, super.key});
  final AyahReference initial;
  final ValueChanged<AyahReference> onChanged;
  @override
  State<AyahPicker> createState() => _AyahPickerState();
}

class _AyahPickerState extends State<AyahPicker> {
  late int _surah = widget.initial.surah, _ayah = widget.initial.ayah;
  @override
  Widget build(BuildContext c) {
    final l = AppLocalizations.of(c),
        names = QuranLibrary.getAllSurahs(
          isArabic: Localizations.localeOf(c).languageCode == 'ar',
        );
    return Column(
      children: [
        DropdownButtonFormField<int>(
          initialValue: _surah,
          isExpanded: true,
          decoration: InputDecoration(labelText: l.chooseSurah),
          items: [
            for (var i = 0; i < names.length; i++)
              DropdownMenuItem(
                value: i + 1,
                child: Text('${i + 1}. ${names[i]}'),
              ),
          ],
          onChanged: (s) {
            if (s != null) {
              setState(() {
                _surah = s;
                _ayah = 1;
              });
              widget.onChanged(AyahReference(_surah, _ayah));
            }
          },
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<int>(
          key: ValueKey(_surah),
          initialValue: _ayah,
          isExpanded: true,
          decoration: InputDecoration(labelText: l.ayahSingular),
          items: [
            for (var i = 1; i <= hafsAyahCounts[_surah - 1]; i++)
              DropdownMenuItem(value: i, child: Text('$i')),
          ],
          onChanged: (a) {
            if (a != null) {
              setState(() => _ayah = a);
              widget.onChanged(AyahReference(_surah, _ayah));
            }
          },
        ),
      ],
    );
  }
}

class _AyahPickerDialog extends StatefulWidget {
  const _AyahPickerDialog();
  @override
  State<_AyahPickerDialog> createState() => _AyahPickerDialogState();
}

class _AyahPickerDialogState extends State<_AyahPickerDialog> {
  AyahReference _ref = const AyahReference(1, 1);
  @override
  Widget build(BuildContext c) {
    final l = AppLocalizations.of(c);
    return AlertDialog(
      title: Text(l.addAyah),
      content: AyahPicker(initial: _ref, onChanged: (r) => _ref = r),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: Text(l.cancel)),
        FilledButton(
          onPressed: () => Navigator.pop(c, _ref),
          child: Text(l.save),
        ),
      ],
    );
  }
}

Future<void> addPersonalNote(BuildContext c, AyahReference ref) async {
  final repo = PersonalRepository(), l = AppLocalizations.of(c);
  try {
    final data = await repo.load();
    if (!c.mounted) return;
    if (data.notes.length >= 2000) throw StateError('Limit');
    final note = await showNoteEditor(c, reference: ref);
    if (note == null) return;
    await repo.save(data.copyWith(notes: [...data.notes, note]));
    if (c.mounted) personalMessage(c, l.personalSaved);
  } catch (_) {
    if (c.mounted) personalMessage(c, l.localSaveFailed);
  }
}

Future<void> addPersonalCollectionAyah(
  BuildContext c,
  AyahReference ref,
) async {
  final repo = PersonalRepository(), l = AppLocalizations.of(c);
  try {
    var data = await repo.load();
    if (!c.mounted) return;
    final selected = await showDialog<String>(
      context: c,
      builder: (d) => AlertDialog(
        title: Text(l.addToCollection),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final item in data.collections)
                  ListTile(
                    title: Text(item.name),
                    onTap: () => Navigator.pop(d, item.id),
                  ),
                TextButton.icon(
                  onPressed: () => Navigator.pop(d, '__new__'),
                  icon: const Icon(Icons.add),
                  label: Text(l.createCollection),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d), child: Text(l.cancel)),
        ],
      ),
    );
    if (selected == null || !c.mounted) return;
    String id = selected;
    if (selected == '__new__') {
      if (data.collections.length >= 100) throw StateError('Limit');
      final name = await showCollectionName(c);
      if (name == null) return;
      id = PersonalData.newId();
      data = data.copyWith(
        collections: [
          ...data.collections,
          AyahCollection(id: id, name: name, ayahs: []),
        ],
      );
    }
    final existing = data.collections.singleWhere((e) => e.id == id);
    if (existing.ayahs.any((r) => r.key == ref.key)) {
      if (c.mounted) personalMessage(c, l.personalDuplicate);
      return;
    }
    await repo.save(
      data.copyWith(
        collections: [
          for (final item in data.collections)
            item.id == id
                ? AyahCollection(
                    id: id,
                    name: item.name,
                    ayahs: [...item.ayahs, ref],
                  )
                : item,
        ],
      ),
    );
    if (c.mounted) personalMessage(c, l.personalSaved);
  } catch (_) {
    if (c.mounted) personalMessage(c, l.localSaveFailed);
  }
}
