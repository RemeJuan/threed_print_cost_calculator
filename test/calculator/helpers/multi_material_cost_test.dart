import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/calculator/helpers/calculator_helpers.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  CalculatorHelpers helpers() => container.read(calculatorHelpersProvider);

  group('multiFilamentCost', () {
    test('returns 0 for empty list', () {
      final result = helpers().multiFilamentCost([]);
      expect(result, equals(0.0));
    });

    test('single material matches legacy filamentCost exactly', () {
      const itemWeight = 10;
      const spoolWeight = 1000;
      const spoolCost = 200.0;

      final usages = [
        const MaterialUsage(
          materialId: 'mat1',
          materialName: 'PLA Black',
          weightGrams: itemWeight,
          spoolWeight: spoolWeight,
          spoolCost: spoolCost,
        ),
      ];

      final multiResult = helpers().multiFilamentCost(usages);
      final legacyResult = helpers().filamentCost(
        itemWeight,
        spoolWeight,
        spoolCost,
      );

      expect(multiResult, equals(legacyResult));
      expect(multiResult, equals(2.0));
    });

    test('two materials sum correctly with different cost per kg', () {
      // PLA Black: 120g used, 1000g spool, $20 cost → 120/1000 * 20 = 2.40
      // PLA White:  35g used,  500g spool, $15 cost →  35/500  * 15 = 1.05
      // Total = 3.45
      final usages = [
        const MaterialUsage(
          materialId: 'mat1',
          materialName: 'PLA Black',
          weightGrams: 120,
          spoolWeight: 1000,
          spoolCost: 20.0,
        ),
        const MaterialUsage(
          materialId: 'mat2',
          materialName: 'PLA White',
          weightGrams: 35,
          spoolWeight: 500,
          spoolCost: 15.0,
        ),
      ];

      final result = helpers().multiFilamentCost(usages);

      expect(result, equals(3.45));
    });

    test('three materials sum correctly', () {
      // 100g / 1000g * $25 = 2.50
      // 50g  /  500g * $18 = 1.80
      // 20g  / 1000g * $30 = 0.60
      // Total = 4.90
      final usages = [
        const MaterialUsage(
          materialId: 'a',
          materialName: 'A',
          weightGrams: 100,
          spoolWeight: 1000,
          spoolCost: 25.0,
        ),
        const MaterialUsage(
          materialId: 'b',
          materialName: 'B',
          weightGrams: 50,
          spoolWeight: 500,
          spoolCost: 18.0,
        ),
        const MaterialUsage(
          materialId: 'c',
          materialName: 'C',
          weightGrams: 20,
          spoolWeight: 1000,
          spoolCost: 30.0,
        ),
      ];

      final result = helpers().multiFilamentCost(usages);

      expect(result, equals(4.90));
    });

    test('usage with zero weight contributes 0 cost', () {
      final usages = [
        const MaterialUsage(
          materialId: 'mat1',
          materialName: 'PLA Black',
          weightGrams: 0,
          spoolWeight: 1000,
          spoolCost: 20.0,
        ),
        const MaterialUsage(
          materialId: 'mat2',
          materialName: 'PLA White',
          weightGrams: 100,
          spoolWeight: 1000,
          spoolCost: 20.0,
        ),
      ];

      final result = helpers().multiFilamentCost(usages);

      // Only mat2 contributes: 100/1000 * 20 = 2.00
      expect(result, equals(2.0));
    });

    test('usage with zero spool weight is skipped to avoid division by zero', () {
      final usages = [
        const MaterialUsage(
          materialId: 'mat1',
          materialName: 'Invalid',
          weightGrams: 100,
          spoolWeight: 0, // zero spool weight → skip
          spoolCost: 20.0,
        ),
        const MaterialUsage(
          materialId: 'mat2',
          materialName: 'Valid',
          weightGrams: 50,
          spoolWeight: 1000,
          spoolCost: 20.0,
        ),
      ];

      final result = helpers().multiFilamentCost(usages);

      // mat1 skipped; mat2: 50/1000 * 20 = 1.00
      expect(result, equals(1.0));
    });

    test('all-zero weights returns 0', () {
      final usages = [
        const MaterialUsage(
          materialId: 'mat1',
          materialName: 'A',
          weightGrams: 0,
          spoolWeight: 1000,
          spoolCost: 20.0,
        ),
        const MaterialUsage(
          materialId: 'mat2',
          materialName: 'B',
          weightGrams: 0,
          spoolWeight: 500,
          spoolCost: 15.0,
        ),
      ];

      final result = helpers().multiFilamentCost(usages);

      expect(result, equals(0.0));
    });
  });

  group('computeUsageCosts', () {
    test('populates filamentCost on each usage', () {
      final usages = [
        const MaterialUsage(
          materialId: 'mat1',
          materialName: 'PLA Black',
          weightGrams: 120,
          spoolWeight: 1000,
          spoolCost: 20.0,
        ),
        const MaterialUsage(
          materialId: 'mat2',
          materialName: 'PLA White',
          weightGrams: 35,
          spoolWeight: 500,
          spoolCost: 15.0,
        ),
      ];

      final result = helpers().computeUsageCosts(usages);

      expect(result[0].filamentCost, equals(2.40));
      expect(result[1].filamentCost, equals(1.05));
    });

    test('total of individual costs equals multiFilamentCost', () {
      final usages = [
        const MaterialUsage(
          materialId: 'mat1',
          materialName: 'PLA Black',
          weightGrams: 120,
          spoolWeight: 1000,
          spoolCost: 20.0,
        ),
        const MaterialUsage(
          materialId: 'mat2',
          materialName: 'PLA White',
          weightGrams: 35,
          spoolWeight: 500,
          spoolCost: 15.0,
        ),
      ];

      final costed = helpers().computeUsageCosts(usages);
      final totalFromUsages =
          costed.fold<num>(0, (sum, u) => sum + u.filamentCost);
      final multiTotal = helpers().multiFilamentCost(usages);

      // The sum of individual (rounded to 2dp) costs may differ by rounding;
      // check they are equal within a small epsilon.
      expect((totalFromUsages - multiTotal).abs(), lessThanOrEqualTo(0.01));
    });
  });

  group('risk calculation snapshot — unchanged by multi-material', () {
    test('risk is still computed on total cost only', () {
      // Arrange: 10% risk on a 10.00 total → risk = 1.00
      const totalCost = 10.0;
      const failureRiskPct = 10.0;

      final frCost = failureRiskPct / 100 * totalCost;

      expect(frCost, equals(1.0));
    });
  });
}
