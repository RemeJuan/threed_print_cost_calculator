import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage_input.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import '../../helpers/lower_level_test_fakes.dart' show FakeSettingsRepository;

void main() {
  group('CalculatorProvider.applyImportedValues', () {
    late FakeSettingsRepository settingsRepo;
    late ProviderContainer container;
    late CalculatorProvider notifier;

    setUp(() {
      settingsRepo = FakeSettingsRepository();
      container = ProviderContainer(
        overrides: [settingsRepositoryProvider.overrideWithValue(settingsRepo)],
      );
      notifier = container.read(calculatorProvider.notifier);
    });

    tearDown(() {
      container.dispose();
      settingsRepo.dispose();
    });

    test(
      'prefills duration and normalizes total material weight to first row',
      () {
        notifier.addMaterialUsage(
          const MaterialUsageInput(
            materialId: 'mat-1',
            materialName: 'PLA Red',
            costPerKg: 24,
            weightGrams: 10,
          ),
        );
        notifier.addMaterialUsage(
          const MaterialUsageInput(
            materialId: 'mat-2',
            materialName: 'PLA Blue',
            costPerKg: 24,
            weightGrams: 20,
          ),
        );

        notifier.applyImportedValues(
          estimatedDuration: const Duration(hours: 2, minutes: 4, seconds: 31),
          filamentWeightGrams: 48.6,
        );

        final state = container.read(calculatorProvider);
        expect(state.hours.value, 2);
        expect(state.minutes.value, 5);
        expect(state.printWeight.value, 49);
        expect(state.materialUsages.first.weightGrams, 49);
        expect(state.materialUsages.last.weightGrams, 0);
      },
    );
  });
}
