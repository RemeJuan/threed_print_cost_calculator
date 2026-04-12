import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage_input.dart';
import 'package:threed_print_cost_calculator/calculator/helpers/calculator_helpers.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculation_results_state.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculator_state.dart';
import 'package:threed_print_cost_calculator/calculator/view/save_form.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/printers_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/shared/components/num_input.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';

import '../../helpers/helpers.dart';
import '../../helpers/lower_level_test_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupTest();
  });

  PrinterModel printer(String id, String name) {
    return PrinterModel(
      id: id,
      name: name,
      bedSize: '220x220',
      wattage: '120',
      archived: false,
    );
  }

  MaterialModel material(String id, String name) {
    return MaterialModel(
      id: id,
      name: name,
      cost: '20',
      color: '#FFFFFF',
      weight: '1000',
      archived: false,
    );
  }

  void expectHistoryFields({
    required HistoryModelCapture capture,
    required String printer,
    required String material,
    required num weight,
    required String timeHours,
    required List<Map<String, dynamic>> materialUsages,
  }) {
    expect(capture.model, isNotNull);
    expect(capture.model!.printer, printer);
    expect(capture.model!.material, material);
    expect(capture.model!.weight, weight);
    expect(capture.model!.timeHours, timeHours);
    expect(capture.model!.materialUsages, hasLength(materialUsages.length));
    for (var i = 0; i < materialUsages.length; i += 1) {
      expect(
        capture.model!.materialUsages[i]['materialId'],
        materialUsages[i]['materialId'],
      );
      expect(
        capture.model!.materialUsages[i]['materialName'],
        materialUsages[i]['materialName'],
      );
      expect(
        capture.model!.materialUsages[i]['costPerKg'],
        materialUsages[i]['costPerKg'],
      );
      expect(
        capture.model!.materialUsages[i]['weightGrams'],
        materialUsages[i]['weightGrams'],
      );
    }
  }

  testWidgets('falls back to persisted printer and material', (tester) async {
    final settingsRepo = FakeSettingsRepository(
      initialSettings: GeneralSettingsModel.initial().copyWith(
        activePrinter: 'printer-a',
        selectedMaterial: 'material-a',
      ),
    );
    final printersRepo = FakePrintersRepository({
      'printer-a': printer('printer-a', 'Printer A'),
    });
    final materialsRepo = FakeMaterialsRepository({
      'material-a': material('material-a', 'PLA Black'),
    });
    final helpers = FakeCalculatorHelpers();
    final calculatorState = CalculatorState(
      printWeight: const NumberInput.dirty(value: 95),
      hours: const NumberInput.dirty(value: 1),
      minutes: const NumberInput.dirty(value: 5),
    );
    final calculatorNotifier = FakeCalculatorNotifier(
      initialState: calculatorState,
    );
    final showSave = ValueNotifier<bool>(true);
    final data = const CalculationResult(
      electricity: 1.2,
      filament: 3.4,
      risk: 0.5,
      labour: 2.0,
      total: 7.1,
    );

    await tester.pumpApp(SaveForm(data: data, showSave: showSave), [
      calculatorProvider.overrideWith(() => calculatorNotifier),
      settingsRepositoryProvider.overrideWithValue(settingsRepo),
      printersRepositoryProvider.overrideWithValue(printersRepo),
      materialsRepositoryProvider.overrideWithValue(materialsRepo),
      calculatorHelpersProvider.overrideWithValue(helpers),
    ]);

    await tester.pumpAndSettle();

    tester
        .widget<TextField>(
          find.byKey(const ValueKey<String>('calculator.save.name.input')),
        )
        .onChanged
        ?.call('Benchy');
    await tester.pump();
    tester
        .widget<IconButton>(
          find.byKey(const ValueKey<String>('calculator.save.confirm.button')),
        )
        .onPressed
        ?.call();
    await tester.pump();

    expectHistoryFields(
      capture: HistoryModelCapture(helpers.lastSavedPrint),
      printer: 'Printer A',
      material: 'PLA Black',
      weight: 95,
      timeHours: '01:05',
      materialUsages: [
        const MaterialUsageInput(
          materialId: 'material-a',
          materialName: 'PLA Black',
          costPerKg: 0,
          weightGrams: 95,
        ).toMap(),
      ],
    );
    expect(showSave.value, isFalse);
  });

  testWidgets('summarizes multi-material payload deterministically', (
    tester,
  ) async {
    final settingsRepo = FakeSettingsRepository(
      initialSettings: GeneralSettingsModel.initial(),
    );
    final helpers = FakeCalculatorHelpers();
    final calculatorNotifier = FakeCalculatorNotifier(
      initialState: CalculatorState(
        materialUsages: const [
          MaterialUsageInput(
            materialId: 'material-a',
            materialName: 'PLA',
            costPerKg: 20,
            weightGrams: 40,
          ),
          MaterialUsageInput(
            materialId: 'material-b',
            materialName: 'ABS',
            costPerKg: 30,
            weightGrams: 60,
          ),
        ],
        hours: const NumberInput.dirty(value: 2),
        minutes: const NumberInput.dirty(value: 3),
      ),
    );
    final showSave = ValueNotifier<bool>(true);

    await tester.pumpApp(
      SaveForm(
        data: const CalculationResult(
          electricity: 0,
          filament: 0,
          risk: 0,
          labour: 0,
          total: 0,
        ),
        showSave: showSave,
      ),
      [
        calculatorProvider.overrideWith(() => calculatorNotifier),
        settingsRepositoryProvider.overrideWithValue(settingsRepo),
        printersRepositoryProvider.overrideWithValue(FakePrintersRepository()),
        materialsRepositoryProvider.overrideWithValue(
          FakeMaterialsRepository(),
        ),
        calculatorHelpersProvider.overrideWithValue(helpers),
      ],
    );

    await tester.pumpAndSettle();

    tester
        .widget<TextField>(
          find.byKey(const ValueKey<String>('calculator.save.name.input')),
        )
        .onChanged
        ?.call('Dual material');
    await tester.pump();
    tester
        .widget<IconButton>(
          find.byKey(const ValueKey<String>('calculator.save.confirm.button')),
        )
        .onPressed
        ?.call();
    await tester.pump();

    expectHistoryFields(
      capture: HistoryModelCapture(helpers.lastSavedPrint),
      printer: '',
      material: 'PLA +1',
      weight: 100,
      timeHours: '02:03',
      materialUsages: const [
        {
          'materialId': 'material-a',
          'materialName': 'PLA',
          'costPerKg': 20,
          'weightGrams': 40,
        },
        {
          'materialId': 'material-b',
          'materialName': 'ABS',
          'costPerKg': 30,
          'weightGrams': 60,
        },
      ],
    );
  });

  testWidgets('cancel does not save anything', (tester) async {
    final helpers = FakeCalculatorHelpers();
    final showSave = ValueNotifier<bool>(true);
    final settingsRepo = FakeSettingsRepository(
      initialSettings: GeneralSettingsModel.initial(),
    );
    final calculatorNotifier = FakeCalculatorNotifier(
      initialState: CalculatorState(),
    );

    await tester.pumpApp(
      SaveForm(
        data: const CalculationResult(
          electricity: 0,
          filament: 0,
          risk: 0,
          labour: 0,
          total: 0,
        ),
        showSave: showSave,
      ),
      [
        calculatorProvider.overrideWith(() => calculatorNotifier),
        settingsRepositoryProvider.overrideWithValue(settingsRepo),
        printersRepositoryProvider.overrideWithValue(FakePrintersRepository()),
        materialsRepositoryProvider.overrideWithValue(
          FakeMaterialsRepository(),
        ),
        calculatorHelpersProvider.overrideWithValue(helpers),
      ],
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey<String>('calculator.save.cancel.button')),
    );
    await tester.pumpAndSettle();

    expect(helpers.lastSavedPrint, isNull);
    expect(showSave.value, isFalse);
  });
}

class HistoryModelCapture {
  HistoryModelCapture(this.model);

  final HistoryModel? model;
}
