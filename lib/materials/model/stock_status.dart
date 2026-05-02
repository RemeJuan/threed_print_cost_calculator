import 'package:threed_print_cost_calculator/settings/model/material_model.dart';

enum StockStatus { outOfStock, lowStock, inStock, noTracking }

StockStatus calculateStockStatus(MaterialModel material) {
  if (!material.autoDeductEnabled) return StockStatus.noTracking;
  if (material.remainingWeight <= 0) return StockStatus.outOfStock;
  if (material.originalWeight <= 0) return StockStatus.noTracking;
  final percent = material.remainingWeight / material.originalWeight;
  if (percent <= 0.15) return StockStatus.lowStock;
  return StockStatus.inStock;
}

double stockPercent(MaterialModel material) {
  if (!material.autoDeductEnabled || material.originalWeight <= 0) return 1;
  return (material.remainingWeight / material.originalWeight).clamp(0, 1);
}
