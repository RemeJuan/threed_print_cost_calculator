import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/calculator/model/pricing_models.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculation_results_state.dart';
import 'package:threed_print_cost_calculator/customer_view/customer_view_data.dart';

void main() {
  const results = CalculationResult(
    electricity: 2,
    filament: 20,
    risk: 3,
    labour: 5,
    total: 30,
  );

  test('uses final sell price when pricing is enabled', () {
    const pricing = PricingResult(
      baseCost: 30,
      markupPercent: 20,
      markupAmount: 6,
      setupFee: 0,
      roundingMode: PricingRoundingMode.none,
      subtotalBeforeRounding: 36,
      roundingAdjustment: 0,
      finalPrice: 36,
    );

    expect(
      CustomerViewData.fromCalculator(
        results: results,
        pricing: pricing,
      ).finalPrice,
      36,
    );
  });

  test('uses calculation total when pricing is disabled', () {
    const pricing = PricingResult.empty();

    expect(
      CustomerViewData.fromCalculator(
        results: results,
        pricing: pricing,
      ).finalPrice,
      30,
    );
  });
}
