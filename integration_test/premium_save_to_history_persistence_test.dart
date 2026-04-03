import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';

import 'helpers/integration_test_harness.dart';

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
            GeneralSettingsModel.initial().copyWith(
              electricityCost: electricityCostPerKwh.toStringAsFixed(2),
            ),
          );
          await harness.seedPrinters(const [
            PrinterModel(
              id: targetPrinterId,
              name: targetPrinterName,
              bedSize: targetPrinterBedSize,
              wattage: '$targetPrinterWattage',
              archived: false,
            ),
            PrinterModel(
              id: secondaryPrinterId,
              name: secondaryPrinterName,
              bedSize: secondaryPrinterBedSize,
              wattage: '$secondaryPrinterWattage',
              archived: false,
            ),
          ]);
          await harness.seedMaterials([
            MaterialModel(
              id: materialId,
              name: materialName,
              cost: materialCostPerKg.toStringAsFixed(2),
              color: materialColor,
              weight: materialWeightGrams.toString(),
              archived: false,
            ),
          ]);
        },
      );
      addTearDown(harness.dispose);

      await tester.launchHarnessApp(harness);

      await _tapByKey(tester, 'nav.calculator.button');
      await _selectDropdownValueByKey(
        tester,
        'calculator.printer.select',
        'calculator.printer.option.$targetPrinterName',
      );
      await _tapByKey(tester, 'calculator.materials.add.button');
      await _tapByKey(tester, 'calculator.materialPicker.item.$materialName');
      await _enterTextByKey(
        tester,
        'calculator.materials.item.0.weight.input',
        printWeightGrams.toString(),
      );

      await _tapByKey(tester, 'calculator.duration.button');
      await _enterTextByKey(
        tester,
        'calculator.duration.hours.input',
        durationHours.toString(),
      );
      await _enterTextByKey(
        tester,
        'calculator.duration.minutes.input',
        durationMinutes.toString(),
      );
      await _tapByKey(tester, 'calculator.duration.save.button');

      await _enterTextByKey(
        tester,
        'calculator.rates.wearAndTear.input',
        wearAndTear.toStringAsFixed(2),
      );
      await _enterTextByKey(
        tester,
        'calculator.rates.failureRisk.input',
        failureRiskPercent.toStringAsFixed(2),
      );
      await _enterTextByKey(
        tester,
        'calculator.adjustments.labourRate.input',
        labourRate.toStringAsFixed(2),
      );
      await _enterTextByKey(
        tester,
        'calculator.adjustments.labourTime.input',
        labourTimeHours.toStringAsFixed(2),
      );
      await _settleDebounce(tester);

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
        _numberFromTextKey(tester, 'calculator.result.electricityCost'),
        closeTo(expectedElectricityCost, 0.01),
      );
      expect(
        _numberFromTextKey(tester, 'calculator.result.filamentCost'),
        closeTo(expectedFilamentCost, 0.01),
      );
      expect(
        _numberFromTextKey(tester, 'calculator.result.labourCost'),
        closeTo(expectedLabourCost, 0.01),
      );
      expect(
        _numberFromTextKey(tester, 'calculator.result.riskCost'),
        closeTo(expectedRiskCost, 0.01),
      );
      expect(
        _numberFromTextKey(tester, 'calculator.result.totalCost'),
        closeTo(expectedTotalCost, 0.01),
      );

      await _tapByKey(tester, 'calculator.save.open.button');
      await _enterTextByKey(
        tester,
        'calculator.save.name.input',
        savedPrintName,
      );
      await _tapByKey(tester, 'calculator.save.confirm.button');

      expect(
        find.byKey(const ValueKey<String>('calculator.save.name.input')),
        findsNothing,
      );

      await _tapByKey(tester, 'nav.history.button');

      final itemKeyPrefix = 'history.item.$savedPrintName';

      expect(
        find.byKey(ValueKey<String>('$itemKeyPrefix.card')),
        findsOneWidget,
      );
      expect(_textFromKey(tester, '$itemKeyPrefix.name'), savedPrintName);
      expect(
        _numberFromTextKey(tester, '$itemKeyPrefix.electricityCost'),
        closeTo(expectedElectricityCost, 0.01),
      );
      expect(
        _numberFromTextKey(tester, '$itemKeyPrefix.filamentCost'),
        closeTo(expectedFilamentCost, 0.01),
      );
      expect(
        _numberFromTextKey(tester, '$itemKeyPrefix.labourCost'),
        closeTo(expectedLabourCost, 0.01),
      );
      expect(
        _numberFromTextKey(tester, '$itemKeyPrefix.riskCost'),
        closeTo(expectedRiskCost, 0.01),
      );
      expect(
        _numberFromTextKey(tester, '$itemKeyPrefix.totalCost'),
        closeTo(expectedTotalCost, 0.01),
      );

      final summary = _textFromKey(tester, '$itemKeyPrefix.summary');
      expect(summary, contains('0.15 kg'));
      expect(summary, contains('2h 30m'));
      expect(summary, contains(targetPrinterName));
      expect(summary, contains(materialName));
    },
  );
}

Future<void> _tapByKey(WidgetTester tester, String key) async {
  final finder = find.byKey(ValueKey<String>(key));
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _selectDropdownValueByKey(
  WidgetTester tester,
  String dropdownKey,
  String optionKey,
) async {
  await _tapByKey(tester, dropdownKey);
  final optionFinder = find.byKey(ValueKey<String>(optionKey)).last;
  await tester.ensureVisible(optionFinder);
  await tester.tap(optionFinder);
  await tester.pumpAndSettle();
}

Future<void> _enterTextByKey(
  WidgetTester tester,
  String key,
  String value,
) async {
  final finder = find.byKey(ValueKey<String>(key));
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
  await tester.enterText(finder, value);
  await tester.pump();
}

Future<void> _settleDebounce(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pumpAndSettle();
}

String _textFromKey(WidgetTester tester, String key) {
  final widget = tester.widget<Text>(find.byKey(ValueKey<String>(key)));
  return widget.data ?? '';
}

double _numberFromTextKey(WidgetTester tester, String key) {
  final widget = tester.widget<Text>(find.byKey(ValueKey<String>(key)));
  final rawText = widget.data ?? '';
  final cleaned = rawText.replaceAll(RegExp(r'[^0-9.\-]'), '');

  if (cleaned.isEmpty || cleaned == '-' || cleaned == '.' || cleaned == '-.') {
    throw FormatException(
      'Expected numeric text for key "$key", found "$rawText".',
    );
  }

  return double.parse(cleaned);
}
