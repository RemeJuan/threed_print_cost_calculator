import 'package:flutter/material.dart';

import 'package:threed_print_cost_calculator/batch_costing/state/batch_costing_state.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/batch_allocation_picker_dialog.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';

class BatchSplitCopiesDialog extends StatelessWidget {
  const BatchSplitCopiesDialog({
    super.key,
    required this.itemName,
    required this.itemQuantity,
    required this.allocations,
    required this.printers,
  });

  final String itemName;
  final int itemQuantity;
  final List<BatchAssignmentAllocation> allocations;
  final List<PrinterModel> printers;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BatchAllocationPickerDialog(
      title: l10n.batchCostingAssignmentSplitCopiesDialogTitle(itemName),
      itemQuantity: itemQuantity,
      allocations: allocations,
      options: [
        for (final printer in printers)
          BatchAllocationPickerOption(id: printer.id, title: printer.name),
      ],
    );
  }
}
