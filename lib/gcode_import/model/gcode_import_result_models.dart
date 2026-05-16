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
    final rawCode = map['code'];
    final code = (() {
      try {
        return GCodeParseWarningCode.values.byName(rawCode.toString());
      } catch (_) {
        return GCodeParseWarningCode.unknownSlicer;
      }
    })();
    return GCodeParseWarning(code, details: map['details']?.toString());
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

  String safeSummary([AppLocalizations? localizations]) {
    final previewLabel = localizations?.importGcodePreviewLabel ?? 'preview';
    final unsafeLabel =
        localizations?.importGcodePreviewUnavailable ?? previewLabel;
    if (!present || !isSafe) return unsafeLabel;
    if (format == null || width == null || height == null) return previewLabel;
    return '$previewLabel $format ${width}x$height';
  }

  String summary([AppLocalizations? localizations]) {
    final availableLabel =
        localizations?.importGcodePreviewAvailable ?? 'Available';
    final unavailableLabel =
        localizations?.importGcodePreviewUnavailable ?? 'No preview';
    if (!present) return unavailableLabel;
    if (format == null || width == null || height == null) {
      return unavailableLabel;
    }
    return '$availableLabel · $format · ${width}x$height';
  }

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
