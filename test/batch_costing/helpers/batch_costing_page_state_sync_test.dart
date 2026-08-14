import 'package:flutter_test/flutter_test.dart';

import 'package:threed_print_cost_calculator/batch_costing/helpers/batch_costing_page_state_sync.dart';
import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';

void main() {
  BatchCostingItem item(String id, {int quantity = 1}) =>
      BatchCostingItem.manual(
        id: id,
        displayName: id,
        quantity: quantity,
        printWeightG: 1,
        printDuration: const Duration(minutes: 1),
      );

  test('initial controller seeding and reuse', () {
    final sync = BatchCostingPageStateSync();
    final first = item('a', quantity: 2);

    expect(sync.needsInitialSync, true);
    sync.sync([first]);
    expect(sync.needsInitialSync, false);

    final controller = sync.controllerFor(first);
    expect(controller.text, '2');
    expect(identical(controller, sync.controllerFor(first)), true);
  });

  test('changed quantity text and removed IDs disposed', () {
    final sync = BatchCostingPageStateSync();
    final a = item('a', quantity: 2);
    final b = item('b', quantity: 3);
    sync.sync([a, b]);

    final aController = sync.controllerFor(a);
    sync.sync([a.copyWith(quantity: 5)]);
    expect(aController.text, '5');
  });

  test('expanded pruning, default expansion, setExpanded, dispose', () {
    final sync = BatchCostingPageStateSync();
    final a = item('a');
    final b = item('b');

    sync.sync([a, b]);
    expect(sync.isExpanded('a'), true);
    expect(sync.isExpanded('b'), false);

    sync.setExpanded('b', true);
    expect(sync.isExpanded('b'), true);

    sync.sync([b]);
    expect(sync.isExpanded('a'), false);
    expect(sync.isExpanded('b'), true);

    sync.sync([]);
    expect(sync.isExpanded('b'), false);

    sync.dispose();
    expect(sync.isExpanded('b'), false);
  });
}
