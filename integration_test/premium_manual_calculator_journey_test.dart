import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/integration_test_harness.dart';
import 'helpers/integration_test_ui.dart';

// Local-only integration smoke test.
// Retained for manual cross-feature checks while Patrol covers the release gates.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const electricityCostPerKwh = 3.00;
  const targetPrinterName = 'Premium Manual Printer';
  const targetPrinterBedSize = '250x250x250';
  const targetPrinterWattage = 120;
  const secondaryPrinterName = 'Premium Secondary Printer';
  const secondaryPrinterBedSize = '180x180x180';
  const secondaryPrinterWattage = 80;
  const materialName = 'Premium Manual PLA';
  const materialColor = 'Black';
  const materialWeightGrams = 1000;
  const materialCostPerKg = 200.00;
  const printWeightGrams = 150;
  const durationHours = 2;
  const durationMinutes = 30;
  const wearAndTear = 1.50;
  const failureRiskPercent = 10.00;
  const labourRate = 25.00;
  const labourTimeHours = 0.50;

  testWidgets('premium user completes the full manual calculator journey', (
    tester,
  ) async {
    final harness = await IntegrationTestHarness.premium();
    addTearDown(harness.dispose);

    await tester.launchHarnessApp(harness);

    await tester.tapByKey('nav.settings.button');

    await tester.enterTextByKey(
      'settings.electricityCost.input',
      electricityCostPerKwh.toStringAsFixed(2),
    );
    await tester.settleDebounce();

    await tester.tapByKey('settings.printers.section');
    await tester.tapByKey('settings.printers.add.button');
    await tester.enterTextByKey(
      'settings.printers.name.input',
      targetPrinterName,
    );
    await tester.enterTextByKey(
      'settings.printers.bedSize.input',
      targetPrinterBedSize,
    );
    await tester.enterTextByKey(
      'settings.printers.wattage.input',
      targetPrinterWattage.toString(),
    );
    await tester.tapByKey('settings.printers.save.button');

    await tester.tapByKey('settings.printers.add.button');
    await tester.enterTextByKey(
      'settings.printers.name.input',
      secondaryPrinterName,
    );
    await tester.enterTextByKey(
      'settings.printers.bedSize.input',
      secondaryPrinterBedSize,
    );
    await tester.enterTextByKey(
      'settings.printers.wattage.input',
      secondaryPrinterWattage.toString(),
    );
    await tester.tapByKey('settings.printers.save.button');

    expect(
      tester.textFromKey('settings.printers.item.0.name'),
      targetPrinterName,
    );
    expect(
      tester.textFromKey('settings.printers.item.1.name'),
      secondaryPrinterName,
    );

    await tester.tapByKey('settings.materials.section');
    await tester.tapByKey('settings.materials.add.button');
    await tester.enterTextByKey('settings.materials.name.input', materialName);
    await tester.enterTextByKey(
      'settings.materials.color.input',
      materialColor,
    );
    await tester.enterTextByKey(
      'settings.materials.weight.input',
      materialWeightGrams.toString(),
    );
    await tester.enterTextByKey(
      'settings.materials.cost.input',
      materialCostPerKg.toStringAsFixed(2),
    );
    await tester.tapByKey('settings.materials.save.button');

    expect(tester.textFromKey('settings.materials.item.0.name'), materialName);

    await tester.tapByKey('nav.calculator.button');

    await tester.selectDropdownValueByKey(
      'calculator.printer.select',
      'calculator.printer.option.$targetPrinterName',
    );

    await tester.tapByKey('calculator.materials.add.button');
    await tester.tapByKey('calculator.materialPicker.item.$materialName');
    await tester.enterTextByKey(
      'calculator.materials.item.0.weight.input',
      printWeightGrams.toString(),
    );

    await tester.tapByKey('calculator.duration.button');
    await tester.enterTextByKey(
      'calculator.duration.hours.input',
      durationHours.toString(),
    );
    await tester.enterTextByKey(
      'calculator.duration.minutes.input',
      durationMinutes.toString(),
    );
    await tester.tapByKey('calculator.duration.save.button');

    await tester.enterTextByKey(
      'calculator.rates.wearAndTear.input',
      wearAndTear.toStringAsFixed(2),
    );
    await tester.enterTextByKey(
      'calculator.rates.failureRisk.input',
      failureRiskPercent.toStringAsFixed(2),
    );
    await tester.enterTextByKey(
      'calculator.adjustments.labourRate.input',
      labourRate.toStringAsFixed(2),
    );
    await tester.enterTextByKey(
      'calculator.adjustments.labourTime.input',
      labourTimeHours.toStringAsFixed(2),
    );
    await tester.settleDebounce();

    // App formulas:
    // electricity = (120 / 1000) * (2 + 30 / 60) * 3.00 = 0.90
    // filament = (150 * 200.00) / 1000 = 30.00
    // labour = 25.00 * 0.50 = 12.50
    // total = 0.90 + 30.00 + 1.50 + 12.50 = 44.90
    // risk = 10% of total = 4.49
    const expectedElectricityCost = 0.90;
    const expectedFilamentCost = 30.00;
    const expectedLabourCost = 12.50;
    const expectedTotalCost = 44.90;
    const expectedRiskCost = 4.49;

    expect(
      find.byKey(const ValueKey<String>('calculator.result.totalCost')),
      findsOneWidget,
    );
    expect(
      tester.numberFromTextKey('calculator.result.electricityCost'),
      closeTo(expectedElectricityCost, 0.01),
    );
    expect(
      tester.numberFromTextKey('calculator.result.filamentCost'),
      closeTo(expectedFilamentCost, 0.01),
    );
    expect(
      tester.numberFromTextKey('calculator.result.labourCost'),
      closeTo(expectedLabourCost, 0.01),
    );
    expect(
      tester.numberFromTextKey('calculator.result.riskCost'),
      closeTo(expectedRiskCost, 0.01),
    );
    expect(
      tester.numberFromTextKey('calculator.result.totalCost'),
      closeTo(expectedTotalCost, 0.01),
    );

    expect(
      tester.focusSafeFieldText('calculator.materials.item.0.weight.input'),
      printWeightGrams.toString(),
    );
  });
}
