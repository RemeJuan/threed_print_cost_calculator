import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/printers_repository.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';

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

  testWidgets('premium printer CRUD journey', (tester) async {
    final harness = await IntegrationTestHarness.premium();
    addTearDown(harness.dispose);

    await tester.launchHarnessApp(harness);
    final printersRepository = harness.container.read(
      printersRepositoryProvider,
    );

    await tester.tapByKey('nav.settings.button');
    await tester.tapByKey('settings.printers.section');
    await tester.tapByKey('settings.printers.add.button');
    await tester.enterTextByKey('settings.printers.name.input', 'Printer A');
    await tester.enterTextByKey(
      'settings.printers.bedSize.input',
      '220x220x250',
    );
    await tester.enterTextByKey('settings.printers.wattage.input', '120');
    await tester.tapByKey('settings.printers.save.button');

    expect(tester.textFromKey('settings.printers.item.0.name'), 'Printer A');
    expect(
      tester.textFromKey('settings.printers.item.0.summary'),
      contains('220x220x250'),
    );
    expect(await printersRepository.count(), 1);
    final printer = (await printersRepository.getPrinters()).single;
    final printerId = printer.id;

    await tester.drag(
      find.byKey(const ValueKey<String>('settings.printers.item.0')),
      const Offset(-300, 0),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(
        const ValueKey<String>('settings.printers.item.0.edit.button'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterTextByKey(
      'settings.printers.name.input',
      'Printer A Edited',
    );
    await tester.enterTextByKey(
      'settings.printers.bedSize.input',
      '300x300x300',
    );
    await tester.enterTextByKey('settings.printers.wattage.input', '150');
    await tester.tapByKey('settings.printers.save.button');

    expect(
      tester.textFromKey('settings.printers.item.0.name'),
      'Printer A Edited',
    );
    expect(
      tester.textFromKey('settings.printers.item.0.summary'),
      contains('300x300x300'),
    );
    final editedPrinter = await printersRepository.getPrinterById(printerId);
    expect(editedPrinter?.name, 'Printer A Edited');
    expect(editedPrinter?.bedSize, '300x300x300');
    expect(editedPrinter?.wattage, '150');

    await tester.tapByKey('nav.calculator.button');
    await tester.tapByKey('nav.settings.button');
    await tester.tapByKey('settings.printers.section');
    expect(
      tester.textFromKey('settings.printers.item.0.name'),
      'Printer A Edited',
    );

    await tester.drag(
      find.byKey(const ValueKey<String>('settings.printers.item.0')),
      const Offset(-300, 0),
    );
    await tester.pumpAndSettle();
    final printerItemFinder = find.byKey(
      const ValueKey<String>('settings.printers.item.0'),
    );
    await tester.tap(
      find
          .descendant(
            of: printerItemFinder,
            matching: find.byType(CustomSlidableAction),
          )
          .first,
    );
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    final printerDeleteDialog = find.byType(AlertDialog);
    await tester.tap(
      find
          .descendant(
            of: printerDeleteDialog,
            matching: find.byType(AppTertiaryButton),
          )
          .last,
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('settings.printers.item.0')),
      findsNothing,
    );
    expect(await printersRepository.count(), 0);
    expect(await printersRepository.getPrinterById(printerId), isNull);
  });

  testWidgets('premium material CRUD journey', (tester) async {
    final harness = await IntegrationTestHarness.premium();
    addTearDown(harness.dispose);

    await tester.launchHarnessApp(harness);
    final materialsRepository = harness.container.read(
      materialsRepositoryProvider,
    );

    await tester.tapByKey('nav.settings.button');
    await tester.tapByKey('settings.materials.section');
    await tester.tapByKey('settings.materials.add.button');
    await tester.enterTextByKey('settings.materials.name.input', 'Material A');
    await tester.enterTextByKey('settings.materials.color.input', 'Black');
    await tester.enterTextByKey('settings.materials.weight.input', '1000');
    await tester.enterTextByKey('settings.materials.cost.input', '20.00');
    await tester.tapByKey('settings.materials.save.button');

    expect(tester.textFromKey('settings.materials.item.0.name'), 'Material A');
    expect(tester.textFromKey('settings.materials.item.0.color'), 'Black');
    expect(await materialsRepository.count(), 1);
    final material = (await materialsRepository.getMaterials()).single;
    final materialId = material.id;

    await tester.drag(
      find.byKey(const ValueKey<String>('settings.materials.item.0')),
      const Offset(-300, 0),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(
        const ValueKey<String>('settings.materials.item.0.edit.button'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterTextByKey(
      'settings.materials.name.input',
      'Material A Edited',
    );
    await tester.enterTextByKey('settings.materials.color.input', 'Gray');
    await tester.enterTextByKey('settings.materials.weight.input', '900');
    await tester.enterTextByKey('settings.materials.cost.input', '22.50');
    await tester.tapByKey('settings.materials.save.button');

    expect(
      tester.textFromKey('settings.materials.item.0.name'),
      'Material A Edited',
    );
    expect(tester.textFromKey('settings.materials.item.0.color'), 'Gray');
    expect(
      tester.numberFromTextKey('settings.materials.item.0.weight'),
      closeTo(900, 0.001),
    );
    expect(
      tester.numberFromTextKey('settings.materials.item.0.cost'),
      closeTo(22.5, 0.001),
    );
    final editedMaterial = await materialsRepository.getMaterialById(
      materialId,
    );
    expect(editedMaterial?.name, 'Material A Edited');
    expect(editedMaterial?.color, 'Gray');
    expect(editedMaterial?.weight, '900');
    expect(editedMaterial?.cost, '22.50');

    await tester.tapByKey('nav.calculator.button');
    await tester.tapByKey('nav.settings.button');
    await tester.tapByKey('settings.materials.section');
    expect(
      tester.textFromKey('settings.materials.item.0.name'),
      'Material A Edited',
    );

    await tester.drag(
      find.byKey(const ValueKey<String>('settings.materials.item.0')),
      const Offset(-300, 0),
    );
    await tester.pumpAndSettle();
    final materialItemFinder = find.byKey(
      const ValueKey<String>('settings.materials.item.0'),
    );
    await tester.tap(
      find
          .descendant(
            of: materialItemFinder,
            matching: find.byType(CustomSlidableAction),
          )
          .first,
    );
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    final materialDeleteDialog = find.byType(AlertDialog);
    await tester.tap(
      find
          .descendant(
            of: materialDeleteDialog,
            matching: find.byType(AppTertiaryButton),
          )
          .last,
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('settings.materials.item.0')),
      findsNothing,
    );
    expect(await materialsRepository.count(), 0);
    expect(await materialsRepository.getMaterialById(materialId), isNull);
  });
}
