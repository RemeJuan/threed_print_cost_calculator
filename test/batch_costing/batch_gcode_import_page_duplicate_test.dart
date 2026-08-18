import 'dart:typed_data';

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

    await tester.tap(find.text(l10n.batchGcodeImportPickButton));
    await tester.pumpAndSettle();
    expect(find.text('one.gcode'), findsOneWidget);
    expect(find.text('two.gcode'), findsOneWidget);

    await tester.tap(find.text(l10n.batchGcodeImportPickButton));
    await tester.pumpAndSettle();

    expect(find.text('one.gcode'), findsOneWidget);
    expect(find.text('two.gcode'), findsOneWidget);
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
