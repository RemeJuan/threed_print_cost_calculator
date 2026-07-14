import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:threed_print_cost_calculator/calculator/model/pricing_models.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculator_state.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/shared/components/num_input.dart';

import '../../helpers/helpers.dart';
import '../../helpers/lower_level_test_fakes.dart';

class _ControllableSettingsRepository implements SettingsRepository {
  _ControllableSettingsRepository({required GeneralSettingsModel initial})
    : _settings = initial {
    _controller = StreamController<GeneralSettingsModel>.broadcast(
      sync: true,
      onListen: () {
        if (!watchSubscribed.isCompleted) watchSubscribed.complete();
      },
    );
  }

  late final StreamController<GeneralSettingsModel> _controller;
  final Completer<void> watchSubscribed = Completer<void>();
  GeneralSettingsModel _settings;

  @override
  Ref get ref => throw UnimplementedError();

  @override
  Future<GeneralSettingsModel> getSettings() async => _settings;

  @override
  Stream<GeneralSettingsModel> watchSettings() => _controller.stream;

  @override
  Future<void> saveSettings(GeneralSettingsModel settings) async {
    _settings = settings;
    _controller.add(settings);
  }

  void emit(GeneralSettingsModel settings) {
    _settings = settings;
    _controller.add(settings);
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}

void main() {
  setUpAll(setupTest);

  group('CalculatorProvider pricing settings sync', () {
    test(
      'ignores pricing settings events before defaults hydrate',
      () async {
        final settingsRepo = _ControllableSettingsRepository(
          initial: GeneralSettingsModel.initial().copyWith(
            pricingMarkupPercent: '10',
            pricingSetupFee: '5',
            pricingRoundingMode: 'none',
          ),
        );
        final db = await databaseFactoryMemory.openDatabase(
          'pricing_settings_sync.db',
        );

        final container = ProviderContainer(
          overrides: [
            databaseProvider.overrideWithValue(db),
            settingsRepositoryProvider.overrideWithValue(settingsRepo),
          ],
        );
        addTearDown(container.dispose);
        addTearDown(db.close);
        addTearDown(settingsRepo.dispose);

        final sub = container.listen<CalculatorState>(calculatorProvider, (
          previous,
          next,
        ) {}, fireImmediately: false);
        addTearDown(sub.close);

        await settingsRepo.watchSubscribed.future;
        settingsRepo.emit(
          GeneralSettingsModel.initial().copyWith(
            pricingMarkupPercent: '20',
            pricingSetupFee: '7',
            pricingRoundingMode: '.99',
          ),
        );

        final preHydration = container.read(calculatorProvider);
        expect(preHydration.hasHydratedDefaults, isFalse);
        expect(preHydration.markupPercent.value, isNull);
        expect(preHydration.setupFee.value, isNull);
        expect(preHydration.roundingMode, PricingRoundingMode.none);
      },
    );

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
      'legacy markup override blocks setup/rounding baseline refresh',
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
          markupPercent: const NumberInput.dirty(value: 15),
          setupFee: const NumberInput.dirty(value: 5),
          roundingMode: PricingRoundingMode.none,
          baselineMarkupPercent: 10,
          baselineSetupFee: 5,
          baselineRoundingMode: PricingRoundingMode.none,
          markupPercentOverridden: true,
        );

        final hydrated = <CalculatorState>[];
        final firstUpdate = Completer<void>();
        final sub = container.listen<CalculatorState>(calculatorProvider, (
          previous,
          next,
        ) {
          hydrated.add(next);
          if (!firstUpdate.isCompleted) firstUpdate.complete();
        }, fireImmediately: false);
        addTearDown(sub.close);

        settingsRepo.emit(
          GeneralSettingsModel.initial().copyWith(
            pricingMarkupPercent: '20',
            pricingSetupFee: '7',
            pricingRoundingMode: '.99',
          ),
        );

        await firstUpdate.future;
        final state = container.read(calculatorProvider);
        expect(hydrated, isNotEmpty);
        expect(state.markupPercent.value, 15);
        expect(state.setupFee.value, 5);
        expect(state.roundingMode, PricingRoundingMode.none);
        expect(state.baselineMarkupPercent, 20);
        expect(state.baselineSetupFee, 5);
        expect(state.baselineRoundingMode, PricingRoundingMode.none);
        expect(hydrated.last.markupPercent.value, 15);
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
