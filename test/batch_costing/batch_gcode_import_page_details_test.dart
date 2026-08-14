import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/batch_costing/batch_gcode_import_page.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_file_picker.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_result.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_service.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';

import '../helpers/helpers.dart';

void main() {
  setUpAll(setupTest);

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

  testWidgets('shows quantity hint text', (tester) async {
    await tester.pumpApp(const BatchGCodeImportPage(), [
      isPremiumProvider.overrideWithValue(true),
    ]);

    final l10n = AppLocalizations.of(
      tester.element(find.byType(BatchGCodeImportPage)),
    )!;
    expect(find.text(l10n.batchGcodeImportQuantityHint), findsOneWidget);
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
