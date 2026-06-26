import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:threed_print_cost_calculator/core/analytics/analytics_service.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_controller.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_file_picker.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_result.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_service.dart';

class TestNavigatorObserver extends NavigatorObserver {
  int pushCount = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushCount += 1;
    super.didPush(route, previousRoute);
  }
}

class RecordingAnalyticsEvent {
  RecordingAnalyticsEvent(this.name, this.params);

  final String name;
  final Map<String, Object>? params;
}

class RecordingAnalytics implements AnalyticsService {
  final List<RecordingAnalyticsEvent> events = [];

  List<String> get eventNames => events.map((event) => event.name).toList();

  @override
  Future<void> logEvent(String name, {Map<String, Object>? params}) async {
    events.add(RecordingAnalyticsEvent(name, params));
  }
}

class FakeController extends GCodeImportController {
  FakeController(this.state);

  @override
  final GCodeImportState state;

  @override
  GCodeImportState build() => state;
}

class FakePicker extends GCodeImportFilePicker {
  FakePicker(this.files);

  final List<GCodePickedFile> files;

  @override
  Future<GCodePickedFile?> pick() async => files.isEmpty ? null : files.first;

  @override
  Future<List<GCodePickedFile>> pickMany() async => files;
}

class TrackingPicker extends GCodeImportFilePicker {
  TrackingPicker(this.files);

  final List<GCodePickedFile> files;
  int pickCalls = 0;
  int pickManyCalls = 0;

  @override
  Future<GCodePickedFile?> pick() async {
    pickCalls += 1;
    return files.isEmpty ? null : files.first;
  }

  @override
  Future<List<GCodePickedFile>> pickMany() async {
    pickManyCalls += 1;
    return files;
  }
}

class NullPicker extends GCodeImportFilePicker {
  @override
  Future<GCodePickedFile?> pick() async => null;

  @override
  Future<List<GCodePickedFile>> pickMany() async => const [];
}

class FakeService extends GCodeImportService {
  FakeService(this.result);

  final GCodeImportResult result;

  @override
  Future<GCodeImportResult> importPickedFile(GCodePickedFile file) async =>
      result;
}

GCodeImportState successState({
  required GCodeSlicer slicer,
  required GCodePreviewMetadata? previewMetadata,
  required Uint8List? previewImageBytes,
  int selectedFileSizeBytes = 1024,
  bool hasSafePreview = false,
}) {
  return GCodeImportState.success(
    selectedFileName: 'preview.gcode',
    selectedFileSizeBytes: selectedFileSizeBytes,
    result: GCodeImportResult(
      slicer: slicer,
      estimatedDuration: const Duration(minutes: 10),
      filamentLengthMm: 100,
      filamentWeightG: 10,
      layerHeightMm: 0.2,
      previewMetadata: previewMetadata,
      previewImageBytes: previewImageBytes,
      warnings: const [],
      rawExtractedValues: const {},
      hasSafePreview: hasSafePreview,
    ),
  );
}

Uint8List validPngBytes() => Uint8List.fromList([
  ...base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAASsJTYQAAAAASUVORK5CYII=',
  ),
]);

GCodePickedFile pickedFile(String name) {
  return GCodePickedFile(
    name: name,
    originalName: name,
    size: 1024,
    readAsBytes: () async =>
        Uint8List.fromList(';FLAVOR:Marlin\nG1 X10 Y10\n;TIME:10\n'.codeUnits),
  );
}

final batchResult = GCodeImportResult(
  slicer: GCodeSlicer.prusaSlicer,
  estimatedDuration: const Duration(minutes: 10),
  filamentLengthMm: 100,
  filamentWeightG: 10,
  layerHeightMm: 0.2,
  previewMetadata: null,
  previewImageBytes: null,
  warnings: const [],
  rawExtractedValues: const {},
);
