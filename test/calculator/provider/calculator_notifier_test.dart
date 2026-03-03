import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage_input.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculator_state.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/settings/model/settings_model.dart';

void main() {
  late Database db;
  late ProviderContainer container;

  setUp(() async {
    final name = 'test_calculator_${DateTime.now().microsecondsSinceEpoch}.db';
    db = await databaseFactoryMemory.openDatabase(name);

    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
      ],
    );

    // Initialize settings with defaults
    final settingsStore = stringMapStoreFactory.store(DBName.settings.name);
    await settingsStore.record('settings').put(db, {
      'wattage': '200',
      'electricityCost': '1.5',
      'wearAndTear': '5',
      'failureRisk': '10',
      'labourRate': '15',
      'activePrinter': '',
      'selectedMaterial': '',
    });
  });

  tearDown(() async {
    await db.close();
    container.dispose();
  });

  group('CalculatorProvider', () {
    test('build returns initial state', () {
      final notifier = container.read(calculatorProvider.notifier);
      final state = notifier.build();

      expect(state.materialUsages, isEmpty);
      expect(state.spoolCostText, equals(''));
      expect(state.results.total, equals(0.0));
    });

    test('updateWatt updates watt value', () {
      final notifier = container.read(calculatorProvider.notifier);

      notifier.updateWatt('250');

      expect(notifier.state.watt.value, equals(250));
    });

    test('updateWatt handles comma decimal separator', () {
      final notifier = container.read(calculatorProvider.notifier);

      notifier.updateWatt('250,5');

      expect(notifier.state.watt.value, equals(250.5));
    });

    test('updateWatt handles invalid input with 0', () {
      final notifier = container.read(calculatorProvider.notifier);

      notifier.updateWatt('invalid');

      expect(notifier.state.watt.value, equals(0));
    });

    test('updateKwCost updates kwCost value', () {
      final notifier = container.read(calculatorProvider.notifier);

      notifier.updateKwCost('2.5');

      expect(notifier.state.kwCost.value, equals(2.5));
    });

    test('updateKwCost handles comma decimal separator', () {
      final notifier = container.read(calculatorProvider.notifier);

      notifier.updateKwCost('2,5');

      expect(notifier.state.kwCost.value, equals(2.5));
    });

    test('updatePrintWeight updates weight and single material usage', () {
      final notifier = container.read(calculatorProvider.notifier);

      notifier.state = notifier.state.copyWith(
        materialUsages: [
          const MaterialUsageInput(
            materialId: 'mat-1',
            materialName: 'PLA Black',
            costPerKg: 200,
            weightGrams: 0,
          ),
        ],
      );

      notifier.updatePrintWeight('150');

      expect(notifier.state.printWeight.value, equals(150));
      expect(notifier.state.materialUsages[0].weightGrams, equals(150));
    });

    test('updatePrintWeight does not update multiple material usages', () {
      final notifier = container.read(calculatorProvider.notifier);

      notifier.state = notifier.state.copyWith(
        materialUsages: [
          const MaterialUsageInput(
            materialId: 'mat-1',
            materialName: 'PLA Black',
            costPerKg: 200,
            weightGrams: 100,
          ),
          const MaterialUsageInput(
            materialId: 'mat-2',
            materialName: 'PLA White',
            costPerKg: 250,
            weightGrams: 50,
          ),
        ],
      );

      notifier.updatePrintWeight('200');

      expect(notifier.state.printWeight.value, equals(200));
      expect(notifier.state.materialUsages[0].weightGrams, equals(100));
      expect(notifier.state.materialUsages[1].weightGrams, equals(50));
    });

    test('addMaterialUsage adds new material to list', () {
      final notifier = container.read(calculatorProvider.notifier);

      const usage = MaterialUsageInput(
        materialId: 'mat-1',
        materialName: 'PLA Black',
        costPerKg: 200,
        weightGrams: 100,
      );

      notifier.addMaterialUsage(usage);

      expect(notifier.state.materialUsages.length, equals(1));
      expect(notifier.state.materialUsages[0].materialId, equals('mat-1'));
      expect(notifier.state.materialUsages[0].materialName, equals('PLA Black'));
    });

    test('addMaterialUsage can add multiple materials', () {
      final notifier = container.read(calculatorProvider.notifier);

      const usage1 = MaterialUsageInput(
        materialId: 'mat-1',
        materialName: 'PLA Black',
        costPerKg: 200,
        weightGrams: 100,
      );

      const usage2 = MaterialUsageInput(
        materialId: 'mat-2',
        materialName: 'PLA White',
        costPerKg: 250,
        weightGrams: 50,
      );

      notifier.addMaterialUsage(usage1);
      notifier.addMaterialUsage(usage2);

      expect(notifier.state.materialUsages.length, equals(2));
    });

    test('removeMaterialUsageAt removes material at valid index', () {
      final notifier = container.read(calculatorProvider.notifier);

      notifier.state = notifier.state.copyWith(
        materialUsages: [
          const MaterialUsageInput(
            materialId: 'mat-1',
            materialName: 'PLA Black',
            costPerKg: 200,
            weightGrams: 100,
          ),
          const MaterialUsageInput(
            materialId: 'mat-2',
            materialName: 'PLA White',
            costPerKg: 250,
            weightGrams: 50,
          ),
        ],
      );

      notifier.removeMaterialUsageAt(0);

      expect(notifier.state.materialUsages.length, equals(1));
      expect(notifier.state.materialUsages[0].materialId, equals('mat-2'));
    });

    test('removeMaterialUsageAt does nothing for invalid index', () {
      final notifier = container.read(calculatorProvider.notifier);

      notifier.state = notifier.state.copyWith(
        materialUsages: [
          const MaterialUsageInput(
            materialId: 'mat-1',
            materialName: 'PLA Black',
            costPerKg: 200,
            weightGrams: 100,
          ),
        ],
      );

      notifier.removeMaterialUsageAt(5);

      expect(notifier.state.materialUsages.length, equals(1));
    });

    test('removeMaterialUsageAt does nothing for negative index', () {
      final notifier = container.read(calculatorProvider.notifier);

      notifier.state = notifier.state.copyWith(
        materialUsages: [
          const MaterialUsageInput(
            materialId: 'mat-1',
            materialName: 'PLA Black',
            costPerKg: 200,
            weightGrams: 100,
          ),
        ],
      );

      notifier.removeMaterialUsageAt(-1);

      expect(notifier.state.materialUsages.length, equals(1));
    });

    test('removeMaterialUsageAt does not remove Unassigned placeholder', () {
      final notifier = container.read(calculatorProvider.notifier);

      notifier.state = notifier.state.copyWith(
        materialUsages: [
          const MaterialUsageInput(
            materialId: 'none',
            materialName: 'Unassigned',
            costPerKg: 0,
            weightGrams: 0,
          ),
        ],
      );

      notifier.removeMaterialUsageAt(0);

      expect(notifier.state.materialUsages.length, equals(1));
      expect(notifier.state.materialUsages[0].materialId, equals('none'));
    });

    test('removeMaterialUsageAt does not remove empty id placeholder', () {
      final notifier = container.read(calculatorProvider.notifier);

      notifier.state = notifier.state.copyWith(
        materialUsages: [
          const MaterialUsageInput(
            materialId: '',
            materialName: 'Unassigned',
            costPerKg: 0,
            weightGrams: 0,
          ),
        ],
      );

      notifier.removeMaterialUsageAt(0);

      expect(notifier.state.materialUsages.length, equals(1));
    });

    test('removeMaterialUsageAt adds placeholder when removing last material', () {
      final notifier = container.read(calculatorProvider.notifier);

      notifier.state = notifier.state.copyWith(
        materialUsages: [
          const MaterialUsageInput(
            materialId: 'mat-1',
            materialName: 'PLA Black',
            costPerKg: 200,
            weightGrams: 100,
          ),
        ],
      );

      notifier.removeMaterialUsageAt(0);

      expect(notifier.state.materialUsages.length, equals(1));
      expect(notifier.state.materialUsages[0].materialId, equals('none'));
      expect(notifier.state.materialUsages[0].materialName, equals('Unassigned'));
    });

    test('removeMaterialUsageAt updates printWeight', () {
      final notifier = container.read(calculatorProvider.notifier);

      notifier.state = notifier.state.copyWith(
        materialUsages: [
          const MaterialUsageInput(
            materialId: 'mat-1',
            materialName: 'PLA Black',
            costPerKg: 200,
            weightGrams: 100,
          ),
          const MaterialUsageInput(
            materialId: 'mat-2',
            materialName: 'PLA White',
            costPerKg: 250,
            weightGrams: 50,
          ),
        ],
      );

      notifier.removeMaterialUsageAt(0);

      expect(notifier.state.printWeight.value, equals(50));
    });

    test('updateMaterialUsageWeight updates weight at index', () {
      final notifier = container.read(calculatorProvider.notifier);

      notifier.state = notifier.state.copyWith(
        materialUsages: [
          const MaterialUsageInput(
            materialId: 'mat-1',
            materialName: 'PLA Black',
            costPerKg: 200,
            weightGrams: 100,
          ),
        ],
      );

      notifier.updateMaterialUsageWeight(0, 150);

      expect(notifier.state.materialUsages[0].weightGrams, equals(150));
    });

    test('updateMaterialUsageWeight updates total printWeight', () {
      final notifier = container.read(calculatorProvider.notifier);

      notifier.state = notifier.state.copyWith(
        materialUsages: [
          const MaterialUsageInput(
            materialId: 'mat-1',
            materialName: 'PLA Black',
            costPerKg: 200,
            weightGrams: 100,
          ),
          const MaterialUsageInput(
            materialId: 'mat-2',
            materialName: 'PLA White',
            costPerKg: 250,
            weightGrams: 50,
          ),
        ],
      );

      notifier.updateMaterialUsageWeight(0, 150);

      expect(notifier.state.printWeight.value, equals(200));
    });

    test('updateMaterialUsageWeight handles multiple materials', () {
      final notifier = container.read(calculatorProvider.notifier);

      notifier.state = notifier.state.copyWith(
        materialUsages: [
          const MaterialUsageInput(
            materialId: 'mat-1',
            materialName: 'PLA Black',
            costPerKg: 200,
            weightGrams: 100,
          ),
          const MaterialUsageInput(
            materialId: 'mat-2',
            materialName: 'PLA White',
            costPerKg: 250,
            weightGrams: 50,
          ),
          const MaterialUsageInput(
            materialId: 'mat-3',
            materialName: 'PETG',
            costPerKg: 300,
            weightGrams: 25,
          ),
        ],
      );

      notifier.updateMaterialUsageWeight(1, 75);

      expect(notifier.state.materialUsages[1].weightGrams, equals(75));
      expect(notifier.state.printWeight.value, equals(200));
    });

    test('applySingleTotalWeightToFirstRow applies weight to first row', () {
      final notifier = container.read(calculatorProvider.notifier);

      notifier.state = notifier.state.copyWith(
        printWeight: const NumberInput.dirty(value: 200),
        materialUsages: [
          const MaterialUsageInput(
            materialId: 'mat-1',
            materialName: 'PLA Black',
            costPerKg: 200,
            weightGrams: 0,
          ),
        ],
      );

      notifier.applySingleTotalWeightToFirstRow();

      expect(notifier.state.materialUsages[0].weightGrams, equals(200));
    });

    test('applySingleTotalWeightToFirstRow does nothing when no materials', () {
      final notifier = container.read(calculatorProvider.notifier);

      notifier.state = notifier.state.copyWith(
        printWeight: const NumberInput.dirty(value: 200),
        materialUsages: [],
      );

      notifier.applySingleTotalWeightToFirstRow();

      expect(notifier.state.materialUsages, isEmpty);
    });

    test('updateHours updates hours value', () {
      final notifier = container.read(calculatorProvider.notifier);

      notifier.updateHours(3);

      expect(notifier.state.hours.value, equals(3));
    });

    test('updateMinutes updates minutes value', () {
      final notifier = container.read(calculatorProvider.notifier);

      notifier.updateMinutes(45);

      expect(notifier.state.minutes.value, equals(45));
    });

    test('updateSpoolWeight updates spoolWeight value', () {
      final notifier = container.read(calculatorProvider.notifier);

      notifier.updateSpoolWeight(750);

      expect(notifier.state.spoolWeight.value, equals(750));
    });

    test('updateSpoolCost updates spoolCost and spoolCostText', () {
      final notifier = container.read(calculatorProvider.notifier);

      notifier.updateSpoolCost('25.50');

      expect(notifier.state.spoolCost.value, equals(25.50));
      expect(notifier.state.spoolCostText, equals('25.50'));
    });

    test('setWearAndTear updates wearAndTear locally without DB', () {
      final notifier = container.read(calculatorProvider.notifier);

      notifier.setWearAndTear(7);

      expect(notifier.state.wearAndTear.value, equals(7));
    });

    test('setFailureRisk updates failureRisk locally without DB', () {
      final notifier = container.read(calculatorProvider.notifier);

      notifier.setFailureRisk(15);

      expect(notifier.state.failureRisk.value, equals(15));
    });

    test('setLabourRate updates labourRate locally without DB', () {
      final notifier = container.read(calculatorProvider.notifier);

      notifier.setLabourRate(20);

      expect(notifier.state.labourRate.value, equals(20));
    });

    test('updateResults updates results', () {
      final notifier = container.read(calculatorProvider.notifier);

      const results = CalculationResult(
        electricity: 2.0,
        filament: 3.0,
        risk: 1.0,
        labour: 20.0,
        total: 26.0,
      );

      notifier.updateResults(results);

      expect(notifier.state.results.total, equals(26.0));
      expect(notifier.state.results.electricity, equals(2.0));
      expect(notifier.state.results.filament, equals(3.0));
    });

    test('submit calculates all costs correctly', () {
      final notifier = container.read(calculatorProvider.notifier);

      notifier.state = notifier.state.copyWith(
        watt: const NumberInput.dirty(value: 200),
        kwCost: const NumberInput.dirty(value: 1.5),
        hours: const NumberInput.dirty(value: 2),
        minutes: const NumberInput.dirty(value: 0),
        materialUsages: [
          const MaterialUsageInput(
            materialId: 'mat-1',
            materialName: 'PLA Black',
            costPerKg: 200,
            weightGrams: 100,
          ),
        ],
        wearAndTear: const NumberInput.dirty(value: 5),
        labourRate: const NumberInput.dirty(value: 15),
        labourTime: const NumberInput.dirty(value: 1),
        failureRisk: const NumberInput.dirty(value: 10),
      );

      notifier.submit();

      expect(notifier.state.results.electricity, greaterThan(0));
      expect(notifier.state.results.filament, equals(20.0));
      expect(notifier.state.results.labour, equals(15.0));
      expect(notifier.state.results.risk, greaterThan(0));
      expect(notifier.state.results.total, greaterThan(0));
    });

    test('submit handles zero values gracefully', () {
      final notifier = container.read(calculatorProvider.notifier);

      notifier.state = CalculatorState();

      notifier.submit();

      expect(notifier.state.results.electricity, equals(0));
      expect(notifier.state.results.filament, equals(0));
      expect(notifier.state.results.labour, equals(0));
      expect(notifier.state.results.total, equals(0));
    });

    test('submit uses multi-material cost when available', () {
      final notifier = container.read(calculatorProvider.notifier);

      notifier.state = notifier.state.copyWith(
        materialUsages: [
          const MaterialUsageInput(
            materialId: 'mat-1',
            materialName: 'PLA Black',
            costPerKg: 200,
            weightGrams: 100,
          ),
          const MaterialUsageInput(
            materialId: 'mat-2',
            materialName: 'PLA White',
            costPerKg: 250,
            weightGrams: 50,
          ),
        ],
      );

      notifier.submit();

      expect(notifier.state.results.filament, equals(32.5));
    });

    test('submit falls back to legacy cost when no material usages', () {
      final notifier = container.read(calculatorProvider.notifier);

      notifier.state = notifier.state.copyWith(
        printWeight: const NumberInput.dirty(value: 100),
        spoolWeight: const NumberInput.dirty(value: 1000),
        spoolCost: const NumberInput.dirty(value: 200),
        materialUsages: [],
      );

      notifier.submit();

      expect(notifier.state.results.filament, equals(20.0));
    });

    test('submit ignores multi-material when all weights are zero', () {
      final notifier = container.read(calculatorProvider.notifier);

      notifier.state = notifier.state.copyWith(
        printWeight: const NumberInput.dirty(value: 100),
        spoolWeight: const NumberInput.dirty(value: 1000),
        spoolCost: const NumberInput.dirty(value: 200),
        materialUsages: [
          const MaterialUsageInput(
            materialId: 'mat-1',
            materialName: 'PLA Black',
            costPerKg: 200,
            weightGrams: 0,
          ),
        ],
      );

      notifier.submit();

      expect(notifier.state.results.filament, equals(20.0));
    });

    test('submit calculates risk percentage correctly', () {
      final notifier = container.read(calculatorProvider.notifier);

      notifier.state = notifier.state.copyWith(
        watt: const NumberInput.dirty(value: 200),
        kwCost: const NumberInput.dirty(value: 1.0),
        hours: const NumberInput.dirty(value: 1),
        minutes: const NumberInput.dirty(value: 0),
        materialUsages: [
          const MaterialUsageInput(
            materialId: 'mat-1',
            materialName: 'PLA',
            costPerKg: 200,
            weightGrams: 100,
          ),
        ],
        wearAndTear: const NumberInput.dirty(value: 0),
        labourRate: const NumberInput.dirty(value: 0),
        labourTime: const NumberInput.dirty(value: 0),
        failureRisk: const NumberInput.dirty(value: 10),
      );

      notifier.submit();

      final expectedElectricity = 0.2;
      final expectedFilament = 20.0;
      final expectedTotal = expectedElectricity + expectedFilament;
      final expectedRisk = (10 / 100 * expectedTotal);

      expect(notifier.state.results.risk, closeTo(expectedRisk, 0.01));
    });

    test('submitDebounced schedules debounced submit', () async {
      final notifier = container.read(calculatorProvider.notifier);

      notifier.state = notifier.state.copyWith(
        materialUsages: [
          const MaterialUsageInput(
            materialId: 'mat-1',
            materialName: 'PLA Black',
            costPerKg: 200,
            weightGrams: 100,
          ),
        ],
      );

      notifier.submitDebounced(delay: const Duration(milliseconds: 10));

      await Future.delayed(const Duration(milliseconds: 50));

      expect(notifier.state.results.filament, equals(20.0));
    });

    test('submitDebounced cancels previous debounce', () async {
      final notifier = container.read(calculatorProvider.notifier);

      notifier.state = notifier.state.copyWith(
        materialUsages: [
          const MaterialUsageInput(
            materialId: 'mat-1',
            materialName: 'PLA Black',
            costPerKg: 200,
            weightGrams: 100,
          ),
        ],
      );

      notifier.submitDebounced(delay: const Duration(milliseconds: 100));
      notifier.submitDebounced(delay: const Duration(milliseconds: 10));

      await Future.delayed(const Duration(milliseconds: 50));

      expect(notifier.state.results.filament, equals(20.0));
    });

    test('handles case-insensitive "NONE" material id', () {
      final notifier = container.read(calculatorProvider.notifier);

      notifier.state = notifier.state.copyWith(
        materialUsages: [
          const MaterialUsageInput(
            materialId: 'NONE',
            materialName: 'Unassigned',
            costPerKg: 0,
            weightGrams: 0,
          ),
        ],
      );

      notifier.removeMaterialUsageAt(0);

      expect(notifier.state.materialUsages.length, equals(1));
      expect(notifier.state.materialUsages[0].materialId.toLowerCase(), equals('none'));
    });

    test('handles whitespace in material id for removal', () {
      final notifier = container.read(calculatorProvider.notifier);

      notifier.state = notifier.state.copyWith(
        materialUsages: [
          const MaterialUsageInput(
            materialId: '  none  ',
            materialName: 'Unassigned',
            costPerKg: 0,
            weightGrams: 0,
          ),
        ],
      );

      notifier.removeMaterialUsageAt(0);

      expect(notifier.state.materialUsages.length, equals(1));
    });
  });
}