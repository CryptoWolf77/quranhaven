import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../../reminders/data/reminder_service.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/backup_repository.dart';
import '../data/local_files.dart';
import '../data/local_restore_lifecycle.dart';
import '../domain/local_backup.dart';

class BackupCard extends StatefulWidget {
  const BackupCard({super.key});
  @override
  State<BackupCard> createState() => _BackupCardState();
}

class _BackupCardState extends State<BackupCard> {
  final _repository = BackupRepository();
  bool _busy = false;
  void _message(String text) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    }
  }

  Future<void> _export() async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final data = await _repository.export();
      await _saveFile(data, 'quran-haven-backup');
      if (!supportsLocalFiles) _message(l.backupCopied);
    } catch (_) {
      _message(l.backupFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _saveFile(LocalBackup data, String prefix) async {
    final text = data.encode();
    if (supportsLocalFiles) {
      if (!mounted) return false;
      final box = context.findRenderObject() as RenderBox?;
      final origin = box == null
          ? null
          : (box.localToGlobal(Offset.zero) & box.size).intersect(
              Offset.zero & MediaQuery.sizeOf(context),
            );
      return downloadLocalFile(
        Uint8List.fromList(utf8.encode(text)),
        '$prefix-${DateTime.now().toIso8601String().substring(0, 10)}.json',
        'application/json',
        origin: origin,
      );
    } else {
      await Clipboard.setData(ClipboardData(text: text));
      return true;
    }
  }

  Future<void> _choose({bool paste = false}) async {
    if (!supportsLocalFiles) return;
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      String? text;
      if (!paste && supportsLocalFiles) {
        text = await chooseBackupFile();
      } else {
        if (!mounted) return;
        text = await showDialog<String>(
          context: context,
          builder: (_) => const _PasteBackupDialog(),
        );
      }
      if (text == null || !mounted) return;
      final document = LocalBackup.decode(text);
      final current = await _repository
          .export(); // Snapshot exists before confirmation.
      if (!mounted) return;
      final restore = await showDialog<bool>(
        context: context,
        builder: (_) => _BackupPreview(
          document: document,
          onSafetyCopy: () => _saveFile(current, 'quran-haven-safety-copy'),
        ),
      );
      if (restore != true || !mounted) return;
      await LocalRestoreLifecycle.prepare();
      await _repository.restore(document);
      // Reminder preferences are already disabled by the validated transaction.
      // A platform notification service failure must not misreport a successful
      // restore as rolled back.
      try {
        await ReminderService().cancelDaily();
      } catch (_) {}
      if (!mounted) return;
      final shouldReload = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const BackupRestoredDialog(isWeb: kIsWeb),
      );
      if (!kIsWeb || shouldReload == true) {
        try {
          await reloadAfterRestore();
        } catch (_) {
          _message(l.backupRefreshFailed);
        }
      }
    } on FormatException {
      _message(l.backupInvalid);
    } catch (error) {
      _message(
        error is StateError &&
                error.message.toString().contains('rollback failed')
            ? l.backupRecoveryFailed
            : l.backupFailed,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext c) {
    final l = AppLocalizations.of(c), s = Theme.of(c).colorScheme;
    return Card(
      semanticContainer: false,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.save_alt_rounded, color: s.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l.backupTitle,
                    style: Theme.of(c).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(l.backupBody, style: const TextStyle(height: 1.5)),
            if (!supportsLocalFiles) ...[
              const SizedBox(height: 10),
              Text(l.backupNativeHint),
            ],
            const SizedBox(height: 16),
            if (_busy) const LinearProgressIndicator(),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: _busy ? null : _export,
                  icon: const Icon(Icons.download_outlined),
                  label: Text(l.exportBackup),
                ),
                if (supportsLocalFiles)
                  OutlinedButton.icon(
                    onPressed: _busy ? null : () => _choose(),
                    icon: const Icon(Icons.upload_file_outlined),
                    label: Text(l.chooseBackup),
                  ),
                if (supportsLocalFiles)
                  TextButton(
                    onPressed: _busy ? null : () => _choose(paste: true),
                    child: Text(l.pasteBackup),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Completion copy follows the host's existing restore refresh behavior.
class BackupRestoredDialog extends StatelessWidget {
  const BackupRestoredDialog({super.key, required this.isWeb});

  final bool isWeb;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.backupTitle),
      content: Text(isWeb ? l.backupRestored : l.backupRestoredNative),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(MaterialLocalizations.of(context).closeButtonLabel),
        ),
        if (isWeb)
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.reloadApp),
          ),
      ],
    );
  }
}

class _PasteBackupDialog extends StatefulWidget {
  const _PasteBackupDialog();
  @override
  State<_PasteBackupDialog> createState() => _PasteBackupDialogState();
}

class _PasteBackupDialogState extends State<_PasteBackupDialog> {
  final _text = TextEditingController();
  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) {
    final l = AppLocalizations.of(c);
    return AlertDialog(
      title: Text(l.pasteBackup),
      content: SizedBox(
        width: 600,
        child: TextField(
          controller: _text,
          maxLines: 10,
          maxLength: LocalBackup.maxBytes,
          decoration: const InputDecoration(
            hintText: '{ "format": "Quran Haven local backup", … }',
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: Text(l.cancel)),
        FilledButton(
          onPressed: () => Navigator.pop(c, _text.text),
          child: Text(l.previewBackup),
        ),
      ],
    );
  }
}

class _BackupPreview extends StatefulWidget {
  const _BackupPreview({required this.document, required this.onSafetyCopy});
  final LocalBackup document;
  final Future<bool> Function() onSafetyCopy;
  @override
  State<_BackupPreview> createState() => _BackupPreviewState();
}

class _BackupPreviewState extends State<_BackupPreview> {
  bool _safe = false, _busy = false, _copyRequested = false;
  @override
  Widget build(BuildContext c) {
    final l = AppLocalizations.of(c), d = widget.document;
    return AlertDialog(
      title: Text(l.backupPreviewTitle),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${l.backupCreated}: ${d.createdAt.toLocal().toIso8601String().substring(0, 10)}',
              ),
              const SizedBox(height: 14),
              for (final row in [
                (l.personalNotes, d.personal.notes.length),
                (l.personalCollections, d.personal.collections.length),
                (l.bookmarks, d.bookmarks.length),
                (l.plans, d.memorization.length + (d.khatmah == null ? 0 : 1)),
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(child: Text(row.$1)),
                      Text(
                        '${row.$2}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              const Divider(),
              Text(l.backupReplaceWarning, style: const TextStyle(height: 1.5)),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: _busy
                    ? null
                    : () async {
                        setState(() => _busy = true);
                        try {
                          final completed = await widget.onSafetyCopy();
                          if (mounted) {
                            setState(() {
                              _copyRequested = completed;
                              _safe = completed && !localFilesUseShareSheet;
                            });
                          }
                        } catch (_) {
                          if (c.mounted) {
                            ScaffoldMessenger.of(c).showSnackBar(
                              SnackBar(content: Text(l.backupFailed)),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => _busy = false);
                        }
                      },
                icon: Icon(_safe ? Icons.check_circle_outline : Icons.download),
                label: Text(l.backupSafetyCopy),
              ),
              if (_safe) Text(l.backupSafetyReady),
              if (localFilesUseShareSheet)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _safe,
                  onChanged: _copyRequested && !_busy
                      ? (value) => setState(() => _safe = value == true)
                      : null,
                  title: Text(l.backupSafetyConfirm),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(c, false),
          child: Text(l.cancel),
        ),
        FilledButton(
          onPressed: _safe && !_busy ? () => Navigator.pop(c, true) : null,
          child: Text(l.restoreBackup),
        ),
      ],
    );
  }
}
