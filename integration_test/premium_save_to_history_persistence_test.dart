import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'fixtures/integration_fixtures.dart';
import 'helpers/integration_test_harness.dart';
import 'helpers/integration_test_ui.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

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

  testWidgets(
    'premium user saves a calculation and finds persisted values in history',
    (tester) async {
      final harness = await IntegrationTestHarness.premium(
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
      addTearDown(harness.dispose);

      await tester.launchHarnessApp(harness);

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
      expectCalculatorResultValues(
        tester,
        electricityCost: expectedElectricityCost,
        filamentCost: expectedFilamentCost,
        labourCost: expectedLabourCost,
        riskCost: expectedRiskCost,
        totalCost: expectedTotalCost,
      );

      await tester.tapByKey('calculator.save.open.button');
      await tester.enterTextByKey('calculator.save.name.input', savedPrintName);
      await tester.tapByKey('calculator.save.confirm.button');

      expect(
        find.byKey(const ValueKey<String>('calculator.save.name.input')),
        findsNothing,
      );

      await tester.tapByKey('nav.history.button');

      final itemKeyPrefix = 'history.item.$savedPrintName';

      expect(find.byKey(historyCardKey(savedPrintName)), findsOneWidget);
      expect(tester.textFromKey('$itemKeyPrefix.name'), savedPrintName);
      expectHistoryItemCostValues(
        tester,
        savedPrintName,
        electricityCost: expectedElectricityCost,
        filamentCost: expectedFilamentCost,
        labourCost: expectedLabourCost,
        riskCost: expectedRiskCost,
        totalCost: expectedTotalCost,
      );

      final summary = tester.textFromKey('$itemKeyPrefix.summary');
      expect(summary, contains('0.15 kg'));
      expect(summary, contains('2h 30m'));
      expect(summary, contains(targetPrinterName));
      expect(summary, contains(materialName));
    },
  );
}
