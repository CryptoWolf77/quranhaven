import 'dart:async';

import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../data/offline_service.dart';
import '../domain/offline_status.dart';

class OfflineCard extends StatefulWidget {
  const OfflineCard({this.service, super.key});

  final OfflineService? service;

  @override
  State<OfflineCard> createState() => _OfflineCardState();
}

class _OfflineCardState extends State<OfflineCard> {
  late final OfflineService _service;
  StreamSubscription<OfflineStatus>? _subscription;
  OfflineStatus _status = const OfflineStatus();
  bool _loading = true;
  bool _cancelling = false;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? OfflineService();
    _subscription = _service.changes.listen(_update);
    _run(_service.status);
  }

  void _update(OfflineStatus value) {
    if (mounted) setState(() => _status = value);
  }

  Future<void> _run(Future<OfflineStatus> Function() action) async {
    setState(() => _loading = true);
    try {
      _update(await action());
    } catch (_) {
      _update(const OfflineStatus(supported: true, state: 'error'));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _remove() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: Text(l10n.offlineRemove),
        content: Text(l10n.offlineRemoveWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.offlineRemove),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _run(_service.remove);
    if (mounted && _status.state == 'unprepared') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.offlineRemoved)));
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    if (widget.service == null) _service.dispose();
    super.dispose();
  }

  Future<void> _cancel() async {
    if (_cancelling) return;
    setState(() => _cancelling = true);
    try {
      _update(await _service.cancel());
    } catch (_) {
      _update(const OfflineStatus(supported: true, state: 'error'));
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final statusText = switch (_status.state) {
      'ready' => l10n.offlineReady,
      'updateReady' => l10n.offlineUpdateReady,
      'preparing' => l10n.offlinePreparing,
      'cancelled' => l10n.offlineCancelled,
      'error' => switch (_status.errorCode) {
        'other_tabs_open' => l10n.offlineOtherTabs,
        'activation_timeout' => l10n.offlineActivationTimeout,
        _ => l10n.offlineError,
      },
      'unsupported' => l10n.offlineUnavailable,
      _ => l10n.offlineNotReady,
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.offlineTitle,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            Text(l10n.offlineBody),
            const SizedBox(height: 12),
            Semantics(liveRegion: true, child: Text(statusText)),
            if (_loading || _status.preparing) ...[
              const SizedBox(height: 10),
              LinearProgressIndicator(value: _status.progress),
            ],
            if (_status.totalBytes > 0) ...[
              const SizedBox(height: 8),
              Text(
                l10n.offlineProgress(
                  (_status.completedBytes / (1024 * 1024)).toStringAsFixed(1),
                  (_status.totalBytes / (1024 * 1024)).toStringAsFixed(1),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              l10n.offlineStorageWarning,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: [
                if (_status.preparing)
                  OutlinedButton(
                    onPressed: _cancelling ? null : _cancel,
                    child: Text(l10n.offlineCancel),
                  )
                else if (_status.state == 'updateReady' ||
                    (_status.state == 'error' &&
                        const {
                          'other_tabs_open',
                          'activation_timeout',
                        }.contains(_status.errorCode)))
                  FilledButton(
                    onPressed: _loading
                        ? null
                        : () => _run(_service.activateAndReload),
                    child: Text(l10n.offlineActivate),
                  )
                else
                  FilledButton.icon(
                    onPressed: !_status.supported || _loading
                        ? null
                        : () => _run(_service.prepare),
                    icon: const Icon(Icons.download_for_offline_outlined),
                    label: Text(l10n.offlinePrepare),
                  ),
                if (_status.offlineReady && !_status.preparing)
                  OutlinedButton(
                    onPressed: _loading ? null : _remove,
                    child: Text(l10n.offlineRemove),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
