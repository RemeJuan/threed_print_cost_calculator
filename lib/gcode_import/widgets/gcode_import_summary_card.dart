import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:threed_print_cost_calculator/app/components/focus_safe_text_field.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_result.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/utils/text_input_normalizers.dart';

import 'gcode_import_preview_section.dart';

class GCodeImportSummaryCard extends StatelessWidget {
  const GCodeImportSummaryCard({
    super.key,
    required this.result,
    required this.l10n,
    required this.fileSizeBytes,
    required this.parseStatus,
    required this.batchCostingEnabled,
    required this.quantity,
    required this.quantityController,
    required this.quantityFocusNode,
    required this.canCreateBatchFromImport,
    required this.onQuantityChanged,
  });

  final GCodeImportResult result;
  final AppLocalizations l10n;
  final int fileSizeBytes;
  final String parseStatus;
  final bool batchCostingEnabled;
  final ValueNotifier<int> quantity;
  final TextEditingController quantityController;
  final FocusNode quantityFocusNode;
  final bool canCreateBatchFromImport;
  final ValueChanged<String> onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.importGcodeSummaryTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _summaryRow(
              context,
              l10n.importGcodeSlicerLabel,
              Text(
                _slicerLabel(l10n, result.slicer),
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            _summaryRow(
              context,
              l10n.importGcodeDurationLabel,
              Text(
                result.estimatedDuration == null
                    ? l10n.importGcodeMissingValue
                    : _formatDuration(result.estimatedDuration!),
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            _summaryRow(
              context,
              l10n.importGcodeFilamentWeightLabel,
              Text(
                result.filamentWeightG == null
                    ? l10n.importGcodeMissingValue
                    : '${result.filamentWeightG!.toStringAsFixed(2)} ${l10n.gramsSuffix}',
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            _summaryRow(
              context,
              l10n.importGcodeFilamentLengthLabel,
              Text(
                result.filamentLengthMm == null
                    ? l10n.importGcodeMissingValue
                    : '${result.filamentLengthMm!.toStringAsFixed(2)} mm',
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            _summaryRow(
              context,
              l10n.importGcodeLayerHeightLabel,
              Text(
                result.layerHeightMm == null
                    ? l10n.importGcodeMissingValue
                    : '${result.layerHeightMm!.toStringAsFixed(2)} mm',
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            _summaryRow(
              context,
              _previewLabel(l10n, result),
              GCodeImportPreviewSection(
                result: result,
                l10n: l10n,
                fileSizeBytes: fileSizeBytes,
                parseStatus: parseStatus,
              ),
            ),
            if (_shouldShowPreviewNote(result)) ...[
              const SizedBox(height: 8),
              Text(
                l10n.importGcodePreviewCuraNote,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 8),
            Text(
              l10n.importGcodeCalculatorNote,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (batchCostingEnabled) ...[
              const SizedBox(height: 16),
              FocusSafeTextField(
                key: const ValueKey<String>('gcode_import.quantity.field'),
                controller: quantityController,
                focusNode: quantityFocusNode,
                externalText: quantity.value.toString(),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                inputNormalizer: (value) => normalizeLeadingZeroNumericInput(
                  value,
                  allowDecimal: false,
                ),
                decoration: InputDecoration(
                  labelText: l10n.importGcodeQuantityLabel,
                  border: const OutlineInputBorder(),
                ),
                onChanged: onQuantityChanged,
              ),
              if (quantity.value > 1 && !canCreateBatchFromImport) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.importGcodeBatchRequiresDetectedValues,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  String _slicerLabel(AppLocalizations l10n, GCodeSlicer slicer) =>
      slicer.label(l10n);
  String _formatDuration(Duration duration) {
    final roundedMinutes = (duration.inSeconds / 60).round();
    final hours = roundedMinutes ~/ 60;
    final minutes = roundedMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  String _previewLabel(AppLocalizations l10n, GCodeImportResult result) {
    final width = result.previewWidth;
    final height = result.previewHeight;
    if (width != null && height != null && (width < 128 || height < 128)) {
      return '${l10n.importGcodePreviewLabel} · $width×$height';
    }
    return l10n.importGcodePreviewLabel;
  }

  bool _shouldShowPreviewNote(GCodeImportResult result) =>
      result.slicer == GCodeSlicer.cura && result.previewImageBytes == null;

  Widget _summaryRow(BuildContext context, String label, Widget value) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ),
            const SizedBox(width: 12),
            Expanded(flex: 3, child: value),
          ],
        ),
      );
}
