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
      readAsBytes: () async => Uint8List.fromList('G1 X1 Y1\n'.codeUnits),
    );
    final picker = _FakeGCodeImportFilePicker(pickedFile);
    final service = _FakeGCodeImportService(
      GCodeImportResult(
        slicer: GCodeSlicer.prusaSlicer,
        estimatedDuration: const Duration(hours: 1, minutes: 45),
        filamentLengthMm: 100.0,
        filamentWeightG: 42.0,
        layerHeightMm: 0.2,
        previewMetadata: const GCodePreviewMetadata(
          present: true,
          format: 'png',
          width: 1,
          height: 1,
        ),
        previewImageBytes: Uint8List.fromList(const [
          0x89,
          0x50,
          0x4E,
          0x47,
          0x0D,
          0x0A,
          0x1A,
          0x0A,
          0x00,
          0x00,
          0x00,
          0x0D,
          0x49,
          0x48,
          0x44,
          0x52,
          0x00,
          0x00,
          0x00,
          0x01,
          0x00,
          0x00,
          0x00,
          0x01,
          0x08,
          0x06,
          0x00,
          0x00,
          0x00,
          0x1F,
          0x15,
          0xC4,
          0x89,
          0x00,
          0x00,
          0x00,
          0x0A,
          0x49,
          0x44,
          0x41,
          0x54,
          0x78,
          0x9C,
          0x63,
          0xF8,
          0xCF,
          0xC0,
          0x00,
          0x00,
          0x03,
          0x01,
          0x01,
          0x00,
          0x18,
          0xDD,
          0x8D,
          0xB7,
          0x00,
          0x00,
          0x00,
          0x00,
          0x49,
          0x45,
          0x4E,
          0x44,
          0xAE,
          0x42,
          0x60,
          0x82,
        ]),
        hasSafePreview: true,
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
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await tester.tapByKey('header.gcode_import.open.button');
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await tester.tapByKey('gcode_import.select_file.button');
    await tester.pumpAndSettle(const Duration(seconds: 1));
    final previewButton = find.byKey(
      const ValueKey<String>('gcode_import.preview.button'),
    );
    final previewImage = find.byType(Image);
    expect(
      previewButton.evaluate().isNotEmpty || previewImage.evaluate().isNotEmpty,
      isTrue,
    );
    if (previewButton.evaluate().isNotEmpty) {
      await tester.tap(previewButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await tester.tapByKey('gcode_import.preview.close.button');
      await tester.pumpAndSettle(const Duration(seconds: 1));
    } else if (previewImage.evaluate().isNotEmpty) {
      await tester.tap(previewImage.last);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await tester.tapByKey('gcode_import.preview.close.button');
      await tester.pumpAndSettle(const Duration(seconds: 1));
    }
    await tester.tapByKey('gcode_import.apply.button');
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(
      find.byKey(const ValueKey<String>('gcode_import.apply.button')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey<String>('header.gcode_import.open.button')),
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
