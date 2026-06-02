import 'dart:math';
import 'package:riverpod/riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage_input.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculator_state.dart';

final calculatorMaterialsServiceProvider = Provider<CalculatorMaterialsService>(
  (ref) {
    return CalculatorMaterialsService();
  },
);

class CalculatorMaterialsService {
  List<MaterialUsageInput> syncedSingleMaterialUsage({
    required CalculatorState state,
    String? materialId,
    String? materialName,
    num? spoolWeight,
    num? spoolCost,
  }) {
    if (state.materialUsages.length != 1) return state.materialUsages;

    final usage = state.materialUsages.first;
    final nextSpoolWeight = spoolWeight ?? (state.spoolWeight.value ?? 0);
    final nextSpoolCost = spoolCost ?? (state.spoolCost.value ?? 0);

    return [
      usage.copyWith(
        materialId: materialId ?? usage.materialId,
        materialName: materialName ?? usage.materialName,
        costPerKg: _costPerKgFromSpool(
          spoolWeight: nextSpoolWeight,
          spoolCost: nextSpoolCost,
        ),
      ),
    ];
  }

  List<MaterialUsageInput> addUsage(
    List<MaterialUsageInput> usages,
    MaterialUsageInput usage,
  ) {
    final id = usage.materialId.trim();
    if (id.isNotEmpty) {
      final exists = usages.any(
        (u) => u.materialId.trim().isNotEmpty && u.materialId.trim() == id,
      );
      if (exists) return usages;
    }

    return [...usages, usage];
  }

  ({List<MaterialUsageInput> usages, int totalWeight}) removeUsageAt(
    List<MaterialUsageInput> usages,
    int index,
  ) {
    if (index < 0 || index >= usages.length) {
      return (usages: usages, totalWeight: _totalWeight(usages));
    }

    final nextUsages = [...usages]..removeAt(index);
    return (usages: nextUsages, totalWeight: _totalWeight(nextUsages));
  }

  ({List<MaterialUsageInput> usages, int totalWeight}) updateUsageWeight(
    List<MaterialUsageInput> usages,
    int index,
    int grams,
  ) {
    if (index < 0 || index >= usages.length) {
      return (usages: usages, totalWeight: _totalWeight(usages));
    }

    final safeGrams = grams < 0 ? 0 : grams;
    final nextUsages = [...usages];
    nextUsages[index] = nextUsages[index].copyWith(weightGrams: safeGrams);

    return (usages: nextUsages, totalWeight: _totalWeight(nextUsages));
  }

  List<MaterialUsageInput> normalizedMaterialUsagesForSingleTotalWeight(
    List<MaterialUsageInput> usages,
    int totalWeight,
  ) {
    if (usages.isEmpty) return usages;

    final nonNegativeTotal = totalWeight < 0 ? 0 : totalWeight;
    return List<MaterialUsageInput>.generate(usages.length, (index) {
      return usages[index].copyWith(
        weightGrams: index == 0 ? nonNegativeTotal : 0,
      );
    });
  }

  ({List<MaterialUsageInput> usages, int totalWeight}) updateUsage(
    List<MaterialUsageInput> usages,
    int index,
    MaterialUsageInput usage,
  ) {
    if (index < 0 || index >= usages.length) {
      return (usages: usages, totalWeight: _totalWeight(usages));
    }

    final nextUsages = [...usages];
    nextUsages[index] = usage;
    return (usages: nextUsages, totalWeight: _totalWeight(nextUsages));
  }

  MaterialUsageInput updateUnsavedSpoolValues(
    MaterialUsageInput usage, {
    num? spoolWeight,
    num? spoolCost,
  }) {
    final sw = max(0, spoolWeight ?? usage.unsavedSpoolWeight);
    final sc = max(0, spoolCost ?? usage.unsavedSpoolCost);
    final cpkg = sw > 0 ? (sc / sw) * 1000 : 0;
    return usage.copyWith(
      unsavedSpoolWeight: sw,
      unsavedSpoolCost: sc,
      costPerKg: cpkg,
    );
  }

  int totalWeight(List<MaterialUsageInput> usages) => _totalWeight(usages);

  num _costPerKgFromSpool({required num spoolWeight, required num spoolCost}) {
    return spoolWeight <= 0 ? 0 : (spoolCost / spoolWeight) * 1000;
  }

  int _totalWeight(List<MaterialUsageInput> usages) {
    return usages.fold<int>(0, (sum, item) => sum + item.weightGrams);
  }
}
