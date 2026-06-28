import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/batch_costing/batch_gcode_import_page.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_controller.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_file_picker.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_page.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_service.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_result.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';

import '../helpers/helpers.dart';
import 'gcode_import_page_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await setupTest();
  });

  testWidgets('quantity field hidden and apply uses calculator path', (
    tester,
  ) async {
    final observer = TestNavigatorObserver();
    final container = await tester.pumpAppWithContainer(
      const GCodeImportPage(),
      overrides: [
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
      ],
      observers: [observer],
    );
    final initialPushCount = observer.pushCount;

    expect(
      find.byKey(const ValueKey<String>('gcode_import.quantity.field')),
      findsNothing,
    );
    final l10n = AppLocalizations.of(
      tester.element(find.byType(GCodeImportPage)),
    )!;
    expect(find.text(l10n.importGcodeUseValuesButton), findsOneWidget);
    expect(find.text(l10n.importGcodeCreateBatchButton), findsNothing);

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

  testWidgets('premium batch flow opens batch page', (tester) async {
    final files = [pickedFile('one.gcode'), pickedFile('two.gcode')];

    await tester.pumpApp(const GCodeImportPage(), [
      isPremiumProvider.overrideWithValue(true),
      gcodeImportFilePickerProvider.overrideWithValue(FakePicker(files)),
      gcodeImportServiceProvider.overrideWithValue(FakeService(batchResult)),
    ]);

    await tester.tap(
      find.byKey(const ValueKey<String>('gcode_import.select_file.button')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(BatchGCodeImportPage), findsOneWidget);
    expect(find.text('one.gcode'), findsOneWidget);
    expect(find.text('two.gcode'), findsOneWidget);
  });

  testWidgets('free users are blocked from batch G-code import', (
    tester,
  ) async {
    final files = [pickedFile('one.gcode'), pickedFile('two.gcode')];
    final picker = TrackingPicker(files);
    await tester.pumpApp(const GCodeImportPage(), [
      gcodeImportFilePickerProvider.overrideWithValue(picker),
      gcodeImportServiceProvider.overrideWithValue(FakeService(batchResult)),
      isPremiumProvider.overrideWithValue(false),
    ]);

    await tester.tap(
      find.byKey(const ValueKey<String>('gcode_import.select_file.button')),
    );
    await tester.pumpAndSettle();

    expect(picker.pickCalls, 1);
    expect(picker.pickManyCalls, 0);
    expect(find.byType(BatchGCodeImportPage), findsNothing);
    expect(find.text('one.gcode'), findsNothing);
    expect(find.text('two.gcode'), findsNothing);
  });
}
