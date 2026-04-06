import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'helpers/patrol_test_bootstrap.dart';
import 'helpers/patrol_test_ui.dart';

void main() {
  const electricityCostPerKwh = 3.00;
  const wattage = 120;
  const materialCostPerKg = 200.00;
  const materialWeightGrams = 1000;
  const printWeightGrams = 150;
  const durationHours = 2;
  const durationMinutes = 30;

  patrolTest('calculates the deterministic free-user journey end to end', (
    $,
  ) async {
    await launchFreePatrolApp($);

    await $.tapByKey('nav.settings.button');
    await $.enterTextByKey(
      'settings.electricityCost.input',
      electricityCostPerKwh.toStringAsFixed(2),
    );
    await $.enterTextByKey('settings.generalWattage.input', wattage.toString());
    await $.settleDebounce();

    await $.tapByKey('nav.calculator.button');
    await $.tapByKey('nav.settings.button');
    await $.expectFieldTextEventually(
      'settings.electricityCost.input',
      anyOf('3.0', '3.00'),
    );

    await $.tapByKey('nav.calculator.button');
    await $.enterTextByKey(
      'calculator.spoolWeight.input',
      materialWeightGrams.toString(),
    );
    await $.enterTextByKey(
      'calculator.spoolCost.input',
      materialCostPerKg.toStringAsFixed(2),
    );
    await $.enterTextByKey(
      'calculator.printWeight.input',
      printWeightGrams.toString(),
    );
    await $.pump(const Duration(milliseconds: 300));
    await $.pumpAndSettle();

    await $.tapByKey('calculator.duration.button');
    await $.enterTextByKey(
      'calculator.duration.hours.input',
      durationHours.toString(),
    );
    await $.enterTextByKey(
      'calculator.duration.minutes.input',
      durationMinutes.toString(),
    );
    await $.tapByKey('calculator.duration.save.button');

    final expectedElectricityCost =
        (wattage / 1000) *
        (durationHours + durationMinutes / 60) *
        electricityCostPerKwh;
    final expectedFilamentCost = (printWeightGrams / 1000) * materialCostPerKg;
    final expectedTotalCost = expectedElectricityCost + expectedFilamentCost;

    expect(
      $.numberFromTextKey('calculator.result.electricityCost'),
      closeTo(expectedElectricityCost, 0.001),
    );
    expect(
      $.numberFromTextKey('calculator.result.filamentCost'),
      closeTo(expectedFilamentCost, 0.001),
    );
    expect(
      $.numberFromTextKey('calculator.result.totalCost'),
      closeTo(expectedTotalCost, 0.001),
    );
  });
}
