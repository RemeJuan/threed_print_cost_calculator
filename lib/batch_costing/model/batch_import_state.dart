import 'package:threed_print_cost_calculator/gcode_import/gcode_import_file_picker.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_result.dart';

class BatchSingleImport {
  BatchSingleImport({
    required this.file,
    required this.batchItemId,
    required this.result,
    required this.missingWeight,
    required this.missingDuration,
  });

  final GCodePickedFile file;
  final String batchItemId;
  final GCodeImportResult result;
  bool missingWeight;
  bool missingDuration;
  String weightText = '';
  String durationText = '';
  double? overrideWeightG;
  Duration? overrideDuration;

  bool get canContinue => !missingWeight && !missingDuration;
}

enum ImportStatus { importing, needsDetails, ready, failed }

class BatchImportRow {
  BatchImportRow(this.file)
    : status = ImportStatus.importing,
      errorMessage = null;

  final GCodePickedFile file;
  ImportStatus status;
  String? errorMessage;
  String? batchItemId;
  bool missingWeight = false;
  bool missingDuration = false;
  String weightText = '';
  String durationText = '';
}
