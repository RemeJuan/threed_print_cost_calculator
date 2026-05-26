import 'dart:convert';
import 'dart:typed_data';

import 'model/gcode_import_file.dart';
import 'gcode_import_file_reader.dart';

enum GCodeImportError { unsupportedType, unsupportedFile, tooLarge, readFailed }

class GCodeValidationResult {
  const GCodeValidationResult._({this.error});

  final GCodeImportError? error;

  static const supported = GCodeValidationResult._();

  static const unsupportedType = GCodeValidationResult._(
    error: GCodeImportError.unsupportedType,
  );

  static const tooLarge = GCodeValidationResult._(
    error: GCodeImportError.tooLarge,
  );
}

const maxGCodeImportBytes = 50 * 1024 * 1024;
const gCodeImportMaxSizeMb = maxGCodeImportBytes ~/ (1024 * 1024);
const sniffBytesLimit = 64 * 1024;

Future<GCodeValidationResult> validateGCodeFile(GCodePickedFile file) async {
  final fileSize = await resolvePickedGCodeFileSize(file);
  if (fileSize != null && fileSize > maxGCodeImportBytes) {
    return GCodeValidationResult.tooLarge;
  }

  final hasSupportedName = file.candidateNames.any(hasSupportedGCodeExtension);
  final mimeType = file.mimeType?.toLowerCase();
  final shouldInspectContent =
      !hasSupportedName ||
      mimeType == null ||
      mimeType == 'application/octet-stream' ||
      !looksLikeTextualGCodeMimeType(mimeType);

  if (!shouldInspectContent) {
    return GCodeValidationResult.supported;
  }

  final bytes = await readPickedGCodeSample(file, sniffBytesLimit);
  final text = sniffText(bytes);
  if (!looksTextLike(text)) {
    return GCodeValidationResult.unsupportedType;
  }

  if (hasSupportedName) {
    return GCodeValidationResult.supported;
  }

  return looksLikeGCode(text)
      ? GCodeValidationResult.supported
      : GCodeValidationResult.unsupportedType;
}

String sniffText(Uint8List bytes) {
  final sample = bytes.length > sniffBytesLimit
      ? bytes.sublist(0, sniffBytesLimit)
      : bytes;
  return utf8.decode(sample, allowMalformed: true);
}

bool looksLikeGCode(String text) {
  if (!looksTextLike(text)) return false;

  final markers = <RegExp>[
    RegExp(r';\s*FLAVOR\s*:', caseSensitive: false),
    RegExp(r';\s*Generated with', caseSensitive: false),
    RegExp(r';\s*TIME\s*:', caseSensitive: false),
    RegExp(r';\s*filament used', caseSensitive: false),
    RegExp(r'\bG0\s', caseSensitive: false),
    RegExp(r'\bG1\s', caseSensitive: false),
    RegExp(r'\bM104\b', caseSensitive: false),
    RegExp(r'\bM109\b', caseSensitive: false),
    RegExp(r'\bM140\b', caseSensitive: false),
    RegExp(r'\bM190\b', caseSensitive: false),
  ];
  return markers.any((pattern) => pattern.hasMatch(text));
}

bool looksLikeTextualGCodeMimeType(String mimeType) {
  return mimeType.startsWith('text/') ||
      mimeType.contains('gcode') ||
      mimeType.contains('g-code') ||
      mimeType == 'application/x-gcode' ||
      mimeType == 'application/gcode';
}

bool looksTextLike(String text) {
  if (text.isEmpty) return false;
  final controlCount = text.runes
      .where((r) => r < 32 && r != 9 && r != 10 && r != 13)
      .length;
  return controlCount * 20 < text.length;
}
