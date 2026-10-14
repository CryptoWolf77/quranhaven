import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../l10n/generated/app_localizations.dart';

const projectContactEmail = 'admin@yahyazlab.com';
Uri projectPrivacyUri(String language) =>
    Uri.https('quranhaven.org', '/privacy.html', {
      'lang': ['ar', 'en', 'es'].contains(language) ? language : 'en',
    });

class PrivacyContactCard extends StatelessWidget {
  const PrivacyContactCard({super.key, this.openLink});
  final Future<bool> Function(Uri)? openLink;
  Future<void> _open(BuildContext context, Uri uri) async {
    try {
      final opened =
          await (openLink ??
              (u) => launchUrl(u, mode: LaunchMode.externalApplication))(uri);
      if (opened) return;
    } catch (_) {}
    if (context.mounted) await _copy(context, uri.toString());
  }

  Future<void> _copy(BuildContext context, String value) async {
    var copied = false;
    try {
      await Clipboard.setData(ClipboardData(text: value));
      copied = true;
    } catch (_) {}
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            copied
                ? AppLocalizations.of(context).privacyLinkCopied
                : AppLocalizations.of(context).privacyLinkFailed,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context), s = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.privacy_tip_outlined, color: s.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l.privacyTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(l.privacyLocalSummary, style: const TextStyle(height: 1.6)),
            const SizedBox(height: 12),
            Text(l.privacyNetworkSummary, style: const TextStyle(height: 1.6)),
            const SizedBox(height: 16),
            TextButton.icon(
              key: const ValueKey('privacy-policy-link'),
              onPressed: () => _open(
                context,
                projectPrivacyUri(Localizations.localeOf(context).languageCode),
              ),
              icon: const Icon(Icons.open_in_new),
              label: Text(l.privacyOpen),
            ),
            const Divider(),
            Text(
              projectContactEmail,
              textDirection: TextDirection.ltr,
              style: TextStyle(color: s.primary, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _open(
                    context,
                    Uri(scheme: 'mailto', path: projectContactEmail),
                  ),
                  icon: const Icon(Icons.mail_outline),
                  label: Text(l.contactProject),
                ),
                TextButton.icon(
                  onPressed: () => _copy(context, projectContactEmail),
                  icon: const Icon(Icons.copy),
                  label: Text(l.copyContactEmail),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
