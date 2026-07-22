import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/materials/csv_import/csv_import_parser.dart';
import 'package:threed_print_cost_calculator/materials/csv_import/materials_csv_schema.dart';

void main() {
  test('parses BOM CRLF quoted multiline CSV and preserves start lines', () {
    final file = parseCsvImportFile(
      '\ufeff$materialsCsvHeader\r\n'
      'id-1,PLA,Brand,PLA,Red,#ff0000,1000,900,12.5,true,false,"Line 1\nLine 2"\r\n'
      ',PETG,Brand2,PETG,Blue,#0000ff,2000,2000,13.5,false,true,Notes\r\n',
    );

    expect(file.header, materialsCsvHeaders);
    expect(file.rows, hasLength(2));
    expect(file.rows.first.startLine, 2);
    expect(file.rows.first.values.last, 'Line 1\nLine 2');
    expect(file.rows.last.startLine, 3);
  });

  test('rejects header mismatch', () {
    final file = parseCsvImportFile('bad,header\n');
    expect(
      () => const CsvImportParser().classify(file: file, existingIds: const {}),
      throwsFormatException,
    );
  });

  test('rejects malformed unclosed quote csv', () {
    expect(
      () => parseCsvImportFile('$materialsCsvHeader\n"bad, row'),
      throwsFormatException,
    );
  });

  test('skips blank records throughout', () {
    final file = parseCsvImportFile(
      '$materialsCsvHeader\n\n\nid-1,PLA,Brand,PLA,Red,#ff0000,1000,900,12.5,true,false,Notes\n\n',
    );

    expect(file.rows, hasLength(1));
    expect(file.rows.single.startLine, 4);
  });

  test(
    'preserves whitespace in text fields and trims only validation inputs',
    () {
      final classified = const CsvImportParser().classify(
        file: parseCsvImportFile(
          '$materialsCsvHeader\n,  name  ,  brand  ,PLA,  color  ,#fff,1000,900,12.5,true,false,  note  \n',
        ),
        existingIds: const {},
      );

      final row = classified.rows.single;
      expect(row.name, '  name  ');
      expect(row.brand, '  brand  ');
      expect(row.color, '  color  ');
      expect(row.notes, '  note  ');
      expect(row.kind, CsvImportRowKind.create);
    },
  );

  test('marks validation errors invalid before update or create', () {
    final classified = const CsvImportParser().classify(
      file: parseCsvImportFile(
        '$materialsCsvHeader\nexisting-id, ,Brand,PLA,Red,#ff0000,1000,900,12.5,true,false,Notes\n',
      ),
      existingIds: const {'existing-id': true},
    );

    final row = classified.rows.single;
    expect(row.kind, CsvImportRowKind.invalid);
    expect(row.errors.single.code, CsvImportErrorCode.requiredName);
  });

  test('rejects non-finite numeric values', () {
    final classified = const CsvImportParser().classify(
      file: parseCsvImportFile(
        '$materialsCsvHeader\n,PLA,Brand,PLA,Red,#ff0000,Infinity,900,12.5,true,false,Notes\n',
      ),
      existingIds: const {},
    );

    final row = classified.rows.single;
    expect(row.kind, CsvImportRowKind.invalid);
    expect(
      row.errors.any((e) => e.code == CsvImportErrorCode.invalidSpoolWeight),
      isTrue,
    );
  });
}
