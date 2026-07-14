import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/database/repositories/history_repository.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_file_picker.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_result.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_service.dart';
import 'package:threed_print_cost_calculator/purchases/premium_local_store_keys.dart';

import 'helpers/integration_test_harness.dart';
import 'helpers/integration_test_ui.dart';

class _FakeGCodeImportFilePicker extends GCodeImportFilePicker {
  _FakeGCodeImportFilePicker(this.file);

  final GCodePickedFile file;
  int pickCalls = 0;
  int pickManyCalls = 0;

  @override
  Future<GCodePickedFile?> pick() async {
    pickCalls += 1;
    return file;
  }

  @override
  Future<List<GCodePickedFile>> pickMany() async {
    pickManyCalls += 1;
    return [file];
  }
}

class _FakeGCodeImportService extends GCodeImportService {
  _FakeGCodeImportService(this.result);

  final GCodeImportResult result;

  @override
  Future<GCodeImportResult> importPickedFile(GCodePickedFile file) async =>
      result;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('gcode import applies to calculator shell', (tester) async {
    final pickedFile = GCodePickedFile(
      name: 'journey.gcode',
      originalName: 'journey.gcode',
      size: 1,
      readAsBytes: () async => Uint8List.fromList(const [1]),
    );
    final picker = _FakeGCodeImportFilePicker(pickedFile);
    final service = _FakeGCodeImportService(
      GCodeImportResult(
        slicer: GCodeSlicer.prusaSlicer,
        estimatedDuration: const Duration(hours: 1, minutes: 45),
        filamentLengthMm: 100.0,
        filamentWeightG: 42.0,
        layerHeightMm: 0.2,
        previewMetadata: null,
        previewImageBytes: null,
        warnings: const [],
        rawExtractedValues: const {},
      ),
    );

    final harness = await IntegrationTestHarness.free(
      overrides: [
        gcodeImportFilePickerProvider.overrideWithValue(picker),
        gcodeImportServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(harness.dispose);

    await tester.launchHarnessApp(harness);

    await tester.tapByKey('nav.calculator.button');
    await tester.tapByKey('calculator.gcode_import.open.button');
    await tester.tapByKey('gcode_import.select_file.button');
    await tester.tapByKey('gcode_import.apply.button');

    expect(
      find.byKey(const ValueKey<String>('gcode_import.apply.button')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey<String>('calculator.gcode_import.open.button')),
      findsOneWidget,
    );

    final calculatorState = harness.container.read(calculatorProvider);
    expect(calculatorState.hours.value, 1);
    expect(calculatorState.minutes.value, 45);
    expect(calculatorState.printWeight.value, 42);
    expect(calculatorState.importedFromGcode, isTrue);

    expect(picker.pickCalls, 1);
    expect(picker.pickManyCalls, 0);
    expect(
      harness.sharedPreferences.getString(hasUsedGcodeImportPreferenceKey),
      'true',
    );

    final historyRepository = harness.container.read(historyRepositoryProvider);
    expect(await historyRepository.countHistory(), 0);
  });
}
