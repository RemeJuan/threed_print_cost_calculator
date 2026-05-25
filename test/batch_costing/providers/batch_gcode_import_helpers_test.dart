import 'package:flutter_test/flutter_test.dart';

import 'package:threed_print_cost_calculator/batch_costing/helpers/batch_gcode_import_helpers.dart';
import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/model/batch_import_state.dart';
import 'package:threed_print_cost_calculator/gcode_import/model/gcode_import_file.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_result.dart';

GCodePickedFile _file(String name, {String? path}) =>
    GCodePickedFile(name: name, path: path ?? '/dev/null/$name', size: 100);

GCodeImportResult _result({
  double? weightG,
  Duration? duration,
  GCodeSlicer slicer = GCodeSlicer.orcaSlicer,
}) => GCodeImportResult(
  slicer: slicer,
  estimatedDuration: duration,
  filamentLengthMm: null,
  filamentWeightG: weightG,
  layerHeightMm: null,
  previewMetadata: null,
  previewImageBytes: null,
  warnings: const [],
  rawExtractedValues: const {},
);

void main() {
  group('parseImportOverrideDetails', () {
    test('returns existing values when no missing fields', () {
      final result = parseImportOverrideDetails(
        existingWeight: 15.0,
        existingDuration: const Duration(minutes: 30),
        missingWeight: false,
        weightText: '',
        missingDuration: false,
        durationText: '',
      );
      expect(result, isNotNull);
      expect(result!.weight, 15.0);
      expect(result.duration, const Duration(minutes: 30));
    });

    test('parses weight override when missing', () {
      final result = parseImportOverrideDetails(
        existingWeight: null,
        existingDuration: const Duration(minutes: 30),
        missingWeight: true,
        weightText: '25.5',
        missingDuration: false,
        durationText: '',
      );
      expect(result, isNotNull);
      expect(result!.weight, 25.5);
      expect(result.duration, const Duration(minutes: 30));
    });

    test('parses duration override when missing', () {
      final result = parseImportOverrideDetails(
        existingWeight: 15.0,
        existingDuration: null,
        missingWeight: false,
        weightText: '',
        missingDuration: true,
        durationText: '45',
      );
      expect(result, isNotNull);
      expect(result!.weight, 15.0);
      expect(result.duration, const Duration(minutes: 45));
    });

    test('returns null for invalid weight input', () {
      expect(
        parseImportOverrideDetails(
          existingWeight: null,
          existingDuration: null,
          missingWeight: true,
          weightText: 'abc',
          missingDuration: false,
          durationText: '',
        ),
        isNull,
      );
    });

    test('returns null for non-positive weight', () {
      expect(
        parseImportOverrideDetails(
          existingWeight: null,
          existingDuration: null,
          missingWeight: true,
          weightText: '0',
          missingDuration: false,
          durationText: '',
        ),
        isNull,
      );
    });

    test('returns null for invalid duration input', () {
      expect(
        parseImportOverrideDetails(
          existingWeight: null,
          existingDuration: null,
          missingWeight: false,
          weightText: '',
          missingDuration: true,
          durationText: 'abc',
        ),
        isNull,
      );
    });
  });

  group('findItemById', () {
    test('finds item by id', () {
      final List<BatchCostingItem> items = [
        BatchCostingItem.manual(
          id: 'a',
          displayName: 'A',
          quantity: 1,
          printWeightG: 10,
          printDuration: const Duration(minutes: 10),
        ),
        BatchCostingItem.manual(
          id: 'b',
          displayName: 'B',
          quantity: 1,
          printWeightG: 20,
          printDuration: const Duration(minutes: 20),
        ),
      ];
      expect(findItemById(items, 'a')?.displayName, 'A');
      expect(findItemById(items, 'b')?.displayName, 'B');
    });

    test('returns null for missing id', () {
      final items = <BatchCostingItem>[];
      expect(findItemById(items, 'x'), isNull);
    });

    test('returns null for null id', () {
      final items = <BatchCostingItem>[];
      expect(findItemById(items, null), isNull);
    });
  });

  group('isDuplicateFile', () {
    test('detects duplicate by path in single import', () {
      final file = _file('a.gcode', path: '/path/a.gcode');
      final single = BatchSingleImport(
        file: file,
        batchItemId: '1',
        result: _result(),
        missingWeight: false,
        missingDuration: false,
      );
      expect(isDuplicateFile(file, single, []), isTrue);
    });

    test('detects duplicate by name in single import when path differs', () {
      final file = _file('a.gcode', path: '/path/a.gcode');
      final existing = _file('a.gcode', path: '/other/a.gcode');
      final single = BatchSingleImport(
        file: existing,
        batchItemId: '1',
        result: _result(),
        missingWeight: false,
        missingDuration: false,
      );
      expect(isDuplicateFile(file, single, []), isTrue);
    });

    test('detects duplicate by path in rows', () {
      final file = _file('a.gcode', path: '/path/a.gcode');
      final row = BatchImportRow(file);
      expect(isDuplicateFile(file, null, [row]), isTrue);
    });

    test('returns false for unique file', () {
      final file = _file('a.gcode');
      final existing = _file('b.gcode');
      final row = BatchImportRow(existing);
      expect(isDuplicateFile(file, null, [row]), isFalse);
    });
  });

  group('buildImportResult', () {
    test('returns original result when no overrides', () {
      final result = _result(
        weightG: 15.0,
        duration: const Duration(minutes: 30),
      );
      final single = BatchSingleImport(
        file: _file('a.gcode'),
        batchItemId: '1',
        result: result,
        missingWeight: false,
        missingDuration: false,
      );
      expect(buildImportResult(single), same(result));
    });

    test('merges override weight and duration', () {
      final result = _result(
        weightG: 15.0,
        duration: const Duration(minutes: 30),
      );
      final single =
          BatchSingleImport(
              file: _file('a.gcode'),
              batchItemId: '1',
              result: result,
              missingWeight: false,
              missingDuration: false,
            )
            ..overrideWeightG = 20.0
            ..overrideDuration = const Duration(minutes: 45);
      final built = buildImportResult(single);
      expect(built.filamentWeightG, 20.0);
      expect(built.estimatedDuration, const Duration(minutes: 45));
      expect(built.slicer, GCodeSlicer.orcaSlicer);
    });
  });

  group('buildCostingItem', () {
    test('creates BatchCostingItem from import result', () {
      final result = _result(
        weightG: 15.0,
        duration: const Duration(minutes: 30),
      );
      final file = _file('test.gcode', path: '/path/test.gcode');
      final item = buildCostingItem(id: 'item-1', file: file, result: result);

      expect(item.id, 'item-1');
      expect(item.displayName, 'test.gcode');
      expect(item.quantity, 1);
      expect(item.printWeightG, 15.0);
      expect(item.printDuration, const Duration(minutes: 30));
      expect(item.sourceType, BatchCostingItemSourceType.gcode);
    });
  });
}
