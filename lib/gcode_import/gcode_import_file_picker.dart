import 'package:flutter/foundation.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod/riverpod.dart';

import 'gcode_import_android_file_picker.dart';

final gcodeImportFilePickerProvider = Provider<GCodeImportFilePicker>((ref) {
  return const PlatformGCodeImportFilePicker();
});

abstract class GCodeImportFilePicker {
  const GCodeImportFilePicker();

  Future<GCodePickedFile?> pick();
}

class PlatformGCodeImportFilePicker extends GCodeImportFilePicker {
  const PlatformGCodeImportFilePicker();

  static const _androidPicker = AndroidGCodeImportFilePicker();

  @override
  Future<GCodePickedFile?> pick() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return _androidPicker.pick();
    }

    final file = await openFile(
      acceptedTypeGroups: gCodeAcceptedTypeGroups(defaultTargetPlatform),
    );

    if (file == null) return null;

    final size = await file.length();

    return GCodePickedFile(
      name: file.name,
      originalName: file.name,
      path: file.path,
      mimeType: file.mimeType,
      size: size,
      readAsBytes: file.readAsBytes,
    );
  }
}

@visibleForTesting
List<XTypeGroup> gCodeAcceptedTypeGroups(TargetPlatform platform) {
  switch (platform) {
    case TargetPlatform.iOS:
      return const [
        XTypeGroup(label: 'G-code', uniformTypeIdentifiers: ['public.data']),
      ];
    default:
      return const [
        XTypeGroup(label: 'G-code', extensions: ['gcode', 'gco', 'nc', 'bin']),
      ];
  }
}

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
  switch (p.extension(name).toLowerCase()) {
    case '.gcode':
    case '.gco':
    case '.nc':
      return true;
    default:
      return false;
  }
}
