enum BatchPricingScope { item, batch }

class BatchPricingFieldState {
  const BatchPricingFieldState({
    this.value = '',
    this.scope = BatchPricingScope.item,
  });

  final String value;
  final BatchPricingScope scope;

  BatchPricingFieldState copyWith({String? value, BatchPricingScope? scope}) {
    return BatchPricingFieldState(
      value: value ?? this.value,
      scope: scope ?? this.scope,
    );
  }
}

class BatchPricingState {
  const BatchPricingState({
    this.failureRisk = const BatchPricingFieldState(),
    this.markupPercent = const BatchPricingFieldState(),
    this.labourRate = const BatchPricingFieldState(),
    this.additionalCostAmount = const BatchPricingFieldState(
      scope: BatchPricingScope.batch,
    ),
  });

  final BatchPricingFieldState failureRisk;
  final BatchPricingFieldState markupPercent;
  final BatchPricingFieldState labourRate;
  final BatchPricingFieldState additionalCostAmount;

  BatchPricingState copyWith({
    BatchPricingFieldState? failureRisk,
    BatchPricingFieldState? markupPercent,
    BatchPricingFieldState? labourRate,
    BatchPricingFieldState? additionalCostAmount,
  }) {
    return BatchPricingState(
      failureRisk: failureRisk ?? this.failureRisk,
      markupPercent: markupPercent ?? this.markupPercent,
      labourRate: labourRate ?? this.labourRate,
      additionalCostAmount: additionalCostAmount ?? this.additionalCostAmount,
    );
  }
}
