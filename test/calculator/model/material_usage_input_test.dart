import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage_input.dart';

void main() {
  group('MaterialUsageInput', () {
    test('creates instance with required parameters', () {
      const input = MaterialUsageInput(
        materialId: 'mat-1',
        materialName: 'PLA Black',
        costPerKg: 200,
        weightGrams: 100,
      );

      expect(input.materialId, equals('mat-1'));
      expect(input.materialName, equals('PLA Black'));
      expect(input.costPerKg, equals(200));
      expect(input.weightGrams, equals(100));
    });

    test('copyWith creates new instance with updated values', () {
      const original = MaterialUsageInput(
        materialId: 'mat-1',
        materialName: 'PLA Black',
        costPerKg: 200,
        weightGrams: 100,
      );

      final updated = original.copyWith(
        weightGrams: 150,
        costPerKg: 250,
      );

      expect(updated.materialId, equals('mat-1'));
      expect(updated.materialName, equals('PLA Black'));
      expect(updated.costPerKg, equals(250));
      expect(updated.weightGrams, equals(150));
    });

    test('copyWith preserves original values when no parameters provided', () {
      const original = MaterialUsageInput(
        materialId: 'mat-1',
        materialName: 'PLA Black',
        costPerKg: 200,
        weightGrams: 100,
      );

      final copied = original.copyWith();

      expect(copied.materialId, equals(original.materialId));
      expect(copied.materialName, equals(original.materialName));
      expect(copied.costPerKg, equals(original.costPerKg));
      expect(copied.weightGrams, equals(original.weightGrams));
    });

    test('toMap converts to map correctly', () {
      const input = MaterialUsageInput(
        materialId: 'mat-1',
        materialName: 'PLA Black',
        costPerKg: 200,
        weightGrams: 100,
      );

      final map = input.toMap();

      expect(map['materialId'], equals('mat-1'));
      expect(map['materialName'], equals('PLA Black'));
      expect(map['costPerKg'], equals(200));
      expect(map['weightGrams'], equals(100));
    });

    test('fromMap creates instance from valid map', () {
      final map = {
        'materialId': 'mat-1',
        'materialName': 'PLA Black',
        'costPerKg': 200,
        'weightGrams': 100,
      };

      final input = MaterialUsageInput.fromMap(map);

      expect(input.materialId, equals('mat-1'));
      expect(input.materialName, equals('PLA Black'));
      expect(input.costPerKg, equals(200));
      expect(input.weightGrams, equals(100));
    });

    test('fromMap handles null materialId with empty string', () {
      final map = {
        'materialName': 'PLA Black',
        'costPerKg': 200,
        'weightGrams': 100,
      };

      final input = MaterialUsageInput.fromMap(map);

      expect(input.materialId, equals(''));
      expect(input.materialName, equals('PLA Black'));
    });

    test('fromMap handles null materialName with "Unassigned"', () {
      final map = {
        'materialId': 'mat-1',
        'costPerKg': 200,
        'weightGrams': 100,
      };

      final input = MaterialUsageInput.fromMap(map);

      expect(input.materialId, equals('mat-1'));
      expect(input.materialName, equals('Unassigned'));
    });

    test('fromMap handles null costPerKg with 0', () {
      final map = {
        'materialId': 'mat-1',
        'materialName': 'PLA Black',
        'weightGrams': 100,
      };

      final input = MaterialUsageInput.fromMap(map);

      expect(input.costPerKg, equals(0));
    });

    test('fromMap handles null weightGrams with 0', () {
      final map = {
        'materialId': 'mat-1',
        'materialName': 'PLA Black',
        'costPerKg': 200,
      };

      final input = MaterialUsageInput.fromMap(map);

      expect(input.weightGrams, equals(0));
    });

    test('fromMap handles string numbers correctly', () {
      final map = {
        'materialId': 'mat-1',
        'materialName': 'PLA Black',
        'costPerKg': '200',
        'weightGrams': '100',
      };

      final input = MaterialUsageInput.fromMap(map);

      expect(input.costPerKg, equals(200));
      expect(input.weightGrams, equals(100));
    });

    test('fromMap handles invalid string numbers with 0', () {
      final map = {
        'materialId': 'mat-1',
        'materialName': 'PLA Black',
        'costPerKg': 'invalid',
        'weightGrams': 'not-a-number',
      };

      final input = MaterialUsageInput.fromMap(map);

      expect(input.costPerKg, equals(0));
      expect(input.weightGrams, equals(0));
    });

    test('fromMap handles decimal costPerKg correctly', () {
      final map = {
        'materialId': 'mat-1',
        'materialName': 'PLA Black',
        'costPerKg': 199.99,
        'weightGrams': 100,
      };

      final input = MaterialUsageInput.fromMap(map);

      expect(input.costPerKg, equals(199.99));
    });

    test('fromMap handles decimal string costPerKg', () {
      final map = {
        'materialId': 'mat-1',
        'materialName': 'PLA Black',
        'costPerKg': '199.99',
        'weightGrams': 100,
      };

      final input = MaterialUsageInput.fromMap(map);

      expect(input.costPerKg, equals(199.99));
    });

    test('round-trip conversion preserves data', () {
      const original = MaterialUsageInput(
        materialId: 'mat-1',
        materialName: 'PLA Black',
        costPerKg: 200,
        weightGrams: 100,
      );

      final map = original.toMap();
      final restored = MaterialUsageInput.fromMap(map);

      expect(restored.materialId, equals(original.materialId));
      expect(restored.materialName, equals(original.materialName));
      expect(restored.costPerKg, equals(original.costPerKg));
      expect(restored.weightGrams, equals(original.weightGrams));
    });

    test('handles zero values correctly', () {
      const input = MaterialUsageInput(
        materialId: '',
        materialName: '',
        costPerKg: 0,
        weightGrams: 0,
      );

      expect(input.materialId, equals(''));
      expect(input.materialName, equals(''));
      expect(input.costPerKg, equals(0));
      expect(input.weightGrams, equals(0));
    });

    test('handles negative weight (edge case)', () {
      const input = MaterialUsageInput(
        materialId: 'mat-1',
        materialName: 'PLA Black',
        costPerKg: 200,
        weightGrams: -10,
      );

      expect(input.weightGrams, equals(-10));
    });

    test('handles very large numbers', () {
      const input = MaterialUsageInput(
        materialId: 'mat-1',
        materialName: 'PLA Black',
        costPerKg: 999999.99,
        weightGrams: 999999,
      );

      expect(input.costPerKg, equals(999999.99));
      expect(input.weightGrams, equals(999999));
    });
  });
}