import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage_input.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculation_results_state.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculator_state.dart';
import 'package:threed_print_cost_calculator/shared/components/num_input.dart';

void main() {
  test('starts with empty inputs and default results', () {
    final state = CalculatorState();

    expect(state.inputs, hasLength(14));
    expect(state.inputs.every((input) => input.isPure), isTrue);
    expect(
      state.results,
      const CalculationResult(
        electricity: 0.0,
        filament: 0.0,
        risk: 0.0,
        labour: 0.0,
        total: 0.0,
      ),
    );
    expect(state.materialUsages, isEmpty);
    expect(state.showHistoryLoadReplacementWarning, isFalse);
    expect(state.importedFromGcode, isFalse);
  });

  test('copyWith preserves prior values and isolates material list', () {
    final original = CalculatorState(
      watt: const NumberInput.dirty(value: 350),
      materialUsages: const [
        MaterialUsageInput(
          materialId: 'mat-1',
          materialName: 'PLA',
          costPerKg: 25,
          weightGrams: 12,
        ),
      ],
    );

    final updated = original.copyWith(
      kwCost: const NumberInput.dirty(value: 0.3),
      results: const CalculationResult(
        electricity: 1,
        filament: 2,
        risk: 3,
        labour: 4,
        total: 10,
      ),
      importedFromGcode: true,
    );

    expect(updated.watt, original.watt);
    expect(updated.kwCost.value, 0.3);
    expect(updated.materialUsages, original.materialUsages);
    expect(updated.results.total, 10);
    expect(updated.importedFromGcode, isTrue);
    expect(original.kwCost.isPure, isTrue);
    expect(original.importedFromGcode, isFalse);
  });

  test('material usages are unmodifiable', () {
    final state = CalculatorState(
      materialUsages: const [
        MaterialUsageInput(
          materialId: 'mat-1',
          materialName: 'PLA',
          costPerKg: 25,
          weightGrams: 12,
        ),
      ],
    );

    expect(
      () => state.materialUsages.add(
        const MaterialUsageInput(
          materialId: 'mat-2',
          materialName: 'PETG',
          costPerKg: 30,
          weightGrams: 5,
        ),
      ),
      throwsUnsupportedError,
    );
  });
}
