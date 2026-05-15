import 'package:riverpod/riverpod.dart';

import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_costing_state.dart';

final batchCostingProvider =
    NotifierProvider<BatchCostingNotifier, BatchCostingState>(
      BatchCostingNotifier.new,
    );

class BatchCostingNotifier extends Notifier<BatchCostingState> {
  @override
  BatchCostingState build() {
    return BatchCostingState();
  }

  void reset() {
    state = BatchCostingState();
  }

  void addItem(BatchCostingItem item) {
    state = state.copyWith(items: [...state.items, item]);
  }

  void updateItem(BatchCostingItem item) {
    state = state.copyWith(
      items: [
        for (final current in state.items)
          if (current.id == item.id) item else current,
      ],
    );
  }

  void removeItem(String itemId) {
    state = state.copyWith(
      items: state.items
          .where((item) => item.id != itemId)
          .toList(growable: false),
    );
  }
}
