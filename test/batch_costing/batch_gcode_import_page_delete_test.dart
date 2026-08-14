import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/batch_costing/batch_gcode_import_page.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_file_picker.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_result.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_service.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';

import 'dart:typed_data';

import '../helpers/helpers.dart';

void main() {
  setUpAll(setupTest);

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

    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();

    expect(find.text('one.gcode'), findsNothing);
    expect(find.text('two.gcode'), findsOneWidget);
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

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(find.text('one.gcode'), findsNothing);
    expect(find.text(l10n.batchGcodeImportContinueButton), findsNothing);
    expect(find.text(l10n.batchGcodeImportPickButton), findsOneWidget);
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
