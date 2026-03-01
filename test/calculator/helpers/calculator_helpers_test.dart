import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/calculator/helpers/calculator_helpers.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage_input.dart';

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

  test('single material through multi-material API matches old behavior', () {
    const usage = MaterialUsageInput(
      materialId: 'pla-black',
      materialName: 'PLA Black',
      costPerKg: 200,
      weightGrams: 10,
    );

    final result = container
        .read(calculatorHelpersProvider)
        .multiMaterialFilamentCost([usage]);

    expect(result, equals(2.0));
  });

  test('multi-material sums correctly with different cost per kg', () {
    const usages = [
      MaterialUsageInput(
        materialId: 'pla-black',
        materialName: 'PLA Black',
        costPerKg: 200,
        weightGrams: 120,
      ),
      MaterialUsageInput(
        materialId: 'pla-white',
        materialName: 'PLA White',
        costPerKg: 250,
        weightGrams: 35,
      ),
    ];

    final result = container
        .read(calculatorHelpersProvider)
        .multiMaterialFilamentCost(usages);

    expect(result, equals(32.75));
  });

  test('risk formula remains unchanged with multi-material filament total', () {
    final filament = container.read(calculatorHelpersProvider).multiMaterialFilamentCost([
      const MaterialUsageInput(
        materialId: 'mat-1',
        materialName: 'M1',
        costPerKg: 210,
        weightGrams: 100,
      ),
    ]);
    final electricity =
        container.read(calculatorHelpersProvider).electricityCost(200, 1, 0, 1);
    final labour = 3;
    final wearAndTear = 1;
    const riskPercent = 10;

    final baseTotal = filament + electricity + labour + wearAndTear;
    final risk = num.parse((riskPercent / 100 * baseTotal).toStringAsFixed(2));

    expect(filament, equals(21.0));
    expect(baseTotal, equals(25.2));
    expect(risk, equals(2.52));
  });
}
