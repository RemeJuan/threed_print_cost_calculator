import 'dart:typed_data';

import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';

class GCodeImportResult {
  const GCodeImportResult({
    required this.slicer,
    required this.estimatedDuration,
    required this.filamentLengthMm,
    required this.filamentWeightG,
    required this.layerHeightMm,
    required this.previewMetadata,
    required this.previewImageBytes,
    required this.warnings,
    required this.rawExtractedValues,
    this.hasSafePreview = false,
  });

  final GCodeSlicer slicer;
  final Duration? estimatedDuration;
  final double? filamentLengthMm;
  final double? filamentWeightG;
  final double? layerHeightMm;
  final GCodePreviewMetadata? previewMetadata;
  final Uint8List? previewImageBytes;
  final List<GCodeParseWarning> warnings;
  final Map<String, String> rawExtractedValues;
  final bool hasSafePreview;

  bool get hasPreviewMetadata => previewMetadata?.present ?? false;

  bool get hasAnyExtractedMetadata =>
      slicer != GCodeSlicer.unknown ||
      estimatedDuration != null ||
      filamentLengthMm != null ||
      filamentWeightG != null ||
      layerHeightMm != null ||
      hasPreviewMetadata;

  int? get roundedFilamentWeightG => filamentWeightG?.round();

  Map<String, dynamic> toWireMap() {
    return {
      'slicer': slicer.name,
      'estimatedDurationMicros': estimatedDuration?.inMicroseconds,
      'filamentLengthMm': filamentLengthMm,
      'filamentWeightG': filamentWeightG,
      'layerHeightMm': layerHeightMm,
      'previewMetadata': previewMetadata?.toWireMap(),
      'previewImageBytes': previewImageBytes,
      'warnings': warnings
          .map((warning) => warning.toWireMap())
          .toList(growable: false),
      'rawExtractedValues': rawExtractedValues,
      'hasSafePreview': hasSafePreview,
    };
  }

  factory GCodeImportResult.fromWireMap(Map<String, dynamic> map) {
    return GCodeImportResult(
      slicer: GCodeSlicer.values.byName(map['slicer'] as String),
      estimatedDuration: map['estimatedDurationMicros'] == null
          ? null
          : Duration(microseconds: map['estimatedDurationMicros'] as int),
      filamentLengthMm: (map['filamentLengthMm'] as num?)?.toDouble(),
      filamentWeightG: (map['filamentWeightG'] as num?)?.toDouble(),
      layerHeightMm: (map['layerHeightMm'] as num?)?.toDouble(),
      previewMetadata: map['previewMetadata'] == null
          ? null
          : GCodePreviewMetadata.fromWireMap(
              Map<String, dynamic>.from(
                map['previewMetadata'] as Map<dynamic, dynamic>,
              ),
            ),
      previewImageBytes: map['previewImageBytes'] as Uint8List?,
      warnings: (map['warnings'] as List<dynamic>? ?? const [])
          .map(
            (warning) => GCodeParseWarning.fromWireMap(
              Map<String, dynamic>.from(warning as Map<dynamic, dynamic>),
            ),
          )
          .toList(growable: false),
      rawExtractedValues: Map<String, String>.from(
        map['rawExtractedValues'] as Map<dynamic, dynamic>? ?? const {},
      ),
      hasSafePreview: map['hasSafePreview'] == true,
    );
  }
}

enum GCodeSlicer { prusaSlicer, orcaSlicer, bambuStudio, cura, unknown }

extension GCodeSlicerX on GCodeSlicer {
  String label(AppLocalizations l10n) => switch (this) {
    GCodeSlicer.prusaSlicer => l10n.slicerPrusaSlicer,
    GCodeSlicer.orcaSlicer => l10n.slicerOrcaSlicer,
    GCodeSlicer.bambuStudio => l10n.slicerBambuStudio,
    GCodeSlicer.cura => l10n.slicerCura,
    GCodeSlicer.unknown => l10n.slicerUnknown,
  };
}

class GCodeParseWarning {
  const GCodeParseWarning(this.code, {this.details});

  final GCodeParseWarningCode code;
  final String? details;

  Map<String, dynamic> toWireMap() {
    return {'code': code.name, 'details': details};
  }

  factory GCodeParseWarning.fromWireMap(Map<String, dynamic> map) {
    return GCodeParseWarning(
      GCodeParseWarningCode.values.byName(map['code'] as String),
      details: map['details'] as String?,
    );
  }
}

enum GCodeParseWarningCode {
  unknownSlicer,
  missingDuration,
  missingFilament,
  missingFilamentWeight,
  partialMetadata,
  mixedMaterials,
}

class GCodePreviewMetadata {
  const GCodePreviewMetadata({
    required this.present,
    required this.format,
    required this.width,
    required this.height,
    this.isSafe = true,
  });

  final bool present;
  final String? format;
  final int? width;
  final int? height;
  final bool isSafe;

  String get safeSummary => format == null || width == null || height == null
      ? 'preview'
      : '$format ${width}x$height';

  String get summary => format == null || width == null || height == null
      ? 'Available'
      : 'Available · $format · ${width}x$height';

  Map<String, dynamic> toWireMap() {
    return {
      'present': present,
      'format': format,
      'width': width,
      'height': height,
      'isSafe': isSafe,
    };
  }

  factory GCodePreviewMetadata.fromWireMap(Map<String, dynamic> map) {
    return GCodePreviewMetadata(
      present: map['present'] == true,
      format: map['format'] as String?,
      width: (map['width'] as num?)?.toInt(),
      height: (map['height'] as num?)?.toInt(),
      isSafe: map['isSafe'] != false,
    );
  }
}
