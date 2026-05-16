import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/model/pricing_models.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculator_state.dart';
import 'package:threed_print_cost_calculator/shared/components/num_input.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculation_results_state.dart';
import 'package:threed_print_cost_calculator/calculator/view/calculator_results.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/shared/providers/pro_promotion_visibility.dart';

import '../../helpers/helpers.dart';
import '../../helpers/lower_level_test_fakes.dart';

class _FakeSettingsRepository implements SettingsRepository {
  _FakeSettingsRepository(this._settings);
  final GeneralSettingsModel _settings;
  @override
  Ref get ref => throw UnimplementedError();
  @override
  Future<GeneralSettingsModel> getSettings() async => _settings;
  @override
  Stream<GeneralSettingsModel> watchSettings() async* {
    yield _settings;
  }

  @override
  Future<void> saveSettings(GeneralSettingsModel settings) async {}
}

void main() {
  const results = CalculationResult(
    electricity: 1.25,
    filament: 2.5,
    risk: 0.75,
    labour: 3.25,
    total: 10.0,
  );

  const pricing = PricingResult(
    baseCost: 10.0,
    markupPercent: 25,
    markupAmount: 2.5,
    setupFee: 1.25,
    roundingMode: PricingRoundingMode.wholeDollar,
    subtotalBeforeRounding: 13.75,
    roundingAdjustment: 0.25,
    finalPrice: 14.0,
  );

  setUpAll(() async {
    await setupTest();
  });

  Future<void> pumpResults(
    WidgetTester tester, {
    required bool isPremium,
    required bool shouldShowProPromotion,
    PricingResult pricingResult = pricing,
    num additionalCostAmount = 0,
  }) async {
    final calculatorNotifier = FakeCalculatorNotifier(
      initialState: CalculatorState(
        additionalCostAmount: NumberInput.dirty(value: additionalCostAmount),
      ),
    );
    final db = await tester
        .pumpApp(CalculatorResults(results: results, pricing: pricingResult), [
          calculatorProvider.overrideWith(() => calculatorNotifier),
          isPremiumProvider.overrideWithValue(isPremium),
          shouldShowProPromotionProvider.overrideWithValue(
            shouldShowProPromotion,
          ),
        ]);
    addTearDown(() => db.close());
    await tester.pumpAndSettle();
  }

  group('CalculatorResults', () {
    testWidgets('covers promo visibility matrix for free and premium users', (
      tester,
    ) async {
      final matrix = <({bool isPremium, bool shouldShow, bool locked})>[
        (isPremium: false, shouldShow: true, locked: true),
        (isPremium: false, shouldShow: false, locked: false),
        (isPremium: true, shouldShow: true, locked: false),
        (isPremium: true, shouldShow: false, locked: false),
      ];

      for (final c in matrix) {
        await pumpResults(
          tester,
          isPremium: c.isPremium,
          shouldShowProPromotion: c.shouldShow,
        );

        expect(
          find.byKey(
            const ValueKey<String>('calculator.result.locked.wearAndTear'),
          ),
          c.locked ? findsOneWidget : findsNothing,
        );
        expect(
          find.byKey(
            const ValueKey<String>('calculator.result.locked.riskCost'),
          ),
          c.locked ? findsOneWidget : findsNothing,
        );
        expect(
          find.byKey(
            const ValueKey<String>('calculator.result.locked.labourCost'),
          ),
          c.locked ? findsOneWidget : findsNothing,
        );
      }
    });

    testWidgets('free user with promos enabled sees locked premium rows', (
      tester,
    ) async {
      await pumpResults(tester, isPremium: false, shouldShowProPromotion: true);

      expect(
        find.byKey(
          const ValueKey<String>('calculator.result.locked.wearAndTear'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('calculator.result.locked.riskCost')),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const ValueKey<String>('calculator.result.locked.labourCost'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('calculator.result.riskCost')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey<String>('calculator.result.labourCost')),
        findsNothing,
      );
    });

    testWidgets('free user with promos hidden does not see locked rows', (
      tester,
    ) async {
      await pumpResults(
        tester,
        isPremium: false,
        shouldShowProPromotion: false,
      );

      expect(
        find.byKey(
          const ValueKey<String>('calculator.result.locked.wearAndTear'),
        ),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey<String>('calculator.result.locked.riskCost')),
        findsNothing,
      );
      expect(
        find.byKey(
          const ValueKey<String>('calculator.result.locked.labourCost'),
        ),
        findsNothing,
      );
    });

    testWidgets(
      'premium user does not see locked promo rows even when promos enabled',
      (tester) async {
        await pumpResults(
          tester,
          isPremium: true,
          shouldShowProPromotion: true,
        );

        expect(
          find.byKey(
            const ValueKey<String>('calculator.result.locked.wearAndTear'),
          ),
          findsNothing,
        );
        expect(
          find.byKey(
            const ValueKey<String>('calculator.result.locked.riskCost'),
          ),
          findsNothing,
        );
        expect(
          find.byKey(
            const ValueKey<String>('calculator.result.locked.labourCost'),
          ),
          findsNothing,
        );
        expect(
          find.byKey(const ValueKey<String>('calculator.result.riskCost')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey<String>('calculator.result.labourCost')),
          findsOneWidget,
        );
      },
    );

    testWidgets('promo rendering does not change calculator totals', (
      tester,
    ) async {
      await pumpResults(tester, isPremium: false, shouldShowProPromotion: true);

      expect(
        find.byKey(const ValueKey<String>('calculator.result.electricityCost')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('calculator.result.filamentCost')),
        findsOneWidget,
      );
      expect(find.text(results.total.toStringAsFixed(2)), findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('calculator.result.totalCost')),
        findsOneWidget,
      );
    });

    testWidgets('pricing section keeps additional cost below cost subtotal', (
      tester,
    ) async {
      await pumpResults(
        tester,
        isPremium: true,
        shouldShowProPromotion: false,
        additionalCostAmount: 4.25,
      );

      final costFinder = find.byKey(
        const ValueKey<String>('calculator.result.totalCost'),
      );
      final additionalCostFinder = find.byKey(
        const ValueKey<String>('calculator.result.additionalCost'),
      );
      final markupFinder = find.byKey(
        const ValueKey<String>('calculator.result.markupAmount'),
      );

      expect(costFinder, findsOneWidget);
      expect(additionalCostFinder, findsOneWidget);
      expect(markupFinder, findsOneWidget);
      expect(
        tester.getTopLeft(additionalCostFinder).dy,
        greaterThan(tester.getTopLeft(costFinder).dy),
      );
      expect(
        tester.getTopLeft(markupFinder).dy,
        greaterThan(tester.getTopLeft(additionalCostFinder).dy),
      );
      expect(find.text('Total cost'), findsNothing);
      expect(find.text('Cost'), findsWidgets);
    });

    testWidgets('premium user sees pricing rows when pricing enabled', (
      tester,
    ) async {
      await pumpResults(tester, isPremium: true, shouldShowProPromotion: false);

      expect(
        find.byKey(const ValueKey('calculator.result.markupAmount')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('calculator.result.setupFee')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('calculator.result.roundingAdjustment')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('calculator.result.finalPrice')),
        findsOneWidget,
      );
    });

    testWidgets('formats final price with currency settings', (tester) async {
      final db = await tester
          .pumpApp(CalculatorResults(results: results, pricing: pricing), [
            isPremiumProvider.overrideWithValue(true),
            shouldShowProPromotionProvider.overrideWithValue(false),
            settingsRepositoryProvider.overrideWithValue(
              _FakeSettingsRepository(
                const GeneralSettingsModel(
                  electricityCost: '',
                  wattage: '',
                  activePrinter: '',
                  selectedMaterial: '',
                  wearAndTear: '',
                  failureRisk: '',
                  labourRate: '',
                  pricingMarkupPercent: '',
                  pricingSetupFee: '',
                  pricingRoundingMode: 'none',
                  currencySymbol: 'R',
                  currencyPosition: 'before',
                  currencySpacing: false,
                ),
              ),
            ),
          ]);
      addTearDown(() => db.close());
      await tester.pumpAndSettle();

      expect(find.text('R14.00'), findsOneWidget);
    });

    testWidgets('free user does not see pricing output rows', (tester) async {
      await pumpResults(
        tester,
        isPremium: false,
        shouldShowProPromotion: false,
      );

      expect(
        find.byKey(const ValueKey('calculator.result.markupAmount')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('calculator.result.setupFee')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('calculator.result.roundingAdjustment')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('calculator.result.finalPrice')),
        findsNothing,
      );
    });

    testWidgets('renders without overflow on narrow widths', (tester) async {
      final calculatorNotifier = FakeCalculatorNotifier(
        initialState: CalculatorState(
          additionalCostAmount: NumberInput.dirty(value: 4.25),
        ),
      );

      final db = await tester.pumpApp(
        ConstrainedBox(
          constraints: const BoxConstraints.tightFor(width: 220),
          child: CalculatorResults(results: results, pricing: pricing),
        ),
        [
          calculatorProvider.overrideWith(() => calculatorNotifier),
          isPremiumProvider.overrideWithValue(true),
          shouldShowProPromotionProvider.overrideWithValue(false),
        ],
      );
      addTearDown(() => db.close());

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
