import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:threed_print_cost_calculator/database/repositories/printers_repository.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

import 'helpers/patrol_test_bootstrap.dart';
import 'helpers/patrol_test_ui.dart';

void main() {
  const electricityCostPerKwh = 3.00;
  const wattage = 120;
  const materialCostPerKg = 200.00;
  const materialWeightGrams = 1000;
  const printWeightGrams = 150;
  const durationHours = 2;
  const durationMinutes = 30;

  patrolTest('calculates the deterministic free-user journey end to end', (
    $,
  ) async {
    final harness = await launchFreePatrolApp(
      $,
      seed: (harness) async {
        await harness.seedSettings(
          GeneralSettingsModel.initial().copyWith(
            activePrinter: 'free-test-printer',
          ),
        );
        await harness.seedPrinters([
          const PrinterModel(
            id: 'free-test-printer',
            name: 'Free Test Printer',
            bedSize: '220x220x250',
            wattage: '120',
            averageWattage: '120',
            archived: false,
          ),
        ]);
      },
    );

    expect(
      await harness.container.read(printersRepositoryProvider).getPrinters(),
      equals([
        const PrinterModel(
          id: 'free-test-printer',
          name: 'Free Test Printer',
          bedSize: '220x220x250',
          wattage: '120',
          averageWattage: '120',
          archived: false,
        ),
      ]),
    );

    Future<void> scrollSettingsToKey(String key) async {
      final target = find.byKey(patrolKey(key));
      final settingsList = find.byKey(const ValueKey<String>('settings.list'));
      const maxAttempts = 12;

      for (var attempt = 0; attempt < maxAttempts; attempt++) {
        if (target.evaluate().isNotEmpty) {
          return;
        }

        await $.tester.drag(settingsList, const Offset(0, -300));
        await $.tester.pump(const Duration(milliseconds: 100));
      }

      expect(
        target,
        findsOneWidget,
        reason: 'Could not find $key after $maxAttempts scroll attempts',
      );
    }

    await $.tapByKey('nav.settings.button');
    await $.tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(find.byKey(patrolKey('settings.general.section')), findsOneWidget);
    await $.enterTextByKey(
      'settings.electricityCost.input',
      electricityCostPerKwh.toStringAsFixed(2),
    );
    await $.settleDebounce();

    await scrollSettingsToKey('settings.printers.section');
    await scrollSettingsToKey('settings.printers.item.0');
    await $.tester.drag(
      find.byKey(const ValueKey<String>('settings.printers.item.0')),
      const Offset(-300, 0),
    );
    await $.tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(
      find.byKey(patrolKey('settings.printers.item.0.edit.button')),
      findsOneWidget,
    );
    await $.tapByKey('settings.printers.item.0.edit.button');
    await $.enterTextByKey(
      'settings.printers.wattage.input',
      wattage.toString(),
    );
    await $.enterTextByKey(
      'settings.printers.averageWattage.input',
      wattage.toString(),
    );
    await $.tapByKey('settings.printers.save.button');
    await $.settleDebounce();

    await $.expectFieldTextEventually(
      'settings.electricityCost.input',
      anyOf('3.0', '3.00'),
    );

    await $.tapByKey('nav.calculator.button');
    harness.container.read(appRefreshProvider.notifier).refresh();
    await $.tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(
      find.byKey(const ValueKey<String>('calculator.printer.select')),
      findsOneWidget,
    );
    await $.tapByKey('calculator.reset.button');
    await $.tapByKey('calculator.reset.confirm.button');
    await $.tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(
      find.byKey(
        const ValueKey<String>('calculator.printer.field.free-test-printer'),
      ),
      findsOneWidget,
    );
    await $.tapByKey('calculator.materials.add.button');
    await $.tapByKey('calculator.materialPicker.item.Custom material');
    await $.enterTextByKey(
      'calculator.materials.item.0.spoolWeight.input',
      materialWeightGrams.toString(),
    );
    await $.tester.drag(find.byType(ListView).first, const Offset(0, -300));
    await $.tester.pumpAndSettle(const Duration(milliseconds: 100));
    await $.enterTextByKey(
      'calculator.materials.item.0.spoolCost.input',
      materialCostPerKg.toStringAsFixed(2),
    );
    await $.tester.drag(find.byType(ListView).first, const Offset(0, -300));
    await $.tester.pumpAndSettle(const Duration(milliseconds: 100));
    await $.enterTextByKey(
      'calculator.materials.item.0.weight.input',
      printWeightGrams.toString(),
    );

    await $.tapByKey('calculator.duration.button');
    await $.enterTextByKey(
      'calculator.duration.hours.input',
      durationHours.toString(),
    );
    await $.enterTextByKey(
      'calculator.duration.minutes.input',
      durationMinutes.toString(),
    );
    await $.tapByKey('calculator.duration.save.button');
    await $.settleDebounce();
    await $.tester.pumpAndSettle(const Duration(milliseconds: 100));

    final expectedElectricityCost =
        (wattage / 1000) *
        (durationHours + durationMinutes / 60) *
        electricityCostPerKwh;
    final expectedFilamentCost = (printWeightGrams / 1000) * materialCostPerKg;
    final expectedTotalCost = expectedElectricityCost + expectedFilamentCost;

    expect(
      $.numberFromTextKey('calculator.result.electricityCost'),
      closeTo(expectedElectricityCost, 0.001),
    );
    expect(
      $.numberFromTextKey('calculator.result.filamentCost'),
      closeTo(expectedFilamentCost, 0.001),
    );
    expect(
      $.numberFromTextKey('calculator.result.totalCost'),
      closeTo(expectedTotalCost, 0.001),
    );
  });
}
