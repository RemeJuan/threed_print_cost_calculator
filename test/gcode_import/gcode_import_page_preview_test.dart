import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_controller.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_result.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_page.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';

import '../helpers/helpers.dart';
import 'gcode_import_page_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await setupTest();
  });

  testWidgets('renders low-res preview', (tester) async {
    await tester.pumpApp(const GCodeImportPage(), [
      isPremiumProvider.overrideWithValue(true),
      gcodeImportControllerProvider.overrideWith(
        () => FakeController(
          successState(
            slicer: GCodeSlicer.prusaSlicer,
            previewMetadata: const GCodePreviewMetadata(
              present: true,
              format: 'PNG',
              width: 32,
              height: 32,
            ),
            previewImageBytes: validPngBytes(),
            hasSafePreview: true,
          ),
        ),
      ),
    ]);

    expect(find.text('Preview · 32×32'), findsOneWidget);
    expect(
      tester.widget<Image>(find.byType(Image)).filterQuality,
      FilterQuality.none,
    );
    expect(find.byType(Image), findsOneWidget);
    expect(find.byTooltip('Close'), findsNothing);
  });

  testWidgets('shows preview decode fallback', (tester) async {
    await tester.pumpApp(const GCodeImportPage(), [
      isPremiumProvider.overrideWithValue(true),
      gcodeImportControllerProvider.overrideWith(
        () => FakeController(
          successState(
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
        () => FakeController(
          successState(
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
    expect(find.textContaining('Cura previews may require'), findsOneWidget);
  });

  testWidgets('keeps no-preview summary unchanged', (tester) async {
    await tester.pumpApp(const GCodeImportPage(), [
      isPremiumProvider.overrideWithValue(true),
      gcodeImportControllerProvider.overrideWith(
        () => FakeController(
          successState(
            slicer: GCodeSlicer.prusaSlicer,
            previewMetadata: null,
            previewImageBytes: null,
          ),
        ),
      ),
    ]);

    expect(find.text('No preview'), findsOneWidget);
    expect(find.textContaining('Cura previews may require'), findsNothing);
    expect(find.text('Send feedback'), findsOneWidget);
  });
}
