import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_page.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_controller.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_result.dart';
import 'package:threed_print_cost_calculator/calculator/view/subscriptions.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';

import '../helpers/helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupTest();
  });

  testWidgets('non-premium users see the upgrade prompt', (tester) async {
    await tester.pumpApp(const GCodeImportPage(), [
      isPremiumProvider.overrideWithValue(false),
    ]);

    expect(find.byType(Subscriptions), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('gcode_import.select_file.button')),
      findsNothing,
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

  testWidgets('shows preview image when available', (tester) async {
    await tester.pumpApp(const GCodeImportPage(), [
      isPremiumProvider.overrideWithValue(true),
      gcodeImportControllerProvider.overrideWith(
        () => _FakeController(
          _successState(
            slicer: GCodeSlicer.prusaSlicer,
            previewMetadata: const GCodePreviewMetadata(
              present: true,
              format: 'PNG',
              width: 1,
              height: 1,
            ),
            previewImageBytes: _validPngBytes(),
          ),
        ),
      ),
    ]);

    expect(find.widgetWithText(TextButton, 'View'), findsOneWidget);
    expect(find.text('Preview metadata found, but image could not be displayed.'), findsNothing);

    await tester.ensureVisible(find.widgetWithText(TextButton, 'View'));
    await tester.tap(find.widgetWithText(TextButton, 'View'));
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsOneWidget);

    await tester.ensureVisible(find.byTooltip('Close'));
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsNothing);
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
              width: 1,
              height: 1,
            ),
            previewImageBytes: Uint8List.fromList([0, 1, 2, 3]),
          ),
        ),
      ),
    ]);

    await tester.ensureVisible(find.widgetWithText(TextButton, 'View'));
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
    expect(find.text('Not available'), findsOneWidget);
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

    expect(find.text('Not available'), findsOneWidget);
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
}

class _FakeController extends GCodeImportController {
  _FakeController(this._state);

  final GCodeImportState _state;

  @override
  GCodeImportState build() {
    return _state;
  }
}

GCodeImportState _successState({
  required GCodeSlicer slicer,
  required GCodePreviewMetadata? previewMetadata,
  required Uint8List? previewImageBytes,
}) {
  return GCodeImportState.success(
    selectedFileName: 'preview.gcode',
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
    ),
  );
}

Uint8List _validPngBytes() => Uint8List.fromList([
  ...base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAASsJTYQAAAAASUVORK5CYII=',
  ),
]);
