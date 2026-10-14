import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_flutter/features/personal/presentation/backup_card.dart';
import 'package:quran_flutter/l10n/generated/app_localizations.dart';

void main() {
  for (final language in ['ar', 'en', 'es']) {
    for (final isWeb in [false, true]) {
      testWidgets(
        '$language ${isWeb ? 'web' : 'native'} restore confirmation uses the correct refresh action',
        (tester) async {
          await tester.binding.setSurfaceSize(const Size(375, 812));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          bool? result;
          await tester.pumpWidget(
            MaterialApp(
              locale: Locale(language),
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(2)),
                child: child!,
              ),
              home: Builder(
                builder: (context) => Scaffold(
                  body: TextButton(
                    onPressed: () async {
                      result = await showDialog<bool>(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => BackupRestoredDialog(isWeb: isWeb),
                      );
                    },
                    child: const Text('Open confirmation'),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          await tester.tap(find.text('Open confirmation'));
          await tester.pumpAndSettle();
          final l = await AppLocalizations.delegate.load(Locale(language));
          expect(
            find.text(isWeb ? l.backupRestored : l.backupRestoredNative),
            findsOneWidget,
          );
          expect(
            find.text(isWeb ? l.backupRestoredNative : l.backupRestored),
            findsNothing,
          );
          expect(find.text(l.reloadApp), isWeb ? findsOneWidget : findsNothing);
          final dialogContext = tester.element(
            find.byType(BackupRestoredDialog),
          );
          final close = MaterialLocalizations.of(
            dialogContext,
          ).closeButtonLabel;
          expect(find.text(close), findsOneWidget);
          await tester.tap(find.text(isWeb ? l.reloadApp : close));
          await tester.pumpAndSettle();
          expect(result, isWeb);
          expect(find.byType(BackupRestoredDialog), findsNothing);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
