import 'dart:async';
import 'dart:typed_data';

import 'package:riverpod/riverpod.dart';
import 'package:threed_print_cost_calculator/core/analytics/analytics_service.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_file_picker.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_result.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_service.dart';

ProviderContainer makeContainer({
  required GCodePickedFile file,
  required GCodeImportResult serviceResult,
  int Function()? onImport,
  Future<GCodeImportResult> Function()? onImportAsync,
  bool shouldThrow = false,
  Object? failure,
}) {
  return ProviderContainer(
    overrides: [
      gcodeImportFilePickerProvider.overrideWithValue(FakePicker(file)),
      gcodeImportServiceProvider.overrideWithValue(
        FakeService(
          serviceResult,
          onImport: onImport,
          onImportAsync: onImportAsync,
          shouldThrow: shouldThrow,
          failure: failure,
        ),
      ),
    ],
  );
}

GCodePickedFile makeFile(
  String name,
  Uint8List bytes, {
  String? originalName,
  String? mimeType,
  int? size,
  void Function()? onRead,
}) {
  return GCodePickedFile(
    name: name,
    originalName: originalName,
    mimeType: mimeType,
    size: size,
    readAsBytes: () async {
      onRead?.call();
      return bytes;
    },
  );
}

GCodePickedFile makeFileAsync(
  String name,
  Future<Uint8List> bytes, {
  String? originalName,
  String? mimeType,
  int? size,
}) {
  return GCodePickedFile(
    name: name,
    originalName: originalName,
    mimeType: mimeType,
    size: size,
    readAsBytes: () async => bytes,
  );
}

final result = GCodeImportResult(
  slicer: GCodeSlicer.prusaSlicer,
  estimatedDuration: const Duration(minutes: 1),
  filamentLengthMm: 1,
  filamentWeightG: 1,
  layerHeightMm: 0.2,
  previewMetadata: null,
  previewImageBytes: null,
  warnings: const [],
  rawExtractedValues: const {},
);

final emptyResult = GCodeImportResult(
  slicer: GCodeSlicer.unknown,
  estimatedDuration: null,
  filamentLengthMm: null,
  filamentWeightG: null,
  layerHeightMm: null,
  previewMetadata: null,
  previewImageBytes: null,
  warnings: const [],
  rawExtractedValues: const {},
);

Uint8List gcodeBytes() =>
    Uint8List.fromList(';FLAVOR:Marlin\nG1 X10 Y10\n;TIME:10\n'.codeUnits);

class FakePicker extends GCodeImportFilePicker {
  FakePicker(this.file);

  final GCodePickedFile file;

  @override
  Future<GCodePickedFile?> pick() async => file;

  @override
  Future<List<GCodePickedFile>> pickMany() async => [file];
}

class FakeService extends GCodeImportService {
  FakeService(
    this.result, {
    this.onImport,
    this.onImportAsync,
    this.shouldThrow = false,
    this.failure,
  });

  final GCodeImportResult result;
  final int Function()? onImport;
  final Future<GCodeImportResult> Function()? onImportAsync;
  final bool shouldThrow;
  final Object? failure;

  @override
  Future<GCodeImportResult> importPickedFile(GCodePickedFile file) async {
    if (failure != null) throw failure!;
    if (shouldThrow) throw Exception('service error');
    onImport?.call();
    if (onImportAsync != null) return onImportAsync!();
    return result;
  }
}

class ThrowingPicker extends GCodeImportFilePicker {
  @override
  Future<GCodePickedFile?> pick() async => throw Exception('picker failed');

  @override
  Future<List<GCodePickedFile>> pickMany() async =>
      throw Exception('picker failed');
}

class CaptureAnalytics implements AnalyticsService {
  CaptureAnalytics(this.events);

  final List<Map<String, Object?>> events;

  @override
  Future<void> logEvent(String name, {Map<String, Object>? params}) async {
    if (name == 'gcode_parse_failed' && params != null) {
      events.add(Map<String, Object?>.from(params));
    }
  }
}
