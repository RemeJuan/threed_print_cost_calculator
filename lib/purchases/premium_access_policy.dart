enum PremiumFeature {
  materials,
  printers,
  history,
  historyExport,
  singleJobExport,
  bulkHistoryExport,
  gcodeImport,
  batchGcodeImport,
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

enum CellType { text, count, saves, upTo }

class ComparisonCell {
  const ComparisonCell({this.textKey, this.limit, required this.type});

  final String? textKey;
  final int? limit;
  final CellType type;
}

class PaywallComparisonRow {
  const PaywallComparisonRow({
    required this.id,
    required this.labelKey,
    required this.freeCell,
    required this.premiumCell,
    this.emphasis = false,
    required this.order,
  });

  final String id;
  final String labelKey;
  final ComparisonCell freeCell;
  final ComparisonCell premiumCell;
  final bool emphasis;
  final int order;
}

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
  FeatureAccess singleJobExport();
  FeatureAccess bulkHistoryExport();
  FeatureAccess historyExport();
  FeatureAccess gcodeImport();
  FeatureAccess batchGcodeImport();
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

  List<PremiumFeature> get paywallFeatures;

  List<PaywallComparisonRow> get paywallComparisonRows;
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
  bool get shouldShowHistoryTab => true;

  @override
  bool get shouldShowHistoryTeaser => false;

  @override
  int? get materialLimit => _isPremium ? null : 5;

  @override
  int? get printerLimit => _isPremium ? null : 2;

  @override
  int? get historyLimit => _isPremium ? null : 7;

  @override
  int? get batchItemLimit => _isPremium ? null : 3;

  @override
  List<PremiumFeature> get paywallFeatures => _paywallPremiumFeatures;

  static const String _unlimitedKey = 'paywallValueUnlimited';
  static const String _noKey = 'paywallValueNo';
  static const String _yesKey = 'paywallValueYes';
  static const String _basicKey = 'paywallValueBasic';
  static const String _fullKey = 'paywallValueFull';
  static const String _singleJobKey = 'paywallValueSingleJob';
  static const String _fullSuiteKey = 'paywallValueFullSuite';

  @override
  List<PaywallComparisonRow> get paywallComparisonRows => [
    PaywallComparisonRow(
      id: 'materials',
      labelKey: 'paywallRowMaterialsLabel',
      freeCell: ComparisonCell(type: CellType.count, limit: materialLimit ?? 5),
      premiumCell: ComparisonCell(type: CellType.text, textKey: _unlimitedKey),
      emphasis: true,
      order: 1,
    ),
    PaywallComparisonRow(
      id: 'printers',
      labelKey: 'paywallRowPrintersLabel',
      freeCell: ComparisonCell(type: CellType.count, limit: printerLimit ?? 2),
      premiumCell: ComparisonCell(type: CellType.text, textKey: _unlimitedKey),
      order: 2,
    ),
    PaywallComparisonRow(
      id: 'history',
      labelKey: 'paywallRowHistoryLabel',
      freeCell: ComparisonCell(type: CellType.saves, limit: historyLimit ?? 7),
      premiumCell: ComparisonCell(type: CellType.text, textKey: _unlimitedKey),
      emphasis: true,
      order: 3,
    ),
    PaywallComparisonRow(
      id: 'batchCosting',
      labelKey: 'paywallRowBatchCostingLabel',
      freeCell: ComparisonCell(type: CellType.upTo, limit: batchItemLimit ?? 3),
      premiumCell: ComparisonCell(type: CellType.text, textKey: _unlimitedKey),
      emphasis: true,
      order: 4,
    ),
    PaywallComparisonRow(
      id: 'advancedPricing',
      labelKey: 'paywallRowAdvancedPricingLabel',
      freeCell: ComparisonCell(type: CellType.text, textKey: _basicKey),
      premiumCell: ComparisonCell(type: CellType.text, textKey: _fullKey),
      order: 5,
    ),
    PaywallComparisonRow(
      id: 'exportTools',
      labelKey: 'paywallRowExportToolsLabel',
      freeCell: ComparisonCell(type: CellType.text, textKey: _singleJobKey),
      premiumCell: ComparisonCell(type: CellType.text, textKey: _fullSuiteKey),
      order: 6,
    ),
    PaywallComparisonRow(
      id: 'inventoryTracking',
      labelKey: 'paywallRowInventoryTrackingLabel',
      freeCell: ComparisonCell(type: CellType.text, textKey: _noKey),
      premiumCell: ComparisonCell(type: CellType.text, textKey: _yesKey),
      order: 7,
    ),
  ];

  static const List<PremiumFeature> _paywallPremiumFeatures = [
    PremiumFeature.materials,
    PremiumFeature.printers,
    PremiumFeature.advancedPricingConfig,
    PremiumFeature.historyExport,
    PremiumFeature.bulkHistoryExport,
    PremiumFeature.batchExport,
    PremiumFeature.stockTracking,
  ];

  @override
  FeatureAccess materialsLibrary() => _premiumFeature(PremiumFeature.materials);

  @override
  FeatureAccess printers() => _freeFeature(PremiumFeature.printers);

  @override
  FeatureAccess printersList() => _premiumFeature(PremiumFeature.printers);

  @override
  FeatureAccess historyView() => _freeFeature(PremiumFeature.history);

  @override
  FeatureAccess singleJobExport() =>
      _freeFeature(PremiumFeature.singleJobExport);

  @override
  FeatureAccess bulkHistoryExport() =>
      _premiumFeature(PremiumFeature.bulkHistoryExport);

  @override
  FeatureAccess historyExport() =>
      _premiumFeature(PremiumFeature.historyExport);

  @override
  FeatureAccess gcodeImport() => _freeFeature(PremiumFeature.gcodeImport);

  @override
  FeatureAccess batchGcodeImport() =>
      _premiumFeature(PremiumFeature.batchGcodeImport);

  @override
  FeatureAccess batchCosting() => _freeFeature(PremiumFeature.batchCosting);

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
  FeatureAccess multiMaterial() => _freeFeature(PremiumFeature.multiMaterial);

  @override
  FeatureAccess saveToHistory() => _freeFeature(PremiumFeature.saveToHistory);

  @override
  FeatureAccess csvMaterialImport() =>
      _premiumFeature(PremiumFeature.csvMaterialImport);

  @override
  FeatureAccess stockTracking() =>
      _premiumFeature(PremiumFeature.stockTracking);

  @override
  QuotaAccess canCreateMaterial(int currentCount) =>
      _quotaAccess(currentCount, materialLimit);

  @override
  QuotaAccess canCreatePrinter(int currentCount) =>
      _quotaAccess(currentCount, printerLimit);

  @override
  QuotaAccess canSaveHistoryItem(int currentCount) =>
      _quotaAccess(currentCount, historyLimit);

  @override
  QuotaAccess canAddBatchItem(int currentCount) =>
      _quotaAccess(currentCount, batchItemLimit);

  FeatureAccess _freeFeature(PremiumFeature feature) {
    return FeatureAccess(allowed: true, feature: feature);
  }

  QuotaAccess _quotaAccess(int currentCount, int? limit) {
    if (limit == null) {
      return QuotaAccess(
        allowed: true,
        limit: null,
        currentCount: currentCount,
      );
    }

    final allowed = currentCount < limit;
    return QuotaAccess(
      allowed: allowed,
      limit: limit,
      currentCount: currentCount,
      denyReason: allowed ? null : AccessDenyReason.quotaExceeded,
    );
  }

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
      PremiumFeature.singleJobExport => UpsellSurface.historyExport,
      PremiumFeature.bulkHistoryExport => UpsellSurface.historyExport,
      PremiumFeature.gcodeImport => UpsellSurface.gcodeImport,
      PremiumFeature.batchGcodeImport => UpsellSurface.gcodeImport,
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
