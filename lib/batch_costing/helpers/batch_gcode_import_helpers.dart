import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/model/batch_import_state.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_result.dart';
import 'package:threed_print_cost_calculator/gcode_import/model/gcode_import_file.dart';

class ImportOverrideDetails {
  const ImportOverrideDetails({required this.weight, required this.duration});
  final double? weight;
  final Duration? duration;
}

ImportOverrideDetails? parseImportOverrideDetails({
  required double? existingWeight,
  required Duration? existingDuration,
  required bool missingWeight,
  required String weightText,
  required bool missingDuration,
  required String durationText,
}) {
  double? weight = existingWeight;
  Duration? duration = existingDuration;

  if (missingWeight) {
    final parsed = double.tryParse(weightText.replaceAll(',', '.'));
    if (parsed == null || parsed <= 0) return null;
    weight = parsed;
  }

  if (missingDuration) {
    final parsed = int.tryParse(durationText);
    if (parsed == null || parsed <= 0) return null;
    duration = Duration(minutes: parsed);
  }

  return ImportOverrideDetails(weight: weight, duration: duration);
}

BatchCostingItem? findItemById(List<BatchCostingItem> items, String? id) {
  if (id == null) return null;
  for (final item in items) {
    if (item.id == id) return item;
  }
  return null;
}

bool isDuplicateFile(
  GCodePickedFile file,
  BatchSingleImport? singleImport,
  List<BatchImportRow> rows,
) {
  if (singleImport != null) {
    if (file.path != null && singleImport.file.path != null) {
      if (file.path == singleImport.file.path) return true;
    }
    if (file.name == singleImport.file.name) return true;
  }
  return rows.any((row) {
    if (file.path != null && row.file.path != null) {
      return file.path == row.file.path;
    }
    return file.name == row.file.name;
  });
}

GCodeImportResult buildImportResult(BatchSingleImport singleImport) {
  if (singleImport.overrideWeightG == null &&
      singleImport.overrideDuration == null) {
    return singleImport.result;
  }

  return GCodeImportResult(
    slicer: singleImport.result.slicer,
    estimatedDuration:
        singleImport.overrideDuration ?? singleImport.result.estimatedDuration,
    filamentLengthMm: singleImport.result.filamentLengthMm,
    filamentWeightG:
        singleImport.overrideWeightG ?? singleImport.result.filamentWeightG,
    layerHeightMm: singleImport.result.layerHeightMm,
    previewMetadata: singleImport.result.previewMetadata,
    previewImageBytes: singleImport.result.previewImageBytes,
    warnings: singleImport.result.warnings,
    rawExtractedValues: singleImport.result.rawExtractedValues,
    hasSafePreview: singleImport.result.hasSafePreview,
  );
}

BatchCostingItem buildCostingItem({
  required String id,
  required GCodePickedFile file,
  required GCodeImportResult result,
}) {
  return BatchCostingItem.fromGCodeImport(
    id: id,
    displayName: file.name,
    quantity: 1,
    importResult: result,
    sourceFileName: file.name,
    sourcePath: file.path,
    sourceFileSizeBytes: file.size,
  );
}
