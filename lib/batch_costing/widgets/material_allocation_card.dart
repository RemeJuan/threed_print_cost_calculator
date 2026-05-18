import 'package:flutter/material.dart';

import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_costing_state.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/material_allocation_row.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/warning_box.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';

class MaterialAllocationCard extends StatelessWidget {
  const MaterialAllocationCard({
    super.key,
    required this.item,
    required this.allocations,
    required this.materials,
    required this.warningText,
    required this.onAllocationChanged,
    required this.onAddAllocation,
    required this.onRemoveAllocation,
    required this.hintText,
    required this.addButtonLabel,
    required this.copiesLabel,
    required this.labelText,
  });

  final BatchCostingItem item;
  final List<BatchAssignmentAllocation> allocations;
  final List<MaterialModel> materials;
  final String? warningText;
  final void Function(int allocationIndex, String? materialId)
  onAllocationChanged;
  final VoidCallback onAddAllocation;
  final void Function(int allocationIndex) onRemoveAllocation;
  final String hintText;
  final String addButtonLabel;
  final String copiesLabel;
  final String labelText;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.displayName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  '${item.quantity} $copiesLabel',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (var index = 0; index < allocations.length; index += 1) ...[
              MaterialAllocationRow(
                copies: allocations[index].quantity,
                materials: materials,
                selectedMaterialId: allocations[index].targetId.isEmpty
                    ? null
                    : allocations[index].targetId,
                hintText: hintText,
                labelText: labelText,
                onChanged: (value) => onAllocationChanged(index, value),
                onRemove: allocations.length > 1
                    ? () => onRemoveAllocation(index)
                    : null,
              ),
              if (index != allocations.length - 1) const SizedBox(height: 12),
            ],
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onAddAllocation,
              icon: const Icon(Icons.add),
              label: Text(addButtonLabel),
            ),
            if (warningText != null) ...[
              const SizedBox(height: 8),
              WarningBox(text: warningText!),
            ],
          ],
        ),
      ),
    );
  }
}
