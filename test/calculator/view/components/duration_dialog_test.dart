import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/calculator/view/components/duration_dialog.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';

import '../../../helpers/helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupTest();
  });

  testWidgets('hours and minutes strip leading zeros', (tester) async {
    late AppLocalizations l10n;
    final db = await tester.pumpApp(
      Builder(
        builder: (context) {
          l10n = AppLocalizations.of(context)!;
          return DurationDialog(
            initialHours: 0,
            initialMinutes: 0,
            title: l10n.printingTimeDialogTitle,
            hoursLabel: l10n.durationHoursLabel,
            minutesLabel: l10n.durationMinutesLabel,
          );
        },
      ),
    );
    addTearDown(db.close);

    expect(find.text(l10n.printingTimeDialogTitle), findsOneWidget);
    expect(find.text(l10n.durationHoursLabel), findsOneWidget);
    expect(find.text(l10n.durationMinutesLabel), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey<String>('calculator.duration.hours.input')),
      '007',
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('calculator.duration.minutes.input')),
      '09',
    );
    await tester.pump();

    expect(
      tester
          .widget<TextFormField>(
            find.byKey(
              const ValueKey<String>('calculator.duration.hours.input'),
            ),
          )
          .controller!
          .text,
      '7',
    );
    expect(
      tester
          .widget<TextFormField>(
            find.byKey(
              const ValueKey<String>('calculator.duration.minutes.input'),
            ),
          )
          .controller!
          .text,
      '9',
    );
  });

  testWidgets('supports work time config labels', (tester) async {
    late AppLocalizations l10n;
    final db = await tester.pumpApp(
      Builder(
        builder: (context) {
          l10n = AppLocalizations.of(context)!;
          return DurationDialog(
            initialHours: 1,
            initialMinutes: 30,
            title: l10n.workTimeDialogTitle,
            hoursLabel: l10n.durationHoursLabel,
            minutesLabel: l10n.durationMinutesLabel,
          );
        },
      ),
    );
    addTearDown(db.close);

    expect(find.text(l10n.workTimeDialogTitle), findsOneWidget);
    expect(find.text(l10n.durationHoursLabel), findsOneWidget);
    expect(find.text(l10n.durationMinutesLabel), findsOneWidget);
  });
}
