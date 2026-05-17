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

  Future<List<GCodePickedFile>> pickMany() async {
    Object? payload;
    try {
      payload = await _channel.invokeMethod<Object?>('pickGCodeFiles');
    } on PlatformException {
      return const <GCodePickedFile>[];
    } catch (e) {
      return const <GCodePickedFile>[];
    }

    if (payload is! List) return const <GCodePickedFile>[];

    final files = <GCodePickedFile>[];
    for (final entry in payload) {
      if (entry is! Map<Object?, Object?>) continue;
      final name = _safeString(entry['displayName']);
      final path = _safeString(entry['path']);
      if (name == null || path == null) continue;
      files.add(
        GCodePickedFile(
          name: name,
          originalName: _safeString(entry['originalName']),
          path: path,
          sourceUri: _safeString(entry['uri']),
          mimeType: _safeString(entry['mimeType']),
          size: _safeInt(entry['size']),
        ),
      );
    }
    return files;
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
