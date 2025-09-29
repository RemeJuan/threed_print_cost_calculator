import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/app/components/num_input.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculator_state.dart';

void main() {
  group('Spool Cost Input Test', () {
    test('should preserve decimal point input as raw text', () {
      // Arrange
      const initialState = CalculatorState();
      
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
      const initialState = CalculatorState();
      
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
      const initialState = CalculatorState();
      
      // Act
      final updatedState = initialState.copyWith(
        spoolCost: const NumberInput.dirty(value: 10.5),
        spoolCostText: '10.5',
      );
      
      // Assert
      expect(updatedState.spoolCostText, equals('10.5'));
      expect(updatedState.spoolCost.value, equals(10.5));
    });
  });
}