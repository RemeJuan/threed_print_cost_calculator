import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/calculator/helpers/calculator_helpers.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  test('should calculate electricityCost', () async {
    //arrange
    const watts = 200;
    const minutes = 60;
    const hours = 1;
    const cost = 1.0;
    //act
    final result = container.read(calculatorHelpersProvider).electricityCost(
          watts,
          hours,
          minutes,
          cost,
        );
    //assert
    expect(result, equals(0.4));
  });

  test('should calculate filament cost', () async {
    //arrange
    const itemWeight = 10;
    const spoolWeight = 1000;
    const cost = 200;
    //act
    final result = container.read(calculatorHelpersProvider).filamentCost(
          itemWeight,
          spoolWeight,
          cost,
        );
    //assert
    expect(result, equals(2.0));
  });

  group('multiMaterialFilamentCost', () {
    test('single material matches legacy filamentCost', () {
      // 10g print weight, 1000g spool, $200 spool cost → $2.00
      const usage = MaterialUsage(
        materialId: 'mat1',
        materialName: 'PLA Black',
        weightGrams: 10,
        spoolWeightGrams: 1000,
        spoolCost: 200,
      );

      final result = container
          .read(calculatorHelpersProvider)
          .multiMaterialFilamentCost([usage]);

      expect(result, equals(2.0));
    });

    test('two materials sum correctly with different cost per gram', () {
      // Material A: 80g from 1000g spool at $25 → (80/1000)*25 = $2.00
      // Material B: 20g from 500g spool at $15 → (20/500)*15 = $0.60
      // Total: $2.60
      const usageA = MaterialUsage(
        materialId: 'matA',
        materialName: 'PLA White',
        weightGrams: 80,
        spoolWeightGrams: 1000,
        spoolCost: 25,
      );
      const usageB = MaterialUsage(
        materialId: 'matB',
        materialName: 'PETG Clear',
        weightGrams: 20,
        spoolWeightGrams: 500,
        spoolCost: 15,
      );

      final result = container
          .read(calculatorHelpersProvider)
          .multiMaterialFilamentCost([usageA, usageB]);

      expect(result, equals(2.60));
    });

    test('usage with zero spool weight is skipped (zero contribution)', () {
      const usage = MaterialUsage(
        materialId: 'mat1',
        materialName: 'Unknown',
        weightGrams: 50,
        spoolWeightGrams: 0,
        spoolCost: 100,
      );

      final result = container
          .read(calculatorHelpersProvider)
          .multiMaterialFilamentCost([usage]);

      expect(result, equals(0.0));
    });

    test('empty usage list returns zero', () {
      final result = container
          .read(calculatorHelpersProvider)
          .multiMaterialFilamentCost([]);

      expect(result, equals(0.0));
    });

    test('three materials sum correctly', () {
      // A: 100g / 1000g spool @ $20  → $2.00
      // B: 50g  / 500g spool  @ $15  → $1.50
      // C: 30g  / 750g spool  @ $30  → $1.20
      // Total: $4.70
      const usages = [
        MaterialUsage(
          materialId: 'a',
          materialName: 'A',
          weightGrams: 100,
          spoolWeightGrams: 1000,
          spoolCost: 20,
        ),
        MaterialUsage(
          materialId: 'b',
          materialName: 'B',
          weightGrams: 50,
          spoolWeightGrams: 500,
          spoolCost: 15,
        ),
        MaterialUsage(
          materialId: 'c',
          materialName: 'C',
          weightGrams: 30,
          spoolWeightGrams: 750,
          spoolCost: 30,
        ),
      ];

      final result = container
          .read(calculatorHelpersProvider)
          .multiMaterialFilamentCost(usages);

      expect(result, equals(4.70));
    });
  });
}
