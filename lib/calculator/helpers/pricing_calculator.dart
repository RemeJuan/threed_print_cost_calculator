import 'dart:math' as math;

import 'package:threed_print_cost_calculator/calculator/model/pricing_models.dart';

class PricingCalculator {
  const PricingCalculator._();

  static PricingResult calculate({
    required num baseCost,
    required num markupPercent,
    required num setupFee,
    required PricingRoundingMode roundingMode,
  }) {
    final normalizedBaseCost = _roundCurrency(baseCost);
    final normalizedMarkupPercent = _roundCurrency(markupPercent);
    final normalizedSetupFee = _roundCurrency(setupFee);

    if (normalizedBaseCost <= 0) {
      return PricingResult(
        baseCost: normalizedBaseCost,
        markupPercent: normalizedMarkupPercent,
        markupAmount: 0,
        setupFee: normalizedSetupFee,
        roundingMode: roundingMode,
        subtotalBeforeRounding: 0,
        roundingAdjustment: 0,
        finalPrice: 0,
      );
    }

    final markupAmount = _roundCurrency(
      normalizedBaseCost * (normalizedMarkupPercent / 100),
    );
    final subtotalBeforeRounding = _roundCurrency(
      normalizedBaseCost + markupAmount + normalizedSetupFee,
    );
    final finalPrice = _applyRounding(subtotalBeforeRounding, roundingMode);
    final roundingAdjustment = _roundCurrency(finalPrice - subtotalBeforeRounding);

    return PricingResult(
      baseCost: normalizedBaseCost,
      markupPercent: normalizedMarkupPercent,
      markupAmount: markupAmount,
      setupFee: normalizedSetupFee,
      roundingMode: roundingMode,
      subtotalBeforeRounding: subtotalBeforeRounding,
      roundingAdjustment: roundingAdjustment,
      finalPrice: finalPrice,
    );
  }

  static num _applyRounding(num subtotal, PricingRoundingMode roundingMode) {
    if (subtotal <= 0) return 0;

    switch (roundingMode) {
      case PricingRoundingMode.none:
        return _roundCurrency(subtotal);
      case PricingRoundingMode.wholeDollar:
        return _roundCurrency(subtotal.ceil());
      case PricingRoundingMode.pointNinetyNine:
        final floorValue = subtotal.floor();
        final candidate = floorValue + 0.99;
        if (subtotal < candidate) {
          return _roundCurrency(candidate);
        }
        return _roundCurrency(math.max(floorValue + 1, subtotal.ceil()) + 0.99);
    }
  }

  static num _roundCurrency(num value) => num.parse(value.toStringAsFixed(2));
}
