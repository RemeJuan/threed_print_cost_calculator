import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart';

import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';

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
        final failure = error is FormatException
            ? GCodeImportFailure.parse(error, stackTrace, file: file)
            : GCodeImportFailure.read(error, stackTrace, file: file);
        unawaited(_captureFailure(failure));
        throw failure;
      }
    }

    try {
      final bytes = await file.readAsBytesOrThrow();
      return importPickedBytes(bytes);
    } catch (error, stackTrace) {
      if (error is GCodeImportFailure) rethrow;
      final failure = GCodeImportFailure.read(error, stackTrace, file: file);
      unawaited(_captureFailure(failure));
      throw failure;
    }
  }

  Future<GCodeImportResult> importPickedBytes(Uint8List bytes) async {
    String? text;
    try {
      text = utf8.decode(bytes, allowMalformed: true);
      final wire = await compute(_parseInBackground, text);
      return GCodeImportResult.fromWireMap(wire);
    } catch (error, stackTrace) {
      final failure = error is FormatException
          ? GCodeImportFailure.parse(
              error,
              stackTrace,
              lineCount: text == null ? null : _estimateLineCount(text),
            )
          : GCodeImportFailure.read(
              error,
              stackTrace,
              lineCount: text == null ? null : _estimateLineCount(text),
            );
      unawaited(_captureFailure(failure));
      throw failure;
    }
  }
}

class GCodeImportFailure implements Exception {
  const GCodeImportFailure._(
    this.stage,
    this.error,
    this.stackTrace, {
    this.file,
    this.lineCount,
  });

  factory GCodeImportFailure.read(
    Object error,
    StackTrace stackTrace, {
    GCodePickedFile? file,
    int? lineCount,
  }) => GCodeImportFailure._(
    GCodeImportFailureStage.read,
    error,
    stackTrace,
    file: file,
    lineCount: lineCount,
  );

  factory GCodeImportFailure.parse(
    Object error,
    StackTrace stackTrace, {
    GCodePickedFile? file,
    int? lineCount,
  }) => GCodeImportFailure._(
    GCodeImportFailureStage.parse,
    error,
    stackTrace,
    file: file,
    lineCount: lineCount,
  );

  final GCodeImportFailureStage stage;
  final Object error;
  final StackTrace stackTrace;
  final GCodePickedFile? file;
  final int? lineCount;
}

enum GCodeImportFailureStage { read, parse }

Future<void> _captureFailure(GCodeImportFailure failure) {
  final failureReason = failure.stage == GCodeImportFailureStage.parse
      ? GCodeFailureReason.parseException
      : GCodeFailureReason.readFailed;
  return captureGCodeImportFailure(
    stage: failure.stage.name,
    error: failure.error,
    stackTrace: failure.stackTrace,
    file: failure.file,
    category: failureReason,
    lineCount: failure.lineCount,
  );
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
