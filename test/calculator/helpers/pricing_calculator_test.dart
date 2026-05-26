import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/calculator/helpers/pricing_calculator.dart';
import 'package:threed_print_cost_calculator/calculator/model/pricing_models.dart';

void main() {
  group('PricingCalculator', () {
    test('zero base cost still includes setup fee', () {
      final result = PricingCalculator.calculate(
        baseCost: 0,
        markupPercent: 25,
        setupFee: 4,
        roundingMode: PricingRoundingMode.pointNinetyNine,
      );

      expect(result.finalPrice, 4.99);
      expect(result.markupAmount, 0);
      expect(result.subtotalBeforeRounding, 4);
    });

    test('none keeps exact subtotal with currency rounding', () {
      final result = PricingCalculator.calculate(
        baseCost: 10,
        markupPercent: 12.5,
        setupFee: 1.25,
        roundingMode: PricingRoundingMode.none,
      );

      expect(result.markupAmount, 1.25);
      expect(result.subtotalBeforeRounding, 12.5);
      expect(result.finalPrice, 12.5);
      expect(result.roundingAdjustment, 0);
    });

    test('.00 rounds up to whole dollar at the end', () {
      final result = PricingCalculator.calculate(
        baseCost: 10,
        markupPercent: 10,
        setupFee: 0.4,
        roundingMode: PricingRoundingMode.wholeDollar,
      );

      expect(result.subtotalBeforeRounding, 11.4);
      expect(result.finalPrice, 12);
      expect(result.roundingAdjustment, 0.6);
    });

    test('.99 example rounds to next .99 price point', () {
      final result = PricingCalculator.calculate(
        baseCost: 10,
        markupPercent: 20,
        setupFee: 0,
        roundingMode: PricingRoundingMode.pointNinetyNine,
      );

      expect(result.subtotalBeforeRounding, 12);
      expect(result.finalPrice, 12.99);
      expect(result.roundingAdjustment, 0.99);
    });

    test('markup applies only to base cost and setup fee adds globally', () {
      final result = PricingCalculator.calculate(
        baseCost: 12,
        markupPercent: 50,
        setupFee: 2,
        roundingMode: PricingRoundingMode.none,
      );

      expect(result.markupAmount, 6);
      expect(result.subtotalBeforeRounding, 20);
      expect(result.finalPrice, 20);
    });

    test('example pricing math includes additional cost in base cost', () {
      final result = PricingCalculator.calculate(
        baseCost: 37.92,
        markupPercent: 10,
        setupFee: 10,
        roundingMode: PricingRoundingMode.wholeDollar,
      );

      expect(result.baseCost, 37.92);
      expect(result.markupAmount, 3.79);
      expect(result.subtotalBeforeRounding, 51.71);
      expect(result.finalPrice, 52);
      expect(result.roundingAdjustment, 0.29);
    });

    test('rounding happens once at the end', () {
      final result = PricingCalculator.calculate(
        baseCost: 9.995,
        markupPercent: 10.005,
        setupFee: 0.005,
        roundingMode: PricingRoundingMode.none,
      );

      expect(result.baseCost, 9.99);
      expect(result.markupPercent, 10.01);
      expect(result.setupFee, 0.01);
      expect(result.subtotalBeforeRounding, 11.0);
      expect(result.finalPrice, 11.0);
    });

    test('negative subtotal clamps to zero', () {
      final result = PricingCalculator.calculate(
        baseCost: 0,
        markupPercent: 0,
        setupFee: -1,
        roundingMode: PricingRoundingMode.wholeDollar,
      );

      expect(result.subtotalBeforeRounding, -1);
      expect(result.finalPrice, 0);
      expect(result.roundingAdjustment, 1);
    });

    test('handles oversized inputs without overflowing', () {
      final huge = double.parse('19369081277395030400');

      final result = PricingCalculator.calculate(
        baseCost: huge,
        markupPercent: huge,
        setupFee: huge,
        roundingMode: PricingRoundingMode.pointNinetyNine,
      );

      expect(result.finalPrice.isFinite, isTrue);
      expect(result.subtotalBeforeRounding.isFinite, isTrue);
      expect(result.roundingMode, PricingRoundingMode.pointNinetyNine);
    });
  });
}
