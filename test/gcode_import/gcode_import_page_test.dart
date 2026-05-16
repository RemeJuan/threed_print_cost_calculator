import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_page.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_controller.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_result.dart';
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

  testWidgets('shows quantity field and create batch CTA when enabled', (
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
      findsOneWidget,
    );
    expect(find.text('Use these values'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey<String>('gcode_import.quantity.field')),
      '3',
    );
    await tester.pump();

    expect(find.text('Create batch'), findsOneWidget);
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

  testWidgets('quantity resets to minimum of one on blur', (tester) async {
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

    final quantityField = find.byKey(
      const ValueKey<String>('gcode_import.quantity.field'),
    );
    await tester.ensureVisible(quantityField);
    await tester.tap(quantityField);
    await tester.pump();
    await tester.enterText(quantityField, '0');
    await tester.pump();

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();

    expect(find.text('1'), findsOneWidget);
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
    expect(container.read(batchCostingProvider).items, isEmpty);
  });

  testWidgets('quantity greater than one creates batch item and navigates', (
    tester,
  ) async {
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

    await tester.enterText(
      find.byKey(const ValueKey<String>('gcode_import.quantity.field')),
      '3',
    );
    await tester.pump();
    final applyButton = find.byKey(
      const ValueKey<String>('gcode_import.apply.button'),
    );
    await tester.ensureVisible(applyButton);
    await tester.tap(applyButton);
    await tester.pumpAndSettle();

    final batchItems = container.read(batchCostingProvider);
    expect(batchItems.items, hasLength(1));
    expect(batchItems.items.single.quantity, 3);
    expect(batchItems.items.single.displayName, 'preview.gcode');
    expect(observer.pushCount, initialPushCount + 1);
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
