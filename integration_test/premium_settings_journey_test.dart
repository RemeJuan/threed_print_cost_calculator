import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:threed_print_cost_calculator/app/components/focus_safe_text_field.dart';

import 'helpers/integration_test_harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const electricityCostPerKwh = '3.00';
  const generalWattage = '120';
  const printerName = 'Premium Test Printer';
  const printerBedSize = '250x250x250';
  const materialName = 'Premium PLA Black';
  const materialColor = 'Black';
  const materialWeight = '1000';
  const materialCostPerKg = '200.00';
  const wearAndTear = '1.50';
  const failureRisk = '10.00';
  const labourRate = '25.00';

  testWidgets('premium user can configure premium settings and revisit them', (
    tester,
  ) async {
    final harness = await IntegrationTestHarness.premium();
    addTearDown(harness.dispose);

    await tester.launchHarnessApp(harness);
    await _tapByKey(tester, 'nav.settings.button');

    expect(
      find.byKey(const ValueKey<String>('settings.general.section')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('settings.printers.section')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('settings.materials.section')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('settings.workCost.section')),
      findsOneWidget,
    );

    await _enterTextByKey(
      tester,
      'settings.electricityCost.input',
      electricityCostPerKwh,
    );
    await _enterTextByKey(
      tester,
      'settings.generalWattage.input',
      generalWattage,
    );
    await _settleDebounce(tester);

    await _tapByKey(tester, 'settings.printers.section');
    await _tapByKey(tester, 'settings.printers.add.button');
    await _enterTextByKey(tester, 'settings.printers.name.input', printerName);
    await _enterTextByKey(
      tester,
      'settings.printers.bedSize.input',
      printerBedSize,
    );
    await _enterTextByKey(
      tester,
      'settings.printers.wattage.input',
      generalWattage,
    );
    await _tapByKey(tester, 'settings.printers.save.button');

    expect(_textFromKey(tester, 'settings.printers.item.0.name'), printerName);
    expect(
      _textFromKey(tester, 'settings.printers.item.0.summary'),
      contains(printerBedSize),
    );
    expect(
      _textFromKey(tester, 'settings.printers.item.0.summary'),
      contains('120'),
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
      materialWeight,
    );
    await _enterTextByKey(
      tester,
      'settings.materials.cost.input',
      materialCostPerKg,
    );
    await _tapByKey(tester, 'settings.materials.save.button');

    expect(
      _textFromKey(tester, 'settings.materials.item.0.name'),
      materialName,
    );
    expect(
      _textFromKey(tester, 'settings.materials.item.0.color'),
      materialColor,
    );
    expect(
      _numberFromTextKey(tester, 'settings.materials.item.0.cost'),
      closeTo(200, 0.001),
    );
    expect(
      _numberFromTextKey(tester, 'settings.materials.item.0.weight'),
      closeTo(1000, 0.001),
    );

    await _tapByKey(tester, 'settings.workCost.section');
    await _scrollSettingsUntilVisible(
      tester,
      'settings.workCost.wearAndTear.input',
    );
    expect(
      find.byKey(const ValueKey<String>('settings.workCost.wearAndTear.input')),
      findsOneWidget,
    );
    expect(find.text('Premium users only:'), findsNothing);

    await _enterTextByKey(
      tester,
      'settings.workCost.wearAndTear.input',
      wearAndTear,
    );
    await _enterTextByKey(
      tester,
      'settings.workCost.failureRisk.input',
      failureRisk,
    );
    await _enterTextByKey(
      tester,
      'settings.workCost.labourRate.input',
      labourRate,
    );
    await _settleDebounce(tester);

    await _tapByKey(tester, 'nav.calculator.button');
    await _tapByKey(tester, 'nav.settings.button');

    await _scrollSettingsUntilVisible(tester, 'settings.general.section');
    await _tapByKey(tester, 'settings.general.section');
    expect(
      _focusSafeFieldText(tester, 'settings.electricityCost.input'),
      anyOf('3.0', '3.00'),
    );
    expect(
      _focusSafeFieldText(tester, 'settings.generalWattage.input'),
      generalWattage,
    );

    await _tapByKey(tester, 'settings.printers.section');
    expect(_textFromKey(tester, 'settings.printers.item.0.name'), printerName);
    expect(
      _textFromKey(tester, 'settings.printers.item.0.summary'),
      contains(printerBedSize),
    );

    await _tapByKey(tester, 'settings.materials.section');
    expect(
      _textFromKey(tester, 'settings.materials.item.0.name'),
      materialName,
    );
    expect(
      _numberFromTextKey(tester, 'settings.materials.item.0.cost'),
      closeTo(200, 0.001),
    );

    await _tapByKey(tester, 'settings.workCost.section');
    await _scrollSettingsUntilVisible(
      tester,
      'settings.workCost.wearAndTear.input',
    );
    expect(
      _focusSafeFieldText(tester, 'settings.workCost.wearAndTear.input'),
      anyOf('1.5', '1.50'),
    );
    expect(
      _focusSafeFieldText(tester, 'settings.workCost.failureRisk.input'),
      anyOf('10.0', '10.00'),
    );
    expect(
      _focusSafeFieldText(tester, 'settings.workCost.labourRate.input'),
      anyOf('25.0', '25.00'),
    );
  });
}

Future<void> _tapByKey(WidgetTester tester, String key) async {
  final finder = find.byKey(ValueKey<String>(key));
  await tester.ensureVisible(finder);
  await tester.tap(finder);
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

Future<void> _scrollSettingsUntilVisible(
  WidgetTester tester,
  String key,
) async {
  final finder = find.byKey(ValueKey<String>(key));
  await tester.scrollUntilVisible(
    finder,
    150,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

Future<void> _settleDebounce(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pumpAndSettle();
}

String _focusSafeFieldText(WidgetTester tester, String key) {
  final widget = tester.widget<FocusSafeTextField>(
    find.byKey(ValueKey<String>(key)),
  );
  return widget.controller.text;
}

String _textFromKey(WidgetTester tester, String key) {
  final widget = tester.widget<Text>(find.byKey(ValueKey<String>(key)));
  return widget.data ?? '';
}

double _numberFromTextKey(WidgetTester tester, String key) {
  return double.parse(
    _textFromKey(tester, key).replaceAll(RegExp(r'[^0-9.\-]'), ''),
  );
}
