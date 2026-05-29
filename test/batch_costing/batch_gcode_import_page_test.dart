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
    await tester.pumpApp(const BatchGCodeImportPage(), [
      gcodeImportFilePickerProvider.overrideWithValue(_FakePicker(files)),
      gcodeImportServiceProvider.overrideWithValue(_FakeService(successResult)),
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

  testWidgets('shows imported details sheet from ready row', (tester) async {
    await tester.pumpApp(const BatchGCodeImportPage(), [
      gcodeImportFilePickerProvider.overrideWithValue(
        _FakePicker([_file('preview-a.gcode'), _file('preview-b.gcode')]),
      ),
      gcodeImportServiceProvider.overrideWithValue(_FakeService(successResult)),
      isPremiumProvider.overrideWithValue(true),
    ]);

    final l10n = AppLocalizations.of(
      tester.element(find.byType(BatchGCodeImportPage)),
    )!;
    await tester.tap(find.text(l10n.batchGcodeImportPickButton));
    await tester.pumpAndSettle();

    await tester.tap(
      find
          .byKey(const ValueKey<String>('batch_gcode_import.details.button'))
          .first,
    );
    await tester.pumpAndSettle();

    expect(find.text('preview-a.gcode'), findsWidgets);
    expect(find.text(l10n.importGcodeSummaryTitle), findsOneWidget);
    expect(find.text(l10n.importGcodePreviewUnavailable), findsOneWidget);
  });

  testWidgets('shows failures and blocks continue when single import fails', (
    tester,
  ) async {
    await tester.pumpApp(const BatchGCodeImportPage(), [
      gcodeImportFilePickerProvider.overrideWithValue(
        _FakePicker([_file('bad.gcode')]),
      ),
      gcodeImportServiceProvider.overrideWithValue(_FakeService(null)),
      isPremiumProvider.overrideWithValue(true),
    ]);

    final l10n = AppLocalizations.of(
      tester.element(find.byType(BatchGCodeImportPage)),
    )!;
    await tester.tap(find.text(l10n.batchGcodeImportPickButton));
    await tester.pumpAndSettle();

    expect(
      find.textContaining(l10n.batchGcodeImportParseFailure),
      findsOneWidget,
    );
    expect(find.text(l10n.batchGcodeImportContinueButton), findsNothing);
  });

  testWidgets('free users cannot start multi-file batch import', (
    tester,
  ) async {
    final files = [_file('one.gcode'), _file('two.gcode')];
    final paywallPresenter = FakePaywallPresenter();

    await tester.pumpApp(const BatchGCodeImportPage(), [
      gcodeImportFilePickerProvider.overrideWithValue(_FakePicker(files)),
      gcodeImportServiceProvider.overrideWithValue(_FakeService(successResult)),
      paywallPresenterProvider.overrideWithValue(paywallPresenter),
      isPremiumProvider.overrideWithValue(false),
    ]);

    final l10n = AppLocalizations.of(
      tester.element(find.byType(BatchGCodeImportPage)),
    )!;

    await tester.tap(find.text(l10n.batchGcodeImportPickButton));
    await tester.pumpAndSettle();

    expect(paywallPresenter.calls, 1);
    expect(find.text('one.gcode'), findsNothing);
    expect(find.text('two.gcode'), findsNothing);
    expect(find.byType(BatchCostingPage), findsNothing);
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

    // Should show needs-details with weight field
    expect(find.text(l10n.batchGcodeImportNeedsDetailsLabel), findsOneWidget);
    expect(find.text(l10n.batchGcodeImportNeedsWeight), findsOneWidget);
    expect(find.text(l10n.batchGcodeImportAddButton), findsOneWidget);

    // Fill in weight
    await tester.enterText(
      find.widgetWithText(TextFormField, l10n.batchGcodeImportNeedsWeight),
      '5.0',
    );
    await tester.pump();

    // Tap Apply
    await tester.tap(find.text(l10n.batchGcodeImportApply));
    await tester.pumpAndSettle();

    // Should still show add-to-batch CTA
    expect(find.text(l10n.batchGcodeImportAddButton), findsOneWidget);
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

    // Pump — parse in progress
    await tester.pump();
    // Let the fake delay complete
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

    // Button is enabled before tapping
    final button = find.widgetWithText(
      ElevatedButton,
      l10n.batchGcodeImportPickButton,
    );
    expect(tester.widget<ElevatedButton>(button).onPressed, isNotNull);

    await tester.tap(button);

    // After pump, button should be disabled while loading
    await tester.pump();
    expect(tester.widget<ElevatedButton>(button).onPressed, isNull);

    // Let loading finish
    await tester.pump(const Duration(seconds: 1));
    expect(tester.widget<ElevatedButton>(button).onPressed, isNotNull);
  });

  testWidgets('deletes ready imported row', (tester) async {
    final files = [_file('one.gcode'), _file('two.gcode')];
    await tester.pumpApp(const BatchGCodeImportPage(), [
      gcodeImportFilePickerProvider.overrideWithValue(_FakePicker(files)),
      gcodeImportServiceProvider.overrideWithValue(_FakeService(successResult)),
      isPremiumProvider.overrideWithValue(true),
    ]);

    final l10n = AppLocalizations.of(
      tester.element(find.byType(BatchGCodeImportPage)),
    )!;
    await tester.tap(find.text(l10n.batchGcodeImportPickButton));
    await tester.pumpAndSettle();

    expect(find.text('one.gcode'), findsOneWidget);
    expect(find.text('two.gcode'), findsOneWidget);
    expect(find.text(l10n.batchGcodeImportContinueButton), findsOneWidget);

    // Delete first row
    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();

    expect(find.text('one.gcode'), findsNothing);
    expect(find.text('two.gcode'), findsOneWidget);
    // Continue should still be visible since 'two.gcode' is ready
    expect(find.text(l10n.batchGcodeImportContinueButton), findsOneWidget);
  });

  testWidgets(
    'deleting finished row while another import is pending stays stable',
    (tester) async {
      final files = [_file('fast.gcode'), _file('slow.gcode')];
      await tester.pumpApp(const BatchGCodeImportPage(), [
        gcodeImportFilePickerProvider.overrideWithValue(_FakePicker(files)),
        gcodeImportServiceProvider.overrideWithValue(
          _SequencedFakeService(
            [successResult, successResult],
            [Duration.zero, const Duration(milliseconds: 400)],
          ),
        ),
        isPremiumProvider.overrideWithValue(true),
      ]);

      final l10n = AppLocalizations.of(
        tester.element(find.byType(BatchGCodeImportPage)),
      )!;
      await tester.tap(find.text(l10n.batchGcodeImportPickButton));
      await tester.pump();
      await tester.pump();

      expect(find.text('fast.gcode'), findsOneWidget);
      expect(find.text('slow.gcode'), findsOneWidget);
      expect(find.text(l10n.batchGcodeImportReadyLabel), findsOneWidget);
      expect(find.text(l10n.batchGcodeImportImportingLabel), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pump();

      expect(find.text('fast.gcode'), findsNothing);
      expect(find.text('slow.gcode'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.text('slow.gcode'), findsOneWidget);
      expect(find.text(l10n.batchGcodeImportReadyLabel), findsOneWidget);
      expect(find.text(l10n.batchGcodeImportContinueButton), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('deletes needs-details row', (tester) async {
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
    final files = [_file('no-weight.gcode')];
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

    // Find and tap the delete button in the needs-details card
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(find.text('no-weight.gcode'), findsNothing);
    expect(find.text(l10n.batchGcodeImportContinueButton), findsNothing);
    expect(find.text(l10n.batchGcodeImportPickButton), findsOneWidget);
  });

  testWidgets('delete all rows returns to empty state', (tester) async {
    final files = [_file('one.gcode')];
    await tester.pumpApp(const BatchGCodeImportPage(), [
      gcodeImportFilePickerProvider.overrideWithValue(_FakePicker(files)),
      gcodeImportServiceProvider.overrideWithValue(_FakeService(successResult)),
      isPremiumProvider.overrideWithValue(true),
    ]);

    final l10n = AppLocalizations.of(
      tester.element(find.byType(BatchGCodeImportPage)),
    )!;
    await tester.tap(find.text(l10n.batchGcodeImportPickButton));
    await tester.pumpAndSettle();

    expect(find.text('one.gcode'), findsOneWidget);

    // Delete the only row
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(find.text('one.gcode'), findsNothing);
    expect(find.text(l10n.batchGcodeImportContinueButton), findsNothing);
    // Pick button should still be visible
    expect(find.text(l10n.batchGcodeImportPickButton), findsOneWidget);
  });

  testWidgets('shows quantity hint text', (tester) async {
    await tester.pumpApp(const BatchGCodeImportPage(), [
      isPremiumProvider.overrideWithValue(true),
    ]);

    final l10n = AppLocalizations.of(
      tester.element(find.byType(BatchGCodeImportPage)),
    )!;
    expect(find.text(l10n.batchGcodeImportQuantityHint), findsOneWidget);
  });

  testWidgets('duplicate file selection does not create duplicate rows', (
    tester,
  ) async {
    final files = [_file('one.gcode'), _file('two.gcode')];
    final picker = _FakePicker(files);
    await tester.pumpApp(const BatchGCodeImportPage(), [
      gcodeImportFilePickerProvider.overrideWithValue(picker),
      gcodeImportServiceProvider.overrideWithValue(_FakeService(successResult)),
      isPremiumProvider.overrideWithValue(true),
    ]);

    final l10n = AppLocalizations.of(
      tester.element(find.byType(BatchGCodeImportPage)),
    )!;

    // First pick
    await tester.tap(find.text(l10n.batchGcodeImportPickButton));
    await tester.pumpAndSettle();
    expect(find.text('one.gcode'), findsOneWidget);
    expect(find.text('two.gcode'), findsOneWidget);

    // Second pick with same files — duplicates should be skipped
    await tester.tap(find.text(l10n.batchGcodeImportPickButton));
    await tester.pumpAndSettle();

    // Still only 2 rows, not 4
    expect(find.text('one.gcode'), findsOneWidget);
    expect(find.text('two.gcode'), findsOneWidget);
    // Continue button still visible since originals are ready
    expect(find.text(l10n.batchGcodeImportContinueButton), findsOneWidget);
  });

  testWidgets('duplicate selection shows snackbar', (tester) async {
    final files = [_file('one.gcode')];
    final picker = _FakePicker(files);
    await tester.pumpApp(const BatchGCodeImportPage(), [
      gcodeImportFilePickerProvider.overrideWithValue(picker),
      gcodeImportServiceProvider.overrideWithValue(_FakeService(successResult)),
      isPremiumProvider.overrideWithValue(true),
    ]);

    final l10n = AppLocalizations.of(
      tester.element(find.byType(BatchGCodeImportPage)),
    )!;

    await tester.tap(find.text(l10n.batchGcodeImportPickButton));
    await tester.pumpAndSettle();

    // Second pick with same file
    await tester.tap(find.text(l10n.batchGcodeImportPickButton));
    await tester.pumpAndSettle();

    expect(find.text(l10n.batchGcodeImportDuplicateMessage), findsOneWidget);
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
  @override
  Future<GCodeImportResult> importPickedFile(GCodePickedFile file) async {
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

class _SequencedFakeService extends GCodeImportService {
  _SequencedFakeService(this.results, this.delays);

  final List<GCodeImportResult?> results;
  final List<Duration> delays;
  int _callCount = 0;

  @override
  Future<GCodeImportResult> importPickedFile(GCodePickedFile file) async {
    final index = _callCount++;
    final delay = delays[index];
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    final result = results[index];
    if (result == null) throw StateError('fail');
    return result;
  }
}
