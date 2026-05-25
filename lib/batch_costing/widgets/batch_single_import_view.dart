import 'package:flutter/material.dart';

import 'package:threed_print_cost_calculator/batch_costing/model/batch_import_state.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/batch_missing_details_form.dart';
import 'package:threed_print_cost_calculator/gcode_import/widgets/gcode_import_metadata_summary.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';

class BatchSingleImportView extends StatelessWidget {
  const BatchSingleImportView({
    super.key,
    required this.singleImport,
    required this.l10n,
    required this.onRemove,
    required this.onApplyDetails,
  });

  final BatchSingleImport singleImport;
  final AppLocalizations l10n;
  final VoidCallback onRemove;
  final VoidCallback onApplyDetails;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(kAppSpace16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.description_outlined),
                    const SizedBox(width: kAppSpace8),
                    Expanded(
                      child: Text(
                        singleImport.file.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: l10n.batchCostingReviewRemoveButton,
                      onPressed: onRemove,
                    ),
                  ],
                ),
                const SizedBox(height: kAppSpace12),
                GCodeImportMetadataSummary(
                  l10n: l10n,
                  slicer: singleImport.result.slicer,
                  estimatedDuration: singleImport.result.estimatedDuration,
                  filamentWeightG: singleImport.result.filamentWeightG,
                  filamentLengthMm: singleImport.result.filamentLengthMm,
                  layerHeightMm: singleImport.result.layerHeightMm,
                  previewMetadata: singleImport.result.previewMetadata,
                  previewImageBytes: singleImport.result.previewImageBytes,
                  hasSafePreview: singleImport.result.hasSafePreview,
                  fileSizeBytes: singleImport.file.size ?? 0,
                  hasPartialMetadata: singleImport.result.hasPartialMetadata,
                  showTitle: false,
                ),
                if (singleImport.missingWeight ||
                    singleImport.missingDuration) ...[
                  const SizedBox(height: kAppSpace16),
                  Text(
                    l10n.batchGcodeImportNeedsDetailsLabel,
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(color: STATUS_WARNING),
                  ),
                  MissingDetailsForm(
                    l10n: l10n,
                    missingWeight: singleImport.missingWeight,
                    missingDuration: singleImport.missingDuration,
                    onApply: (weightText, durationText) {
                      singleImport.weightText = weightText;
                      singleImport.durationText = durationText;
                      onApplyDetails();
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
