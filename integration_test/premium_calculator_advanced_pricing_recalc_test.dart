import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/integration_test_harness.dart';
import 'helpers/integration_test_ui.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('advanced pricing fields recalculate the calculator live', (
    tester,
  ) async {
    final harness = await IntegrationTestHarness.premium();
    addTearDown(harness.dispose);

    await tester.launchHarnessApp(harness);
    await tester.tapByKey('nav.calculator.button');
    await tester.scrollUntilKeyVisible(
      'calculator.jobPricingOverrides.section',
    );

    await tester.tapByKey('calculator.jobPricingOverrides.section');
    await tester.pumpAndSettle();

    await tester.scrollUntilKeyVisible(
      'calculator.jobPricingOverrides.labourRate.input',
    );
    await tester.scrollUntilKeyVisible(
      'calculator.jobPricingOverrides.additionalCost.input',
    );
    await tester.scrollUntilKeyVisible(
      'calculator.jobPricingOverrides.markupPercent.input',
    );
    await tester.scrollUntilKeyVisible(
      'calculator.jobPricingOverrides.labourRate.input',
    );
    await tester.enterTextByKey(
      'calculator.jobPricingOverrides.labourRate.input',
      '25',
    );
    await tester.enterTextByKey(
      'calculator.jobPricingOverrides.additionalCost.input',
      '5',
    );
    await tester.enterTextByKey(
      'calculator.jobPricingOverrides.markupPercent.input',
      '10',
    );
    await tester.settleDebounce();

    final before = tester.numberFromTextKey('calculator.result.totalCost');

    await tester.enterTextByKey(
      'calculator.jobPricingOverrides.additionalCost.input',
      '15',
    );
    await tester.settleDebounce();

    final after = tester.numberFromTextKey('calculator.result.totalCost');
    expect(after, greaterThan(before));
  });
}
