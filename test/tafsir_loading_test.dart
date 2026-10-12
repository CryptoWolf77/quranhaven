import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_library/quran_library.dart';

void main() {
  Widget host(AsyncSnapshot<void> snapshot, {bool hasContent = true}) =>
      MaterialApp(
        home: TafsirAsyncContent(
          snapshot: snapshot,
          hasContent: hasContent,
          emptyMessage: 'The reading resource is unavailable.',
          contentBuilder: () => const Text('Verified reading text'),
        ),
      );
  testWidgets(
    'waiting shows progress even when previous text is still cached',
    (tester) async {
      await tester.pumpWidget(host(const AsyncSnapshot<void>.waiting()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Verified reading text'), findsNothing);
    },
  );
  testWidgets('finished resource displays its actual content', (tester) async {
    await tester.pumpWidget(
      host(const AsyncSnapshot<void>.withData(ConnectionState.done, null)),
    );
    expect(find.text('Verified reading text'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
  testWidgets('failed or empty text never becomes a blank successful panel', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        AsyncSnapshot<void>.withError(
          ConnectionState.done,
          StateError('unavailable'),
        ),
      ),
    );
    expect(find.text('The reading resource is unavailable.'), findsOneWidget);
    expect(find.text('Verified reading text'), findsNothing);
    await tester.pumpWidget(
      host(
        const AsyncSnapshot<void>.withData(ConnectionState.done, null),
        hasContent: false,
      ),
    );
    expect(find.text('The reading resource is unavailable.'), findsOneWidget);
  });
}
