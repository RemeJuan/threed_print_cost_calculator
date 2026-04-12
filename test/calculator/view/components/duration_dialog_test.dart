import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/calculator/view/components/duration_dialog.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';

import '../../../helpers/helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupTest();
  });

  testWidgets('hours and minutes strip leading zeros', (tester) async {
    late S l10n;
    final db = await tester.pumpApp(
      Builder(
        builder: (context) {
          l10n = S.of(context);
          return DurationDialog(initialHours: 0, initialMinutes: 0, l10n: l10n);
        },
      ),
    );
    addTearDown(db.close);

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
}
