import 'dart:typed_data';

import 'model/gcode_import_result_models.dart';

export 'model/gcode_import_result_models.dart';

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

  bool get hasPreview => hasPreviewMetadata;

  int? get previewWidth => previewMetadata?.width;

  int? get previewHeight => previewMetadata?.height;

  bool get hasPartialMetadata => warnings.any(
    (warning) => warning.code == GCodeParseWarningCode.partialMetadata,
  );

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
