import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage_input.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/purchases/premium_local_store_keys.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
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

    test('sets imported flag and preserves existing inputs', () {
      notifier.updateHours(3);
      notifier.updatePrintWeight('42');
      notifier.addMaterialUsage(
        const MaterialUsageInput(
          materialId: 'mat-1',
          materialName: 'PLA Red',
          costPerKg: 24,
          weightGrams: 10,
        ),
      );

      final before = container.read(calculatorProvider).pricing.finalPrice;

      notifier.applyImportedValues(
        estimatedDuration: const Duration(minutes: 5),
      );

      final state = container.read(calculatorProvider);
      expect(state.importedFromGcode, isTrue);
      expect(state.hours.value, 0);
      expect(state.minutes.value, 5);
      expect(state.printWeight.value, 42);
      expect(state.materialUsages.first.weightGrams, 10);
      expect(state.pricing.finalPrice, isNot(before));
      expect(
        container
            .read(premiumLocalStoreProvider)
            .readSync(hasUsedGcodeImportPreferenceKey),
        'true',
      );
    });

    test('clamps negative imported weight to zero and recalculates usage', () {
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
          costPerKg: 26,
          weightGrams: 20,
        ),
      );

      notifier.applyImportedValues(filamentWeightGrams: -7.2);

      final state = container.read(calculatorProvider);
      expect(state.printWeight.value, 0);
      expect(state.materialUsages.first.weightGrams, 0);
      expect(state.materialUsages.last.weightGrams, 0);
    });
  });
}
