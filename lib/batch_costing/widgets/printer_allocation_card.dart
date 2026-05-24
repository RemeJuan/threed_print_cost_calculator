import 'package:flutter/material.dart';

import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_costing_state.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/batch_split_copies_dialog.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/material_allocation_row.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_surface_card.dart';

class PrinterAllocationCard extends StatelessWidget {
  const PrinterAllocationCard({
    super.key,
    required this.item,
    required this.allocations,
    required this.printers,
    required this.onSetAllocations,
  });

  final BatchCostingItem item;
  final List<BatchAssignmentAllocation> allocations;
  final List<PrinterModel> printers;
  final void Function(List<BatchAssignmentAllocation>) onSetAllocations;

  Future<void> _openSplitCopiesDialog(BuildContext context) async {
    final result = await showDialog<List<BatchAssignmentAllocation>>(
      context: context,
      builder: (_) => BatchSplitCopiesDialog(
        itemName: item.displayName,
        itemQuantity: item.quantity,
        allocations: allocations,
        printers: printers,
      ),
    );
    if (result == null || !context.mounted) return;
    onSetAllocations(result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final visibleIndices = <int>[
      for (var index = 0; index < allocations.length; index += 1)
        if (allocations[index].targetId.isNotEmpty) index,
    ];
    return AppSurfaceCard(
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
                '${item.quantity} ${l10n.batchCostingAssignmentCopiesLabel}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          if (visibleIndices.isNotEmpty) ...[
            const SizedBox(height: kAppSpace8),
            for (
              var visibleIndex = 0;
              visibleIndex < visibleIndices.length;
              visibleIndex += 1
            ) ...[
              MaterialAllocationRow(
                title: _printerName(
                  allocations[visibleIndices[visibleIndex]].targetId,
                ),
                subtitle: null,
                copies: allocations[visibleIndices[visibleIndex]].quantity,
                onRemove: visibleIndices.length > 1
                    ? () => onSetAllocations(
                        [...allocations]
                          ..removeAt(visibleIndices[visibleIndex]),
                      )
                    : null,
              ),
            ],
          ],
          AppSecondaryButton(
            onPressed: () => _openSplitCopiesDialog(context),
            icon: const Icon(Icons.tune),
            label: l10n.batchCostingAssignmentSplitCopiesButton,
          ),
        ],
      ),
    );
  }

  String _printerName(String targetId) {
    for (final printer in printers) {
      if (printer.id == targetId) return printer.name;
    }
    return targetId;
  }
}
