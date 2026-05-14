import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart';

import 'model/gcode_import_file.dart';
import 'gcode_import_file_reader.dart';
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
    if (file.path != null) {
      final wire = await compute(_parsePathInBackground, file.path!);
      return GCodeImportResult.fromWireMap(wire);
    }

    final bytes = await file.readAsBytesOrThrow();
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

Future<Map<String, dynamic>> _parsePathInBackground(String path) async {
  const parser = GCodeImportParser();
  final result = await parser.parseLineStream(openGCodeLines(path));
  return result.toWireMap();
}
