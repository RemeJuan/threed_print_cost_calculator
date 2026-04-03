import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:threed_print_cost_calculator/app/components/focus_safe_text_field.dart';

import 'helpers/integration_test_harness.dart';

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

    await _tapByKey(tester, 'nav.settings.button');

    await _enterTextByKey(
      tester,
      'settings.electricityCost.input',
      electricityCostPerKwh.toStringAsFixed(2),
    );
    await _settleDebounce(tester);

    await _tapByKey(tester, 'settings.printers.section');
    await _tapByKey(tester, 'settings.printers.add.button');
    await _enterTextByKey(
      tester,
      'settings.printers.name.input',
      targetPrinterName,
    );
    await _enterTextByKey(
      tester,
      'settings.printers.bedSize.input',
      targetPrinterBedSize,
    );
    await _enterTextByKey(
      tester,
      'settings.printers.wattage.input',
      targetPrinterWattage.toString(),
    );
    await _tapByKey(tester, 'settings.printers.save.button');

    await _tapByKey(tester, 'settings.printers.add.button');
    await _enterTextByKey(
      tester,
      'settings.printers.name.input',
      secondaryPrinterName,
    );
    await _enterTextByKey(
      tester,
      'settings.printers.bedSize.input',
      secondaryPrinterBedSize,
    );
    await _enterTextByKey(
      tester,
      'settings.printers.wattage.input',
      secondaryPrinterWattage.toString(),
    );
    await _tapByKey(tester, 'settings.printers.save.button');

    expect(
      _textFromKey(tester, 'settings.printers.item.0.name'),
      targetPrinterName,
    );
    expect(
      _textFromKey(tester, 'settings.printers.item.1.name'),
      secondaryPrinterName,
    );

    await _tapByKey(tester, 'settings.materials.section');
    await _tapByKey(tester, 'settings.materials.add.button');
    await _enterTextByKey(
      tester,
      'settings.materials.name.input',
      materialName,
    );
    await _enterTextByKey(
      tester,
      'settings.materials.color.input',
      materialColor,
    );
    await _enterTextByKey(
      tester,
      'settings.materials.weight.input',
      materialWeightGrams.toString(),
    );
    await _enterTextByKey(
      tester,
      'settings.materials.cost.input',
      materialCostPerKg.toStringAsFixed(2),
    );
    await _tapByKey(tester, 'settings.materials.save.button');

    expect(
      _textFromKey(tester, 'settings.materials.item.0.name'),
      materialName,
    );

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

    expect(
      _focusSafeFieldText(tester, 'calculator.materials.item.0.weight.input'),
      printWeightGrams.toString(),
    );
  });
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

String _focusSafeFieldText(WidgetTester tester, String key) {
  final widget = tester.widget<FocusSafeTextField>(
    find.byKey(ValueKey<String>(key)),
  );
  return widget.controller.text;
}

double _numberFromTextKey(WidgetTester tester, String key) {
  final widget = tester.widget<Text>(find.byKey(ValueKey<String>(key)));
  return double.parse((widget.data ?? '').replaceAll(RegExp(r'[^0-9.\-]'), ''));
}
