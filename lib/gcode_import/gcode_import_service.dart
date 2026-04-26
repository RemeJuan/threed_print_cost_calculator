import 'package:riverpod/riverpod.dart';

import 'gcode_import_file_picker.dart';
import 'gcode_import_file_reader.dart';
import 'gcode_import_parser.dart';
import 'gcode_import_result.dart';

final gcodeImportParserProvider = Provider<GCodeImportParser>((ref) {
  return const GCodeImportParser();
});

final gcodeImportServiceProvider = Provider<GCodeImportService>((ref) {
  return GCodeImportService(parser: ref.read(gcodeImportParserProvider));
});

class GCodeImportService {
  const GCodeImportService({required GCodeImportParser parser})
    : _parser = parser;

  final GCodeImportParser _parser;

  Future<GCodeImportResult> importPickedFile(GCodePickedFile file) async {
    final text = await readPickedGCodeText(file);
    return _parser.parse(text);
  }
}
