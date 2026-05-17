import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:threed_print_cost_calculator/batch_costing/batch_gcode_import_page.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_file_picker.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_result.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_service.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/providers/batch_costing_visibility.dart';

import '../helpers/helpers.dart';

void main() {
  setUpAll(setupTest);

  testWidgets('hides flow when batch costing disabled', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpApp(const BatchGCodeImportPage());
    expect(find.text('Import batch G-code'), findsNothing);
    expect(find.text('Choose files'), findsNothing);
  });

  testWidgets('imports multiple files and seeds batch items', (tester) async {
    SharedPreferences.setMockInitialValues({batchCostingEnabledPreferenceKey: true});
    final files = [
      _file('one.gcode'),
      _file('two.gcode'),
    ];
    await tester.pumpApp(
      const BatchGCodeImportPage(),
      [
        gcodeImportFilePickerProvider.overrideWithValue(_FakePicker(files)),
        gcodeImportServiceProvider.overrideWithValue(_FakeService(successResult)),
      ],
    );

    final l10n = AppLocalizations.of(tester.element(find.byType(BatchGCodeImportPage)))!;
    await tester.tap(find.text(l10n.batchGcodeImportPickButton));
    await tester.pumpAndSettle();

    expect(find.text('one.gcode'), findsOneWidget);
    expect(find.text('two.gcode'), findsOneWidget);
    expect(find.text(l10n.batchGcodeImportContinueButton), findsOneWidget);
  });

  testWidgets('shows failures and blocks continue when all fail', (tester) async {
    SharedPreferences.setMockInitialValues({batchCostingEnabledPreferenceKey: true});
    await tester.pumpApp(
      const BatchGCodeImportPage(),
      [
        gcodeImportFilePickerProvider.overrideWithValue(_FakePicker([_file('bad.gcode')])),
        gcodeImportServiceProvider.overrideWithValue(_FakeService(null)),
      ],
    );

    final l10n = AppLocalizations.of(tester.element(find.byType(BatchGCodeImportPage)))!;
    await tester.tap(find.text(l10n.batchGcodeImportPickButton));
    await tester.pumpAndSettle();

    expect(find.textContaining(l10n.batchGcodeImportParseFailure), findsOneWidget);
    expect(find.text(l10n.batchGcodeImportContinueButton), findsNothing);
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
