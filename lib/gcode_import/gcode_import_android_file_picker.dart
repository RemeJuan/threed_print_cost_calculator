import 'package:flutter/services.dart';

import 'model/gcode_import_file.dart';

class AndroidGCodeImportFilePicker {
  const AndroidGCodeImportFilePicker();

  static const MethodChannel _channel = MethodChannel(
    'com.threed_print_calculator/gcode_import_picker',
  );

  Future<GCodePickedFile?> pick() async {
    Object? payload;
    try {
      payload = await _channel.invokeMethod<Object?>('pickGCodeFile');
    } on PlatformException {
      return null;
    } catch (e) {
      return null;
    }

    if (payload is! Map<Object?, Object?>) return null;

    final name = _safeString(payload['displayName']);
    final path = _safeString(payload['path']);
    if (name == null || path == null) return null;

    final size = _safeInt(payload['size']);

    return GCodePickedFile(
      name: name,
      originalName: _safeString(payload['originalName']),
      path: path,
      sourceUri: _safeString(payload['uri']),
      mimeType: _safeString(payload['mimeType']),
      size: size,
    );
  }

  String? _safeString(Object? value) {
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) return trimmed;
    }
    return null;
  }

  int? _safeInt(Object? value) {
    if (value is num) return value.toInt();
    return null;
  }
}
