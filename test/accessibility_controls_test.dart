import 'dart:ui' show SemanticsAction, Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_flutter/features/account/presentation/account_card.dart';
import 'package:quran_flutter/features/plans/domain/plans_models.dart';
import 'package:quran_flutter/features/plans/presentation/plans_page.dart';
import 'package:quran_flutter/l10n/generated/app_localizations.dart';

const _plan = MemorizationPlan(
  id: 'accessible-practice',
  surahNumber: 1,
  startAyah: 1,
  endAyah: 7,
  currentAyah: 3,
  repetitions: 5,
  rangeRepetitions: 1,
  delaySeconds: 2,
  hideAyah: true,
);

Widget _host(
  Widget child, {
  String locale = 'en',
  double width = 700,
  double textScale = 1,
}) {
  return MaterialApp(
    locale: Locale(locale),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
    home: Scaffold(
      body: Center(
        child: SizedBox(width: width, child: child),
      ),
    ),
  );
}

void main() {
  testWidgets('password control exposes its action and responds to keyboard', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var obscured = true;
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) => PasswordVisibilityButton(
            obscured: obscured,
            onPressed: () => setState(() => obscured = !obscured),
          ),
        ),
      ),
    );

    final data = tester
        .getSemantics(find.byTooltip('Show password'))
        .getSemanticsData();
    expect(data.tooltip, 'Show password');
    expect(data.flagsCollection.isButton, isTrue);
    expect(data.hasAction(SemanticsAction.tap), isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(obscured, isFalse);
    expect(find.byTooltip('Hide password'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(obscured, isTrue);
    expect(find.byTooltip('Show password'), findsOneWidget);
    semantics.dispose();
  });

  for (final entry in const {
    'en': ['Previous Ayah', 'Next Ayah', 'Show password', 'Hide password'],
    'ar': [
      'الآية السابقة',
      'الآية التالية',
      'إظهار كلمة المرور',
      'إخفاء كلمة المرور',
    ],
    'es': [
      'Aya anterior',
      'Aya siguiente',
      'Mostrar contraseña',
      'Ocultar contraseña',
    ],
  }.entries) {
    testWidgets(
      '${entry.key} controls have localized labels and correct reading order',
      (tester) async {
        final semantics = tester.ensureSemantics();
        await tester.pumpWidget(
          _host(
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MemorizationAyahControls(plan: _plan, onChanged: (_) {}),
                PasswordVisibilityButton(obscured: true, onPressed: () {}),
                PasswordVisibilityButton(obscured: false, onPressed: () {}),
              ],
            ),
            locale: entry.key,
          ),
        );
        for (final label in entry.value) {
          final node = tester.getSemantics(find.byTooltip(label));
          expect(node.getSemanticsData().tooltip, label);
          expect(
            node.getSemanticsData().hasAction(SemanticsAction.tap),
            isTrue,
          );
        }
        final previous = tester.getCenter(find.byTooltip(entry.value[0]));
        final next = tester.getCenter(find.byTooltip(entry.value[1]));
        expect(previous.dx < next.dx, entry.key != 'ar');
        expect(
          Directionality.of(
            tester.element(find.byType(MemorizationAyahControls)),
          ),
          entry.key == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        );
        semantics.dispose();
      },
    );

    testWidgets(
      '${entry.key} practice controls fit narrow screens with large text',
      (tester) async {
        await tester.pumpWidget(
          _host(
            MemorizationAyahControls(plan: _plan, onChanged: (_) {}),
            locale: entry.key,
            width: 240,
            textScale: 2,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final bounds = tester.getRect(find.byType(MemorizationAyahControls));
        for (final button in find.byType(IconButton).evaluate()) {
          final rectangle = tester.getRect(find.byWidget(button.widget));
          expect(rectangle.left, greaterThanOrEqualTo(bounds.left));
          expect(rectangle.right, lessThanOrEqualTo(bounds.right));
        }
      },
    );
  }

  testWidgets(
    'Ayah navigation is keyboard operable and keeps revision state labeled',
    (tester) async {
      var plan = _plan;
      await tester.pumpWidget(
        _host(
          StatefulBuilder(
            builder: (context, setState) => MemorizationAyahControls(
              plan: plan,
              onChanged: (changed) => setState(() => plan = changed),
            ),
          ),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(plan.currentAyah, 2);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(plan.currentAyah, 3);
      await tester.tap(find.byTooltip('Mark for revision'));
      await tester.pump();
      expect(plan.isCurrentForRevision, isTrue);
      expect(find.byTooltip('Remove revision marker'), findsOneWidget);
      await tester.tap(find.byTooltip('Remove revision marker'));
      await tester.pump();
      expect(plan.isCurrentForRevision, isFalse);
    },
  );

  testWidgets(
    'range boundaries expose disabled navigation without a tap action',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          MemorizationAyahControls(
            plan: _plan.copyWith(currentAyah: 1),
            onChanged: (_) => fail('Previous Ayah cannot leave the range'),
          ),
        ),
      );
      var data = tester
          .getSemantics(find.byTooltip('Previous Ayah'))
          .getSemanticsData();
      expect(data.tooltip, 'Previous Ayah');
      expect(data.hasAction(SemanticsAction.tap), isFalse);
      expect(data.flagsCollection.isEnabled, Tristate.isFalse);
      await tester.pumpWidget(
        _host(
          MemorizationAyahControls(
            plan: _plan.copyWith(currentAyah: 7),
            onChanged: (_) => fail('Next Ayah cannot leave the range'),
          ),
        ),
      );
      data = tester
          .getSemantics(find.byTooltip('Next Ayah'))
          .getSemanticsData();
      expect(data.tooltip, 'Next Ayah');
      expect(data.hasAction(SemanticsAction.tap), isFalse);
      semantics.dispose();
    },
  );
}
