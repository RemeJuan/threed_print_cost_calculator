import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/batch_costing/batch_costing_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/batch_gcode_import_page.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_file_picker.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_result.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_service.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/paywall_presenter.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';

import '../helpers/helpers.dart';
import '../helpers/lower_level_test_fakes.dart';

void main() {
  setUpAll(setupTest);

  testWidgets('imports multiple files and seeds batch items', (tester) async {
    final files = [_file('one.gcode'), _file('two.gcode')];
    final service = _FakeService(successResult);
    await tester.pumpApp(const BatchGCodeImportPage(), [
      gcodeImportFilePickerProvider.overrideWithValue(_FakePicker(files)),
      gcodeImportServiceProvider.overrideWithValue(service),
      isPremiumProvider.overrideWithValue(true),
    ]);

    final l10n = AppLocalizations.of(
      tester.element(find.byType(BatchGCodeImportPage)),
    )!;
    await tester.tap(find.text(l10n.batchGcodeImportPickButton));
    await tester.pumpAndSettle();

    expect(find.text('one.gcode'), findsOneWidget);
    expect(find.text('two.gcode'), findsOneWidget);
    expect(find.text(l10n.batchGcodeImportReadyLabel), findsNWidgets(2));
    expect(find.text(l10n.batchGcodeImportContinueButton), findsOneWidget);

    await tester.tap(find.text(l10n.batchGcodeImportContinueButton));
    await tester.pumpAndSettle();

    expect(find.byType(BatchCostingPage), findsOneWidget);
    expect(service.importCalls, 2);
    expect(find.text('one.gcode'), findsOneWidget);
    expect(find.text('two.gcode'), findsOneWidget);
  });

  testWidgets('moves single-file import into batch review on confirm', (
    tester,
  ) async {
    await tester.pumpApp(const BatchGCodeImportPage(), [
      gcodeImportFilePickerProvider.overrideWithValue(
        _FakePicker([_file('single.gcode')]),
      ),
      gcodeImportServiceProvider.overrideWithValue(_FakeService(successResult)),
      isPremiumProvider.overrideWithValue(true),
    ]);

    final l10n = AppLocalizations.of(
      tester.element(find.byType(BatchGCodeImportPage)),
    )!;
    await tester.tap(find.text(l10n.batchGcodeImportPickButton));
    await tester.pumpAndSettle();

    expect(find.text('single.gcode'), findsOneWidget);
    expect(find.text(l10n.importGcodeSummaryTitle), findsNothing);
    expect(find.text(l10n.batchGcodeImportQuantityHint), findsNothing);
    expect(find.text(l10n.batchGcodeImportAddButton), findsOneWidget);

    await tester.tap(find.text(l10n.batchGcodeImportAddButton));
    await tester.pumpAndSettle();

    expect(find.byType(BatchCostingPage), findsOneWidget);
    expect(find.text('single.gcode'), findsOneWidget);
    expect(find.text(l10n.batchCostingReviewContinueButton), findsOneWidget);
  });

  testWidgets('imports files with missing weight and shows needs-details', (
    tester,
  ) async {
    final files = [_file('no-weight.gcode')];
    final noWeightResult = GCodeImportResult(
      slicer: GCodeSlicer.prusaSlicer,
      estimatedDuration: const Duration(minutes: 30),
      filamentLengthMm: null,
      filamentWeightG: null,
      layerHeightMm: 0.2,
      previewMetadata: null,
      previewImageBytes: null,
      warnings: const [],
      rawExtractedValues: const {},
    );

    await tester.pumpApp(const BatchGCodeImportPage(), [
      gcodeImportFilePickerProvider.overrideWithValue(_FakePicker(files)),
      gcodeImportServiceProvider.overrideWithValue(
        _FakeService(noWeightResult),
      ),
      isPremiumProvider.overrideWithValue(true),
    ]);

    final l10n = AppLocalizations.of(
      tester.element(find.byType(BatchGCodeImportPage)),
    )!;
    await tester.tap(find.text(l10n.batchGcodeImportPickButton));
    await tester.pumpAndSettle();

    expect(find.text('no-weight.gcode'), findsOneWidget);
    expect(find.text(l10n.batchGcodeImportNeedsDetailsLabel), findsOneWidget);
    expect(find.text(l10n.batchGcodeImportNeedsWeight), findsOneWidget);
    expect(find.text(l10n.batchGcodeImportApply), findsOneWidget);
    expect(find.text(l10n.batchGcodeImportAddButton), findsOneWidget);
  });

  testWidgets('fills in missing weight and continues', (tester) async {
    final files = [_file('no-weight.gcode')];
    final noWeightResult = GCodeImportResult(
      slicer: GCodeSlicer.prusaSlicer,
      estimatedDuration: const Duration(minutes: 30),
      filamentLengthMm: null,
      filamentWeightG: null,
      layerHeightMm: 0.2,
      previewMetadata: null,
      previewImageBytes: null,
      warnings: const [],
      rawExtractedValues: const {},
    );

    await tester.pumpApp(const BatchGCodeImportPage(), [
      gcodeImportFilePickerProvider.overrideWithValue(_FakePicker(files)),
      gcodeImportServiceProvider.overrideWithValue(
        _FakeService(noWeightResult),
      ),
      isPremiumProvider.overrideWithValue(true),
    ]);

    final l10n = AppLocalizations.of(
      tester.element(find.byType(BatchGCodeImportPage)),
    )!;
    await tester.tap(find.text(l10n.batchGcodeImportPickButton));
    await tester.pumpAndSettle();

    expect(find.text(l10n.batchGcodeImportNeedsDetailsLabel), findsOneWidget);
    expect(find.text(l10n.batchGcodeImportNeedsWeight), findsOneWidget);
    expect(find.text(l10n.batchGcodeImportAddButton), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, l10n.batchGcodeImportNeedsWeight),
      '5.0',
    );
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    final addButton = find.widgetWithText(
      ElevatedButton,
      l10n.batchGcodeImportAddButton,
    );
    await tester.ensureVisible(addButton);
    await tester.pumpAndSettle();
    expect(tester.widget<ElevatedButton>(addButton).onPressed, isNotNull);
    await tester.tap(addButton, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.byType(BatchCostingPage), findsOneWidget);
  });

  testWidgets('free users cannot start multi-file batch import', (
    tester,
  ) async {
    final files = [_file('one.gcode'), _file('two.gcode')];
    final paywallPresenter = FakePaywallPresenter();
    final service = _FakeService(successResult);

    await tester.pumpApp(const BatchGCodeImportPage(), [
      gcodeImportFilePickerProvider.overrideWithValue(_FakePicker(files)),
      gcodeImportServiceProvider.overrideWithValue(service),
      paywallPresenterProvider.overrideWithValue(paywallPresenter),
      isPremiumProvider.overrideWithValue(false),
    ]);

    final l10n = AppLocalizations.of(
      tester.element(find.byType(BatchGCodeImportPage)),
    )!;

    await tester.tap(find.text(l10n.batchGcodeImportPickButton));
    await tester.pumpAndSettle();

    expect(paywallPresenter.calls, 1);
    expect(service.importCalls, 0);
    expect(find.text('one.gcode'), findsNothing);
    expect(find.text('two.gcode'), findsNothing);
    expect(find.byType(BatchCostingPage), findsNothing);
  });

  testWidgets('shows importing then ready states', (tester) async {
    final files = [_file('slow.gcode')];
    await tester.pumpApp(const BatchGCodeImportPage(), [
      gcodeImportFilePickerProvider.overrideWithValue(_FakePicker(files)),
      gcodeImportServiceProvider.overrideWithValue(
        _SlowFakeService(successResult),
      ),
      isPremiumProvider.overrideWithValue(true),
    ]);

    final l10n = AppLocalizations.of(
      tester.element(find.byType(BatchGCodeImportPage)),
    )!;
    await tester.tap(find.text(l10n.batchGcodeImportPickButton));

    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('slow.gcode'), findsOneWidget);
    expect(find.text(l10n.batchGcodeImportAddButton), findsOneWidget);
  });

  testWidgets('choose files disabled while loading', (tester) async {
    final files = [_file('one.gcode'), _file('two.gcode')];
    await tester.pumpApp(const BatchGCodeImportPage(), [
      gcodeImportFilePickerProvider.overrideWithValue(_FakePicker(files)),
      gcodeImportServiceProvider.overrideWithValue(
        _SlowFakeService(successResult),
      ),
      isPremiumProvider.overrideWithValue(true),
    ]);

    final l10n = AppLocalizations.of(
      tester.element(find.byType(BatchGCodeImportPage)),
    )!;
    final button = find.widgetWithText(
      ElevatedButton,
      l10n.batchGcodeImportPickButton,
    );
    expect(tester.widget<ElevatedButton>(button).onPressed, isNotNull);

    await tester.tap(button);
    await tester.pump();
    expect(tester.widget<ElevatedButton>(button).onPressed, isNull);

    await tester.pump(const Duration(seconds: 1));
    expect(tester.widget<ElevatedButton>(button).onPressed, isNotNull);
  });
}

GCodePickedFile _file(String name) => GCodePickedFile(
  name: name,
  path: '/tmp/$name',
  readAsBytes: () async => Uint8List.fromList('G1 X1 Y1'.codeUnits),
);

final successResult = GCodeImportResult(
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
  final GCodeImportResult? result;
  var importCalls = 0;
  @override
  Future<GCodeImportResult> importPickedFile(GCodePickedFile file) async {
    importCalls += 1;
    if (result == null) throw StateError('fail');
    return result!;
  }
}

class _SlowFakeService extends GCodeImportService {
  _SlowFakeService(this.result);
  final GCodeImportResult result;
  @override
  Future<GCodeImportResult> importPickedFile(GCodePickedFile file) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return result;
  }
}
