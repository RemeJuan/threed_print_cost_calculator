import 'package:flutter/material.dart';

import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/model/batch_import_state.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/batch_missing_details_form.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';

import 'package:threed_print_cost_calculator/shared/widgets/app_surface_card.dart';

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
        return AppSurfaceCard(
          padding: const EdgeInsets.fromLTRB(
            kAppSpace16,
            0,
            kAppSpace16,
            kAppSpace16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: STATUS_WARNING,
                    size: 20,
                  ),
                  const SizedBox(width: kAppSpace8),
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
              const SizedBox(height: kAppSpace8),
              Text(
                l10n.batchGcodeImportNeedsDetailsLabel,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: STATUS_WARNING),
              ),
              MissingDetailsForm(
                l10n: l10n,
                missingWeight: row.missingWeight,
                missingDuration: row.missingDuration,
                onApply: (weightText, durationText) {
                  row.weightText = weightText;
                  row.durationText = durationText;
                  onApply();
                },
              ),
            ],
          ),
        );
      case ImportStatus.ready:
        return ListTile(
          leading: const Icon(Icons.check_circle, color: STATUS_SUCCESS),
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
          subtitle: Text(row.errorMessage ?? l10n.batchGcodeImportFailureLabel),
        );
    }
  }
}
