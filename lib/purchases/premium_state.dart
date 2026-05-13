class PremiumState {
  const PremiumState({
    required this.isPremium,
    required this.isLoading,
    this.userId = '',
    this.platform = 'unknown',
    this.entitlementType = 'none',
    this.productId = '',
    this.willRenew = true,
    this.cancellationDetectedAt,
    this.billingIssueDetectedAt,
    this.originalPurchaseDate,
    this.expirationDate,
  });

  const PremiumState.loading() : this(isPremium: false, isLoading: true);

  final bool isPremium;
  final bool isLoading;
  final String userId;
  final String platform;
  final String entitlementType;
  final String productId;
  final bool willRenew;
  final DateTime? cancellationDetectedAt;
  final DateTime? billingIssueDetectedAt;
  final DateTime? originalPurchaseDate;
  final DateTime? expirationDate;

  bool get hasActiveCanceledEntitlement {
    return isPremium &&
        entitlementType != 'none' &&
        billingIssueDetectedAt == null &&
        (cancellationDetectedAt != null || !willRenew);
  }

  String? get cancellationStateKey {
    if (!hasActiveCanceledEntitlement) return null;

    return <String>[
      userId,
      entitlementType,
      productId,
      cancellationDetectedAt?.toIso8601String() ?? '',
      originalPurchaseDate?.toIso8601String() ?? '',
    ].join('|');
  }

  PremiumState copyWith({
    bool? isPremium,
    bool? isLoading,
    String? userId,
    String? platform,
    String? entitlementType,
    String? productId,
    bool? willRenew,
    DateTime? cancellationDetectedAt,
    bool clearCancellationDetectedAt = false,
    DateTime? billingIssueDetectedAt,
    bool clearBillingIssueDetectedAt = false,
    DateTime? originalPurchaseDate,
    bool clearOriginalPurchaseDate = false,
    DateTime? expirationDate,
    bool clearExpirationDate = false,
  }) {
    return PremiumState(
      isPremium: isPremium ?? this.isPremium,
      isLoading: isLoading ?? this.isLoading,
      userId: userId ?? this.userId,
      platform: platform ?? this.platform,
      entitlementType: entitlementType ?? this.entitlementType,
      productId: productId ?? this.productId,
      willRenew: willRenew ?? this.willRenew,
      cancellationDetectedAt: clearCancellationDetectedAt
          ? null
          : cancellationDetectedAt ?? this.cancellationDetectedAt,
      billingIssueDetectedAt: clearBillingIssueDetectedAt
          ? null
          : billingIssueDetectedAt ?? this.billingIssueDetectedAt,
      originalPurchaseDate: clearOriginalPurchaseDate
          ? null
          : originalPurchaseDate ?? this.originalPurchaseDate,
      expirationDate: clearExpirationDate
          ? null
          : expirationDate ?? this.expirationDate,
    );
  }
}
