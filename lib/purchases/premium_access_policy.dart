enum PremiumFeature {
  materials,
  printers,
  history,
  historyExport,
  gcodeImport,
  batchCosting,
  batchExport,
  labourPricing,
  riskPricing,
  advancedPricingConfig,
  multiMaterial,
  saveToHistory,
  csvMaterialImport,
  stockTracking,
}

enum AccessDenyReason { notPremium, quotaExceeded, featureNotAvailable }

enum UpsellSurface {
  materialsTab,
  historyTab,
  historyExport,
  gcodeImport,
  batchCosting,
  batchExport,
  labourPricing,
  riskPricing,
  advancedPricingConfig,
  printerManagement,
  stockTracking,
}

class FeatureAccess {
  const FeatureAccess({
    required this.allowed,
    required this.feature,
    this.denyReason,
    this.upsellSurface,
  });

  final bool allowed;
  final PremiumFeature feature;
  final AccessDenyReason? denyReason;
  final UpsellSurface? upsellSurface;
}

class QuotaAccess {
  const QuotaAccess({
    required this.allowed,
    this.limit,
    required this.currentCount,
    this.denyReason,
  });

  final bool allowed;
  final int? limit;
  final int currentCount;
  final AccessDenyReason? denyReason;
}

abstract class PremiumAccessPolicy {
  bool get isPremium;
  bool get shouldShowPromotions;
  bool get shouldShowHistoryTab;
  bool get shouldShowHistoryTeaser;

  FeatureAccess materialsLibrary();
  FeatureAccess printers();
  FeatureAccess printersList();
  FeatureAccess historyView();
  FeatureAccess historyExport();
  FeatureAccess gcodeImport();
  FeatureAccess batchCosting();
  FeatureAccess batchExport();
  FeatureAccess labourPricing();
  FeatureAccess riskPricing();
  FeatureAccess advancedPricingConfig();
  FeatureAccess multiMaterial();
  FeatureAccess saveToHistory();
  FeatureAccess csvMaterialImport();
  FeatureAccess stockTracking();

  QuotaAccess canCreateMaterial(int currentCount);
  QuotaAccess canCreatePrinter(int currentCount);
  QuotaAccess canSaveHistoryItem(int currentCount);
  QuotaAccess canAddBatchItem(int currentCount);

  int? get materialLimit;
  int? get printerLimit;
  int? get historyLimit;
  int? get batchItemLimit;
}

class DefaultPremiumAccessPolicy implements PremiumAccessPolicy {
  DefaultPremiumAccessPolicy({
    required bool isPremium,
    required bool hideProPromotions,
  }) : _isPremium = isPremium,
       _hideProPromotions = hideProPromotions;

  final bool _isPremium;
  final bool _hideProPromotions;

  @override
  bool get isPremium => _isPremium;

  @override
  bool get shouldShowPromotions => !_isPremium && !_hideProPromotions;

  @override
  bool get shouldShowHistoryTab => _isPremium || !_hideProPromotions;

  @override
  bool get shouldShowHistoryTeaser => !_isPremium && shouldShowHistoryTab;

  @override
  int? get materialLimit => null;

  @override
  int? get printerLimit => null;

  @override
  int? get historyLimit => null;

  @override
  int? get batchItemLimit => null;

  @override
  FeatureAccess materialsLibrary() => _premiumFeature(PremiumFeature.materials);

  @override
  FeatureAccess printers() => _premiumFeature(PremiumFeature.printers);

  @override
  FeatureAccess printersList() => _premiumFeature(PremiumFeature.printers);

  @override
  FeatureAccess historyView() => _premiumFeature(PremiumFeature.history);

  @override
  FeatureAccess historyExport() =>
      _premiumFeature(PremiumFeature.historyExport);

  @override
  FeatureAccess gcodeImport() => _premiumFeature(PremiumFeature.gcodeImport);

  @override
  FeatureAccess batchCosting() => _premiumFeature(PremiumFeature.batchCosting);

  @override
  FeatureAccess batchExport() => _premiumFeature(PremiumFeature.batchExport);

  @override
  FeatureAccess labourPricing() =>
      _premiumFeature(PremiumFeature.labourPricing);

  @override
  FeatureAccess riskPricing() => _premiumFeature(PremiumFeature.riskPricing);

  @override
  FeatureAccess advancedPricingConfig() =>
      _premiumFeature(PremiumFeature.advancedPricingConfig);

  @override
  FeatureAccess multiMaterial() =>
      _premiumFeature(PremiumFeature.multiMaterial);

  @override
  FeatureAccess saveToHistory() =>
      _premiumFeature(PremiumFeature.saveToHistory);

  @override
  FeatureAccess csvMaterialImport() =>
      _premiumFeature(PremiumFeature.csvMaterialImport);

  @override
  FeatureAccess stockTracking() =>
      _premiumFeature(PremiumFeature.stockTracking);

  @override
  QuotaAccess canCreateMaterial(int currentCount) =>
      QuotaAccess(allowed: _isPremium, limit: null, currentCount: currentCount);

  @override
  QuotaAccess canCreatePrinter(int currentCount) =>
      QuotaAccess(allowed: _isPremium, limit: null, currentCount: currentCount);

  @override
  QuotaAccess canSaveHistoryItem(int currentCount) =>
      QuotaAccess(allowed: _isPremium, limit: null, currentCount: currentCount);

  @override
  QuotaAccess canAddBatchItem(int currentCount) =>
      QuotaAccess(allowed: _isPremium, limit: null, currentCount: currentCount);

  FeatureAccess _premiumFeature(PremiumFeature feature) {
    return FeatureAccess(
      allowed: _isPremium,
      feature: feature,
      denyReason: _isPremium ? null : AccessDenyReason.notPremium,
      upsellSurface: _isPremium ? null : _upsellSurfaceForFeature(feature),
    );
  }

  UpsellSurface _upsellSurfaceForFeature(PremiumFeature feature) {
    return switch (feature) {
      PremiumFeature.materials => UpsellSurface.materialsTab,
      PremiumFeature.printers => UpsellSurface.printerManagement,
      PremiumFeature.history => UpsellSurface.historyTab,
      PremiumFeature.historyExport => UpsellSurface.historyExport,
      PremiumFeature.gcodeImport => UpsellSurface.gcodeImport,
      PremiumFeature.batchCosting => UpsellSurface.batchCosting,
      PremiumFeature.batchExport => UpsellSurface.batchExport,
      PremiumFeature.labourPricing => UpsellSurface.labourPricing,
      PremiumFeature.riskPricing => UpsellSurface.riskPricing,
      PremiumFeature.advancedPricingConfig =>
        UpsellSurface.advancedPricingConfig,
      PremiumFeature.multiMaterial => UpsellSurface.materialsTab,
      PremiumFeature.saveToHistory => UpsellSurface.historyTab,
      PremiumFeature.csvMaterialImport => UpsellSurface.materialsTab,
      PremiumFeature.stockTracking => UpsellSurface.stockTracking,
    };
  }
}
