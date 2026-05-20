import 'package:flutter/material.dart';

import 'package:threed_print_cost_calculator/gcode_import/gcode_import_file_picker.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_result.dart';

class BatchSingleImport {
  BatchSingleImport({
    required this.file,
    required this.batchItemId,
    required this.result,
    required this.missingWeight,
    required this.missingDuration,
  }) : weightController = TextEditingController(),
       durationController = TextEditingController();

  final GCodePickedFile file;
  final String batchItemId;
  final GCodeImportResult result;
  bool missingWeight;
  bool missingDuration;
  final TextEditingController weightController;
  final TextEditingController durationController;
  double? overrideWeightG;
  Duration? overrideDuration;

  bool get canContinue => !missingWeight && !missingDuration;

  void dispose() {
    weightController.dispose();
    durationController.dispose();
  }
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
  TextEditingController? weightController;
  TextEditingController? durationController;

  void dispose() {
    weightController?.dispose();
    durationController?.dispose();
  }
}
