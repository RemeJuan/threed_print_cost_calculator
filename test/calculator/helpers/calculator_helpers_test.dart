import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/calculator/helpers/calculator_helpers.dart';

void main() {
  test('should calculate electricityCost', () async {
    //arrange
    const watts = '200';
    const minutes = '60';
    const cost = '2';
    //act
    final result = CalculatorHelpers.electricityCost(
      watts,
      minutes,
      cost,
    );
    //assert
    expect(result, equals(0.4));
  });

  test('should calculate filament cost', () async {
    //arrange
    const itemWeight = '10';
    const spoolWeight = '1000';
    const cost = '200';
    //act
    final result = CalculatorHelpers.filamentCost(
      itemWeight,
      spoolWeight,
      cost,
    );
    //assert
    expect(result, equals(2.0));
  });
}
