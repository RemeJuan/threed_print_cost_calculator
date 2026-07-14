import 'package:flutter/material.dart';

import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';

import 'batch_costing_item_card.dart';

class BatchCostingPageItemList extends StatelessWidget {
  const BatchCostingPageItemList({
    super.key,
    required this.items,
    required this.controllerFor,
    required this.isExpanded,
    required this.onExpansionChanged,
    required this.onEdit,
  });

  final List<BatchCostingItem> items;
  final TextEditingController Function(BatchCostingItem item) controllerFor;
  final bool Function(String id) isExpanded;
  final void Function(BatchCostingItem item, bool expanded) onExpansionChanged;
  final void Function(BatchCostingItem item) onEdit;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (context, _) => const SizedBox(height: kAppSpace12),
      itemBuilder: (context, index) {
        final item = items[index];
        return BatchCostingItemCard(
          key: ValueKey(item.id),
          item: item,
          quantityController: controllerFor(item),
          initiallyExpanded: isExpanded(item.id),
          onExpansionChanged: (expanded) => onExpansionChanged(item, expanded),
          onEdit: () => onEdit(item),
        );
      },
    );
  }
}
