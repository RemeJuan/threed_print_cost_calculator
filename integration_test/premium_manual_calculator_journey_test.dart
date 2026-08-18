import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';

import 'helpers/integration_test_harness.dart';
import 'helpers/integration_test_ui.dart';

// Local-only integration smoke test.
// Retained for manual cross-feature checks while Patrol covers the release gates.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

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
  const seededMaterialId = 'premium-manual-pla';

  testWidgets('premium user completes the full manual calculator journey', (
    tester,
  ) async {
    final harness = await IntegrationTestHarness.premium(
      seed: (harness) async {
        await harness.seedSettings(
          const GeneralSettingsModel(
            electricityCost: '3.00',
            wattage: '',
            averageWattage: '',
            activePrinter: '',
            selectedMaterial: '',
            wearAndTear: '1.50',
            failureRisk: '10.00',
            labourRate: '25.00',
          ),
        );
        await harness.seedMaterials([
          MaterialModel(
            id: seededMaterialId,
            name: materialName,
            cost: materialCostPerKg.toStringAsFixed(2),
            color: materialColor,
            weight: materialWeightGrams.toString(),
            archived: false,
            remainingWeight: materialWeightGrams.toDouble(),
            originalWeight: materialWeightGrams.toDouble(),
          ),
        ]);
      },
    );
    addTearDown(harness.dispose);

    await tester.launchHarnessApp(harness);
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    await tester.tapByKey('nav.settings.button');
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    await tester.scrollUntilKeyVisible('settings.general.section');
    await tester.scrollUntilKeyVisible('settings.printers.section');

    await tester.scrollUntilKeyVisible('settings.printers.add.button');
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

    await tester.tapByKey('nav.calculator.button');
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    await tester.scrollUntilKeyVisible('calculator.printer.select');

    await tester.selectDropdownValueByKey(
      'calculator.printer.select',
      'calculator.printer.option.$targetPrinterName',
    );

    await tester.scrollUntilKeyVisible('calculator.materials.add.button');
    await tester.tapByKey('calculator.materials.add.button');
    await tester.scrollUntilKeyVisible(
      'calculator.materialPicker.item.$materialName',
    );
    await tester.tapByKey('calculator.materialPicker.item.$materialName');
    await tester.enterTextByKey(
      'calculator.materials.item.0.weight.input',
      printWeightGrams.toString(),
    );

    await tester.tapByKey('calculator.duration.button');
    await tester.scrollUntilKeyVisible('calculator.duration.hours.input');
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

    // App formulas:
    // electricity = (120 / 1000) * (2 + 30 / 60) * 3.00 = 0.90
    // filament = (150 * 200.00) / 1000 = 30.00
    // labour = 1.50
    // total = 0.90 + 30.00 + 1.50 + 3.09 = 35.49
    // risk = 10% surcharge = 3.09
    const expectedElectricityCost = 0.90;
    const expectedFilamentCost = 30.00;
    const expectedLabourCost = 1.50;
    const expectedTotalCost = 35.49;
    const expectedRiskCost = 3.09;

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
