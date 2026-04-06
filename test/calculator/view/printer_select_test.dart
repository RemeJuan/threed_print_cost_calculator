import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/calculator/view/printer_select.dart';
import 'package:threed_print_cost_calculator/database/repositories/printers_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';

import '../../helpers/helpers.dart';
import '../../helpers/lower_level_test_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupTest();
  });

  PrinterModel printer(String id, String name, String wattage) {
    return PrinterModel(
      id: id,
      name: name,
      bedSize: '220x220',
      wattage: wattage,
      archived: false,
    );
  }

  testWidgets('initial printer comes from persisted settings', (tester) async {
    final settingsRepo = FakeSettingsRepository(
      initialSettings: GeneralSettingsModel.initial().copyWith(
        activePrinter: 'printer-a',
      ),
    );
    final printers = {'printer-a': printer('printer-a', 'Printer A', '120')};

    await tester.pumpApp(const PrinterSelect(), [
      settingsRepositoryProvider.overrideWithValue(settingsRepo),
      printersStreamProvider.overrideWith(
        (ref) => Stream.value(printers.values.toList()),
      ),
    ]);

    await tester.pumpAndSettle();

    final dropdown = tester.widget<DropdownButtonFormField<String>>(
      find.byKey(const ValueKey<String>('calculator.printer.select')),
    );
    expect(dropdown.initialValue, 'printer-a');
  });

  testWidgets('changing printer saves settings and updates wattage', (
    tester,
  ) async {
    final settingsRepo = FakeSettingsRepository();
    final calculatorNotifier = FakeCalculatorNotifier();
    final printers = [
      printer('printer-a', 'Printer A', '120'),
      printer('printer-b', 'Printer B', '700'),
    ];

    await tester.pumpApp(const PrinterSelect(), [
      calculatorProvider.overrideWith(() => calculatorNotifier),
      settingsRepositoryProvider.overrideWithValue(settingsRepo),
      printersStreamProvider.overrideWith((ref) => Stream.value(printers)),
    ]);

    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey<String>('calculator.printer.select')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('calculator.printer.option.Printer B')),
    );
    await tester.pumpAndSettle();

    expect(settingsRepo.lastSavedSettings?.activePrinter, 'printer-b');
    expect(calculatorNotifier.wattUpdates, ['700']);
  });

  testWidgets('empty printer data hides the select', (tester) async {
    await tester.pumpApp(const PrinterSelect(), [
      printersStreamProvider.overrideWith(
        (ref) => Stream.value(const <PrinterModel>[]),
      ),
    ]);

    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('calculator.printer.select')),
      findsNothing,
    );
  });
}
