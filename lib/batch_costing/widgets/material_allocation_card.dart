import 'package:flutter/material.dart';

import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_costing_state.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/batch_allocation_picker_dialog.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/material_allocation_row.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/warning_box.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';

class MaterialAllocationCard extends StatelessWidget {
  const MaterialAllocationCard({
    super.key,
    required this.item,
    required this.allocations,
    required this.materials,
    required this.warningText,
    required this.onSetAllocations,
  });

  final BatchCostingItem item;
  final List<BatchAssignmentAllocation> allocations;
  final List<MaterialModel> materials;
  final String? warningText;
  final ValueChanged<List<BatchAssignmentAllocation>> onSetAllocations;

  Future<void> _openPicker(BuildContext context) async {
    final result = await showDialog<List<BatchAssignmentAllocation>>(
      context: context,
      builder: (_) => BatchAllocationPickerDialog(
        title: item.displayName,
        itemQuantity: item.quantity,
        allocations: allocations,
        options: [
          for (final material in materials)
            BatchAllocationPickerOption(id: material.id, title: material.name),
        ],
      ),
    );
    if (result == null || !context.mounted) return;
    onSetAllocations(result);
  }

  String _materialName(String targetId) {
    final found = materials.firstWhere(
      (m) => m.id == targetId,
      orElse: () => MaterialModel(id: '', name: '', cost: '0', color: '', weight: '0', archived: false, autoDeductEnabled: false, originalWeight: 0, remainingWeight: 0),
    );
    return found.name.isEmpty ? targetId : found.name;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [Expanded(child: Text(item.displayName, style: Theme.of(context).textTheme.titleMedium)), Text('${item.quantity} ${l10n.batchCostingAssignmentCopiesLabel}', style: Theme.of(context).textTheme.titleMedium)]),
            const SizedBox(height: 8),
            for (var index = 0; index < allocations.length; index += 1) ...[
              MaterialAllocationRow(title: _materialName(allocations[index].targetId), subtitle: null, copies: allocations[index].quantity, onRemove: allocations.length > 1 ? () => onSetAllocations([...allocations]..removeAt(index)) : null),
              if (index != allocations.length - 1) const SizedBox(height: 12),
            ],
            const SizedBox(height: 12),
            OutlinedButton.icon(onPressed: () => _openPicker(context), icon: const Icon(Icons.search), label: Text(l10n.batchCostingAssignmentSplitCopiesButton)),
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
