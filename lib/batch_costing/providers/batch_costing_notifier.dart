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

  void setPrinterAssignmentMode(BatchPrinterAssignmentMode mode) {
    state = state.copyWith(printerAssignmentMode: mode);
  }

  void setBatchPrinterId(String? printerId) {
    final updatedPrinterIds = printerId == null
        ? state.itemPrinterIds
        : {for (final item in state.items) item.id: printerId};

    state = state.copyWith(
      batchPrinterId: printerId,
      clearBatchPrinterId: printerId == null,
      itemPrinterIds: updatedPrinterIds,
    );
  }

  void setItemPrinterId(String itemId, String? printerId) {
    final updated = Map<String, String>.from(state.itemPrinterIds);
    if (printerId == null) {
      updated.remove(itemId);
    } else {
      updated[itemId] = printerId;
    }

    state = state.copyWith(itemPrinterIds: updated);
  }

  void setMaterialAssignmentMode(BatchMaterialAssignmentMode mode) {
    state = state.copyWith(materialAssignmentMode: mode);
    if (mode == BatchMaterialAssignmentMode.batchWide &&
        state.batchMaterialId != null) {
      final materialId = state.batchMaterialId;
      state = state.copyWith(
        items: [
          for (final item in state.items) item.copyWith(materialId: materialId),
        ],
      );
    }
  }

  void setBatchMaterialId(String? materialId) {
    final updatedItems = materialId == null
        ? [for (final item in state.items) item.copyWith(materialId: null)]
        : [
            for (final item in state.items)
              item.copyWith(materialId: materialId),
          ];

    state = state.copyWith(
      items: updatedItems,
      batchMaterialId: materialId,
      clearBatchMaterialId: materialId == null,
    );
  }

  void setItemMaterialId(String itemId, String? materialId) {
    state = state.copyWith(
      items: [
        for (final current in state.items)
          if (current.id == itemId)
            current.copyWith(materialId: materialId)
          else
            current,
      ],
    );
  }

  void addItem(BatchCostingItem item) {
    if (state.items.any((current) => current.id == item.id)) {
      throw ArgumentError.value(item.id, 'item.id', 'must be unique');
    }

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
    final updatedPrinterIds = Map<String, String>.from(state.itemPrinterIds)
      ..remove(itemId);
    state = state.copyWith(
      items: state.items
          .where((item) => item.id != itemId)
          .toList(growable: false),
      itemPrinterIds: updatedPrinterIds,
    );
  }
}
