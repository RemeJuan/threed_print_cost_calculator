import 'package:flutter/foundation.dart';
import 'package:file_selector/file_selector.dart';
import 'package:riverpod/riverpod.dart';

import 'gcode_import_android_file_picker.dart';
import 'model/gcode_import_file.dart';

export 'model/gcode_import_file.dart';

final gcodeImportFilePickerProvider = Provider<GCodeImportFilePicker>((ref) {
  return const PlatformGCodeImportFilePicker();
});

abstract class GCodeImportFilePicker {
  const GCodeImportFilePicker();

  Future<GCodePickedFile?> pick();

  Future<List<GCodePickedFile>> pickMany();
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

  @override
  Future<List<GCodePickedFile>> pickMany() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return _androidPicker.pickMany();
    }

    final files = await openFiles(
      acceptedTypeGroups: gCodeAcceptedTypeGroups(defaultTargetPlatform),
    );
    return [
      for (final file in files)
        GCodePickedFile(
          name: file.name,
          originalName: file.name,
          path: file.path,
          mimeType: file.mimeType,
          size: await file.length(),
          readAsBytes: file.readAsBytes,
        ),
    ];
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
      return [
        const XTypeGroup(label: 'G-code', extensions: gCodeSupportedExtensions),
      ];
  }
}
