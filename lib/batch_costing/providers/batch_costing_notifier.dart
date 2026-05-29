import 'package:riverpod/riverpod.dart';

import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_costing_state.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_pricing_state.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';

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
    final printerIds = printerId == null
        ? state.itemPrinterIds
        : {for (final item in state.items) item.id: printerId};
    final allocations = printerId == null
        ? state.itemPrinterAllocations
        : {
            for (final item in state.items)
              item.id: [
                BatchAssignmentAllocation(
                  targetId: printerId,
                  quantity: item.quantity,
                ),
              ],
          };

    state = state.copyWith(
      batchPrinterId: printerId,
      clearBatchPrinterId: printerId == null,
      itemPrinterIds: printerIds,
      itemPrinterAllocations: allocations,
    );
  }

  void setItemPrinterAllocations(
    String itemId,
    List<BatchAssignmentAllocation> allocations,
  ) {
    final normalized = _normalizeAllocations(itemId, allocations);
    final updatedIds = Map<String, String>.from(state.itemPrinterIds);
    if (normalized.isEmpty) {
      updatedIds.remove(itemId);
    } else {
      updatedIds[itemId] = normalized.first.targetId;
    }

    state = state.copyWith(
      itemPrinterIds: updatedIds,
      itemPrinterAllocations: _updateAllocations(
        state.itemPrinterAllocations,
        itemId,
        normalized,
      ),
    );
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
        itemMaterialAllocations: {
          for (final item in state.items)
            item.id: [
              BatchAssignmentAllocation(
                targetId: materialId!,
                quantity: item.quantity,
              ),
            ],
        },
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
    final updatedAllocations = materialId == null
        ? state.itemMaterialAllocations
        : {
            for (final item in state.items)
              item.id: [
                BatchAssignmentAllocation(
                  targetId: materialId,
                  quantity: item.quantity,
                ),
              ],
          };

    state = state.copyWith(
      items: updatedItems,
      batchMaterialId: materialId,
      clearBatchMaterialId: materialId == null,
      itemMaterialAllocations: updatedAllocations,
    );
  }

  void setItemMaterialAllocations(
    String itemId,
    List<BatchAssignmentAllocation> allocations,
  ) {
    state = state.copyWith(
      itemMaterialAllocations: _updateAllocations(
        state.itemMaterialAllocations,
        itemId,
        _normalizeAllocations(itemId, allocations),
      ),
    );
  }

  void setFailureRisk(String value) {
    if (!ref.read(premiumAccessPolicyProvider).riskPricing().allowed) {
      return;
    }
    state = state.copyWith(
      pricing: state.pricing.copyWith(
        failureRisk: state.pricing.failureRisk.copyWith(value: value),
      ),
    );
  }

  void setFailureRiskScope(BatchPricingScope scope) {
    state = state.copyWith(
      pricing: state.pricing.copyWith(
        failureRisk: state.pricing.failureRisk.copyWith(scope: scope),
      ),
    );
  }

  void setMarkupPercent(String value) {
    if (!ref.read(premiumAccessPolicyProvider).advancedPricingConfig().allowed) {
      return;
    }
    state = state.copyWith(
      pricing: state.pricing.copyWith(
        markupPercent: state.pricing.markupPercent.copyWith(value: value),
      ),
    );
  }

  void setMarkupPercentScope(BatchPricingScope scope) {
    state = state.copyWith(
      pricing: state.pricing.copyWith(
        markupPercent: state.pricing.markupPercent.copyWith(scope: scope),
      ),
    );
  }

  void setLabourRate(String value) {
    if (!ref.read(premiumAccessPolicyProvider).labourPricing().allowed) {
      return;
    }
    state = state.copyWith(
      pricing: state.pricing.copyWith(
        labourRate: state.pricing.labourRate.copyWith(value: value),
      ),
    );
  }

  void setLabourRateScope(BatchPricingScope scope) {
    state = state.copyWith(
      pricing: state.pricing.copyWith(
        labourRate: state.pricing.labourRate.copyWith(scope: scope),
      ),
    );
  }

  void setAdditionalCostAmount(String value) {
    state = state.copyWith(
      pricing: state.pricing.copyWith(
        additionalCostAmount: state.pricing.additionalCostAmount.copyWith(
          value: value,
        ),
      ),
    );
  }

  void setAdditionalCostAmountScope(BatchPricingScope scope) {
    state = state.copyWith(
      pricing: state.pricing.copyWith(
        additionalCostAmount: state.pricing.additionalCostAmount.copyWith(
          scope: scope,
        ),
      ),
    );
  }

  void addItem(BatchCostingItem item) {
    final access = ref.read(premiumAccessPolicyProvider).canAddBatchItem(
      state.items.length,
    );
    if (!access.allowed) {
      return;
    }

    if (state.items.any((current) => current.id == item.id)) {
      throw ArgumentError.value(item.id, 'item.id', 'must be unique');
    }

    state = state.copyWith(items: [...state.items, item]);
  }

  bool updateItem(BatchCostingItem item) {
    final oldItem = state.items.firstWhere((current) => current.id == item.id);
    final quantityChanged = oldItem.quantity != item.quantity;

    bool cleared = false;

    if (quantityChanged) {
      Map<String, List<BatchAssignmentAllocation>>? pAlloc;
      Map<String, List<BatchAssignmentAllocation>>? mAlloc;
      Map<String, String>? pIds;

      if (state.printerAssignmentMode == BatchPrinterAssignmentMode.perItem) {
        pIds = Map<String, String>.from(state.itemPrinterIds)..remove(item.id);
        pAlloc = Map<String, List<BatchAssignmentAllocation>>.from(
          state.itemPrinterAllocations,
        )..remove(item.id);
        cleared = true;
      } else if (state.batchPrinterId != null) {
        pAlloc = Map<String, List<BatchAssignmentAllocation>>.from(
          state.itemPrinterAllocations,
        );
        pAlloc[item.id] = [
          BatchAssignmentAllocation(
            targetId: state.batchPrinterId!,
            quantity: item.quantity,
          ),
        ];
      }

      if (state.materialAssignmentMode == BatchMaterialAssignmentMode.perItem) {
        mAlloc = Map<String, List<BatchAssignmentAllocation>>.from(
          state.itemMaterialAllocations,
        )..remove(item.id);
        cleared = true;
      } else if (state.batchMaterialId != null) {
        mAlloc = Map<String, List<BatchAssignmentAllocation>>.from(
          state.itemMaterialAllocations,
        );
        mAlloc[item.id] = [
          BatchAssignmentAllocation(
            targetId: state.batchMaterialId!,
            quantity: item.quantity,
          ),
        ];
      }

      state = state.copyWith(
        items: [
          for (final current in state.items)
            if (current.id == item.id) item else current,
        ],
        itemPrinterIds: pIds ?? state.itemPrinterIds,
        itemPrinterAllocations: pAlloc ?? state.itemPrinterAllocations,
        itemMaterialAllocations: mAlloc ?? state.itemMaterialAllocations,
      );
    } else {
      state = state.copyWith(
        items: [
          for (final current in state.items)
            if (current.id == item.id) item else current,
        ],
      );
    }

    return cleared;
  }

  void removeItem(String itemId) {
    final updatedPrinterIds = Map<String, String>.from(state.itemPrinterIds)
      ..remove(itemId);
    final updatedPrinterAllocations =
        Map<String, List<BatchAssignmentAllocation>>.from(
          state.itemPrinterAllocations,
        )..remove(itemId);
    final updatedMaterialAllocations =
        Map<String, List<BatchAssignmentAllocation>>.from(
          state.itemMaterialAllocations,
        )..remove(itemId);
    state = state.copyWith(
      items: state.items
          .where((item) => item.id != itemId)
          .toList(growable: false),
      itemPrinterIds: updatedPrinterIds,
      itemPrinterAllocations: updatedPrinterAllocations,
      itemMaterialAllocations: updatedMaterialAllocations,
    );
  }

  int _itemQuantity(String itemId) =>
      state.items.firstWhere((item) => item.id == itemId).quantity;

  Map<String, List<BatchAssignmentAllocation>> _updateAllocations(
    Map<String, List<BatchAssignmentAllocation>> allocations,
    String itemId,
    List<BatchAssignmentAllocation> updatedAllocations,
  ) {
    final updated = Map<String, List<BatchAssignmentAllocation>>.from(
      allocations,
    );
    if (updatedAllocations.isEmpty) {
      updated.remove(itemId);
    } else {
      updated[itemId] = List.unmodifiable(updatedAllocations);
    }
    return updated;
  }

  List<BatchAssignmentAllocation> _normalizeAllocations(
    String itemId,
    List<BatchAssignmentAllocation> allocations,
  ) {
    final itemQuantity = _itemQuantity(itemId);
    if (allocations.isEmpty) {
      return const <BatchAssignmentAllocation>[];
    }

    final trimmed = allocations.take(itemQuantity).toList(growable: false);
    if (trimmed.length == 1) {
      return [trimmed.first.copyWith(quantity: itemQuantity)];
    }

    final normalized = <BatchAssignmentAllocation>[];
    var remaining = itemQuantity;
    for (var index = 0; index < trimmed.length; index += 1) {
      final quantity = index == trimmed.length - 1
          ? remaining
          : trimmed[index].quantity.clamp(0, remaining);
      remaining -= quantity;
      normalized.add(trimmed[index].copyWith(quantity: quantity));
    }
    return normalized;
  }
}
