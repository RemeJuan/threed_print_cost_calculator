import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'fixtures/integration_fixtures.dart';
import 'helpers/integration_test_harness.dart';
import 'helpers/integration_test_ui.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const electricityCostPerKwh = 3.00;
  const printerId = 'zero-cost-switch-printer';
  const printerName = 'Zero Cost Switch Printer';
  const printerBedSize = '250x250x250';
  const printerWattage = 120;
  const pricedMaterialId = 'zero-cost-switch-paid-pla';
  const pricedMaterialName = 'PLA Paid';
  const zeroCostMaterialId = 'zero-cost-switch-free-pla';
  const zeroCostMaterialName = 'PLA Free';
  const materialColor = 'Black';
  const printWeightGrams = 150;
  const durationHours = 2;
  const durationMinutes = 30;

  testWidgets(
    'premium calculator recalculates when switching from priced to zero-cost material',
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
          await harness.seedMaterials([
            IntegrationFixtures.buildMaterial(
              id: pricedMaterialId,
              name: pricedMaterialName,
              cost: '200.00',
              color: materialColor,
              weight: '1000',
            ),
            IntegrationFixtures.buildMaterial(
              id: zeroCostMaterialId,
              name: zeroCostMaterialName,
              cost: '0.00',
              color: materialColor,
              weight: '1000',
            ),
          ]);
        },
      );
      addTearDown(harness.dispose);

      await tester.launchHarnessApp(harness);

      await tester.tapByKey('nav.calculator.button');
      await tester.selectDropdownValueByKey(
        'calculator.printer.select',
        'calculator.printer.option.$printerName',
      );

      await tester.tapByKey('calculator.materials.add.button');
      await tester.tapByKey(
        'calculator.materialPicker.item.$pricedMaterialName',
      );
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

      // Premium flow rules for this regression:
      // electricity = (120 / 1000) * 2.5 * 3.00 = 0.90
      // filament (paid) = (150 / 1000) * 200.00 = 30.00
      // total = electricity + filament = 30.90
      expectCalculatorResultValues(
        tester,
        filamentCost: 30.00,
        electricityCost: 0.90,
        totalCost: 30.90,
      );

      await tester.tapByKey('calculator.materials.item.0.pick.button');
      await tester.tapByKey(
        'calculator.materialPicker.item.$zeroCostMaterialName',
      );
      await tester.settleDebounce();

      // After switching materials in-place, the material component must drop to
      // zero while electricity remains unchanged.
      expectCalculatorResultValues(
        tester,
        filamentCost: 0.00,
        electricityCost: 0.90,
        totalCost: 0.90,
      );

      await tester.tapByKey('calculator.materials.item.0.pick.button');
      await tester.tapByKey(
        'calculator.materialPicker.item.$pricedMaterialName',
      );
      await tester.settleDebounce();

      expectCalculatorResultValues(
        tester,
        filamentCost: 30.00,
        electricityCost: 0.90,
        totalCost: 30.90,
      );
    },
  );
}
