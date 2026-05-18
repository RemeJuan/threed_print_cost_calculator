import 'package:formz/formz.dart';

import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_pricing_state.dart';

enum BatchPrinterAssignmentMode { batchWide, perItem }

enum BatchMaterialAssignmentMode { batchWide, perItem }

class BatchAssignmentAllocation {
  const BatchAssignmentAllocation({
    required this.targetId,
    required this.quantity,
  });

  final String targetId;
  final int quantity;

  BatchAssignmentAllocation copyWith({String? targetId, int? quantity}) {
    return BatchAssignmentAllocation(
      targetId: targetId ?? this.targetId,
      quantity: quantity ?? this.quantity,
    );
  }
}

class BatchCostingState with FormzMixin {
  final List<BatchCostingItem> items;
  final BatchPrinterAssignmentMode printerAssignmentMode;
  final String? batchPrinterId;
  final Map<String, String> itemPrinterIds;
  final Map<String, List<BatchAssignmentAllocation>> itemPrinterAllocations;
  final BatchMaterialAssignmentMode materialAssignmentMode;
  final String? batchMaterialId;
  final Map<String, List<BatchAssignmentAllocation>> itemMaterialAllocations;
  final BatchPricingState pricing;

  BatchCostingState({
    List<BatchCostingItem>? items,
    this.printerAssignmentMode = BatchPrinterAssignmentMode.batchWide,
    this.batchPrinterId,
    Map<String, String>? itemPrinterIds,
    Map<String, List<BatchAssignmentAllocation>>? itemPrinterAllocations,
    this.materialAssignmentMode = BatchMaterialAssignmentMode.batchWide,
    this.batchMaterialId,
    Map<String, List<BatchAssignmentAllocation>>? itemMaterialAllocations,
    this.pricing = const BatchPricingState(),
  }) : items = List.unmodifiable(items ?? const <BatchCostingItem>[]),
       itemPrinterIds = Map.unmodifiable(
         itemPrinterIds ?? const <String, String>{},
       ),
       itemPrinterAllocations = Map.unmodifiable(
          itemPrinterAllocations ??
              const <String, List<BatchAssignmentAllocation>>{},
        ),
        itemMaterialAllocations = Map.unmodifiable(
          itemMaterialAllocations ??
              const <String, List<BatchAssignmentAllocation>>{},
        );

  BatchCostingState copyWith({
    List<BatchCostingItem>? items,
    BatchPrinterAssignmentMode? printerAssignmentMode,
    String? batchPrinterId,
    bool clearBatchPrinterId = false,
    Map<String, String>? itemPrinterIds,
    bool clearItemPrinterIds = false,
    Map<String, List<BatchAssignmentAllocation>>? itemPrinterAllocations,
    bool clearItemPrinterAllocations = false,
    BatchMaterialAssignmentMode? materialAssignmentMode,
    String? batchMaterialId,
    bool clearBatchMaterialId = false,
    Map<String, List<BatchAssignmentAllocation>>? itemMaterialAllocations,
    bool clearItemMaterialAllocations = false,
    BatchPricingState? pricing,
  }) {
    return BatchCostingState(
      items: items ?? this.items,
      printerAssignmentMode:
          printerAssignmentMode ?? this.printerAssignmentMode,
      batchPrinterId: clearBatchPrinterId
          ? null
          : batchPrinterId ?? this.batchPrinterId,
      itemPrinterIds: clearItemPrinterIds
          ? null
          : itemPrinterIds ?? this.itemPrinterIds,
      itemPrinterAllocations: clearItemPrinterAllocations
          ? null
          : itemPrinterAllocations ?? this.itemPrinterAllocations,
      materialAssignmentMode:
          materialAssignmentMode ?? this.materialAssignmentMode,
      batchMaterialId: clearBatchMaterialId
          ? null
          : batchMaterialId ?? this.batchMaterialId,
      itemMaterialAllocations: clearItemMaterialAllocations
          ? null
          : itemMaterialAllocations ?? this.itemMaterialAllocations,
      pricing: pricing ?? this.pricing,
    );
  }

  @override
  List<FormzInput> get inputs => const [];
}
