import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage_input.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/calculator/view/components/materials_selection/material_picker.dart';
import 'package:threed_print_cost_calculator/shared/utils/number_parsing.dart';

/// Shows the material picker bottom sheet and updates the calculator state.
/// Returns the selected material id or null if cancelled.
Future<String?> showMaterialPicker(
  BuildContext context,
  WidgetRef ref, {
  required int? editingIndex,
  String? focusAfterId,
}) async {
  final state = ref.read(calculatorProvider);

  final selectedIds = state.materialUsages
      .map((u) => u.materialId)
      .where((id) => id.trim().isNotEmpty)
      .map((e) => e.trim())
      .toSet();
  if (focusAfterId != null && focusAfterId.trim().isNotEmpty) {
    selectedIds.remove(focusAfterId);
  }

  final selectedId = await showModalBottomSheet<String>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (context) {
      return FractionallySizedBox(
        heightFactor: 0.95,
        child: MaterialPicker(
          onSelected: (material) {
            final weight = parseLocalizedNumOrFallback(material.weight);
            final cost = parseLocalizedNumOrFallback(material.cost);
            final costPerKg = weight <= 0 ? 0 : (cost / weight) * 1000;

            final notifier = ref.read(calculatorProvider.notifier);
            if (editingIndex != null &&
                editingIndex >= 0 &&
                editingIndex < state.materialUsages.length) {
              notifier.updateMaterialUsage(
                editingIndex,
                MaterialUsageInput(
                  materialId: material.id,
                  materialName: material.name,
                  costPerKg: costPerKg,
                  weightGrams: state.materialUsages[editingIndex].weightGrams,
                ),
              );
            } else {
              notifier.addMaterialUsage(
                MaterialUsageInput(
                  materialId: material.id,
                  materialName: material.name,
                  costPerKg: costPerKg,
                  weightGrams: 0,
                ),
              );
            }
            notifier.submit();
            Navigator.of(context).pop(material.id);
          },
          excludedIds: selectedIds,
        ),
      );
    },
  );

  return selectedId;
}
