import 'package:flutter/material.dart';

import 'package:threed_print_cost_calculator/batch_costing/widgets/batch_anchor_selector.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';

class MaterialAllocationRow extends StatelessWidget {
  const MaterialAllocationRow({
    super.key,
    required this.copies,
    required this.materials,
    required this.selectedMaterialId,
    required this.hintText,
    required this.labelText,
    required this.onChanged,
    required this.onRemove,
  });

  final int copies;
  final List<MaterialModel> materials;
  final String? selectedMaterialId;
  final String hintText;
  final String labelText;
  final ValueChanged<String?> onChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: BatchAnchorSelector(
            labelText: labelText,
            hintText: hintText,
            value:
                materials.any((material) => material.id == selectedMaterialId)
                ? selectedMaterialId
                : null,
            onChanged: onChanged,
            entries: [
              for (final material in materials)
                BatchAnchorSelectorEntry(
                  value: material.id,
                  label: material.name,
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4, right: 4, top: 12),
          child: Text(
            '×$copies',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        if (onRemove != null) ...[
          const SizedBox(width: 4),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.remove_circle_outline),
          ),
        ],
      ],
    );
  }
}
