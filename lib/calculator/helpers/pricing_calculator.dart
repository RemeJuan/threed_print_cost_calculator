import 'package:threed_print_cost_calculator/calculator/model/pricing_models.dart';

class PricingCalculator {
  const PricingCalculator._();

  static final BigInt _hundred = BigInt.from(100);
  static final BigInt _fiveThousand = BigInt.from(5000);
  static final BigInt _tenThousand = BigInt.from(10000);

  static PricingResult calculate({
    required num baseCost,
    required num markupPercent,
    required num setupFee,
    required PricingRoundingMode roundingMode,
  }) {
    final baseCostCents = _toCents(baseCost);
    final markupPercentHundredths = _toHundredths(markupPercent);
    final setupFeeCents = _toCents(setupFee);
    final normalizedBaseCost = _fromCents(baseCostCents);
    final normalizedMarkupPercent = _fromHundredths(markupPercentHundredths);
    final normalizedSetupFee = _fromCents(setupFeeCents);

    if (baseCostCents.isNegative) {
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
        (baseCostCents * markupPercentHundredths + _fiveThousand) ~/
        _tenThousand;
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

  static BigInt _applyRoundingCents(
    BigInt subtotalCents,
    PricingRoundingMode roundingMode,
  ) {
    if (subtotalCents <= BigInt.zero) return BigInt.zero;

    switch (roundingMode) {
      case PricingRoundingMode.none:
        return subtotalCents;
      case PricingRoundingMode.wholeDollar:
        return ((subtotalCents + BigInt.from(99)) ~/ _hundred) * _hundred;
      case PricingRoundingMode.pointNinetyNine:
        final wholeDollars = subtotalCents ~/ _hundred;
        final candidate = wholeDollars * _hundred + BigInt.from(99);
        if (subtotalCents <= candidate) {
          return candidate;
        }
        return (wholeDollars + BigInt.one) * _hundred + BigInt.from(99);
    }
  }

  static BigInt _toCents(num value) {
    if (!value.isFinite) return BigInt.zero;

    final text = value.toStringAsFixed(2);
    final negative = text.startsWith('-');
    final digits = text.replaceFirst('-', '').replaceAll('.', '');
    final cents = BigInt.parse(digits);
    return negative ? -cents : cents;
  }

  static BigInt _toHundredths(num value) => _toCents(value);

  static num _fromCents(BigInt cents) => _fromScaled(cents);

  static num _fromHundredths(BigInt hundredths) => _fromScaled(hundredths);

  static num _fromScaled(BigInt value) {
    final asDouble = value.toDouble();
    if (asDouble.isFinite) return asDouble / 100;

    return value.isNegative ? -double.maxFinite : double.maxFinite;
  }
}
