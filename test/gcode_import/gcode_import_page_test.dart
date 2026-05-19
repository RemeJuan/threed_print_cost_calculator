import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/batch_costing/batch_gcode_import_page.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_page.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_controller.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_file_picker.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_result.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_service.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/shared/providers/batch_costing_visibility.dart';

import '../helpers/helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await setupTest();
  });

  testWidgets('gcode import page renders the import flow', (tester) async {
    await tester.pumpApp(const GCodeImportPage());

    expect(
      find.byKey(const ValueKey<String>('gcode_import.select_file.button')),
      findsOneWidget,
    );
  });

  testWidgets('premium users can access the import flow', (tester) async {
    await tester.pumpApp(const GCodeImportPage(), [
      isPremiumProvider.overrideWithValue(true),
    ]);

    expect(
      find.byKey(const ValueKey<String>('gcode_import.select_file.button')),
      findsOneWidget,
    );
  });

  testWidgets('shows low-res preview label and rendering', (tester) async {
    await tester.pumpApp(const GCodeImportPage(), [
      isPremiumProvider.overrideWithValue(true),
      gcodeImportControllerProvider.overrideWith(
        () => _FakeController(
          _successState(
            slicer: GCodeSlicer.prusaSlicer,
            previewMetadata: const GCodePreviewMetadata(
              present: true,
              format: 'PNG',
              width: 32,
              height: 32,
            ),
            previewImageBytes: _validPngBytes(),
            hasSafePreview: true,
          ),
        ),
      ),
    ]);

    expect(find.text('Preview · 32×32'), findsOneWidget);
    final image = tester.widget<Image>(find.byType(Image));
    expect(image.filterQuality, FilterQuality.none);

    expect(find.byType(Image), findsOneWidget);

    expect(find.byTooltip('Close'), findsNothing);
  });

  testWidgets('shows normal preview label for larger previews', (tester) async {
    await tester.pumpApp(const GCodeImportPage(), [
      isPremiumProvider.overrideWithValue(true),
      gcodeImportControllerProvider.overrideWith(
        () => _FakeController(
          _successState(
            slicer: GCodeSlicer.prusaSlicer,
            previewMetadata: const GCodePreviewMetadata(
              present: true,
              format: 'PNG',
              width: 256,
              height: 256,
            ),
            previewImageBytes: _validPngBytes(),
            hasSafePreview: true,
          ),
        ),
      ),
    ]);

    expect(find.text('Preview'), findsWidgets);
    expect(find.textContaining('×'), findsNothing);
    expect(find.byType(TextButton), findsOneWidget);
  });

  testWidgets('shows fallback text when preview decode fails', (tester) async {
    await tester.pumpApp(const GCodeImportPage(), [
      isPremiumProvider.overrideWithValue(true),
      gcodeImportControllerProvider.overrideWith(
        () => _FakeController(
          _successState(
            slicer: GCodeSlicer.prusaSlicer,
            previewMetadata: const GCodePreviewMetadata(
              present: true,
              format: 'PNG',
              width: 256,
              height: 256,
            ),
            previewImageBytes: Uint8List.fromList([0, 1, 2, 3]),
            hasSafePreview: true,
          ),
        ),
      ),
    ]);

    await tester.tap(find.widgetWithText(TextButton, 'View'));
    await tester.pumpAndSettle();

    expect(
      find.text('Preview metadata found, but image could not be displayed.'),
      findsOneWidget,
    );
  });

  testWidgets('shows Cura preview note when preview missing', (tester) async {
    await tester.pumpApp(const GCodeImportPage(), [
      isPremiumProvider.overrideWithValue(true),
      gcodeImportControllerProvider.overrideWith(
        () => _FakeController(
          _successState(
            slicer: GCodeSlicer.cura,
            previewMetadata: null,
            previewImageBytes: null,
          ),
        ),
      ),
    ]);

    expect(
      find.text(
        'Cura previews may require a post-processing script to embed thumbnails in the G-code.',
      ),
      findsOneWidget,
    );
    expect(find.text('No preview'), findsOneWidget);
  });

  testWidgets('keeps no-preview summary unchanged', (tester) async {
    await tester.pumpApp(const GCodeImportPage(), [
      isPremiumProvider.overrideWithValue(true),
      gcodeImportControllerProvider.overrideWith(
        () => _FakeController(
          _successState(
            slicer: GCodeSlicer.prusaSlicer,
            previewMetadata: null,
            previewImageBytes: null,
          ),
        ),
      ),
    ]);

    expect(find.text('No preview'), findsOneWidget);
    expect(find.textContaining('Cura previews may require'), findsNothing);
  });

  testWidgets('shows feedback entry point after import result', (tester) async {
    await tester.pumpApp(const GCodeImportPage(), [
      isPremiumProvider.overrideWithValue(true),
      gcodeImportControllerProvider.overrideWith(
        () => _FakeController(
          _successState(
            slicer: GCodeSlicer.prusaSlicer,
            previewMetadata: null,
            previewImageBytes: null,
          ),
        ),
      ),
    ]);

    expect(find.text('Send feedback'), findsOneWidget);
  });

  testWidgets('keeps quantity field hidden when batch costing enabled', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      batchCostingEnabledPreferenceKey: true,
    });

    await tester.pumpApp(const GCodeImportPage(), [
      isPremiumProvider.overrideWithValue(true),
      gcodeImportControllerProvider.overrideWith(
        () => _FakeController(
          _successState(
            slicer: GCodeSlicer.prusaSlicer,
            previewMetadata: null,
            previewImageBytes: null,
          ),
        ),
      ),
    ]);

    expect(
      find.byKey(const ValueKey<String>('gcode_import.quantity.field')),
      findsNothing,
    );
    expect(find.text('Use these values'), findsOneWidget);
    expect(find.text('Create batch'), findsNothing);
  });

  testWidgets('quantity field stays hidden when batch costing disabled', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      batchCostingEnabledPreferenceKey: false,
    });

    await tester.pumpApp(const GCodeImportPage(), [
      isPremiumProvider.overrideWithValue(true),
      gcodeImportControllerProvider.overrideWith(
        () => _FakeController(
          _successState(
            slicer: GCodeSlicer.prusaSlicer,
            previewMetadata: null,
            previewImageBytes: null,
          ),
        ),
      ),
    ]);

    expect(
      find.byKey(const ValueKey<String>('gcode_import.quantity.field')),
      findsNothing,
    );
    expect(find.text('Use these values'), findsOneWidget);
  });

  testWidgets('quantity one uses existing calculator path', (tester) async {
    final observer = _TestNavigatorObserver();
    SharedPreferences.setMockInitialValues({
      batchCostingEnabledPreferenceKey: true,
    });

    final container = await tester.pumpAppWithContainer(
      const GCodeImportPage(),
      overrides: [
        isPremiumProvider.overrideWithValue(true),
        gcodeImportControllerProvider.overrideWith(
          () => _FakeController(
            _successState(
              slicer: GCodeSlicer.prusaSlicer,
              previewMetadata: null,
              previewImageBytes: null,
            ),
          ),
        ),
      ],
      observers: [observer],
    );
    final initialPushCount = observer.pushCount;

    final applyButton = find.byKey(
      const ValueKey<String>('gcode_import.apply.button'),
    );
    await tester.ensureVisible(applyButton);
    await tester.tap(applyButton);
    await tester.pumpAndSettle();

    final calculatorState = container.read(calculatorProvider);
    expect(calculatorState.importedFromGcode, isTrue);
    expect(calculatorState.hours.value, 0);
    expect(calculatorState.minutes.value, 10);
    expect(calculatorState.printWeight.value, 10);
    expect(observer.pushCount, initialPushCount);
  });

  testWidgets('multi-file picker switches into batch flow on same page', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      batchCostingEnabledPreferenceKey: true,
    });

    final files = [_pickedFile('one.gcode'), _pickedFile('two.gcode')];

    await tester.pumpApp(const GCodeImportPage(), [
      isPremiumProvider.overrideWithValue(true),
      gcodeImportFilePickerProvider.overrideWithValue(_FakePicker(files)),
      gcodeImportServiceProvider.overrideWithValue(_FakeService(_batchResult)),
    ]);

    final pickButton = find.byKey(
      const ValueKey<String>('gcode_import.select_file.button'),
    );
    await tester.tap(pickButton);
    await tester.pumpAndSettle();

    expect(find.byType(BatchGCodeImportPage), findsOneWidget);
    expect(find.text('one.gcode'), findsOneWidget);
    expect(find.text('two.gcode'), findsOneWidget);
    expect(find.byType(BatchGCodeImportPage), findsOneWidget);
  });
}

class _TestNavigatorObserver extends NavigatorObserver {
  int pushCount = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushCount += 1;
    super.didPush(route, previousRoute);
  }
}

class _FakeController extends GCodeImportController {
  _FakeController(this._state);

  final GCodeImportState _state;

  @override
  GCodeImportState build() {
    return _state;
  }
}

class _FakePicker extends GCodeImportFilePicker {
  _FakePicker(this.files);

  final List<GCodePickedFile> files;

  @override
  Future<GCodePickedFile?> pick() async => files.isEmpty ? null : files.first;

  @override
  Future<List<GCodePickedFile>> pickMany() async => files;
}

class _FakeService extends GCodeImportService {
  _FakeService(this.result);

  final GCodeImportResult result;

  @override
  Future<GCodeImportResult> importPickedFile(GCodePickedFile file) async =>
      result;
}

GCodeImportState _successState({
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

Uint8List _validPngBytes() => Uint8List.fromList([
  ...base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAASsJTYQAAAAASUVORK5CYII=',
  ),
]);

GCodePickedFile _pickedFile(String name) {
  return GCodePickedFile(
    name: name,
    originalName: name,
    size: 1024,
    readAsBytes: () async => Uint8List.fromList(
      ';FLAVOR:Marlin\nG1 X10 Y10\n;TIME:10\n'.codeUnits,
    ),
  );
}

final _batchResult = GCodeImportResult(
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
