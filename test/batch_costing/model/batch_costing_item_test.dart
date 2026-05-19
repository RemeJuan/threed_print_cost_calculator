import 'package:flutter_test/flutter_test.dart';

import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_result.dart';

void main() {
  test('creates manual batch items with required values', () {
    final item = BatchCostingItem.manual(
      id: 'item-1',
      displayName: 'Benchy',
      quantity: 2,
      printWeightG: 34.5,
      printDuration: const Duration(hours: 1, minutes: 20),
    );

    expect(item.id, 'item-1');
    expect(item.displayName, 'Benchy');
    expect(item.quantity, 2);
    expect(item.printWeightG, 34.5);
    expect(item.printDuration, const Duration(hours: 1, minutes: 20));
    expect(item.sourceType, BatchCostingItemSourceType.manual);
  });

  test('creates gcode batch items from parsed import values', () {
    final rawValues = <String, String>{'estimatedDuration': '95m'};
    final item = BatchCostingItem.fromGCodeImport(
      id: 'item-2',
      displayName: 'benchy.gcode',
      quantity: 3,
      importResult: GCodeImportResult(
        slicer: GCodeSlicer.prusaSlicer,
        estimatedDuration: const Duration(minutes: 95),
        filamentLengthMm: 1200,
        filamentWeightG: 42.7,
        layerHeightMm: 0.2,
        previewMetadata: null,
        previewImageBytes: null,
        warnings: const [],
        rawExtractedValues: rawValues,
        hasSafePreview: true,
      ),
      sourceFileName: 'benchy.gcode',
    );

    expect(item.printDuration, const Duration(minutes: 95));
    expect(item.printWeightG, 42.7);
    expect(item.sourceType, BatchCostingItemSourceType.gcode);
    expect(item.importMetadata?.hasSafePreview, isTrue);
    expect(item.importMetadata?.rawExtractedValues['estimatedDuration'], '95m');

    final metadata = item.importMetadata!;
    rawValues['estimatedDuration'] = '100m';
    expect(metadata.rawExtractedValues['estimatedDuration'], '95m');
    expect(
      () => metadata.rawExtractedValues['new'] = 'value',
      throwsUnsupportedError,
    );
  });

  test('rejects invalid batch quantities', () {
    expect(
      () => BatchCostingItem.manual(
        id: 'bad',
        displayName: 'Bad',
        quantity: 0,
        printWeightG: 1,
        printDuration: Duration.zero,
      ),
      throwsArgumentError,
    );
  });

  test('fromGCodeImport accepts null duration and weight', () {
    final item = BatchCostingItem.fromGCodeImport(
      id: 'partial',
      displayName: 'partial.gcode',
      quantity: 1,
      importResult: GCodeImportResult(
        slicer: GCodeSlicer.unknown,
        estimatedDuration: null,
        filamentLengthMm: null,
        filamentWeightG: null,
        layerHeightMm: null,
        previewMetadata: null,
        previewImageBytes: null,
        warnings: const [],
        rawExtractedValues: const {},
      ),
    );

    expect(item.printWeightG, isNull);
    expect(item.printDuration, isNull);
    expect(item.sourceType, BatchCostingItemSourceType.gcode);
    expect(item.quantity, 1);
  });

  test('fromGCodeImport accepts only duration without weight', () {
    final item = BatchCostingItem.fromGCodeImport(
      id: 'dur-only',
      displayName: 'dur.gcode',
      quantity: 1,
      importResult: GCodeImportResult(
        slicer: GCodeSlicer.prusaSlicer,
        estimatedDuration: const Duration(hours: 2),
        filamentLengthMm: null,
        filamentWeightG: null,
        layerHeightMm: null,
        previewMetadata: null,
        previewImageBytes: null,
        warnings: const [],
        rawExtractedValues: const {},
      ),
    );

    expect(item.printDuration, const Duration(hours: 2));
    expect(item.printWeightG, isNull);
  });

  test('fromGCodeImport accepts only weight without duration', () {
    final item = BatchCostingItem.fromGCodeImport(
      id: 'wgt-only',
      displayName: 'wgt.gcode',
      quantity: 1,
      importResult: GCodeImportResult(
        slicer: GCodeSlicer.prusaSlicer,
        estimatedDuration: null,
        filamentLengthMm: 1200,
        filamentWeightG: 42.7,
        layerHeightMm: null,
        previewMetadata: null,
        previewImageBytes: null,
        warnings: const [],
        rawExtractedValues: const {},
      ),
    );

    expect(item.printDuration, isNull);
    expect(item.printWeightG, 42.7);
  });
}
