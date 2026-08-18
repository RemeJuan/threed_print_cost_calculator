import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../integration_test/fixtures/integration_fixtures.dart';
import 'helpers/patrol_test_bootstrap.dart';
import 'helpers/patrol_test_ui.dart';

void main() {
  const electricityCostPerKwh = 3.00;
  const targetPrinterId = 'history-test-printer';
  const targetPrinterName = 'History Test Printer';
  const targetPrinterBedSize = '250x250x250';
  const targetPrinterWattage = 120;
  const secondaryPrinterId = 'history-secondary-printer';
  const secondaryPrinterName = 'History Backup Printer';
  const secondaryPrinterBedSize = '180x180x180';
  const secondaryPrinterWattage = 80;
  const materialId = 'history-test-pla';
  const materialName = 'History Test PLA';
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
  const savedPrintName = 'History Persistence Print';

  patrolTest('premium user calculates, saves, and verifies history', ($) async {
    await launchPremiumPatrolApp(
      $,
      seed: (harness) async {
        await harness.seedSettings(
          IntegrationFixtures.buildSettings(
            electricityCost: electricityCostPerKwh.toStringAsFixed(2),
          ),
        );
        await harness.seedPrinters([
          IntegrationFixtures.buildPrinter(
            id: targetPrinterId,
            name: targetPrinterName,
            bedSize: targetPrinterBedSize,
            wattage: '$targetPrinterWattage',
          ),
          IntegrationFixtures.buildPrinter(
            id: secondaryPrinterId,
            name: secondaryPrinterName,
            bedSize: secondaryPrinterBedSize,
            wattage: '$secondaryPrinterWattage',
          ),
        ]);
        await harness.seedMaterials([
          IntegrationFixtures.buildMaterial(
            id: materialId,
            name: materialName,
            cost: materialCostPerKg.toStringAsFixed(2),
            color: materialColor,
            weight: materialWeightGrams.toString(),
          ),
        ]);
      },
    );

    expect(find.byKey(patrolKey('calculator.printer.select')), findsOneWidget);
    expect(
      find.byKey(patrolKey('calculator.save.open.button')),
      findsOneWidget,
    );

    await $.selectDropdownValueByKey(
      'calculator.printer.select',
      'calculator.printer.option.$targetPrinterName',
    );
    await $.tapByKey('calculator.materials.add.button');
    await $.tapByKey('calculator.materialPicker.item.$materialName');
    await $.enterTextByKey(
      'calculator.materials.item.0.weight.input',
      printWeightGrams.toString(),
    );

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

    await $.tapByKey('calculator.jobPricingOverrides.section');
    await $.tester.scrollUntilVisible(
      find.byKey(patrolKey('calculator.jobPricingOverrides.wearAndTear.input')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await $.enterTextByKey(
      'calculator.jobPricingOverrides.wearAndTear.input',
      wearAndTear.toStringAsFixed(2),
    );
    await $.enterTextByKey(
      'calculator.jobPricingOverrides.failureRisk.input',
      failureRiskPercent.toStringAsFixed(2),
    );
    await $.tester.scrollUntilVisible(
      find.byKey(patrolKey('calculator.jobPricingOverrides.labourRate.input')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await $.enterTextByKey(
      'calculator.jobPricingOverrides.labourRate.input',
      labourRate.toStringAsFixed(2),
    );
    await $.tester.scrollUntilVisible(
      find.byKey(patrolKey('calculator.labour.duration.button')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await $.tapByKey('calculator.labour.duration.button');
    await $.enterTextByKey(
      'calculator.duration.hours.input',
      labourTimeHours.floor().toString(),
    );
    await $.enterTextByKey(
      'calculator.duration.minutes.input',
      ((labourTimeHours - labourTimeHours.floor()) * 60).round().toString(),
    );
    await $.tapByKey('calculator.duration.save.button');
    await $.settleDebounce();

    const expectedElectricityCost = 0.90;
    const expectedFilamentCost = 30.00;
    const expectedDisplayedLabourCost = 14.00;
    const expectedRiskCost = 4.34;
    const expectedTotalCost = 49.24;

    expect(
      find.byKey(patrolKey('calculator.result.totalCost')),
      findsOneWidget,
    );
    expectCalculatorResultValues(
      $,
      electricityCost: expectedElectricityCost,
      filamentCost: expectedFilamentCost,
      labourCost: expectedDisplayedLabourCost,
      riskCost: expectedRiskCost,
      totalCost: expectedTotalCost,
    );

    await $.tapByKey('calculator.save.open.button');
    await $.enterTextByKey('calculator.save.name.input', savedPrintName);
    await $.tapByKey('calculator.save.confirm.button');

    expect(find.byKey(patrolKey('calculator.save.name.input')), findsNothing);

    await $.tapByKey('nav.history.button');
    await $.tester.scrollUntilVisible(
      find.text(savedPrintName),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text(savedPrintName), findsOneWidget);
    expect(find.text('0.90'), findsOneWidget);
    expect(find.text('30.00'), findsOneWidget);
    expect(find.text('12.50'), findsOneWidget);
    expect(find.text('4.34'), findsOneWidget);
    expect(find.text('49.24'), findsOneWidget);
    expect(find.textContaining('0.15 kg'), findsOneWidget);
    expect(find.textContaining('2h 30m'), findsOneWidget);
    expect(find.textContaining(targetPrinterName), findsOneWidget);
    expect(find.textContaining(materialName), findsOneWidget);
  });
}
