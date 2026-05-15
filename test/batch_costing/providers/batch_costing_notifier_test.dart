import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';

void main() {
  test('adds, updates, and removes batch items', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(batchCostingProvider.notifier);

    final first = BatchCostingItem.manual(
      id: 'item-1',
      displayName: 'Benchy',
      quantity: 1,
      printWeightG: 15,
      printDuration: const Duration(minutes: 30),
    );
    final updated = first.copyWith(quantity: 4, printWeightG: 60);

    notifier.addItem(first);
    expect(container.read(batchCostingProvider).items, [first]);

    notifier.updateItem(updated);
    expect(container.read(batchCostingProvider).items.single.quantity, 4);
    expect(container.read(batchCostingProvider).items.single.printWeightG, 60);

    notifier.removeItem('item-1');
    expect(container.read(batchCostingProvider).items, isEmpty);
  });
}
