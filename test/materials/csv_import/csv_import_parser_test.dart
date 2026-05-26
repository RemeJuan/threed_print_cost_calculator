import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/materials/csv_import/csv_import_parser.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  group('parseCsvLine', () {
    test('splits basic comma-separated values', () {
      expect(parseCsvLine('a,b,c'), ['a', 'b', 'c']);
    });

    test('handles quoted fields', () {
      expect(parseCsvLine('"a b",c'), ['a b', 'c']);
    });

    test('handles escaped quotes inside quoted fields', () {
      expect(parseCsvLine('"a ""b""",c'), ['a "b"', 'c']);
    });

    test('handles empty fields', () {
      expect(parseCsvLine('a,,c'), ['a', '', 'c']);
    });

    test('handles trailing comma', () {
      expect(parseCsvLine('a,'), ['a', '']);
    });

    test('handles single value', () {
      expect(parseCsvLine('hello'), ['hello']);
    });
  });

  group('parseImportRow', () {
    final validColIndex = <String, int>{
      'name': 0,
      'brand': 1,
      'material_type': 2,
      'color': 3,
      'color_hex': 4,
      'spool_weight': 5,
      'remaining_weight': 6,
      'spool_cost': 7,
      'notes': 8,
    };

    ImportRow parse(List<String> values, {int line = 1}) {
      return parseImportRow(values, validColIndex, line, l10n);
    }

    test('parses valid row without errors', () {
      final values = [
        'PLA Pro+',
        'Sunlu',
        'PLA',
        'Black',
        '',
        '1000',
        '950',
        '24.99',
        'test notes',
      ];
      final row = parse(values);
      expect(row.lineNumber, 1);
      expect(row.name, 'PLA Pro+');
      expect(row.brand, 'Sunlu');
      expect(row.materialType, 'PLA');
      expect(row.color, 'Black');
      expect(row.colorHex, '');
      expect(row.spoolWeight, 1000);
      expect(row.remainingWeight, 950);
      expect(row.cost, 24.99);
      expect(row.notes, 'test notes');
      expect(row.errors, isEmpty);
    });

    test('reports error when name is empty', () {
      final values = ['', 'Sunlu', '', 'Black', '', '1000', '', '24.99', ''];
      final row = parse(values);
      expect(row.errors, contains(l10n.csvNameRequiredError));
    });

    test('reports error when color is empty', () {
      final values = ['PLA', 'Sunlu', '', '', '', '1000', '', '24.99', ''];
      final row = parse(values);
      expect(row.errors, contains(l10n.csvColorRequiredError));
    });

    test('reports error when spool weight is empty', () {
      final values = ['PLA', 'Sunlu', '', 'Black', '', '', '', '24.99', ''];
      final row = parse(values);
      expect(row.errors, contains(l10n.csvSpoolWeightRequiredError));
    });

    test('reports error when spool weight is not positive', () {
      final values = ['PLA', 'Sunlu', '', 'Black', '', '0', '', '24.99', ''];
      final row = parse(values);
      expect(row.errors, contains(l10n.csvSpoolWeightPositiveError));
    });

    test('reports error when cost is empty', () {
      final values = ['PLA', 'Sunlu', '', 'Black', '', '1000', '', '', ''];
      final row = parse(values);
      expect(row.errors, contains(l10n.csvCostRequiredError));
    });

    test('reports error when cost is not positive', () {
      final values = ['PLA', 'Sunlu', '', 'Black', '', '1000', '', '0', ''];
      final row = parse(values);
      expect(row.errors, contains(l10n.csvCostPositiveError));
    });

    test('defaults remaining weight to spool weight when empty', () {
      final values = ['PLA', 'Sunlu', '', 'Black', '', '1000', '', '24.99', ''];
      final row = parse(values);
      expect(row.remainingWeight, 1000);
    });

    test('handles column index not found gracefully', () {
      final colIndex = <String, int>{'name': 0};
      // Accessing column beyond values length
      final row = parseImportRow(['PLA'], colIndex, 1, l10n);
      expect(row.name, 'PLA');
      expect(row.brand, '');
    });

    test('trims whitespace from values', () {
      final values = [
        ' PLA ',
        ' Sunlu ',
        '',
        ' Black ',
        '',
        '1000',
        '',
        '24.99',
        '',
      ];
      final row = parse(values);
      expect(row.name, 'PLA');
      expect(row.brand, 'Sunlu');
      expect(row.color, 'Black');
    });
  });

  group('parseCsvContent', () {
    test('parses header and data rows', () {
      final content =
          'name,brand,material_type,color,color_hex,spool_weight,remaining_weight,spool_cost,notes\n'
          'PLA Pro+,Sunlu,PLA,Black,,1000,950,24.99,\n'
          'PETG,Overture,PETG,White,,1000,1000,29.99,';
      final rows = parseCsvContent(content, l10n);
      expect(rows.length, 2);
      expect(rows[0].name, 'PLA Pro+');
      expect(rows[0].errors, isEmpty);
      expect(rows[1].name, 'PETG');
      expect(rows[1].errors, isEmpty);
    });

    test('returns empty list for empty content', () {
      expect(parseCsvContent('', l10n), isEmpty);
    });

    test('returns empty list for whitespace-only content', () {
      expect(parseCsvContent('  \n  ', l10n), isEmpty);
    });

    test('returns empty list for header-only content', () {
      final content =
          'name,brand,material_type,color,color_hex,spool_weight,remaining_weight,spool_cost,notes';
      final rows = parseCsvContent(content, l10n);
      expect(rows, isEmpty);
    });

    test('handles flexible column order', () {
      final content =
          'spool_cost,name,color\n'
          '24.99,PLA Pro+,Black';
      final rows = parseCsvContent(content, l10n);
      expect(rows.length, 1);
      expect(rows[0].name, 'PLA Pro+');
      expect(rows[0].cost, 24.99);
      expect(rows[0].color, 'Black');
    });

    test('preserves line numbers starting from 1', () {
      final content =
          'name,brand,material_type,color,color_hex,spool_weight,remaining_weight,spool_cost,notes\n'
          'First,Sunlu,PLA,Black,,1000,950,24.99,\n'
          'Second,Overture,PETG,White,,1000,1000,29.99,';
      final rows = parseCsvContent(content, l10n);
      expect(rows[0].lineNumber, 1);
      expect(rows[1].lineNumber, 2);
    });
  });
}
