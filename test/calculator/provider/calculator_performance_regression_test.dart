import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage_input.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculation_results_state.dart';

MaterialUsageInput _usage(int i) => MaterialUsageInput(
  materialId: 'mat-$i',
  materialName: 'Material $i',
  costPerKg: 25 + i,
  weightGrams: i + 1,
);

void _seedUsages(CalculatorProvider notifier, int count) {
  for (var i = 0; i < count; i++) {
    notifier.addMaterialUsage(_usage(i));
  }
}

void _applyPreviousRowByRowNormalization(CalculatorProvider notifier) {
  final total = (notifier.state.printWeight.value ?? 0).toInt();
  for (var i = 0; i < notifier.state.materialUsages.length; i++) {
    if (i == 0) continue;
    notifier.updateMaterialUsageWeight(i, 0);
  }
  notifier.updateMaterialUsageWeight(0, total);
}

CalculationResult _submitAndReadResults(CalculatorProvider notifier) {
  notifier
    ..updateWatt('200')
    ..updateKwCost('1.25')
    ..updateHours(1)
    ..updateMinutes(30)
    ..setWearAndTear(2)
    ..setFailureRisk(10)
    ..submit();

  return notifier.state.results;
}

void main() {
  group('Calculator performance regressions', () {
    late ProviderContainer container;
    late CalculatorProvider notifier;

    setUp(() {
      container = ProviderContainer();
      notifier = container.read(calculatorProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('single material row normalization keeps the total on first row', () {
      notifier.addMaterialUsage(_usage(0));
      notifier.updatePrintWeight('123');

      var transitions = 0;
      final sub = container.listen(
        calculatorProvider,
        (previous, next) => transitions++,
      );
      addTearDown(sub.close);

      notifier.applySingleTotalWeightToFirstRow();

      final state = container.read(calculatorProvider);
      expect(transitions, 1);
      expect(state.printWeight.value, 123);
      expect(state.materialUsages, hasLength(1));
      expect(state.materialUsages.first.weightGrams, 123);
    });

    test('multiple material rows normalize in memory to first row only', () {
      _seedUsages(notifier, 4);
      notifier.updatePrintWeight('321');

      notifier.applySingleTotalWeightToFirstRow();

      final state = container.read(calculatorProvider);
      expect(state.printWeight.value, 321);
      expect(state.materialUsages.first.weightGrams, 321);
      expect(
        state.materialUsages.skip(1).map((usage) => usage.weightGrams),
        everyElement(0),
      );
    });

    test('zero or missing total weight normalizes all rows to zero', () {
      _seedUsages(notifier, 3);

      notifier.applySingleTotalWeightToFirstRow();

      final state = container.read(calculatorProvider);
      expect(state.printWeight.value, 0);
      expect(
        state.materialUsages.map((usage) => usage.weightGrams),
        everyElement(0),
      );
    });

    test('normalized totals match previous row-by-row behavior', () {
      final oldContainer = ProviderContainer();
      addTearDown(oldContainer.dispose);
      final oldNotifier = oldContainer.read(calculatorProvider.notifier);

      _seedUsages(notifier, 5);
      _seedUsages(oldNotifier, 5);
      notifier.updatePrintWeight('456');
      oldNotifier.updatePrintWeight('456');

      notifier.applySingleTotalWeightToFirstRow();
      _applyPreviousRowByRowNormalization(oldNotifier);

      expect(notifier.state.materialUsages, oldNotifier.state.materialUsages);
      expect(
        notifier.state.printWeight.value,
        oldNotifier.state.printWeight.value,
      );

      final newResults = _submitAndReadResults(notifier);
      final oldResults = _submitAndReadResults(oldNotifier);
      expect(newResults, oldResults);
    });

    test(
      'applySingleTotalWeightToFirstRow emits a single state transition for many rows',
      () {
        _seedUsages(notifier, 200);
        notifier.updatePrintWeight('987');

        var transitions = 0;
        final sub = container.listen(
          calculatorProvider,
          (previous, next) => transitions++,
        );
        addTearDown(sub.close);

        notifier.applySingleTotalWeightToFirstRow();

        expect(transitions, 1);

        final state = container.read(calculatorProvider);
        expect(state.materialUsages.first.weightGrams, 987);
        expect(
          state.materialUsages.skip(1).every((usage) => usage.weightGrams == 0),
          isTrue,
        );
      },
    );

    test(
      'many row updates emit one transition per update (no extra churn)',
      () {
        _seedUsages(notifier, 150);

        var transitions = 0;
        final sub = container.listen(
          calculatorProvider,
          (previous, next) => transitions++,
        );
        addTearDown(sub.close);

        for (var i = 0; i < 150; i++) {
          notifier.updateMaterialUsageWeight(i, i + 10);
        }

        expect(transitions, 150);
        final totalWeight = container
            .read(calculatorProvider)
            .materialUsages
            .fold<int>(0, (sum, usage) => sum + usage.weightGrams);
        expect(
          container.read(calculatorProvider).printWeight.value,
          totalWeight,
        );
      },
    );
  });
}
