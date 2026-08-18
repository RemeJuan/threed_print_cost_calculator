import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_controller.dart';

import 'gcode_import_controller_test_support.dart';

void main() {
  test('accepts .gcode files', () async {
    final container = makeContainer(
      file: makeFile('part.gcode', gcodeBytes()),
      serviceResult: result,
    );

    await container.read(gcodeImportControllerProvider.notifier).pickAndParse();

    expect(
      container.read(gcodeImportControllerProvider).status,
      GCodeImportStatus.success,
    );
  });

  test('accepts .gco files', () async {
    final container = makeContainer(
      file: makeFile('part.gco', gcodeBytes()),
      serviceResult: result,
    );

    await container.read(gcodeImportControllerProvider.notifier).pickAndParse();

    expect(
      container.read(gcodeImportControllerProvider).status,
      GCodeImportStatus.success,
    );
  });

  test('accepts .nc files', () async {
    final container = makeContainer(
      file: makeFile('part.nc', gcodeBytes()),
      serviceResult: result,
    );

    await container.read(gcodeImportControllerProvider.notifier).pickAndParse();

    expect(
      container.read(gcodeImportControllerProvider).status,
      GCodeImportStatus.success,
    );
  });

  test('accepts Android style bin file with G-code text', () async {
    final container = makeContainer(
      file: makeFile(
        'cache.bin',
        gcodeBytes(),
        originalName: 'benchy.gcode',
        mimeType: 'application/octet-stream',
      ),
      serviceResult: result,
    );

    await container.read(gcodeImportControllerProvider.notifier).pickAndParse();

    expect(
      container.read(gcodeImportControllerProvider).status,
      GCodeImportStatus.success,
    );
  });

  test('rejects real binary bin file', () async {
    final container = makeContainer(
      file: makeFile('cache.bin', Uint8List.fromList([0, 1, 2, 3, 4])),
      serviceResult: result,
    );

    await container.read(gcodeImportControllerProvider.notifier).pickAndParse();

    final state = container.read(gcodeImportControllerProvider);
    expect(state.status, GCodeImportStatus.failure);
    expect(state.error, GCodeImportError.unsupportedType);
  });

  test('rejects unknown text without G-code markers', () async {
    final container = makeContainer(
      file: makeFile('notes.txt', Uint8List.fromList('hello world'.codeUnits)),
      serviceResult: result,
    );

    await container.read(gcodeImportControllerProvider.notifier).pickAndParse();

    final state = container.read(gcodeImportControllerProvider);
    expect(state.status, GCodeImportStatus.failure);
    expect(state.error, GCodeImportError.unsupportedType);
  });

  test('rejects oversized files before reading bytes', () async {
    const oversized = 50 * 1024 * 1024 + 1;
    var readCount = 0;
    final container = makeContainer(
      file: makeFile(
        'oversized.gcode',
        gcodeBytes(),
        size: oversized,
        onRead: () => readCount++,
      ),
      serviceResult: result,
    );

    await container.read(gcodeImportControllerProvider.notifier).pickAndParse();

    final state = container.read(gcodeImportControllerProvider);
    expect(state.status, GCodeImportStatus.failure);
    expect(state.error, GCodeImportError.tooLarge);
    expect(state.selectedFileSizeBytes, oversized);
    expect(readCount, 0);
  });

  test('rejects binary gcode files', () async {
    final container = makeContainer(
      file: makeFile('part.gcode', Uint8List.fromList([0, 1, 2, 3, 4])),
      serviceResult: result,
    );

    await container.read(gcodeImportControllerProvider.notifier).pickAndParse();

    final state = container.read(gcodeImportControllerProvider);
    expect(state.status, GCodeImportStatus.failure);
    expect(state.error, GCodeImportError.unsupportedType);
  });
}
