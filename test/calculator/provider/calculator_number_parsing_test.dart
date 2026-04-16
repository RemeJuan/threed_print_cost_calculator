import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';

void main() {
  group('CalculatorProvider localized parsing', () {
    late ProviderContainer container;
    late CalculatorProvider notifier;

    setUp(() {
      container = ProviderContainer();
      notifier = container.read(calculatorProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('parses comma-decimal calculator inputs', () {
      notifier.updateKwCost(' 12,5 ');
      notifier.updatePrintWeight('12,5');

      final state = container.read(calculatorProvider);
      expect(state.kwCost.value, 12.5);
      expect(state.printWeight.value, 12);
    });

    test('invalid calculator inputs keep nullable numeric state', () {
      notifier.updateWatt('abc');
      notifier.updateKwCost('abc');

      final state = container.read(calculatorProvider);
      expect(state.watt.value, isNull);
      expect(state.kwCost.value, isNull);
    });
  });
}
