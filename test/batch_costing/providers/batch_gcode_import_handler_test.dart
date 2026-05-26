import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/batch_costing/batch_gcode_import_page.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_file_picker.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_result.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_service.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';

import '../../helpers/helpers.dart';

void main() {
  setUpAll(setupTest);

  testWidgets('empty picker result does not change state', (tester) async {
    await tester.pumpApp(const BatchGCodeImportPage(), [
      gcodeImportFilePickerProvider.overrideWithValue(_EmptyPicker()),
      gcodeImportServiceProvider.overrideWithValue(_FakeService(null)),
      isPremiumProvider.overrideWithValue(true),
    ]);

    final l10n = AppLocalizations.of(
      tester.element(find.byType(BatchGCodeImportPage)),
    )!;

    await tester.tap(find.text(l10n.batchGcodeImportPickButton));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<ElevatedButton>(
            find.widgetWithText(
              ElevatedButton,
              l10n.batchGcodeImportPickButton,
            ),
          )
          .onPressed,
      isNotNull,
    );
    expect(find.text(l10n.batchGcodeImportParseFailure), findsNothing);
  });

  testWidgets('unmount during import does not crash', (tester) async {
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
    await tester.pump(const Duration(milliseconds: 50));

    await tester.pumpWidget(Container());
    await tester.pump(const Duration(seconds: 1));

    expect(tester.takeException(), isNull);
  });

  testWidgets('multi-file import tracks ready and needs-details counts', (
    tester,
  ) async {
    final noWeightResult = GCodeImportResult(
      slicer: GCodeSlicer.prusaSlicer,
      estimatedDuration: null,
      filamentLengthMm: null,
      filamentWeightG: null,
      layerHeightMm: 0.2,
      previewMetadata: null,
      previewImageBytes: null,
      warnings: const [],
      rawExtractedValues: const {},
    );

    final files = [_file('a.gcode'), _file('b.gcode')];
    await tester.pumpApp(const BatchGCodeImportPage(), [
      gcodeImportFilePickerProvider.overrideWithValue(_FakePicker(files)),
      gcodeImportServiceProvider.overrideWithValue(
        _SequencedFakeService(
          [successResult, noWeightResult],
          [Duration.zero, Duration.zero],
        ),
      ),
      isPremiumProvider.overrideWithValue(true),
    ]);

    final l10n = AppLocalizations.of(
      tester.element(find.byType(BatchGCodeImportPage)),
    )!;

    await tester.tap(find.text(l10n.batchGcodeImportPickButton));
    await tester.pumpAndSettle();

    expect(find.text('a.gcode'), findsOneWidget);
    expect(find.text(l10n.batchGcodeImportReadyLabel), findsOneWidget);
    expect(find.text(l10n.batchGcodeImportNeedsDetailsLabel), findsOneWidget);
  });

  testWidgets('multi-file import marks failed row on service error', (
    tester,
  ) async {
    final files = [_file('good.gcode'), _file('bad.gcode')];
    await tester.pumpApp(const BatchGCodeImportPage(), [
      gcodeImportFilePickerProvider.overrideWithValue(_FakePicker(files)),
      gcodeImportServiceProvider.overrideWithValue(
        _SequencedFakeService(
          [successResult, null],
          [Duration.zero, Duration.zero],
        ),
      ),
      isPremiumProvider.overrideWithValue(true),
    ]);

    final l10n = AppLocalizations.of(
      tester.element(find.byType(BatchGCodeImportPage)),
    )!;

    await tester.tap(find.text(l10n.batchGcodeImportPickButton));
    await tester.pumpAndSettle();

    expect(find.text('good.gcode'), findsOneWidget);
    expect(find.text(l10n.batchGcodeImportReadyLabel), findsOneWidget);
    expect(
      find.textContaining(l10n.batchGcodeImportParseFailure),
      findsOneWidget,
    );
  });

  testWidgets('single-file import parse failure shows error message', (
    tester,
  ) async {
    final files = [_file('bad.gcode')];
    await tester.pumpApp(const BatchGCodeImportPage(), [
      gcodeImportFilePickerProvider.overrideWithValue(_FakePicker(files)),
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

  testWidgets('single-file import applies weight override then adds to batch', (
    tester,
  ) async {
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
      gcodeImportFilePickerProvider.overrideWithValue(
        _FakePicker([_file('no-weight.gcode')]),
      ),
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

    expect(find.text(l10n.batchGcodeImportNeedsWeight), findsOneWidget);
    expect(find.text(l10n.batchGcodeImportAddButton), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, l10n.batchGcodeImportNeedsWeight),
      '5.0',
    );
    await tester.pump();

    // Ensure Apply visible then tap it
    await tester.ensureVisible(find.text(l10n.batchGcodeImportApply));
    await tester.pump();
    await tester.tap(find.text(l10n.batchGcodeImportApply));
    await tester.pumpAndSettle();

    expect(find.text(l10n.batchGcodeImportAddButton), findsOneWidget);
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

class _EmptyPicker extends GCodeImportFilePicker {
  @override
  Future<GCodePickedFile?> pick() async => null;
  @override
  Future<List<GCodePickedFile>> pickMany() async => [];
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
