import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_costing_state.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';

class BatchQuoteSaveAnalytics {
  const BatchQuoteSaveAnalytics({
    required this.outcome,
    required this.itemCount,
    required this.copyCount,
    required this.hasGCodeItems,
    required this.hasManualItems,
    required this.hasSplitPrinters,
    required this.hasSplitMaterials,
  });

  final String outcome;
  final int itemCount;
  final int copyCount;
  final bool hasGCodeItems;
  final bool hasManualItems;
  final bool hasSplitPrinters;
  final bool hasSplitMaterials;

  BatchQuoteSaveAnalytics copyWith({String? outcome}) {
    return BatchQuoteSaveAnalytics(
      outcome: outcome ?? this.outcome,
      itemCount: itemCount,
      copyCount: copyCount,
      hasGCodeItems: hasGCodeItems,
      hasManualItems: hasManualItems,
      hasSplitPrinters: hasSplitPrinters,
      hasSplitMaterials: hasSplitMaterials,
    );
  }
}

BatchQuoteSaveAnalytics buildBatchQuoteSaveAnalytics(BatchCostingState state) {
  final copyCount = state.items.fold<int>(
    0,
    (sum, item) => sum + item.quantity,
  );
  return BatchQuoteSaveAnalytics(
    outcome: 'success',
    itemCount: state.items.length,
    copyCount: copyCount,
    hasGCodeItems: state.items.any(
      (item) => item.sourceType == BatchCostingItemSourceType.gcode,
    ),
    hasManualItems: state.items.any(
      (item) => item.sourceType == BatchCostingItemSourceType.manual,
    ),
    hasSplitPrinters: state.hasSplitPrinters,
    hasSplitMaterials: state.hasSplitMaterials,
  );
}

void recordBatchQuoteSaveOutcome(BatchQuoteSaveAnalytics analytics) {
  AppAnalytics.safeLog(
    () => AppAnalytics.batchQuoteSaved(
      outcome: analytics.outcome,
      itemCount: analytics.itemCount,
      copyCount: analytics.copyCount,
      hasGCodeItems: analytics.hasGCodeItems,
      hasManualItems: analytics.hasManualItems,
      hasSplitPrinters: analytics.hasSplitPrinters,
      hasSplitMaterials: analytics.hasSplitMaterials,
    ),
  );
}
