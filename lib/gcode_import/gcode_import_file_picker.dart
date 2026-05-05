import 'package:flutter/foundation.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod/riverpod.dart';

final gcodeImportFilePickerProvider = Provider<GCodeImportFilePicker>((ref) {
  return const PlatformGCodeImportFilePicker();
});

abstract class GCodeImportFilePicker {
  const GCodeImportFilePicker();

  Future<GCodePickedFile?> pick();
}

class PlatformGCodeImportFilePicker extends GCodeImportFilePicker {
  const PlatformGCodeImportFilePicker();

  @override
  Future<GCodePickedFile?> pick() async {
    final file = await openFile(
      acceptedTypeGroups: gCodeAcceptedTypeGroups(defaultTargetPlatform),
    );

    if (file == null) return null;

    final size = await file.length();

    return GCodePickedFile(
      name: file.name,
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
    required this.readAsBytes,
    this.path,
    this.mimeType,
    this.size,
  });

  final String name;
  final String? path;
  final String? mimeType;
  final int? size;
  final Future<Uint8List> Function() readAsBytes;

  bool get hasSupportedExtension {
    switch (p.extension(name).toLowerCase()) {
      case '.gcode':
      case '.gco':
      case '.nc':
        return true;
      default:
        return false;
    }
  }
}
