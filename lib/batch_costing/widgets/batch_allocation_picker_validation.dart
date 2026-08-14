import 'batch_allocation_picker_entry.dart';

int totalBatchAllocationPickerQuantity(
  List<BatchAllocationPickerEntry> entries,
) => entries.fold<int>(
  0,
  (sum, entry) => sum + (int.tryParse(entry.controller.text) ?? 0),
);
