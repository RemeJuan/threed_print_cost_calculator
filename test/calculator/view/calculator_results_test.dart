import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculation_results_state.dart';
import 'package:threed_print_cost_calculator/calculator/view/calculator_results.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/shared/providers/pro_promotion_visibility.dart';

import '../../helpers/helpers.dart';

void main() {
  const results = CalculationResult(
    electricity: 1.25,
    filament: 2.5,
    risk: 0.75,
    labour: 3.25,
    total: 10.0,
  );

  setUpAll(() async {
    await setupTest();
  });

  Future<void> pumpResults(
    WidgetTester tester, {
    required bool isPremium,
    required bool shouldShowProPromotion,
  }) async {
    final db = await tester.pumpApp(const CalculatorResults(results: results), [
      isPremiumProvider.overrideWithValue(isPremium),
      shouldShowProPromotionProvider.overrideWithValue(shouldShowProPromotion),
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
      expect(find.text(results.total.toString()), findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('calculator.result.totalCost')),
        findsOneWidget,
      );
    });
  });
}
