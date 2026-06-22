import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart';

import 'gcode_import_diagnostics.dart';
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
      try {
        final wire = await compute(_parsePathInBackground, file.path!);
        return GCodeImportResult.fromWireMap(wire);
      } catch (error, stackTrace) {
        unawaited(
          captureGCodeImportFailure(
            stage: 'metadata_parse',
            error: error,
            stackTrace: stackTrace,
            file: file,
            category: 'path_parse_exception',
          ),
        );
        rethrow;
      }
    }

    try {
      final bytes = await file.readAsBytesOrThrow();
      return importPickedBytes(bytes);
    } catch (error, stackTrace) {
      unawaited(
        captureGCodeImportFailure(
          stage: 'file_read',
          error: error,
          stackTrace: stackTrace,
          file: file,
          category: 'byte_read_exception',
        ),
      );
      rethrow;
    }
  }

  Future<GCodeImportResult> importPickedBytes(Uint8List bytes) async {
    String? text;
    try {
      text = utf8.decode(bytes, allowMalformed: true);
      final wire = await compute(_parseInBackground, text);
      return GCodeImportResult.fromWireMap(wire);
    } catch (error, stackTrace) {
      unawaited(
        captureGCodeImportFailure(
          stage: 'decode',
          error: error,
          stackTrace: stackTrace,
          category: 'decode_or_parse_exception',
          lineCount: text == null ? null : _estimateLineCount(text),
        ),
      );
      rethrow;
    }
  }
}

int _estimateLineCount(String text) => '\n'.allMatches(text).length + 1;

Map<String, dynamic> _parseInBackground(String text) {
  const parser = GCodeImportParser();
  return parser.parse(text).toWireMap();
}

Future<Map<String, dynamic>> _parsePathInBackground(String path) async {
  const parser = GCodeImportParser();
  final result = await parser.parseLineStream(openGCodeLines(path));
  return result.toWireMap();
}
