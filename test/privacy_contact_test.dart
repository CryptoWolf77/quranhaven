import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_flutter/features/settings/presentation/privacy_contact_card.dart';
import 'package:quran_flutter/l10n/generated/app_localizations.dart';

void main() {
  for (final language in ['ar', 'en', 'es']) {
    testWidgets(
      '$language privacy/contact fits375px and opens approved localized policy only on click',
      (t) async {
        await t.binding.setSurfaceSize(const Size(375, 812));
        addTearDown(() => t.binding.setSurfaceSize(null));
        final opened = <Uri>[];
        await t.pumpWidget(
          MaterialApp(
            locale: Locale(language),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: Scaffold(
              body: SingleChildScrollView(
                child: PrivacyContactCard(
                  openLink: (uri) async {
                    opened.add(uri);
                    return true;
                  },
                ),
              ),
            ),
          ),
        );
        await t.pumpAndSettle();
        expect(opened, isEmpty);
        expect(find.text('admin@yahyazlab.com'), findsOneWidget);
        final link = find.byKey(const ValueKey('privacy-policy-link'));
        await t.ensureVisible(link);
        await t.pumpAndSettle();
        await t.tap(link);
        await t.pumpAndSettle();
        expect(
          opened.single.toString(),
          'https://quranhaven.org/privacy.html?lang=$language',
        );
        final l = await AppLocalizations.delegate.load(Locale(language));
        expect(l.privacyNetworkSummary, contains('Cloudflare'));
        expect(l.privacyNetworkSummary, contains('IP'));
        expect(find.text(l.privacyLocalSummary), findsOneWidget);
        expect(t.takeException(), null);
      },
    );
  }
  test(
    'privacy URI accepts only supported locale with stable HTTPS owner route',
    () {
      expect(
        projectPrivacyUri('unknown').toString(),
        'https://quranhaven.org/privacy.html?lang=en',
      );
      expect(projectContactEmail, 'admin@yahyazlab.com');
    },
  );
}
