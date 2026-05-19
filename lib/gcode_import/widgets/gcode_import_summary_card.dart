import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_result.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';

import 'gcode_import_metadata_summary.dart';

class GCodeImportSummaryCard extends StatelessWidget {
  const GCodeImportSummaryCard({
    super.key,
    required this.result,
    required this.l10n,
    required this.fileSizeBytes,
  });

  final GCodeImportResult result;
  final AppLocalizations l10n;
  final int fileSizeBytes;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GCodeImportMetadataSummary(
          l10n: l10n,
          slicer: result.slicer,
          estimatedDuration: result.estimatedDuration,
          filamentWeightG: result.filamentWeightG,
          filamentLengthMm: result.filamentLengthMm,
          layerHeightMm: result.layerHeightMm,
          previewMetadata: result.previewMetadata,
          previewImageBytes: result.previewImageBytes,
          hasSafePreview: result.hasSafePreview,
          fileSizeBytes: fileSizeBytes,
          hasPartialMetadata: result.hasPartialMetadata,
          showCalculatorNote: true,
        ),
      ),
    );
  }
}
