import 'package:threed_print_cost_calculator/calculator/model/pricing_models.dart';

class PricingCalculator {
  const PricingCalculator._();

  static PricingResult calculate({
    required num baseCost,
    required num markupPercent,
    required num setupFee,
    required PricingRoundingMode roundingMode,
  }) {
    final normalizedBaseCost = _fromCents(_toCents(baseCost));
    final normalizedMarkupPercent = _fromHundredths(
      _toHundredths(markupPercent),
    );
    final normalizedSetupFee = _fromCents(_toCents(setupFee));
    final baseCostCents = _toCents(normalizedBaseCost);
    final markupPercentHundredths = _toHundredths(normalizedMarkupPercent);
    final setupFeeCents = _toCents(normalizedSetupFee);

    if (baseCostCents < 0) {
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

    final markupAmountCents =
        (baseCostCents * markupPercentHundredths + 5000) ~/ 10000;
    final subtotalBeforeRoundingCents =
        baseCostCents + markupAmountCents + setupFeeCents;
    final finalPriceCents = _applyRoundingCents(
      subtotalBeforeRoundingCents,
      roundingMode,
    );
    final roundingAdjustmentCents =
        finalPriceCents - subtotalBeforeRoundingCents;

    return PricingResult(
      baseCost: normalizedBaseCost,
      markupPercent: normalizedMarkupPercent,
      markupAmount: _fromCents(markupAmountCents),
      setupFee: normalizedSetupFee,
      roundingMode: roundingMode,
      subtotalBeforeRounding: _fromCents(subtotalBeforeRoundingCents),
      roundingAdjustment: _fromCents(roundingAdjustmentCents),
      finalPrice: _fromCents(finalPriceCents),
    );
  }

  static int _applyRoundingCents(
    int subtotalCents,
    PricingRoundingMode roundingMode,
  ) {
    if (subtotalCents <= 0) return 0;

    switch (roundingMode) {
      case PricingRoundingMode.none:
        return subtotalCents;
      case PricingRoundingMode.wholeDollar:
        return ((subtotalCents + 99) ~/ 100) * 100;
      case PricingRoundingMode.pointNinetyNine:
        final wholeDollars = subtotalCents ~/ 100;
        final candidate = wholeDollars * 100 + 99;
        if (subtotalCents <= candidate) {
          return candidate;
        }
        return (wholeDollars + 1) * 100 + 99;
    }
  }

  static int _toCents(num value) {
    if (!value.isFinite) return 0;

    final text = value.toStringAsFixed(2);
    final negative = text.startsWith('-');
    final digits = text.replaceFirst('-', '').replaceAll('.', '');
    final cents = int.parse(digits);
    return negative ? -cents : cents;
  }

  static int _toHundredths(num value) => _toCents(value);

  static num _fromCents(int cents) => cents / 100;

  static num _fromHundredths(int hundredths) => hundredths / 100;
}
