import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_controller.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_file_picker.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_result.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_service.dart';

void main() {
  test('accepts .gcode files', () async {
    final container = _container(
      file: _file('part.gcode', _gcodeBytes()),
      serviceResult: _result,
    );

    await container.read(gcodeImportControllerProvider.notifier).pickAndParse();

    expect(
      container.read(gcodeImportControllerProvider).status,
      GCodeImportStatus.success,
    );
  });

  test('accepts .gco files', () async {
    final container = _container(
      file: _file('part.gco', _gcodeBytes()),
      serviceResult: _result,
    );

    await container.read(gcodeImportControllerProvider.notifier).pickAndParse();

    expect(
      container.read(gcodeImportControllerProvider).status,
      GCodeImportStatus.success,
    );
  });

  test('accepts .nc files', () async {
    final container = _container(
      file: _file('part.nc', _gcodeBytes()),
      serviceResult: _result,
    );

    await container.read(gcodeImportControllerProvider.notifier).pickAndParse();

    expect(
      container.read(gcodeImportControllerProvider).status,
      GCodeImportStatus.success,
    );
  });

  test('accepts Android style bin file with G-code text', () async {
    final container = _container(
      file: _file(
        'cache.bin',
        _gcodeBytes(),
        mimeType: 'application/octet-stream',
      ),
      serviceResult: _result,
    );

    await container.read(gcodeImportControllerProvider.notifier).pickAndParse();

    expect(
      container.read(gcodeImportControllerProvider).status,
      GCodeImportStatus.success,
    );
  });

  test('rejects real binary bin file', () async {
    final container = _container(
      file: _file('cache.bin', Uint8List.fromList([0, 1, 2, 3, 4])),
      serviceResult: _result,
    );

    await container.read(gcodeImportControllerProvider.notifier).pickAndParse();

    final state = container.read(gcodeImportControllerProvider);
    expect(state.status, GCodeImportStatus.failure);
    expect(state.error, GCodeImportError.unsupportedType);
  });

  test('rejects unknown text without G-code markers', () async {
    final container = _container(
      file: _file('notes.txt', Uint8List.fromList('hello world'.codeUnits)),
      serviceResult: _result,
    );

    await container.read(gcodeImportControllerProvider.notifier).pickAndParse();

    final state = container.read(gcodeImportControllerProvider);
    expect(state.status, GCodeImportStatus.failure);
    expect(state.error, GCodeImportError.unsupportedType);
  });

  test('rejects oversized files before reading bytes', () async {
    const oversized = 50 * 1024 * 1024 + 1;
    final container = _container(
      file: _file('oversized.gcode', _gcodeBytes(), size: oversized),
      serviceResult: _result,
    );

    await container.read(gcodeImportControllerProvider.notifier).pickAndParse();

    final state = container.read(gcodeImportControllerProvider);
    expect(state.status, GCodeImportStatus.failure);
    expect(state.error, GCodeImportError.unsupportedType);
    expect(state.selectedFileSizeBytes, oversized);
  });

  test('rejects binary gcode files', () async {
    final container = _container(
      file: _file('part.gcode', Uint8List.fromList([0, 1, 2, 3, 4])),
      serviceResult: _result,
    );

    await container.read(gcodeImportControllerProvider.notifier).pickAndParse();

    final state = container.read(gcodeImportControllerProvider);
    expect(state.status, GCodeImportStatus.failure);
    expect(state.error, GCodeImportError.unsupportedType);
  });
}

ProviderContainer _container({
  required GCodePickedFile file,
  required GCodeImportResult serviceResult,
}) {
  return ProviderContainer(
    overrides: [
      gcodeImportFilePickerProvider.overrideWithValue(_FakePicker(file)),
      gcodeImportServiceProvider.overrideWithValue(_FakeService(serviceResult)),
    ],
  );
}

GCodePickedFile _file(String name, Uint8List bytes, {String? mimeType, int? size}) {
  return GCodePickedFile(
    name: name,
    mimeType: mimeType,
    size: size,
    readAsBytes: () async => bytes,
  );
}

final _result = GCodeImportResult(
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

Uint8List _gcodeBytes() =>
    Uint8List.fromList(';FLAVOR:Marlin\nG1 X10 Y10\n;TIME:10\n'.codeUnits);

class _FakePicker extends GCodeImportFilePicker {
  _FakePicker(this.file);

  final GCodePickedFile file;

  @override
  Future<GCodePickedFile?> pick() async => file;
}

class _FakeService extends GCodeImportService {
  _FakeService(this.result);

  final GCodeImportResult result;

  @override
  Future<GCodeImportResult> importPickedBytes(Uint8List bytes) async => result;
}
