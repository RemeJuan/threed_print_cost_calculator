import 'dart:convert';
import 'dart:typed_data';

import 'gcode_import_result.dart';

part 'gcode_import_parser_patterns.dart';
part 'gcode_import_parser_helpers.dart';
part 'gcode_import_parser_state.dart';

class GCodeImportParser {
  const GCodeImportParser();

  GCodeImportResult parse(String gcodeText) {
    return parseLines(const LineSplitter().convert(gcodeText));
  }

  GCodeImportResult parseLines(Iterable<String> lines) {
    final state = _StreamingParseState(this);
    for (final line in lines) {
      state.addLine(line);
    }
    return state.build();
  }

  Future<GCodeImportResult> parseLineStream(Stream<String> lines) async {
    final state = _StreamingParseState(this);
    await for (final line in lines) {
      state.addLine(line);
    }
    return state.build();
  }

  GCodeSlicer detectSlicerFromLine(String line) {
    return _detectSlicerFromLine(line);
  }
}
