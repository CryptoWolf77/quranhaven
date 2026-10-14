import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/generated/app_localizations.dart';

const creatorLogoAsset = 'assets/brand/yahyazlab.png';
const creatorWebsiteUrl = 'https://yahyazlab.com/';

/// A quiet creator credit, separate from Quran content and reading controls.
class CreatorCredit extends StatefulWidget {
  const CreatorCredit({super.key, this.openLink});

  final Future<bool> Function(Uri)? openLink;

  @override
  State<CreatorCredit> createState() => _CreatorCreditState();
}

class _CreatorCreditState extends State<CreatorCredit> {
  bool _opening = false;

  Future<void> _confirmOpen() async {
    if (_opening) return;
    final l = AppLocalizations.of(context);
    setState(() => _opening = true);
    try {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          scrollable: true,
          title: Text(l.creatorExternalTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'yahyazlab.com',
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  color: Theme.of(dialogContext).colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(l.creatorExternalBody, style: const TextStyle(height: 1.5)),
              const SizedBox(height: 16),
              Text(
                l.creatorGuardianReminder,
                style: const TextStyle(height: 1.5),
              ),
            ],
          ),
          actions: [
            TextButton(
              key: const ValueKey('creator-external-cancel'),
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l.cancel),
            ),
            FilledButton(
              key: const ValueKey('creator-external-continue'),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l.creatorContinue),
            ),
          ],
        ),
      );
      if (proceed != true || !mounted) return;
      var opened = false;
      try {
        opened =
            await (widget.openLink ??
                (uri) => launchUrl(uri, mode: LaunchMode.externalApplication))(
              Uri.parse(creatorWebsiteUrl),
            );
      } catch (_) {}
      if (!opened && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.creatorOpenFailed)));
      }
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context), s = Theme.of(context).colorScheme;
    final logo = Container(
      width: 164,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF171A1C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: AspectRatio(
        aspectRatio: 1228 / 596,
        child: Image.asset(
          creatorLogoAsset,
          key: const ValueKey('creator-logo'),
          fit: BoxFit.contain,
          excludeFromSemantics: true,
        ),
      ),
    );
    final label = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.creatorCreditTitle,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(l.creatorCreditHint, style: TextStyle(color: s.onSurfaceVariant)),
        const SizedBox(height: 4),
        const Text('yahyazlab.com', textDirection: TextDirection.ltr),
      ],
    );
    return Semantics(
      container: true,
      button: true,
      enabled: !_opening,
      label: l.creatorCreditSemantics,
      excludeSemantics: true,
      onTap: _opening ? null : _confirmOpen,
      child: Material(
        color: s.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          key: const ValueKey('creator-credit-link'),
          onTap: _opening ? null : _confirmOpen,
          borderRadius: BorderRadius.circular(18),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 480 ||
                      MediaQuery.textScalerOf(context).scale(14) > 20) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        logo,
                        const SizedBox(height: 16),
                        label,
                        const SizedBox(height: 8),
                        Icon(
                          Icons.open_in_new_rounded,
                          color: s.primary,
                          size: 20,
                        ),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      logo,
                      const SizedBox(width: 22),
                      Expanded(child: label),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.open_in_new_rounded,
                        color: s.primary,
                        size: 20,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
