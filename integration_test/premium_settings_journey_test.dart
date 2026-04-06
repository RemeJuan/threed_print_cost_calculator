import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/integration_test_harness.dart';
import 'helpers/integration_test_ui.dart';

// Local-only integration smoke test.
// Kept to exercise settings CRUD and revisit flow outside the Patrol gate.
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
    await tester.tapByKey('nav.settings.button');

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

    await tester.enterTextByKey(
      'settings.electricityCost.input',
      electricityCostPerKwh,
    );
    await tester.enterTextByKey(
      'settings.generalWattage.input',
      generalWattage,
    );
    await tester.settleDebounce();

    await tester.tapByKey('settings.printers.section');
    await tester.tapByKey('settings.printers.add.button');
    await tester.enterTextByKey('settings.printers.name.input', printerName);
    await tester.enterTextByKey(
      'settings.printers.bedSize.input',
      printerBedSize,
    );
    await tester.enterTextByKey(
      'settings.printers.wattage.input',
      generalWattage,
    );
    await tester.tapByKey('settings.printers.save.button');

    expect(tester.textFromKey('settings.printers.item.0.name'), printerName);
    expect(
      tester.textFromKey('settings.printers.item.0.summary'),
      contains(printerBedSize),
    );
    expect(
      tester.textFromKey('settings.printers.item.0.summary'),
      contains('120'),
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
      materialWeight,
    );
    await tester.enterTextByKey(
      'settings.materials.cost.input',
      materialCostPerKg,
    );
    await tester.tapByKey('settings.materials.save.button');

    expect(tester.textFromKey('settings.materials.item.0.name'), materialName);
    expect(
      tester.textFromKey('settings.materials.item.0.color'),
      materialColor,
    );
    expect(
      tester.numberFromTextKey('settings.materials.item.0.cost'),
      closeTo(200, 0.001),
    );
    expect(
      tester.numberFromTextKey('settings.materials.item.0.weight'),
      closeTo(1000, 0.001),
    );

    await tester.scrollUntilKeyVisible('settings.workCost.section');
    await tester.tapByKey('settings.workCost.section');
    await tester.scrollUntilKeyVisible('settings.workCost.wearAndTear.input');
    expect(
      find.byKey(const ValueKey<String>('settings.workCost.wearAndTear.input')),
      findsOneWidget,
    );
    expect(find.text('Premium users only:'), findsNothing);

    await tester.enterTextByKey(
      'settings.workCost.wearAndTear.input',
      wearAndTear,
    );
    await tester.enterTextByKey(
      'settings.workCost.failureRisk.input',
      failureRisk,
    );
    await tester.enterTextByKey(
      'settings.workCost.labourRate.input',
      labourRate,
    );
    await tester.settleDebounce();

    await tester.tapByKey('nav.calculator.button');
    await tester.tapByKey('nav.settings.button');

    await tester.scrollUntilKeyVisible('settings.general.section');
    await tester.tapByKey('settings.general.section');
    expect(
      tester.focusSafeFieldText('settings.electricityCost.input'),
      anyOf('3.0', '3.00'),
    );
    expect(
      tester.focusSafeFieldText('settings.generalWattage.input'),
      generalWattage,
    );

    await tester.tapByKey('settings.printers.section');
    expect(tester.textFromKey('settings.printers.item.0.name'), printerName);
    expect(
      tester.textFromKey('settings.printers.item.0.summary'),
      contains(printerBedSize),
    );

    await tester.tapByKey('settings.materials.section');
    expect(tester.textFromKey('settings.materials.item.0.name'), materialName);
    expect(
      tester.numberFromTextKey('settings.materials.item.0.cost'),
      closeTo(200, 0.001),
    );

    await tester.tapByKey('settings.workCost.section');
    await tester.scrollUntilKeyVisible('settings.workCost.wearAndTear.input');
    expect(
      tester.focusSafeFieldText('settings.workCost.wearAndTear.input'),
      anyOf('1.5', '1.50'),
    );
    expect(
      tester.focusSafeFieldText('settings.workCost.failureRisk.input'),
      anyOf('10.0', '10.00'),
    );
    expect(
      tester.focusSafeFieldText('settings.workCost.labourRate.input'),
      anyOf('25.0', '25.00'),
    );
  });
}
