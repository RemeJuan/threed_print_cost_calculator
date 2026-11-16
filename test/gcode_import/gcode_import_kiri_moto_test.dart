import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_file_validator.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_controller.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_service.dart';
import 'package:threed_print_cost_calculator/gcode_import/model/gcode_import_file.dart';

void main() {
  final fixturePath =
      '${Directory.current.path}/Documento_da_parte_di_Leonardo_B1681905261655622098.tmp';
  final fixtureExists = File(fixturePath).existsSync();

  test(
    'full local Kiri Moto file imports from path despite .tmp name',
    skip: !fixtureExists,
    () async {
      final file = GCodePickedFile(
        path: fixturePath,
        name: 'Documento_da_parte_di_Leonardo_B1681905261655622098.tmp',
        originalName:
            'Documento_da_parte_di_Leonardo_B1681905261655622098.gcode',
        size: File(fixturePath).lengthSync(),
      );
      expect(await validateGCodeFile(file), GCodeValidationResult.supported);

      final container = ProviderContainer(
        overrides: [
          gcodeImportServiceProvider.overrideWithValue(
            const GCodeImportService(),
          ),
        ],
      );
      addTearDown(container.dispose);
      await container
          .read(gcodeImportControllerProvider.notifier)
          .parsePickedFile(file, attemptId: 'kiri-local');
      final state = container.read(gcodeImportControllerProvider);
      expect(state.status, GCodeImportStatus.success);
      expect(state.result?.estimatedDuration, const Duration(seconds: 4562));
      expect(state.result?.filamentLengthMm, 12990.78);
      expect(state.result?.filamentWeightG, isNull);
    },
  );

  test('unknown command-bearing G-code without metadata succeeds', () async {
    final file = GCodePickedFile(
      name: 'unknown.gcode',
      size: 24,
      readAsBytes: () async =>
          Uint8List.fromList('G1 X10 Y10 E1\nM104 S200\n'.codeUnits),
    );
    final container = ProviderContainer(
      overrides: [
        gcodeImportServiceProvider.overrideWithValue(
          const GCodeImportService(),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(gcodeImportControllerProvider.notifier)
        .parsePickedFile(file, attemptId: 'unknown-valid');
    final state = container.read(gcodeImportControllerProvider);
    expect(state.status, GCodeImportStatus.success);
    expect(state.result?.slicer.name, 'unknown');
    expect(state.result?.estimatedDuration, isNull);
    expect(state.result?.filamentLengthMm, isNull);
    expect(state.result?.warnings, isNotEmpty);
  });

  test('comment-only content without metadata remains rejected', () async {
    final file = GCodePickedFile(
      name: 'comments.gcode',
      size: 24,
      readAsBytes: () async =>
          Uint8List.fromList('; just a comment\n'.codeUnits),
    );
    final container = ProviderContainer(
      overrides: [
        gcodeImportServiceProvider.overrideWithValue(
          const GCodeImportService(),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(gcodeImportControllerProvider.notifier)
        .parsePickedFile(file, attemptId: 'invalid-comment');
    expect(
      container.read(gcodeImportControllerProvider).status,
      GCodeImportStatus.failure,
    );
  });

  test('non-G-code content without supported name fails validation', () async {
    final file = GCodePickedFile(
      name: 'attachment.tmp',
      size: 14,
      readAsBytes: () async => Uint8List.fromList('ordinary text\n'.codeUnits),
    );
    expect(
      (await validateGCodeFile(file)).error,
      GCodeImportError.unsupportedType,
    );
  });

  test(
    'real local file imports with .gcode picked name through service',
    skip: !fixtureExists,
    () async {
      final file = GCodePickedFile(
        path: fixturePath,
        name: 'original.gcode',
        size: File(fixturePath).lengthSync(),
      );
      expect(await validateGCodeFile(file), GCodeValidationResult.supported);
      final result = await const GCodeImportService().importPickedFile(file);
      expect(result.estimatedDuration, const Duration(seconds: 4562));
      expect(result.filamentLengthMm, 12990.78);
      expect(result.filamentWeightG, isNull);
    },
  );
}
