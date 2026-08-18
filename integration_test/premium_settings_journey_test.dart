import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
  const wearAndTear = '1.50';
  const failureRisk = '10.00';
  const labourRate = '25.00';
  testWidgets('premium user can configure premium settings', (tester) async {
    final harness = await IntegrationTestHarness.premium();
    addTearDown(harness.dispose);

    await tester.launchHarnessApp(harness);
    await tester.tapByKey('nav.settings.button');
    await tester.pump();
    final settingsList = find.byKey(const ValueKey<String>('settings.list'));
    await tester.scrollUntilKeyVisibleInScrollable(
      'settings.electricityCost.input',
      scrollable: settingsList,
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

    expect(
      find.byKey(const ValueKey<String>('settings.general.section')),
      findsOneWidget,
    );

    await tester.scrollUntilKeyVisibleInScrollable(
      'settings.printers.add.button',
      scrollable: settingsList,
    );
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
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(tester.textFromKey('settings.printers.item.0.name'), printerName);
    expect(
      tester.textFromKey('settings.printers.item.0.summary'),
      contains(printerBedSize),
    );
    expect(
      tester.textFromKey('settings.printers.item.0.summary'),
      contains('120'),
    );

    await tester.scrollUntilKeyVisibleInScrollable(
      'settings.workCost.section',
      scrollable: settingsList,
      delta: -150,
    );
    await tester.scrollUntilKeyVisibleInScrollable(
      'settings.workCost.wearAndTear.input',
      scrollable: settingsList,
      delta: -150,
    );
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
  });

  testWidgets('premium printer CRUD journey', (tester) async {
    final harness = await IntegrationTestHarness.premium();
    addTearDown(harness.dispose);

    await tester.launchHarnessApp(harness);
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    final printersRepository = harness.container.read(
      printersRepositoryProvider,
    );

    await tester.tapByKey('nav.settings.button');
    await tester.pumpAndSettle(const Duration(seconds: 3));
    await waitForKeyEventually(tester, 'settings.general.section');
    await tester.scrollUntilKeyVisible('settings.printers.section');
    await tester.scrollUntilKeyVisible('settings.printers.add.button');
    await tester.tapByKey('settings.printers.add.button');
    await tester.enterTextByKey('settings.printers.name.input', 'Printer A');
    await tester.enterTextByKey(
      'settings.printers.bedSize.input',
      '220x220x250',
    );
    await tester.enterTextByKey('settings.printers.wattage.input', '120');
    await tester.tapByKey('settings.printers.save.button');
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

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
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
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
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

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
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    await tester.tapByKey('nav.settings.button');
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    await waitForKeyEventually(tester, 'settings.general.section');
    await tester.scrollUntilKeyVisible('settings.printers.section');
    await tester.scrollUntilKeyVisible('settings.printers.item.0.name');
    expect(
      tester.textFromKey('settings.printers.item.0.name'),
      'Printer A Edited',
    );

    await tester.drag(
      find.byKey(const ValueKey<String>('settings.printers.item.0')),
      const Offset(-300, 0),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
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
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
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
}
