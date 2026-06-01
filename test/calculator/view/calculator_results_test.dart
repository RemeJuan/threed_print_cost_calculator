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
import 'package:threed_print_cost_calculator/purchases/premium_access_policy.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';

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
    baseCost: 14.25,
    markupPercent: 25,
    markupAmount: 3.56,
    setupFee: 1.25,
    roundingMode: PricingRoundingMode.wholeDollar,
    subtotalBeforeRounding: 19.06,
    roundingAdjustment: 0.94,
    finalPrice: 20.0,
  );

  const labourOnlyResults = CalculationResult(
    electricity: 1.0,
    filament: 2.0,
    risk: 0.5,
    labour: 0.0,
    total: 8.5,
  );

  const labourAndMaterialsResults = CalculationResult(
    electricity: 1.0,
    filament: 2.0,
    risk: 0.5,
    labour: 3.0,
    total: 10.0,
  );

  const resultsWithAdditionalCost = CalculationResult(
    electricity: 1.25,
    filament: 2.5,
    risk: 0.75,
    labour: 3.25,
    total: 14.25,
  );

  setUpAll(() async {
    await setupTest();
  });

  Future<void> pumpResults(
    WidgetTester tester, {
    required bool isPremium,
    CalculationResult results = results,
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
          premiumAccessPolicyProvider.overrideWithValue(
            DefaultPremiumAccessPolicy(isPremium: isPremium),
          ),
        ]);
    addTearDown(() => db.close());
    await tester.pumpAndSettle();
  }

  double valueFor(WidgetTester tester, String key) {
    final text = tester.widget<Text>(find.byKey(ValueKey<String>(key))).data!;
    return double.parse(text.replaceAll(RegExp(r'[^0-9.\-]'), ''));
  }

  group('CalculatorResults', () {
    testWidgets('covers promo visibility matrix for free and premium users', (
      tester,
    ) async {
      final matrix = <({bool isPremium, bool shouldShow, bool locked})>[
        (isPremium: false, shouldShow: true, locked: true),
        (isPremium: false, shouldShow: false, locked: true),
        (isPremium: true, shouldShow: true, locked: false),
        (isPremium: true, shouldShow: false, locked: false),
      ];

      for (final c in matrix) {
        await pumpResults(tester, isPremium: c.isPremium);

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
      await pumpResults(tester, isPremium: false);

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

    testWidgets('free user sees locked rows', (tester) async {
      await pumpResults(tester, isPremium: false);

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
    });

    testWidgets(
      'premium user does not see locked promo rows even when promos enabled',
      (tester) async {
        await pumpResults(tester, isPremium: true);

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

    testWidgets('labour row includes materials when labour is zero', (
      tester,
    ) async {
      final db = await tester.pumpApp(
        CalculatorResults(results: labourOnlyResults, pricing: pricing),
        [
          premiumAccessPolicyProvider.overrideWithValue(
            DefaultPremiumAccessPolicy(isPremium: true),
          ),
        ],
      );
      addTearDown(() => db.close());
      await tester.pumpAndSettle();

      expect(valueFor(tester, 'calculator.result.labourCost'), 5.0);
    });

    testWidgets(
      'labour row includes labour and materials when both are non-zero',
      (tester) async {
        final db = await tester.pumpApp(
          CalculatorResults(
            results: labourAndMaterialsResults,
            pricing: pricing,
          ),
          [
            premiumAccessPolicyProvider.overrideWithValue(
              DefaultPremiumAccessPolicy(isPremium: true),
            ),
          ],
        );
        addTearDown(() => db.close());
        await tester.pumpAndSettle();

        expect(valueFor(tester, 'calculator.result.labourCost'), 6.5);
      },
    );

    testWidgets('promo rendering does not change calculator totals', (
      tester,
    ) async {
      await pumpResults(tester, isPremium: false);

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

    testWidgets('cost section keeps additional cost above cost subtotal', (
      tester,
    ) async {
      await pumpResults(
        tester,
        isPremium: true,
        results: resultsWithAdditionalCost,
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
        lessThan(tester.getTopLeft(costFinder).dy),
      );
      expect(
        tester.getTopLeft(markupFinder).dy,
        greaterThan(tester.getTopLeft(costFinder).dy),
      );
      expect(find.text('Total cost'), findsNothing);
      expect(find.text('Cost'), findsWidgets);
    });

    testWidgets('labour row excludes additional cost', (tester) async {
      await pumpResults(
        tester,
        isPremium: true,
        results: resultsWithAdditionalCost,
        additionalCostAmount: 4.25,
      );

      expect(valueFor(tester, 'calculator.result.labourCost'), 5.5);
      expect(valueFor(tester, 'calculator.result.additionalCost'), 4.25);
    });

    testWidgets('visible breakdown values sum to displayed total cost', (
      tester,
    ) async {
      await pumpResults(
        tester,
        isPremium: true,
        results: resultsWithAdditionalCost,
        additionalCostAmount: 4.25,
      );

      final breakdown =
          valueFor(tester, 'calculator.result.electricityCost') +
          valueFor(tester, 'calculator.result.filamentCost') +
          valueFor(tester, 'calculator.result.riskCost') +
          valueFor(tester, 'calculator.result.labourCost') +
          valueFor(tester, 'calculator.result.additionalCost');

      expect(breakdown, valueFor(tester, 'calculator.result.totalCost'));
    });

    testWidgets('cost row includes additional cost and pricing uses it', (
      tester,
    ) async {
      await pumpResults(
        tester,
        isPremium: true,
        results: resultsWithAdditionalCost,
        additionalCostAmount: 4.25,
      );

      expect(valueFor(tester, 'calculator.result.totalCost'), 14.25);
      expect(valueFor(tester, 'calculator.result.markupAmount'), 3.56);
      expect(valueFor(tester, 'calculator.result.finalPrice'), 20.0);
    });

    testWidgets('premium user sees pricing rows when pricing enabled', (
      tester,
    ) async {
      await pumpResults(tester, isPremium: true);

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
            premiumAccessPolicyProvider.overrideWithValue(
              DefaultPremiumAccessPolicy(isPremium: true),
            ),
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

      expect(find.text('R20.00'), findsOneWidget);
    });

    testWidgets('free user does not see pricing output rows', (tester) async {
      await pumpResults(tester, isPremium: false);

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
          premiumAccessPolicyProvider.overrideWithValue(
            DefaultPremiumAccessPolicy(isPremium: true),
          ),
        ],
      );
      addTearDown(() => db.close());

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
