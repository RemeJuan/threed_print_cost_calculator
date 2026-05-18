import 'package:formz/formz.dart';

import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_pricing_state.dart';

enum BatchPrinterAssignmentMode { batchWide, perItem }

enum BatchMaterialAssignmentMode { batchWide, perItem }

class BatchCostingState with FormzMixin {
  final List<BatchCostingItem> items;
  final BatchPrinterAssignmentMode printerAssignmentMode;
  final String? batchPrinterId;
  final Map<String, String> itemPrinterIds;
  final BatchMaterialAssignmentMode materialAssignmentMode;
  final String? batchMaterialId;
  final BatchPricingState pricing;

  BatchCostingState({
    List<BatchCostingItem>? items,
    this.printerAssignmentMode = BatchPrinterAssignmentMode.batchWide,
    this.batchPrinterId,
    Map<String, String>? itemPrinterIds,
    this.materialAssignmentMode = BatchMaterialAssignmentMode.batchWide,
    this.batchMaterialId,
    this.pricing = const BatchPricingState(),
  }) : items = List.unmodifiable(items ?? const <BatchCostingItem>[]),
       itemPrinterIds = Map.unmodifiable(
         itemPrinterIds ?? const <String, String>{},
       );

  BatchCostingState copyWith({
    List<BatchCostingItem>? items,
    BatchPrinterAssignmentMode? printerAssignmentMode,
    String? batchPrinterId,
    bool clearBatchPrinterId = false,
    Map<String, String>? itemPrinterIds,
    bool clearItemPrinterIds = false,
    BatchMaterialAssignmentMode? materialAssignmentMode,
    String? batchMaterialId,
    bool clearBatchMaterialId = false,
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
      materialAssignmentMode:
          materialAssignmentMode ?? this.materialAssignmentMode,
      batchMaterialId: clearBatchMaterialId
          ? null
          : batchMaterialId ?? this.batchMaterialId,
      pricing: pricing ?? this.pricing,
    );
  }

  @override
  List<FormzInput> get inputs => const [];
}
