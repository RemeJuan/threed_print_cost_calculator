import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_result.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';

import 'gcode_import_preview_dialog.dart';

class GCodeImportPreviewSection extends StatelessWidget {
  const GCodeImportPreviewSection({
    super.key,
    required this.result,
    required this.l10n,
    required this.fileSizeBytes,
    required this.parseStatus,
  });
  final GCodeImportResult result;
  final AppLocalizations l10n;
  final int fileSizeBytes;
  final String parseStatus;
  @override
  Widget build(BuildContext context) {
    final previewBytes = result.previewImageBytes;
    if (previewBytes == null) return _previewPlaceholder(context);
    if (!result.hasSafePreview) {
      return Text(
        l10n.importGcodePreviewUnavailable,
        textAlign: TextAlign.end,
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }
    final isLowRes =
        result.previewWidth != null &&
        result.previewHeight != null &&
        result.previewWidth! < 128 &&
        result.previewHeight! < 128;
    void onPreviewTap() {
      AppAnalytics.safeLog(
        () => AppAnalytics.gcodePreviewViewed(
          slicer: result.slicer.name,
          hasPreview: result.hasPreviewMetadata,
          fileSizeBytes: fileSizeBytes,
          parseStatus: parseStatus,
        ),
      );
      _showPreviewDialog(context, previewBytes);
    }

    if (isLowRes) {
      return Align(
        alignment: Alignment.centerRight,
        child: SizedBox(
          width: 96,
          height: 96,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPreviewTap,
              child: Container(
                color: Colors.black87,
                alignment: Alignment.center,
                child: Image.memory(
                  previewBytes,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.none,
                  gaplessPlayback: true,
                  isAntiAlias: false,
                ),
              ),
            ),
          ),
        ),
      );
    }
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        onPressed: onPreviewTap,
        icon: const Icon(Icons.launch),
        label: Text(l10n.importGcodePreviewView),
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          alignment: Alignment.centerRight,
        ),
      ),
    );
  }

  Widget _previewPlaceholder(BuildContext context) => Align(
    alignment: Alignment.centerRight,
    child: Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.image_not_supported_outlined,
            color: Colors.white70,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.importGcodePreviewUnavailable,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    ),
  );
  Future<void> _showPreviewDialog(BuildContext context, Uint8List bytes) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      barrierDismissible: true,
      builder: (_) => GCodeImportPreviewDialog(bytes: bytes, l10n: l10n),
    );
  }
}
