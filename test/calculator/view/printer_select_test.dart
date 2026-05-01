import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculator_state.dart';
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
    final calculatorNotifier = FakeCalculatorNotifier(
      initialState: CalculatorState(activePrinterId: 'printer-a'),
    );
    final printers = {'printer-a': printer('printer-a', 'Printer A', '120')};

    await tester.pumpApp(const PrinterSelect(), [
      calculatorProvider.overrideWith(() => calculatorNotifier),
      settingsRepositoryProvider.overrideWithValue(settingsRepo),
      printersStreamProvider.overrideWith(
        (ref) => Stream.value(printers.values.toList()),
      ),
    ]);

    await tester.pumpAndSettle();

    final dropdown = tester.widget<DropdownButtonFormField<String>>(
      find.byType(DropdownButtonFormField<String>),
    );
    expect(dropdown.initialValue, 'printer-a');
  });

  testWidgets('changing printer delegates to calculator form state', (
    tester,
  ) async {
    final calculatorNotifier = FakeCalculatorNotifier();
    final printers = [
      printer('printer-a', 'Printer A', '120'),
      printer('printer-b', 'Printer B', '700'),
    ];

    await tester.pumpApp(const PrinterSelect(), [
      calculatorProvider.overrideWith(() => calculatorNotifier),
      printersStreamProvider.overrideWith((ref) => Stream.value(printers)),
    ]);

    await tester.pumpAndSettle();

    final dropdown = tester.widget<DropdownButtonFormField<String>>(
      find.byType(DropdownButtonFormField<String>),
    );
    dropdown.onChanged?.call('printer-b');
    await tester.pumpAndSettle();

    expect(calculatorNotifier.selectedPrinters, ['printer-b']);
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
