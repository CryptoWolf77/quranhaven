import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_flutter/features/quran/presentation/reader_navigation.dart';
import 'package:quran_library/quran_library.dart';

void main() {
  testWidgets('a reader sheet with its own header closes on Escape', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: TextButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  builder: (_) => const ReaderNavigationFrame(
                    showCloseButton: false,
                    child: SizedBox(height: 200, child: Text('Quick sheet')),
                  ),
                ),
                child: const Text('Open'),
              ),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Quick sheet'), findsOneWidget);
    expect(find.byType(IconButton), findsNothing);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Quick sheet'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  test('reader display labels survive style customization', () {
    const labels = {
      QuranDisplayMode.defaultMode: 'Mushaf',
      QuranDisplayMode.singleScrollable: 'Página desplazable',
    };
    const style = DisplayModeBarStyle(modeLabels: labels);
    expect(style.copyWith(iconSize: 30).modeLabels, labels);
    expect(
      style
          .copyWith(modeLabels: const {QuranDisplayMode.dualPage: 'صفحتان'})
          .modeLabels,
      {QuranDisplayMode.dualPage: 'صفحتان'},
    );
  });
}
