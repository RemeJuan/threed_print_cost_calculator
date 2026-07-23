import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/materials/csv_import/materials_csv_export_service.dart';
import 'package:threed_print_cost_calculator/materials/csv_import/materials_csv_schema.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';

void main() {
  final service = MaterialsCsvExportService();

  test('exports exact header order', () {
    final csv = service.generateCsv(const []);

    expect(csv.split('\n').first, materialsCsvHeader);
    expect(materialsCsvHeaders, hasLength(12));
  });

  test('exports archived materials', () {
    final csv = service.generateCsv([
      const MaterialModel(
        id: 'm-1',
        name: 'PLA',
        cost: '12.5',
        color: 'Red',
        weight: '1000',
        archived: true,
      ),
    ]);

    expect(csv, contains('"true"'));
  });

  test('maps material fields to canonical columns', () {
    final csv = service.generateCsv([
      const MaterialModel(
        id: 'm-1',
        name: 'PLA',
        cost: '12.5',
        color: 'Red',
        weight: '1000',
        archived: false,
        autoDeductEnabled: true,
        originalWeight: 1200,
        remainingWeight: 450,
        brand: 'Brand A',
        materialType: 'PLA',
        colorHex: '#FF0000',
        notes: 'Note',
      ),
    ]);

    expect(
      csv,
      contains(
        '"m-1","PLA","Brand A","PLA","Red","#FF0000","1200.0","450.0","12.5","true","false","Note"',
      ),
    );
  });

  test('escapes quotes commas and newlines', () {
    final csv = service.generateCsv([
      const MaterialModel(
        id: 'id,1',
        name: 'He said "Hi"\nNext',
        cost: '12.5',
        color: 'Red,Blue',
        weight: '1000',
        archived: false,
        notes: 'Line1\r\nLine2',
      ),
    ]);

    expect(csv, contains('"id,1"'));
    expect(csv, contains('"He said ""Hi""\nNext"'));
    expect(csv, contains('"Red,Blue"'));
    expect(csv, contains('"Line1\r\nLine2"'));
  });

  test('neutralizes spreadsheet formulas', () {
    final csv = service.generateCsv([
      const MaterialModel(
        id: '=cmd',
        name: '+sum',
        cost: '12.5',
        color: '-red',
        weight: '1000',
        archived: false,
        colorHex: '@hex',
      ),
    ]);

    expect(csv, contains('"\'=cmd"'));
    expect(csv, contains('"\'+sum"'));
    expect(csv, contains('"\'-red"'));
    expect(csv, contains('"\'@hex"'));
  });

  test('exports all materials', () {
    final csv = service.generateCsv([
      const MaterialModel(
        id: 'm-1',
        name: 'PLA',
        cost: '12.5',
        color: 'Red',
        weight: '1000',
        archived: false,
      ),
      const MaterialModel(
        id: 'm-2',
        name: 'PETG',
        cost: '13.0',
        color: 'Blue',
        weight: '2000',
        archived: true,
      ),
    ]);

    final lines = csv.trim().split('\n');
    expect(lines, hasLength(3));
    expect(lines[1], contains('"m-1"'));
    expect(lines[2], contains('"m-2"'));
  });
}
