import 'dart:convert';

import 'gcode_import_file_picker.dart';

Future<String> readPickedGCodeText(GCodePickedFile file) async {
  final bytes = await file.readAsBytes();
  return utf8.decode(bytes, allowMalformed: true);
}
