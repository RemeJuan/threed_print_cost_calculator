import 'batch_allocation_picker_option.dart';

List<BatchAllocationPickerOption> filterBatchAllocationPickerOptions({
  required List<BatchAllocationPickerOption> options,
  required Set<String> selectedIds,
  required String query,
}) {
  final normalizedQuery = query.trim().toLowerCase();
  return options.where((option) {
    if (selectedIds.contains(option.id)) return false;
    if (normalizedQuery.isEmpty) return true;
    return option.title.toLowerCase().contains(normalizedQuery) ||
        (option.subtitle?.toLowerCase().contains(normalizedQuery) ?? false);
  }).toList();
}
