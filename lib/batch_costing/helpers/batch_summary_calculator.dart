import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_costing_state.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_pricing_state.dart';
import 'package:threed_print_cost_calculator/calculator/helpers/pricing_calculator.dart';
import 'package:threed_print_cost_calculator/calculator/model/pricing_models.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';
import 'package:threed_print_cost_calculator/shared/services/electricity_resolver.dart';
import 'package:threed_print_cost_calculator/shared/utils/number_parsing.dart';

class BatchSummaryItemBreakdown {
  const BatchSummaryItemBreakdown({
    required this.item,
    required this.totalQuantity,
    required this.totalWeightG,
    required this.totalPrintDuration,
    required this.baseCost,
    required this.electricityCost,
    required this.labourCost,
    required this.additionalCost,
    required this.pricing,
  });

  final BatchCostingItem item;
  final int totalQuantity;
  final double totalWeightG;
  final Duration totalPrintDuration;
  final num baseCost;
  final num electricityCost;
  final num labourCost;
  final num additionalCost;
  final PricingResult pricing;
}

class BatchSummaryResult {
  const BatchSummaryResult({
    required this.itemCount,
    required this.totalQuantity,
    required this.totalWeightG,
    required this.totalPrintDuration,
    required this.items,
    required this.additionalCost,
    required this.failureRisk,
    required this.markupPercent,
    required this.labourRate,
    required this.finalTotal,
    required this.totalElectricityCost,
    required this.totalLabourCost,
    required this.failureRiskMonetary,
    required this.markupPercentMonetary,
  });

  final int itemCount;
  final int totalQuantity;
  final double totalWeightG;
  final Duration totalPrintDuration;
  final List<BatchSummaryItemBreakdown> items;
  final num additionalCost;
  final BatchPricingFieldState failureRisk;
  final BatchPricingFieldState markupPercent;
  final BatchPricingFieldState labourRate;
  final num finalTotal;
  final num totalElectricityCost;
  final num totalLabourCost;
  final num failureRiskMonetary;
  final num markupPercentMonetary;
}

class BatchSummaryCalculator {
  const BatchSummaryCalculator._();

  static const _resolver = ElectricityResolver();

  static BatchSummaryResult calculate(
    BatchCostingState state, {
    Map<String, PrinterModel>? printersById,
    Map<String, MaterialModel>? materialsById,
    num kwCost = 0,
  }) {
    final items = <BatchSummaryItemBreakdown>[];
    var totalQuantity = 0;
    var totalWeightG = 0.0;
    var totalPrintMinutes = 0;

    final batchLabourRate = _parseAmount(state.pricing.labourRate.value);
    final batchFailureRisk = _parsePercent(state.pricing.failureRisk.value);
    final parsedBatchMarkupPercent = _parsePercent(
      state.pricing.markupPercent.value,
    );
    final batchAdditionalCost = _parseAmount(
      state.pricing.additionalCostAmount.value,
    );

    var failureRiskMonetary = 0.0;
    var markupPercentMonetary = 0.0;
    var batchSubtotal = 0.0;
    num totalElectricityCost = 0;
    num totalLabourCost = 0;
    for (final item in state.items) {
      final itemWeight = item.printWeightG ?? 0;
      final itemDurationMin = item.printDuration?.inMinutes ?? 0;

      totalQuantity += item.quantity;
      totalWeightG += itemWeight * item.quantity;
      totalPrintMinutes += itemDurationMin * item.quantity;

      final hours = itemDurationMin / 60;
      final itemLabourCost =
          hours *
          _scopeValue(state.pricing.labourRate, batchLabourRate) *
          item.quantity;
      final itemElectricityCost = _itemElectricityCost(
        state,
        item,
        printersById,
        hours,
        kwCost,
      );
      final itemBaseCost =
          itemLabourCost +
          itemElectricityCost +
          _itemMaterialCost(state, item, materialsById);
      totalElectricityCost += itemElectricityCost;
      totalLabourCost += itemLabourCost;
      if (state.pricing.failureRisk.scope == BatchPricingScope.item) {
        failureRiskMonetary += itemBaseCost * batchFailureRisk / 100;
      }
      final itemRiskCost = _itemRiskCost(
        itemBaseCost,
        batchFailureRisk,
        state.pricing,
      );
      final itemAdditionalCost = _itemAdditionalCost(
        item,
        batchAdditionalCost,
        state.pricing,
      );
      final itemMarkupPercent =
          state.pricing.markupPercent.scope == BatchPricingScope.item
          ? parsedBatchMarkupPercent
          : 0;
      final pricing = PricingCalculator.calculate(
        baseCost: itemBaseCost + itemRiskCost,
        markupPercent: itemMarkupPercent,
        setupFee: itemAdditionalCost,
        roundingMode: PricingRoundingMode.none,
      );

      final itemMarkupAmount = pricing.markupPercent > 0
          ? pricing.finalPrice - pricing.baseCost - pricing.setupFee
          : 0;
      if (pricing.markupPercent > 0) {
        markupPercentMonetary += itemMarkupAmount;
      }

      items.add(
        BatchSummaryItemBreakdown(
          item: item,
          totalQuantity: item.quantity,
          totalWeightG: itemWeight * item.quantity,
          totalPrintDuration: Duration(
            minutes: itemDurationMin * item.quantity,
          ),
          baseCost: itemBaseCost,
          electricityCost: itemElectricityCost,
          labourCost: itemLabourCost,
          additionalCost: itemAdditionalCost,
          pricing: pricing,
        ),
      );
      batchSubtotal += pricing.finalPrice;
    }

    if (state.pricing.failureRisk.scope == BatchPricingScope.batch) {
      failureRiskMonetary = batchSubtotal * batchFailureRisk / 100;
    }
    final batchRiskCost = _batchScopedRisk(
      batchSubtotal,
      batchFailureRisk,
      state.pricing.failureRisk,
    );
    final batchMarkupPercent = _batchScopedPercent(
      state.pricing.markupPercent,
      parsedBatchMarkupPercent,
    );
    final batchPricing = PricingCalculator.calculate(
      baseCost: batchSubtotal + batchRiskCost,
      markupPercent: batchMarkupPercent,
      setupFee: _batchScopedSetupFee(
        state.pricing.additionalCostAmount,
        batchAdditionalCost,
      ),
      roundingMode: PricingRoundingMode.none,
    );

    if (state.pricing.markupPercent.scope == BatchPricingScope.batch) {
      markupPercentMonetary =
          (batchSubtotal + batchRiskCost) * parsedBatchMarkupPercent / 100;
    }

    final finalTotal = batchPricing.finalPrice;

    return BatchSummaryResult(
      itemCount: state.items.length,
      totalQuantity: totalQuantity,
      totalWeightG: totalWeightG,
      totalPrintDuration: Duration(minutes: totalPrintMinutes),
      items: items,
      additionalCost: batchAdditionalCost,
      failureRisk: state.pricing.failureRisk,
      markupPercent: state.pricing.markupPercent,
      labourRate: state.pricing.labourRate,
      finalTotal: finalTotal,
      totalElectricityCost: totalElectricityCost,
      totalLabourCost: totalLabourCost,
      failureRiskMonetary: failureRiskMonetary,
      markupPercentMonetary: markupPercentMonetary,
    );
  }

  static num _itemElectricityCost(
    BatchCostingState state,
    BatchCostingItem item,
    Map<String, PrinterModel>? printersById,
    double hours,
    num kwCost,
  ) {
    if (printersById == null) return 0;
    final allocations = state.itemPrinterAllocations[item.id];
    if (allocations != null && allocations.isNotEmpty) {
      num total = 0;
      for (final allocation in allocations) {
        final printer = printersById[allocation.targetId];
        if (printer == null) continue;
        total +=
            _resolver.resolveFromPrinter(printer).wattage /
            1000 *
            hours *
            kwCost *
            allocation.quantity;
      }
      return total;
    }
    final printerId =
        item.printerId ?? state.itemPrinterIds[item.id] ?? state.batchPrinterId;
    final printer = printersById[printerId];
    if (printer == null) return 0;
    return _resolver.resolveFromPrinter(printer).wattage /
        1000 *
        hours *
        kwCost *
        item.quantity;
  }

  static num _itemMaterialCost(
    BatchCostingState state,
    BatchCostingItem item,
    Map<String, MaterialModel>? materialsById,
  ) {
    if (materialsById == null) return 0;

    final weightPerUnit = item.printWeightG ?? 0;
    if (weightPerUnit <= 0) return 0;

    final allocations = state.itemMaterialAllocations[item.id];
    if (allocations != null && allocations.isNotEmpty) {
      return _multiMaterialCost(weightPerUnit, allocations, materialsById);
    }

    final materialId = item.materialId ?? state.batchMaterialId;
    if (materialId == null) return 0;

    final material = materialsById[materialId];
    if (material == null) return 0;

    return _filamentCost(
      itemWeight: weightPerUnit * item.quantity,
      material: material,
    );
  }

  static num _multiMaterialCost(
    double weightPerUnit,
    List<BatchAssignmentAllocation> allocations,
    Map<String, MaterialModel> materialsById,
  ) {
    num total = 0;
    for (final allocation in allocations) {
      final material = materialsById[allocation.targetId];
      if (material == null) continue;

      final spoolWeight = parseLocalizedNumOrFallback(material.weight);
      final costPerSpool = parseLocalizedNumOrFallback(material.cost);
      if (spoolWeight <= 0 || costPerSpool <= 0) continue;

      final weightGrams = weightPerUnit * allocation.quantity;
      final raw = (weightGrams * costPerSpool) / spoolWeight;
      total += num.parse(raw.toStringAsFixed(2));
    }
    return num.parse(total.toStringAsFixed(2));
  }

  static num _filamentCost({
    required double itemWeight,
    required MaterialModel material,
  }) {
    final spoolWeight = parseLocalizedNumOrFallback(material.weight);
    final costPerSpool = parseLocalizedNumOrFallback(material.cost);
    if (spoolWeight <= 0 || costPerSpool <= 0 || itemWeight <= 0) return 0;

    final raw = (itemWeight / spoolWeight) * costPerSpool;
    return num.parse(raw.toStringAsFixed(2));
  }

  static num _itemAdditionalCost(
    BatchCostingItem item,
    num batchAdditionalCost,
    BatchPricingState pricing,
  ) {
    if (pricing.additionalCostAmount.scope != BatchPricingScope.item) {
      return 0;
    }

    final additionalCost = _scopeValue(
      pricing.additionalCostAmount,
      batchAdditionalCost,
    );
    return additionalCost * item.quantity;
  }

  static num _itemRiskCost(
    num baseCost,
    num batchRisk,
    BatchPricingState pricing,
  ) {
    return pricing.failureRisk.scope == BatchPricingScope.item
        ? baseCost * batchRisk / 100
        : 0;
  }

  static num _batchScopedSetupFee(BatchPricingFieldState field, num value) {
    return field.scope == BatchPricingScope.batch ? value : 0;
  }

  static num _batchScopedRisk(
    num baseCost,
    num batchRisk,
    BatchPricingFieldState field,
  ) {
    return field.scope == BatchPricingScope.batch
        ? baseCost * batchRisk / 100
        : 0;
  }

  static num _batchScopedPercent(BatchPricingFieldState field, num value) {
    return field.scope == BatchPricingScope.batch ? value : 0;
  }

  static num _scopeValue(BatchPricingFieldState field, num batchValue) {
    final parsed = _parseAmount(field.value);
    return field.scope == BatchPricingScope.batch ? batchValue : parsed;
  }

  static num _parseAmount(String value) =>
      num.tryParse(value.replaceAll(',', '.')) ?? 0;

  static num _parsePercent(String value) =>
      num.tryParse(value.replaceAll(',', '.')) ?? 0;
}
