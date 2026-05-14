import 'dart:typed_data';

import 'package:path/path.dart' as p;

const Set<String> gCodeSupportedExtensions = {
  '.gcode',
  '.gco',
  '.nc',
  '.bin',
};

const List<String> gCodeSupportedExtensionsWithoutDot = [
  'gcode',
  'gco',
  'nc',
  'bin',
];

class GCodePickedFile {
  const GCodePickedFile({
    required this.name,
    this.originalName,
    this.path,
    this.sourceUri,
    this.mimeType,
    this.size,
    this.readAsBytes,
  });

  final String name;
  final String? originalName;
  final String? path;
  final String? sourceUri;
  final String? mimeType;
  final int? size;
  final Future<Uint8List> Function()? readAsBytes;

  List<String> get candidateNames => [
    name,
    if (originalName != null && originalName != name) originalName!,
  ];

  bool get hasSupportedExtension {
    return candidateNames.any(hasSupportedGCodeExtension);
  }

  Future<Uint8List> readAsBytesOrThrow() {
    final reader = readAsBytes;
    if (reader == null) {
      throw StateError('Selected file does not expose eager byte reads.');
    }
    return reader();
  }
}

bool hasSupportedGCodeExtension(String name) {
  return gCodeSupportedExtensions.contains(p.extension(name).toLowerCase());
}
