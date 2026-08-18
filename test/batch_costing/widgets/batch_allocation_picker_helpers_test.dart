import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:threed_print_cost_calculator/batch_costing/state/batch_costing_state.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/batch_allocation_picker_entry.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/batch_allocation_picker_option.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/batch_allocation_picker_search.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/batch_allocation_picker_validation.dart';

void main() {
  test('build entries skips blank, preserves order, falls back to id', () {
    final selectedIds = <String>{};
    final entries = buildBatchAllocationPickerEntries(
      allocations: const [
        BatchAssignmentAllocation(targetId: '', quantity: 7),
        BatchAssignmentAllocation(targetId: 'known', quantity: 3),
        BatchAssignmentAllocation(targetId: 'missing', quantity: 2),
      ],
      options: const [
        BatchAllocationPickerOption(id: 'known', title: 'Known title'),
      ],
      selectedIds: selectedIds,
    );

    expect(selectedIds, {'known', 'missing'});
    expect(entries, hasLength(2));
    expect(entries.first.option.title, 'Known title');
    expect(entries.last.option.title, 'missing');
  });

  test('filter options trims lowercases and excludes selected', () {
    final filtered = filterBatchAllocationPickerOptions(
      options: const [
        BatchAllocationPickerOption(id: '1', title: 'Alpha', subtitle: 'Beta'),
        BatchAllocationPickerOption(id: '2', title: 'Gamma', subtitle: 'Delta'),
      ],
      selectedIds: {'2'},
      query: '  beT  ',
    );

    expect(filtered.map((option) => option.id), ['1']);
  });

  test('total parses nonnumeric as zero', () {
    final controller = TextEditingController(text: 'abc');
    addTearDown(controller.dispose);

    expect(
      totalBatchAllocationPickerQuantity([
        BatchAllocationPickerEntry(
          option: const BatchAllocationPickerOption(id: '1', title: 'One'),
          controller: controller,
        ),
      ]),
      0,
    );
  });
}
