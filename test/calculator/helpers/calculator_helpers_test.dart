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

  test('electricityCost handles zero watts', () {
    final result = container.read(calculatorHelpersProvider).electricityCost(
          0,
          1,
          30,
          1.5,
        );
    expect(result, equals(0.0));
  });

  test('electricityCost handles zero hours and minutes', () {
    final result = container.read(calculatorHelpersProvider).electricityCost(
          200,
          0,
          0,
          1.5,
        );
    expect(result, equals(0.0));
  });

  test('electricityCost handles zero cost', () {
    final result = container.read(calculatorHelpersProvider).electricityCost(
          200,
          2,
          30,
          0,
        );
    expect(result, equals(0.0));
  });

  test('electricityCost converts minutes to hours correctly', () {
    final result = container.read(calculatorHelpersProvider).electricityCost(
          1000,
          0,
          30,
          2.0,
        );
    expect(result, equals(1.0));
  });

  test('filamentCost handles zero spool weight', () {
    final result = container.read(calculatorHelpersProvider).filamentCost(
          100,
          0,
          200,
        );
    expect(result, equals(0.0));
  });

  test('filamentCost handles zero item weight', () {
    final result = container.read(calculatorHelpersProvider).filamentCost(
          0,
          1000,
          200,
        );
    expect(result, equals(0.0));
  });

  test('filamentCost handles both weights zero', () {
    final result = container.read(calculatorHelpersProvider).filamentCost(
          0,
          0,
          200,
        );
    expect(result, equals(0.0));
  });

  test('multiMaterialFilamentCost handles empty list', () {
    final result = container
        .read(calculatorHelpersProvider)
        .multiMaterialFilamentCost([]);
    expect(result, equals(0.0));
  });

  test('multiMaterialFilamentCost handles zero weight materials', () {
    const usages = [
      MaterialUsageInput(
        materialId: 'mat-1',
        materialName: 'Material 1',
        costPerKg: 200,
        weightGrams: 0,
      ),
      MaterialUsageInput(
        materialId: 'mat-2',
        materialName: 'Material 2',
        costPerKg: 250,
        weightGrams: 0,
      ),
    ];

    final result = container
        .read(calculatorHelpersProvider)
        .multiMaterialFilamentCost(usages);

    expect(result, equals(0.0));
  });

  test('multiMaterialFilamentCost handles mixed zero and non-zero weights', () {
    const usages = [
      MaterialUsageInput(
        materialId: 'mat-1',
        materialName: 'Material 1',
        costPerKg: 200,
        weightGrams: 0,
      ),
      MaterialUsageInput(
        materialId: 'mat-2',
        materialName: 'Material 2',
        costPerKg: 250,
        weightGrams: 100,
      ),
    ];

    final result = container
        .read(calculatorHelpersProvider)
        .multiMaterialFilamentCost(usages);

    expect(result, equals(25.0));
  });

  test('multiMaterialFilamentCost with three materials', () {
    const usages = [
      MaterialUsageInput(
        materialId: 'mat-1',
        materialName: 'Material 1',
        costPerKg: 200,
        weightGrams: 50,
      ),
      MaterialUsageInput(
        materialId: 'mat-2',
        materialName: 'Material 2',
        costPerKg: 250,
        weightGrams: 75,
      ),
      MaterialUsageInput(
        materialId: 'mat-3',
        materialName: 'Material 3',
        costPerKg: 300,
        weightGrams: 25,
      ),
    ];

    final result = container
        .read(calculatorHelpersProvider)
        .multiMaterialFilamentCost(usages);

    expect(result, equals(36.25));
  });

  test('labourCost calculates correctly', () {
    final result = CalculatorHelpers.labourCost(15, 2.5);
    expect(result, equals(37.5));
  });

  test('labourCost handles zero rate', () {
    final result = CalculatorHelpers.labourCost(0, 5);
    expect(result, equals(0.0));
  });

  test('labourCost handles zero time', () {
    final result = CalculatorHelpers.labourCost(15, 0);
    expect(result, equals(0.0));
  });

  test('labourCost handles decimal values', () {
    final result = CalculatorHelpers.labourCost(15.5, 2.25);
    expect(result, equals(34.88));
  });
}