import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';

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
