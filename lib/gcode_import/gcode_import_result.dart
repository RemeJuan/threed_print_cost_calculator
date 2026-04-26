import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';

class GCodeImportResult {
  const GCodeImportResult({
    required this.slicer,
    required this.estimatedDuration,
    required this.filamentLengthMm,
    required this.filamentWeightG,
    required this.layerHeightMm,
    required this.previewMetadata,
    required this.warnings,
    required this.rawExtractedValues,
  });

  final GCodeSlicer slicer;
  final Duration? estimatedDuration;
  final double? filamentLengthMm;
  final double? filamentWeightG;
  final double? layerHeightMm;
  final GCodePreviewMetadata? previewMetadata;
  final List<GCodeParseWarning> warnings;
  final Map<String, String> rawExtractedValues;

  bool get hasPreviewMetadata => previewMetadata?.present ?? false;

  bool get hasAnyExtractedMetadata =>
      slicer != GCodeSlicer.unknown ||
      estimatedDuration != null ||
      filamentLengthMm != null ||
      filamentWeightG != null ||
      layerHeightMm != null ||
      hasPreviewMetadata;

  int? get roundedFilamentWeightG => filamentWeightG?.round();
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
}

enum GCodeParseWarningCode {
  unknownSlicer,
  missingDuration,
  missingFilament,
  missingFilamentWeight,
  partialMetadata,
}

class GCodePreviewMetadata {
  const GCodePreviewMetadata({
    required this.present,
    required this.format,
    required this.width,
    required this.height,
  });

  final bool present;
  final String? format;
  final int? width;
  final int? height;
}
