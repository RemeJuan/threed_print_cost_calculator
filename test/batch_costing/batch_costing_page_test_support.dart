import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/batch_costing/batch_costing_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_costing_state.dart';

class BatchFlowHomeHarness extends StatelessWidget {
  const BatchFlowHomeHarness({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const BatchCostingPage()),
          );
        },
        child: const Text('Open batch'),
      ),
    );
  }
}

class FakeBatchCostingNotifier extends BatchCostingNotifier {
  FakeBatchCostingNotifier(this._items);

  final List<BatchCostingItem> _items;

  @override
  BatchCostingState build() => BatchCostingState(items: _items);
}
