import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'fixtures/integration_fixtures.dart';
import 'helpers/integration_test_harness.dart';
import 'helpers/integration_test_ui.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const electricityCostPerKwh = 3.00;
  const printerId = 'calculator-material-flow-printer';
  const printerName = 'Material Flow Printer';
  const printerBedSize = '250x250x250';
  const printerWattage = 120;
  const materialName = 'Calculator Flow PLA';
  const materialColor = 'Black';
  const materialWeightGrams = 1000;
  const materialCostPerKg = 200.00;
  const printWeightGrams = 150;
  const durationHours = 2;
  const durationMinutes = 30;

  testWidgets(
    'premium user creates a material from the calculator flow and uses it immediately',
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
              id: printerId,
              name: printerName,
              bedSize: printerBedSize,
              wattage: '$printerWattage',
            ),
          ]);
        },
      );
      addTearDown(harness.dispose);

      await tester.launchHarnessApp(harness);

      await tester.tapByKey('nav.calculator.button');
      expect(
        find.byKey(const ValueKey<String>('calculator.printer.select')),
        findsOneWidget,
      );

      await tester.tapByKey('calculator.materials.add.button');
      await tester.tapByKey('calculator.materialPicker.add.button');
      await tester.enterTextByKey(
        'settings.materials.name.input',
        materialName,
      );
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

      expect(
        tester.textFromKey('calculator.materials.item.0.name'),
        materialName,
      );

      await tester.tapByKey('calculator.materials.item.0.pick.button');
      expect(
        find.byKey(
          ValueKey<String>('calculator.materialPicker.item.$materialName'),
        ),
        findsOneWidget,
      );
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
      await tester.settleDebounce();

      const expectedElectricityCost = 0.90;
      const expectedFilamentCost = 30.00;
      const expectedTotalCost = 30.90;

      expectCalculatorResultValues(
        tester,
        electricityCost: expectedElectricityCost,
        filamentCost: expectedFilamentCost,
        totalCost: expectedTotalCost,
      );
    },
  );
}
