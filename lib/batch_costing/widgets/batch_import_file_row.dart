import 'package:flutter/material.dart';

import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/model/batch_import_state.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/batch_missing_details_form.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';

class BatchImportFileRow extends StatelessWidget {
  const BatchImportFileRow({
    super.key,
    required this.row,
    required this.item,
    required this.l10n,
    required this.onShowDetails,
    required this.onRemove,
    required this.onApply,
  });

  final BatchImportRow row;
  final BatchCostingItem? item;
  final AppLocalizations l10n;
  final VoidCallback onShowDetails;
  final VoidCallback onRemove;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    switch (row.status) {
      case ImportStatus.importing:
        return ListTile(
          leading: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          title: Text(row.file.name),
          subtitle: Text(l10n.batchGcodeImportImportingLabel),
        );
      case ImportStatus.needsDetails:
        return Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        row.file.name,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    if (item?.importMetadata?.slicer != null)
                      IconButton(
                        key: const ValueKey<String>(
                          'batch_gcode_import.details.button',
                        ),
                        icon: const Icon(Icons.info_outline, size: 20),
                        tooltip: l10n.batchGcodeImportDetailsButton,
                        onPressed: onShowDetails,
                      ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      tooltip: l10n.batchCostingReviewRemoveButton,
                      onPressed: onRemove,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.batchGcodeImportNeedsDetailsLabel,
                  style: TextStyle(color: Colors.orange.shade700, fontSize: 13),
                ),
                MissingDetailsForm(
                  l10n: l10n,
                  missingWeight: row.missingWeight,
                  missingDuration: row.missingDuration,
                  weightController: row.weightController!,
                  durationController: row.durationController!,
                  onApply: onApply,
                ),
              ],
            ),
          ),
        );
      case ImportStatus.ready:
        return ListTile(
          leading: const Icon(Icons.check_circle, color: Colors.green),
          title: Text(row.file.name),
          subtitle: Text(l10n.batchGcodeImportReadyLabel),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item?.importMetadata?.slicer != null)
                IconButton(
                  key: const ValueKey<String>(
                    'batch_gcode_import.details.button',
                  ),
                  icon: const Icon(Icons.info_outline),
                  tooltip: l10n.batchGcodeImportDetailsButton,
                  onPressed: onShowDetails,
                ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: l10n.batchCostingReviewRemoveButton,
                onPressed: onRemove,
              ),
            ],
          ),
        );
      case ImportStatus.failed:
        return ListTile(
          leading: Icon(
            Icons.error,
            color: Theme.of(context).colorScheme.error,
          ),
          title: Text(row.file.name),
          subtitle:
              Text(row.errorMessage ?? l10n.batchGcodeImportFailureLabel),
        );
    }
  }
}
