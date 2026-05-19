import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_result.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';

import 'gcode_import_preview_section.dart';

class GCodeImportMetadataSummary extends StatelessWidget {
  const GCodeImportMetadataSummary({
    super.key,
    required this.l10n,
    required this.slicer,
    required this.estimatedDuration,
    required this.filamentWeightG,
    required this.filamentLengthMm,
    required this.layerHeightMm,
    required this.previewMetadata,
    required this.previewImageBytes,
    required this.hasSafePreview,
    required this.fileSizeBytes,
    required this.hasPartialMetadata,
    this.showTitle = true,
    this.showCalculatorNote = false,
  });

  final AppLocalizations l10n;
  final GCodeSlicer slicer;
  final Duration? estimatedDuration;
  final double? filamentWeightG;
  final double? filamentLengthMm;
  final double? layerHeightMm;
  final GCodePreviewMetadata? previewMetadata;
  final Uint8List? previewImageBytes;
  final bool hasSafePreview;
  final int fileSizeBytes;
  final bool hasPartialMetadata;
  final bool showTitle;
  final bool showCalculatorNote;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showTitle) ...[
          Text(
            l10n.importGcodeSummaryTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
        ],
        _summaryRow(
          context,
          l10n.importGcodeSlicerLabel,
          Text(
            slicer.label(l10n),
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        _summaryRow(
          context,
          l10n.importGcodeDurationLabel,
          Text(
            estimatedDuration == null
                ? l10n.importGcodeMissingValue
                : _formatDuration(estimatedDuration!),
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        _summaryRow(
          context,
          l10n.importGcodeFilamentWeightLabel,
          Text(
            filamentWeightG == null
                ? l10n.importGcodeMissingValue
                : '${filamentWeightG!.toStringAsFixed(2)} ${l10n.gramsSuffix}',
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        _summaryRow(
          context,
          l10n.importGcodeFilamentLengthLabel,
          Text(
            filamentLengthMm == null
                ? l10n.importGcodeMissingValue
                : '${filamentLengthMm!.toStringAsFixed(2)} mm',
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        _summaryRow(
          context,
          l10n.importGcodeLayerHeightLabel,
          Text(
            layerHeightMm == null
                ? l10n.importGcodeMissingValue
                : '${layerHeightMm!.toStringAsFixed(2)} mm',
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        _summaryRow(
          context,
          _previewLabel(l10n),
          GCodeImportPreviewSection(
            slicer: slicer,
            hasPreviewMetadata: previewMetadata?.present ?? false,
            previewWidth: previewMetadata?.width,
            previewHeight: previewMetadata?.height,
            previewImageBytes: previewImageBytes,
            hasSafePreview: hasSafePreview,
            l10n: l10n,
            fileSizeBytes: fileSizeBytes,
            parseStatus: hasPartialMetadata ? 'partial' : 'success',
          ),
        ),
        if (_shouldShowPreviewNote) ...[
          const SizedBox(height: 8),
          Text(
            l10n.importGcodePreviewCuraNote,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        if (showCalculatorNote) ...[
          const SizedBox(height: 8),
          Text(
            l10n.importGcodeCalculatorNote,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }

  bool get _shouldShowPreviewNote =>
      slicer == GCodeSlicer.cura && previewImageBytes == null;

  String _formatDuration(Duration duration) {
    final roundedMinutes = (duration.inSeconds / 60).round();
    final hours = roundedMinutes ~/ 60;
    final minutes = roundedMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  String _previewLabel(AppLocalizations l10n) {
    final width = previewMetadata?.width;
    final height = previewMetadata?.height;
    if (width != null && height != null && (width < 128 || height < 128)) {
      return '${l10n.importGcodePreviewLabel} · $width×$height';
    }
    return l10n.importGcodePreviewLabel;
  }

  Widget _summaryRow(BuildContext context, String label, Widget value) {
    return Padding(
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
}
