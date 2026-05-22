import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/gcode_import/widgets/gcode_import_metadata_summary.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';

class BatchGCodeImportDetailsSheet extends StatelessWidget {
  const BatchGCodeImportDetailsSheet({
    super.key,
    required this.item,
    required this.l10n,
  });

  final BatchCostingItem item;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final metadata = item.importMetadata;
    final slicer = metadata?.slicer;
    if (metadata == null || slicer == null) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(kAppSpace16, kAppSpace16, kAppSpace16, 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.displayName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).closeButtonTooltip,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: kAppSpace8),
              Text(
                l10n.importGcodeSummaryTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: kAppSpace16),
              GCodeImportMetadataSummary(
                l10n: l10n,
                slicer: slicer,
                estimatedDuration: item.printDuration,
                filamentWeightG: item.printWeightG,
                filamentLengthMm: metadata.filamentLengthMm,
                layerHeightMm: metadata.layerHeightMm,
                previewMetadata: metadata.previewMetadata,
                previewImageBytes: metadata.previewImageBytes,
                hasSafePreview: metadata.hasSafePreview,
                fileSizeBytes: metadata.fileSizeBytes ?? 0,
                hasPartialMetadata: metadata.hasPartialMetadata,
                showTitle: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
