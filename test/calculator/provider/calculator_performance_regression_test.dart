import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage_input.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';

MaterialUsageInput _usage(int i) => MaterialUsageInput(
  materialId: 'mat-$i',
  materialName: 'Material $i',
  costPerKg: 25 + i,
  weightGrams: i + 1,
);

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

    test(
      'applySingleTotalWeightToFirstRow emits a single state transition for many rows',
      () {
        for (var i = 0; i < 200; i++) {
          notifier.addMaterialUsage(_usage(i));
        }
        notifier.updatePrintWeight('987');

        var transitions = 0;
        final sub = container.listen(
          calculatorProvider,
          (_, __) => transitions++,
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
        for (var i = 0; i < 150; i++) {
          notifier.addMaterialUsage(_usage(i));
        }

        var transitions = 0;
        final sub = container.listen(
          calculatorProvider,
          (_, __) => transitions++,
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
