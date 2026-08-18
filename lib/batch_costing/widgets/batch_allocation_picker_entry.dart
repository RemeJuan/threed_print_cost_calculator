import 'package:flutter/material.dart';

import 'package:threed_print_cost_calculator/batch_costing/state/batch_costing_state.dart';

import 'batch_allocation_picker_option.dart';

class BatchAllocationPickerEntry {
  BatchAllocationPickerEntry({required this.option, required this.controller});

  final BatchAllocationPickerOption option;
  final TextEditingController controller;
}

List<BatchAllocationPickerEntry> buildBatchAllocationPickerEntries({
  required List<BatchAssignmentAllocation> allocations,
  required List<BatchAllocationPickerOption> options,
  required Set<String> selectedIds,
}) {
  final entries = <BatchAllocationPickerEntry>[];
  for (final allocation in allocations) {
    if (allocation.targetId.isEmpty) continue;
    selectedIds.add(allocation.targetId);
    final option = options.firstWhere(
      (option) => option.id == allocation.targetId,
      orElse: () => BatchAllocationPickerOption(
        id: allocation.targetId,
        title: allocation.targetId,
      ),
    );
    entries.add(
      BatchAllocationPickerEntry(
        option: option,
        controller: TextEditingController(text: allocation.quantity.toString()),
      ),
    );
  }
  return entries;
}
