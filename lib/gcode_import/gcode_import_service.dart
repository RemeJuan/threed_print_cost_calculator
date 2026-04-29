import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart';

import 'gcode_import_file_picker.dart';
import 'gcode_import_parser.dart';
import 'gcode_import_result.dart';

final gcodeImportParserProvider = Provider<GCodeImportParser>((ref) {
  return const GCodeImportParser();
});

final gcodeImportServiceProvider = Provider<GCodeImportService>((ref) {
  return GCodeImportService();
});

class GCodeImportService {
  const GCodeImportService();

  Future<GCodeImportResult> importPickedFile(GCodePickedFile file) async {
    final bytes = await file.readAsBytes();
    return importPickedBytes(bytes);
  }

  Future<GCodeImportResult> importPickedBytes(Uint8List bytes) async {
    final text = utf8.decode(bytes, allowMalformed: true);
    final wire = await compute(_parseInBackground, text);
    return GCodeImportResult.fromWireMap(wire);
  }
}

Map<String, dynamic> _parseInBackground(String text) {
  const parser = GCodeImportParser();
  return parser.parse(text).toWireMap();
}
