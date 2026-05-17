import 'package:formz/formz.dart';

import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';

enum BatchPrinterAssignmentMode { batchWide, perItem }

class BatchCostingState with FormzMixin {
  final List<BatchCostingItem> items;
  final BatchPrinterAssignmentMode printerAssignmentMode;
  final String? batchPrinterId;
  final Map<String, String> itemPrinterIds;

  BatchCostingState({
    List<BatchCostingItem>? items,
    this.printerAssignmentMode = BatchPrinterAssignmentMode.batchWide,
    this.batchPrinterId,
    Map<String, String>? itemPrinterIds,
  }) : items = List.unmodifiable(items ?? const <BatchCostingItem>[]),
       itemPrinterIds = Map.unmodifiable(itemPrinterIds ?? const <String, String>{});

  BatchCostingState copyWith({
    List<BatchCostingItem>? items,
    BatchPrinterAssignmentMode? printerAssignmentMode,
    String? batchPrinterId,
    bool clearBatchPrinterId = false,
    Map<String, String>? itemPrinterIds,
    bool clearItemPrinterIds = false,
  }) {
    return BatchCostingState(
      items: items ?? this.items,
      printerAssignmentMode: printerAssignmentMode ?? this.printerAssignmentMode,
      batchPrinterId: clearBatchPrinterId ? null : batchPrinterId ?? this.batchPrinterId,
      itemPrinterIds: clearItemPrinterIds ? null : itemPrinterIds ?? this.itemPrinterIds,
    );
  }

  @override
  List<FormzInput> get inputs => const [];
}
