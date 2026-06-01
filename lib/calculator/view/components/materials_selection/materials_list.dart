import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage_input.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'material_row.dart';

/// Renders the list of material rows inside a constrained scroll area.
class MaterialsList extends StatelessWidget {
  const MaterialsList({
    required this.usages,
    required this.materialsById,
    required this.onPick,
    required this.onWeightChanged,
    required this.onRemove,
    this.onSpoolWeightChanged,
    this.onSpoolCostChanged,
    this.currencySymbol = '',
    this.currencyPosition = 'before',
    this.currencySpacing = false,
    super.key,
  });

  final List<MaterialUsageInput> usages;
  final Map<String, MaterialModel> materialsById;
  final void Function(int index) onPick;
  final void Function(int index, int grams) onWeightChanged;
  final void Function(int index) onRemove;
  final void Function(int index, num value)? onSpoolWeightChanged;
  final void Function(int index, num value)? onSpoolCostChanged;
  final String currencySymbol;
  final String currencyPosition;
  final bool currencySpacing;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.45;
    final constrainedHeight =
        (usages.length == 1 && usages.first.weightGrams == 0)
        ? null
        : (usages.length > 4 ? maxHeight : null);

    final sortedIndices = List.generate(usages.length, (i) => i);
    sortedIndices.sort((a, b) {
      if (usages[a].isUnsaved && !usages[b].isUnsaved) return 1;
      if (!usages[a].isUnsaved && usages[b].isUnsaved) return -1;
      return 0;
    });

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: constrainedHeight ?? double.infinity,
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        itemCount: usages.length,
        itemBuilder: (context, index) {
          final actualIndex = sortedIndices[index];
          final usage = usages[actualIndex];
          final material = materialsById[usage.materialId];

          return MaterialRow(
            index: actualIndex,
            usage: usage,
            material: material,
            isUnsaved: usage.isUnsaved,
            onPick: () => onPick(actualIndex),
            onWeightChanged: (grams) => onWeightChanged(actualIndex, grams),
            onRemove: () => onRemove(actualIndex),
            onSpoolWeightChanged: onSpoolWeightChanged != null
                ? (v) => onSpoolWeightChanged!(actualIndex, v)
                : null,
            onSpoolCostChanged: onSpoolCostChanged != null
                ? (v) => onSpoolCostChanged!(actualIndex, v)
                : null,
            currencySymbol: currencySymbol,
            currencyPosition: currencyPosition,
            currencySpacing: currencySpacing,
          );
        },
      ),
    );
  }
}
