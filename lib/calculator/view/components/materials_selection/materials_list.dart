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
    super.key,
  });

  final List<MaterialUsageInput> usages;
  final Map<String, MaterialModel> materialsById;
  final void Function(int index) onPick;
  final void Function(int index, int grams) onWeightChanged;
  final void Function(int index) onRemove;

  @override
  Widget build(BuildContext context) {
    final totalWeight = usages.fold<int>(0, (s, i) => s + i.weightGrams);

    final maxHeight = MediaQuery.of(context).size.height * 0.45;
    final constrainedHeight = totalWeight == 0 && usages.length <= 1
        ? null
        : (usages.length > 4 ? maxHeight : null);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: constrainedHeight ?? double.infinity,
      ),
      child: Scrollbar(
        child: ListView.builder(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          itemCount: usages.length,
          itemBuilder: (context, index) {
            final usage = usages[index];
            final material = materialsById[usage.materialId];

            return MaterialRow(
              index: index,
              usage: usage,
              material: material,
              onPick: () => onPick(index),
              onWeightChanged: (grams) => onWeightChanged(index, grams),
              onRemove: () => onRemove(index),
            );
          },
        ),
      ),
    );
  }
}
