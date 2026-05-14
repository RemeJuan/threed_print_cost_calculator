enum PricingRoundingMode { none, wholeDollar, pointNinetyNine }

extension PricingRoundingModeX on PricingRoundingMode {
  String get storageValue => switch (this) {
    PricingRoundingMode.none => 'none',
    PricingRoundingMode.wholeDollar => '.00',
    PricingRoundingMode.pointNinetyNine => '.99',
  };

  bool get isEnabled => this != PricingRoundingMode.none;
}

PricingRoundingMode pricingRoundingModeFromStorage(String? value) {
  switch (value) {
    case '.00':
      return PricingRoundingMode.wholeDollar;
    case '.99':
      return PricingRoundingMode.pointNinetyNine;
    case 'none':
    default:
      return PricingRoundingMode.none;
  }
}

class PricingResult {
  const PricingResult({
    required this.baseCost,
    required this.markupPercent,
    required this.markupAmount,
    required this.setupFee,
    required this.roundingMode,
    required this.subtotalBeforeRounding,
    required this.roundingAdjustment,
    required this.finalPrice,
  });

  const PricingResult.empty()
    : baseCost = 0,
      markupPercent = 0,
      markupAmount = 0,
      setupFee = 0,
      roundingMode = PricingRoundingMode.none,
      subtotalBeforeRounding = 0,
      roundingAdjustment = 0,
      finalPrice = 0;

  final num baseCost;
  final num markupPercent;
  final num markupAmount;
  final num setupFee;
  final PricingRoundingMode roundingMode;
  final num subtotalBeforeRounding;
  final num roundingAdjustment;
  final num finalPrice;

  bool get isEnabled =>
      markupPercent > 0 || setupFee > 0 || roundingMode.isEnabled;
}
