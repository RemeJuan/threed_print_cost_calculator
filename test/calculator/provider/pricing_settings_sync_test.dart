import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/model/pricing_models.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculator_state.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/shared/components/num_input.dart';

import '../../helpers/helpers.dart';
import '../../helpers/lower_level_test_fakes.dart';

void main() {
  setUpAll(setupTest);

  group('CalculatorProvider pricing settings sync', () {
    test(
      'syncs pricing inputs from settings and recalculates final price',
      () async {
        final settingsRepo = FakeSettingsRepository(
          initialSettings: GeneralSettingsModel.initial().copyWith(
            pricingMarkupPercent: '10',
            pricingSetupFee: '5',
            pricingRoundingMode: 'none',
          ),
        );

        final container = ProviderContainer(
          overrides: [
            settingsRepositoryProvider.overrideWithValue(settingsRepo),
          ],
        );
        addTearDown(container.dispose);

        final notifier = container.read(calculatorProvider.notifier);
        notifier.state = CalculatorState(
          hasHydratedDefaults: true,
          additionalCostAmount: const NumberInput.dirty(value: 100),
          markupPercent: const NumberInput.dirty(value: 10),
          setupFee: const NumberInput.dirty(value: 5),
          roundingMode: PricingRoundingMode.none,
          baselineMarkupPercent: 10,
          baselineSetupFee: 5,
          baselineRoundingMode: PricingRoundingMode.none,
        );

        settingsRepo.emit(
          GeneralSettingsModel.initial().copyWith(
            pricingMarkupPercent: '20',
            pricingSetupFee: '7',
            pricingRoundingMode: '.00',
          ),
        );

        await Future<void>.delayed(const Duration(milliseconds: 1));

        final state = container.read(calculatorProvider);
        expect(state.markupPercent.value, 20);
        expect(state.setupFee.value, 7);
        expect(state.roundingMode, PricingRoundingMode.wholeDollar);
        expect(state.baselineMarkupPercent, 20);
        expect(state.baselineSetupFee, 7);
        expect(state.baselineRoundingMode, PricingRoundingMode.wholeDollar);
        expect(state.pricing.baseCost, 100);
        expect(state.pricing.markupAmount, 20);
        expect(state.pricing.subtotalBeforeRounding, 127);
        expect(state.pricing.finalPrice, 127);
        expect(state.pricing.roundingAdjustment, 0);
      },
    );

    test(
      'keeps overridden rounding mode while refreshing other defaults',
      () async {
        final settingsRepo = FakeSettingsRepository(
          initialSettings: GeneralSettingsModel.initial().copyWith(
            pricingMarkupPercent: '10',
            pricingSetupFee: '5',
            pricingRoundingMode: 'none',
          ),
        );

        final container = ProviderContainer(
          overrides: [
            settingsRepositoryProvider.overrideWithValue(settingsRepo),
          ],
        );
        addTearDown(container.dispose);

        final notifier = container.read(calculatorProvider.notifier);
        notifier.state = CalculatorState(
          hasHydratedDefaults: true,
          additionalCostAmount: const NumberInput.dirty(value: 100),
          markupPercent: const NumberInput.dirty(value: 10),
          setupFee: const NumberInput.dirty(value: 5),
          roundingMode: PricingRoundingMode.wholeDollar,
          baselineMarkupPercent: 10,
          baselineSetupFee: 5,
          baselineRoundingMode: PricingRoundingMode.none,
        );

        settingsRepo.emit(
          GeneralSettingsModel.initial().copyWith(
            pricingMarkupPercent: '12',
            pricingSetupFee: '6',
            pricingRoundingMode: '.99',
          ),
        );

        await Future<void>.delayed(const Duration(milliseconds: 1));

        final state = container.read(calculatorProvider);
        expect(state.markupPercent.value, 12);
        expect(state.setupFee.value, 6);
        expect(state.roundingMode, PricingRoundingMode.wholeDollar);
        expect(state.baselineMarkupPercent, 12);
        expect(state.baselineSetupFee, 6);
        expect(state.baselineRoundingMode, PricingRoundingMode.pointNinetyNine);
        expect(state.pricing.baseCost, 100);
        expect(state.pricing.markupAmount, 12);
        expect(state.pricing.subtotalBeforeRounding, 118);
        expect(state.pricing.finalPrice, 118);
        expect(state.pricing.roundingAdjustment, 0);
      },
    );
  });
}
