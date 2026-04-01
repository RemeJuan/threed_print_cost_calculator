import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:threed_print_cost_calculator/settings/providers/materials_notifier.dart';

void main() {
  group('MaterialsProvider localized parsing', () {
    late ProviderContainer container;
    late MaterialsProvider notifier;

    setUp(() {
      container = ProviderContainer();
      notifier = container.read(materialsProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('parses comma-decimal settings values', () {
      notifier.updateCost(' 12,5 ');
      notifier.updateWeight('0,75');

      final state = container.read(materialsProvider);
      expect(state.cost.value, 12.5);
      expect(state.weight.value, 0.75);
    });

    test('invalid settings values keep numeric fallback behavior', () {
      notifier.updateCost('abc');
      notifier.updateWeight('');

      final state = container.read(materialsProvider);
      expect(state.cost.value, 0);
      expect(state.weight.value, 0);
    });
  });
}
