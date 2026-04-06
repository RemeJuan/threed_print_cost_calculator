import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/integration_test_harness.dart';
import 'helpers/integration_test_ui.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const electricityCostPerKwh = 3.00;
  const wattage = 120;
  const materialCostPerKg = 200.00;
  const materialWeightGrams = 1000;
  const printWeightGrams = 150;
  const durationHours = 2;
  const durationMinutes = 30;

  testWidgets('calculates the deterministic free-user journey end to end', (
    tester,
  ) async {
    final harness = await IntegrationTestHarness.free();
    addTearDown(harness.dispose);

    await tester.launchHarnessApp(harness);

    await tester.tapByKey('nav.settings.button');

    await tester.enterTextByKey(
      'settings.electricityCost.input',
      electricityCostPerKwh.toStringAsFixed(2),
    );
    await tester.enterTextByKey(
      'settings.generalWattage.input',
      wattage.toString(),
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    await tester.tapByKey('nav.calculator.button');
    await tester.pumpAndSettle();
    await tester.tapByKey('nav.settings.button');
    await tester.pumpAndSettle();

    await tester.expectFieldTextEventually(
      'settings.electricityCost.input',
      anyOf('3.0', '3.00'),
    );

    await tester.tapByKey('nav.calculator.button');
    await tester.pumpAndSettle();

    await tester.enterTextByKey(
      'calculator.spoolWeight.input',
      materialWeightGrams.toString(),
    );
    await tester.enterTextByKey(
      'calculator.spoolCost.input',
      materialCostPerKg.toStringAsFixed(2),
    );

    await tester.enterTextByKey(
      'calculator.printWeight.input',
      printWeightGrams.toString(),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    await tester.tapByKey('calculator.duration.button');
    await tester.pumpAndSettle();
    await tester.enterTextByKey(
      'calculator.duration.hours.input',
      durationHours.toString(),
    );
    await tester.enterTextByKey(
      'calculator.duration.minutes.input',
      durationMinutes.toString(),
    );
    await tester.tapByKey('calculator.duration.save.button');
    await tester.pumpAndSettle();

    final expectedElectricityCost =
        (wattage / 1000) *
        (durationHours + durationMinutes / 60) *
        electricityCostPerKwh;
    final expectedFilamentCost = (printWeightGrams / 1000) * materialCostPerKg;
    final expectedTotalCost = expectedElectricityCost + expectedFilamentCost;

    expect(
      tester.numberFromTextKey('calculator.result.electricityCost'),
      closeTo(expectedElectricityCost, 0.001),
    );
    expect(
      tester.numberFromTextKey('calculator.result.filamentCost'),
      closeTo(expectedFilamentCost, 0.001),
    );
    expect(
      tester.numberFromTextKey('calculator.result.totalCost'),
      closeTo(expectedTotalCost, 0.001),
    );
  });
}
