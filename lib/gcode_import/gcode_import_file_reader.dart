import 'dart:convert';
import 'dart:typed_data';

import 'gcode_import_file_picker.dart';
import 'gcode_import_file_reader_unsupported.dart'
    if (dart.library.io) 'gcode_import_file_reader_io.dart'
    as file_io;

Future<String> readPickedGCodeText(GCodePickedFile file) async {
  if (file.path case final path?) {
    return file_io.readGCodeTextFromPath(path);
  }

  final size = file.size ?? 0;
  if (size > 52428800) {
    throw StateError('File is too large to be read without a direct path.');
  }
  final bytes = await file.readAsBytesOrThrow();
  return utf8.decode(bytes, allowMalformed: true);
}

Future<Uint8List> readPickedGCodeSample(
  GCodePickedFile file,
  int maxBytes,
) async {
  final safeMax = maxBytes > 0 ? maxBytes : 0;
  if (safeMax == 0) return Uint8List(0);

  if (file.path case final path?) {
    return file_io.readGCodeSampleFromPath(path, safeMax);
  }

  final size = file.size ?? 0;
  if (size > 52428800) {
    throw StateError('File is too large to be read without a direct path.');
  }
  final bytes = await file.readAsBytesOrThrow();
  if (bytes.length <= safeMax) return bytes;
  return Uint8List.sublistView(bytes, 0, safeMax);
}

Future<int?> resolvePickedGCodeFileSize(GCodePickedFile file) async {
  if (file.size case final size?) return size;
  if (file.path case final path?) {
    return file_io.readGCodeLengthFromPath(path);
  }
  if (file.readAsBytes != null) {
    final size = file.size ?? 0;
  if (size > 52428800) {
    throw StateError('File is too large to be read without a direct path.');
  }
  final bytes = await file.readAsBytesOrThrow();
    return bytes.length;
  }
  return null;
}

Stream<String> openPickedGCodeLines(GCodePickedFile file) {
  if (file.path case final path?) {
    return file_io.openGCodeLinesFromPath(path);
  }

  final size = file.size ?? 0;
  if (size > 52428800) {
    throw StateError('File is too large to be read without a direct path.');
  }
  return Stream.fromFuture(file.readAsBytesOrThrow()).asyncExpand((
    bytes,
  ) async* {
    for (final line in const LineSplitter().convert(
      utf8.decode(bytes, allowMalformed: true),
    )) {
      yield line;
    }
  });
}

Stream<String> openGCodeLines(String path) =>
    file_io.openGCodeLinesFromPath(path);
