import 'package:flutter/material.dart';

import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';

class BatchCostingPageStateSync {
  final Map<String, TextEditingController> _quantityControllers =
      <String, TextEditingController>{};
  final Set<String> _expandedItemIds = <String>{};
  bool _initialSyncDone = false;

  bool get needsInitialSync => !_initialSyncDone;

  void sync(List<BatchCostingItem> items) {
    _syncQuantityControllers(items);
    _syncExpandedState(items);
    _initialSyncDone = true;
  }

  TextEditingController controllerFor(BatchCostingItem item) {
    return _quantityControllers.putIfAbsent(
      item.id,
      () => TextEditingController(text: item.quantity.toString()),
    );
  }

  bool isExpanded(String id) => _expandedItemIds.contains(id);

  void setExpanded(String id, bool expanded) {
    if (expanded) {
      _expandedItemIds.add(id);
    } else {
      _expandedItemIds.remove(id);
    }
  }

  void dispose() {
    for (final controller in _quantityControllers.values) {
      controller.dispose();
    }
    _quantityControllers.clear();
    _expandedItemIds.clear();
  }

  void _syncQuantityControllers(List<BatchCostingItem> items) {
    final activeIds = items.map((item) => item.id).toSet();

    _quantityControllers.removeWhere((id, controller) {
      if (!activeIds.contains(id)) {
        controller.dispose();
        return true;
      }
      return false;
    });

    for (final item in items) {
      final controller = controllerFor(item);
      final quantityText = item.quantity.toString();
      if (controller.text != quantityText) {
        controller.text = quantityText;
      }
    }
  }

  void _syncExpandedState(List<BatchCostingItem> items) {
    final activeIds = items.map((item) => item.id).toSet();
    _expandedItemIds.removeWhere((id) => !activeIds.contains(id));

    if (items.isNotEmpty && _expandedItemIds.isEmpty) {
      _expandedItemIds.add(items.first.id);
    }
  }
}
