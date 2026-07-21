import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_result.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';

import 'gcode_import_preview_dialog.dart';

typedef PreviewImageDecoder = Future<bool> Function(Uint8List bytes);

Future<bool> decodePreviewImage(Uint8List bytes) async {
  ui.Codec? codec;
  ui.FrameInfo? frame;
  try {
    codec = await ui.instantiateImageCodec(bytes);
    frame = await codec.getNextFrame();
    return frame.image.width > 0 && frame.image.height > 0;
  } catch (_) {
    return false;
  } finally {
    frame?.image.dispose();
    codec?.dispose();
  }
}

class GCodeImportPreviewSection extends StatefulWidget {
  const GCodeImportPreviewSection({
    super.key,
    required this.slicer,
    required this.hasPreviewMetadata,
    required this.previewWidth,
    required this.previewHeight,
    required this.previewImageBytes,
    required this.hasSafePreview,
    required this.l10n,
    required this.fileSizeBytes,
    required this.parseStatus,
    this.previewDecoder = decodePreviewImage,
  });

  final GCodeSlicer slicer;
  final bool hasPreviewMetadata;
  final int? previewWidth;
  final int? previewHeight;
  final Uint8List? previewImageBytes;
  final bool hasSafePreview;
  final AppLocalizations l10n;
  final int fileSizeBytes;
  final String parseStatus;
  final PreviewImageDecoder previewDecoder;

  @override
  State<GCodeImportPreviewSection> createState() =>
      _GCodeImportPreviewSectionState();
}

class _GCodeImportPreviewSectionState extends State<GCodeImportPreviewSection> {
  int _generation = 0;
  Uint8List? _loggedForBytes;

  @override
  void initState() {
    super.initState();
    _validatePreview();
  }

  @override
  void didUpdateWidget(covariant GCodeImportPreviewSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.previewImageBytes, widget.previewImageBytes)) {
      _loggedForBytes = null;
    }
    if (oldWidget.hasSafePreview != widget.hasSafePreview ||
        !identical(oldWidget.previewImageBytes, widget.previewImageBytes)) {
      _generation += 1;
      _validatePreview();
    }
  }

  void _validatePreview() {
    final bytes = widget.previewImageBytes;
    if (bytes == null || !widget.hasSafePreview) return;
    final generation = _generation;
    () async {
      try {
        final valid = await widget.previewDecoder(bytes);
        if (!mounted || generation != _generation) return;
        if (!valid || identical(_loggedForBytes, bytes)) return;
        _loggedForBytes = bytes;
        AppAnalytics.safeLog(
          () => AppAnalytics.gcodePreviewAvailable(
            slicer: widget.slicer.name,
            hasPreview: widget.hasPreviewMetadata,
            fileSizeBytes: widget.fileSizeBytes,
            parseStatus: widget.parseStatus,
          ),
        );
      } catch (_) {
        // invalid preview; no event
      }
    }();
  }

  @override
  Widget build(BuildContext context) {
    final previewBytes = widget.previewImageBytes;
    if (previewBytes == null) return _previewPlaceholder(context);
    if (!widget.hasSafePreview) {
      return Text(
        widget.l10n.importGcodePreviewUnavailable,
        textAlign: TextAlign.end,
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }
    final isLowRes =
        (widget.previewWidth != null && widget.previewWidth! < 128) ||
        (widget.previewHeight != null && widget.previewHeight! < 128);

    void onPreviewTap() {
      AppAnalytics.safeLog(
        () => AppAnalytics.gcodePreviewViewed(
          slicer: widget.slicer.name,
          hasPreview: widget.hasPreviewMetadata,
          fileSizeBytes: widget.fileSizeBytes,
          parseStatus: widget.parseStatus,
        ),
      );
      showDialog<void>(
        context: context,
        barrierColor: SCRIM_DARK,
        barrierDismissible: true,
        builder: (_) =>
            GCodeImportPreviewDialog(bytes: previewBytes, l10n: widget.l10n),
      );
    }

    if (isLowRes) {
      return Align(
        alignment: Alignment.centerRight,
        child: SizedBox(
          width: 96,
          height: 96,
          child: Material(
            color: TRANSPARENT_COLOR,
            child: InkWell(
              onTap: onPreviewTap,
              child: Container(
                color: SCRIM_DARK,
                alignment: Alignment.center,
                child: Image.memory(
                  previewBytes,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.none,
                  gaplessPlayback: true,
                  isAntiAlias: false,
                  errorBuilder: (context, error, stackTrace) => Text(
                    widget.l10n.importGcodePreviewUnavailable,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
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
        label: Text(
          widget.l10n.importGcodePreviewView,
          style: TextStyle(color: LIGHT_BLUE),
        ),
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          alignment: Alignment.centerRight,
          iconColor: LIGHT_BLUE,
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
        color: SCRIM_DARK,
        borderRadius: BorderRadius.circular(kAppSurfaceRadius),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.image_not_supported_outlined,
            color: ICON_MUTED,
            size: 24,
          ),
          const SizedBox(height: kAppSpace4),
          Text(
            widget.l10n.importGcodePreviewUnavailable,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: TEXT_SECONDARY),
          ),
        ],
      ),
    ),
  );
}
