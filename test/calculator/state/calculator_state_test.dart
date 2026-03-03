import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage_input.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculator_state.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculation_results_state.dart';
import 'package:threed_print_cost_calculator/shared/components/num_input.dart';

void main() {
  group('CalculatorState', () {
    test('creates instance with default values', () {
      final state = CalculatorState();

      expect(state.watt, equals(const NumberInput.pure()));
      expect(state.kwCost, equals(const NumberInput.pure()));
      expect(state.printWeight, equals(const NumberInput.pure()));
      expect(state.materialUsages, equals(const <MaterialUsageInput>[]));
      expect(state.hours, equals(const NumberInput.pure()));
      expect(state.minutes, equals(const NumberInput.pure()));
      expect(state.spoolWeight, equals(const NumberInput.pure()));
      expect(state.spoolCost, equals(const NumberInput.pure()));
      expect(state.spoolCostText, equals(''));
      expect(state.wearAndTear, equals(const NumberInput.pure()));
      expect(state.failureRisk, equals(const NumberInput.pure()));
      expect(state.labourRate, equals(const NumberInput.pure()));
      expect(state.labourTime, equals(const NumberInput.pure()));
      expect(state.results.electricity, equals(0.0));
      expect(state.results.filament, equals(0.0));
      expect(state.results.risk, equals(0.0));
      expect(state.results.labour, equals(0.0));
      expect(state.results.total, equals(0.0));
    });

    test('creates instance with custom values', () {
      final state = CalculatorState(
        watt: const NumberInput.dirty(value: 200),
        kwCost: const NumberInput.dirty(value: 1.5),
        printWeight: const NumberInput.dirty(value: 100),
        materialUsages: const [
          MaterialUsageInput(
            materialId: 'mat-1',
            materialName: 'PLA Black',
            costPerKg: 200,
            weightGrams: 100,
          ),
        ],
        hours: const NumberInput.dirty(value: 2),
        minutes: const NumberInput.dirty(value: 30),
        spoolWeight: const NumberInput.dirty(value: 1000),
        spoolCost: const NumberInput.dirty(value: 20),
        spoolCostText: '20.00',
        wearAndTear: const NumberInput.dirty(value: 5),
        failureRisk: const NumberInput.dirty(value: 10),
        labourRate: const NumberInput.dirty(value: 15),
        labourTime: const NumberInput.dirty(value: 1),
        results: const CalculationResult(
          electricity: 1.0,
          filament: 2.0,
          risk: 0.5,
          labour: 15.0,
          total: 18.5,
        ),
      );

      expect(state.watt.value, equals(200));
      expect(state.kwCost.value, equals(1.5));
      expect(state.printWeight.value, equals(100));
      expect(state.materialUsages.length, equals(1));
      expect(state.hours.value, equals(2));
      expect(state.minutes.value, equals(30));
      expect(state.spoolWeight.value, equals(1000));
      expect(state.spoolCost.value, equals(20));
      expect(state.spoolCostText, equals('20.00'));
      expect(state.wearAndTear.value, equals(5));
      expect(state.failureRisk.value, equals(10));
      expect(state.labourRate.value, equals(15));
      expect(state.labourTime.value, equals(1));
      expect(state.results.total, equals(18.5));
    });

    test('copyWith creates new instance with updated watt', () {
      final original = CalculatorState(
        watt: const NumberInput.dirty(value: 200),
      );

      final updated = original.copyWith(
        watt: const NumberInput.dirty(value: 300),
      );

      expect(updated.watt.value, equals(300));
      expect(original.watt.value, equals(200));
    });

    test('copyWith creates new instance with updated kwCost', () {
      final original = CalculatorState(
        kwCost: const NumberInput.dirty(value: 1.5),
      );

      final updated = original.copyWith(
        kwCost: const NumberInput.dirty(value: 2.0),
      );

      expect(updated.kwCost.value, equals(2.0));
      expect(original.kwCost.value, equals(1.5));
    });

    test('copyWith creates new instance with updated printWeight', () {
      final original = CalculatorState(
        printWeight: const NumberInput.dirty(value: 100),
      );

      final updated = original.copyWith(
        printWeight: const NumberInput.dirty(value: 150),
      );

      expect(updated.printWeight.value, equals(150));
      expect(original.printWeight.value, equals(100));
    });

    test('copyWith creates new instance with updated materialUsages', () {
      final original = CalculatorState(
        materialUsages: const [
          MaterialUsageInput(
            materialId: 'mat-1',
            materialName: 'PLA Black',
            costPerKg: 200,
            weightGrams: 100,
          ),
        ],
      );

      final updated = original.copyWith(
        materialUsages: const [
          MaterialUsageInput(
            materialId: 'mat-1',
            materialName: 'PLA Black',
            costPerKg: 200,
            weightGrams: 100,
          ),
          MaterialUsageInput(
            materialId: 'mat-2',
            materialName: 'PLA White',
            costPerKg: 250,
            weightGrams: 50,
          ),
        ],
      );

      expect(updated.materialUsages.length, equals(2));
      expect(original.materialUsages.length, equals(1));
    });

    test('copyWith creates new instance with updated hours', () {
      final original = CalculatorState(
        hours: const NumberInput.dirty(value: 2),
      );

      final updated = original.copyWith(
        hours: const NumberInput.dirty(value: 3),
      );

      expect(updated.hours.value, equals(3));
      expect(original.hours.value, equals(2));
    });

    test('copyWith creates new instance with updated minutes', () {
      final original = CalculatorState(
        minutes: const NumberInput.dirty(value: 30),
      );

      final updated = original.copyWith(
        minutes: const NumberInput.dirty(value: 45),
      );

      expect(updated.minutes.value, equals(45));
      expect(original.minutes.value, equals(30));
    });

    test('copyWith creates new instance with updated spoolWeight', () {
      final original = CalculatorState(
        spoolWeight: const NumberInput.dirty(value: 1000),
      );

      final updated = original.copyWith(
        spoolWeight: const NumberInput.dirty(value: 750),
      );

      expect(updated.spoolWeight.value, equals(750));
      expect(original.spoolWeight.value, equals(1000));
    });

    test('copyWith creates new instance with updated spoolCost', () {
      final original = CalculatorState(
        spoolCost: const NumberInput.dirty(value: 20),
      );

      final updated = original.copyWith(
        spoolCost: const NumberInput.dirty(value: 25),
      );

      expect(updated.spoolCost.value, equals(25));
      expect(original.spoolCost.value, equals(20));
    });

    test('copyWith creates new instance with updated spoolCostText', () {
      final original = CalculatorState(
        spoolCostText: '20.00',
      );

      final updated = original.copyWith(
        spoolCostText: '25.50',
      );

      expect(updated.spoolCostText, equals('25.50'));
      expect(original.spoolCostText, equals('20.00'));
    });

    test('copyWith creates new instance with updated wearAndTear', () {
      final original = CalculatorState(
        wearAndTear: const NumberInput.dirty(value: 5),
      );

      final updated = original.copyWith(
        wearAndTear: const NumberInput.dirty(value: 7),
      );

      expect(updated.wearAndTear.value, equals(7));
      expect(original.wearAndTear.value, equals(5));
    });

    test('copyWith creates new instance with updated failureRisk', () {
      final original = CalculatorState(
        failureRisk: const NumberInput.dirty(value: 10),
      );

      final updated = original.copyWith(
        failureRisk: const NumberInput.dirty(value: 15),
      );

      expect(updated.failureRisk.value, equals(15));
      expect(original.failureRisk.value, equals(10));
    });

    test('copyWith creates new instance with updated labourRate', () {
      final original = CalculatorState(
        labourRate: const NumberInput.dirty(value: 15),
      );

      final updated = original.copyWith(
        labourRate: const NumberInput.dirty(value: 20),
      );

      expect(updated.labourRate.value, equals(20));
      expect(original.labourRate.value, equals(15));
    });

    test('copyWith creates new instance with updated labourTime', () {
      final original = CalculatorState(
        labourTime: const NumberInput.dirty(value: 1),
      );

      final updated = original.copyWith(
        labourTime: const NumberInput.dirty(value: 2),
      );

      expect(updated.labourTime.value, equals(2));
      expect(original.labourTime.value, equals(1));
    });

    test('copyWith creates new instance with updated results', () {
      final original = CalculatorState(
        results: const CalculationResult(
          electricity: 1.0,
          filament: 2.0,
          risk: 0.5,
          labour: 15.0,
          total: 18.5,
        ),
      );

      final updated = original.copyWith(
        results: const CalculationResult(
          electricity: 2.0,
          filament: 3.0,
          risk: 1.0,
          labour: 20.0,
          total: 26.0,
        ),
      );

      expect(updated.results.total, equals(26.0));
      expect(original.results.total, equals(18.5));
    });

    test('copyWith preserves original values when no parameters provided', () {
      final original = CalculatorState(
        watt: const NumberInput.dirty(value: 200),
        kwCost: const NumberInput.dirty(value: 1.5),
        printWeight: const NumberInput.dirty(value: 100),
        materialUsages: const [
          MaterialUsageInput(
            materialId: 'mat-1',
            materialName: 'PLA Black',
            costPerKg: 200,
            weightGrams: 100,
          ),
        ],
        spoolCostText: '20.00',
      );

      final copied = original.copyWith();

      expect(copied.watt.value, equals(original.watt.value));
      expect(copied.kwCost.value, equals(original.kwCost.value));
      expect(copied.printWeight.value, equals(original.printWeight.value));
      expect(copied.materialUsages.length, equals(original.materialUsages.length));
      expect(copied.spoolCostText, equals(original.spoolCostText));
    });

    test('inputs getter returns all form inputs', () {
      final state = CalculatorState(
        watt: const NumberInput.dirty(value: 200),
        kwCost: const NumberInput.dirty(value: 1.5),
        printWeight: const NumberInput.dirty(value: 100),
        hours: const NumberInput.dirty(value: 2),
        minutes: const NumberInput.dirty(value: 30),
        spoolWeight: const NumberInput.dirty(value: 1000),
        spoolCost: const NumberInput.dirty(value: 20),
        wearAndTear: const NumberInput.dirty(value: 5),
        failureRisk: const NumberInput.dirty(value: 10),
        labourRate: const NumberInput.dirty(value: 15),
        labourTime: const NumberInput.dirty(value: 1),
      );

      final inputs = state.inputs;

      expect(inputs.length, equals(11));
      expect(inputs[0], equals(state.watt));
      expect(inputs[1], equals(state.kwCost));
      expect(inputs[2], equals(state.printWeight));
      expect(inputs[3], equals(state.hours));
      expect(inputs[4], equals(state.minutes));
      expect(inputs[5], equals(state.spoolWeight));
      expect(inputs[6], equals(state.spoolCost));
      expect(inputs[7], equals(state.wearAndTear));
      expect(inputs[8], equals(state.failureRisk));
      expect(inputs[9], equals(state.labourRate));
      expect(inputs[10], equals(state.labourTime));
    });

    test('copyWith can update multiple fields at once', () {
      final original = CalculatorState();

      final updated = original.copyWith(
        watt: const NumberInput.dirty(value: 200),
        kwCost: const NumberInput.dirty(value: 1.5),
        printWeight: const NumberInput.dirty(value: 100),
        hours: const NumberInput.dirty(value: 2),
        minutes: const NumberInput.dirty(value: 30),
      );

      expect(updated.watt.value, equals(200));
      expect(updated.kwCost.value, equals(1.5));
      expect(updated.printWeight.value, equals(100));
      expect(updated.hours.value, equals(2));
      expect(updated.minutes.value, equals(30));
    });

    test('materialUsages list is independent between instances', () {
      const usage1 = MaterialUsageInput(
        materialId: 'mat-1',
        materialName: 'PLA Black',
        costPerKg: 200,
        weightGrams: 100,
      );

      final original = CalculatorState(
        materialUsages: const [usage1],
      );

      const usage2 = MaterialUsageInput(
        materialId: 'mat-2',
        materialName: 'PLA White',
        costPerKg: 250,
        weightGrams: 50,
      );

      final updated = original.copyWith(
        materialUsages: [usage1, usage2],
      );

      expect(updated.materialUsages.length, equals(2));
      expect(original.materialUsages.length, equals(1));
    });

    test('handles empty materialUsages list', () {
      final state = CalculatorState(
        materialUsages: const [],
      );

      expect(state.materialUsages, isEmpty);
    });

    test('handles null values in NumberInput', () {
      final state = CalculatorState(
        watt: const NumberInput.dirty(value: null),
      );

      expect(state.watt.value, isNull);
    });
  });
}