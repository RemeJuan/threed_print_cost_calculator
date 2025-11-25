import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/app/components/num_input.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculator_state.dart';

void main() {
  group('Spool Cost Input Test', () {
    test('should preserve decimal point input as raw text', () {
      // Arrange
      final initialState = CalculatorState();
      
      // Act - Simulate user typing "10."
      final updatedState = initialState.copyWith(
        spoolCost: const NumberInput.dirty(value: 10),
        spoolCostText: '10.',
      );
      
      // Assert
      expect(updatedState.spoolCostText, equals('10.'));
      expect(updatedState.spoolCost.value, equals(10));
    });

    test('should handle empty input correctly', () {
      // Arrange
      final initialState = CalculatorState();
      
      // Act
      final updatedState = initialState.copyWith(
        spoolCost: const NumberInput.dirty(value: 0),
        spoolCostText: '',
      );
      
      // Assert
      expect(updatedState.spoolCostText, equals(''));
      expect(updatedState.spoolCost.value, equals(0));
    });

    test('should handle complete decimal input correctly', () {
      // Arrange
      final initialState = CalculatorState();
      
      // Act
      final updatedState = initialState.copyWith(
        spoolCost: const NumberInput.dirty(value: 10.5),
        spoolCostText: '10.5',
      );
      
      // Assert
      expect(updatedState.spoolCostText, equals('10.5'));
      expect(updatedState.spoolCost.value, equals(10.5));
    });

    test('should handle material selection with decimal cost', () {
      // Arrange
      final initialState = CalculatorState();
      
      // Act - Simulate material selection setting cost to "15.99"
      final updatedState = initialState.copyWith(
        spoolCost: const NumberInput.dirty(value: 15.99),
        spoolCostText: '15.99',
      );
      
      // Assert
      expect(updatedState.spoolCostText, equals('15.99'));
      expect(updatedState.spoolCost.value, equals(15.99));
    });

    test('should handle initialization from saved data', () {
      // Arrange
      final initialState = CalculatorState();
      const savedValue = '12.5';
      
      // Act - Simulate loading from saved data
      final updatedState = initialState.copyWith(
        spoolCost: NumberInput.dirty(value: num.tryParse(savedValue)),
        spoolCostText: savedValue,
      );
      
      // Assert
      expect(updatedState.spoolCostText, equals('12.5'));
      expect(updatedState.spoolCost.value, equals(12.5));
    });
  });
}