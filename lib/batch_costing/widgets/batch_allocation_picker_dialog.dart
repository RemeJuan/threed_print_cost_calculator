import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:threed_print_cost_calculator/batch_costing/state/batch_costing_state.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/utils/text_input_normalizers.dart';

class BatchAllocationPickerOption {
  const BatchAllocationPickerOption({
    required this.id,
    required this.title,
    this.subtitle,
  });

  final String id;
  final String title;
  final String? subtitle;
}

class BatchAllocationPickerDialog extends StatefulWidget {
  const BatchAllocationPickerDialog({
    super.key,
    required this.title,
    required this.itemQuantity,
    required this.allocations,
    required this.options,
  });

  final String title;
  final int itemQuantity;
  final List<BatchAssignmentAllocation> allocations;
  final List<BatchAllocationPickerOption> options;

  @override
  State<BatchAllocationPickerDialog> createState() =>
      _BatchAllocationPickerDialogState();
}

class _BatchAllocationPickerDialogState extends State<BatchAllocationPickerDialog> {
  final _searchController = TextEditingController();
  final Set<String> _selectedIds = {};
  late List<_AllocationEntry> _entries;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _entries = _buildEntries();
  }

  List<_AllocationEntry> _buildEntries() {
    final entries = <_AllocationEntry>[];
    for (final allocation in widget.allocations) {
      if (allocation.targetId.isEmpty) continue;
      _selectedIds.add(allocation.targetId);
      final option = widget.options.firstWhere(
        (option) => option.id == allocation.targetId,
        orElse: () => BatchAllocationPickerOption(
          id: allocation.targetId,
          title: allocation.targetId,
        ),
      );
      entries.add(
        _AllocationEntry(
          option: option,
          controller: TextEditingController(text: allocation.quantity.toString()),
        ),
      );
    }
    return entries;
  }

  List<BatchAllocationPickerOption> get _filteredOptions {
    final query = _searchController.text.trim().toLowerCase();
    return widget.options.where((option) {
      if (_selectedIds.contains(option.id)) return false;
      if (query.isEmpty) return true;
      return option.title.toLowerCase().contains(query) ||
          (option.subtitle?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  int get _total => _entries.fold<int>(0, (sum, entry) => sum + (int.tryParse(entry.controller.text) ?? 0));

  void _validate() {
    setState(() {
      _errorText = _total == widget.itemQuantity
          ? null
          : AppLocalizations.of(context)!.batchCostingAssignmentSplitCopiesTotalError(widget.itemQuantity.toString());
    });
  }

  void _addOption(BatchAllocationPickerOption option) {
    setState(() {
      _selectedIds.add(option.id);
      _entries.add(_AllocationEntry(option: option, controller: TextEditingController(text: '0')));
      _searchController.clear();
      _validate();
    });
  }

  void _removeEntry(int index) {
    setState(() {
      _selectedIds.remove(_entries[index].option.id);
      _entries[index].controller.dispose();
      _entries.removeAt(index);
      _validate();
    });
  }

  void _onQuantityChanged(int index) {
    final normalized = normalizeLeadingZeroNumericInput(_entries[index].controller.text, allowDecimal: false);
    if (normalized != _entries[index].controller.text) {
      _entries[index].controller.value = TextEditingValue(text: normalized, selection: TextSelection.collapsed(offset: normalized.length));
    }
    _validate();
  }

  void _save() {
    _validate();
    if (_errorText != null) return;
    Navigator.of(context).pop([
      for (final entry in _entries)
        BatchAssignmentAllocation(targetId: entry.option.id, quantity: int.tryParse(entry.controller.text) ?? 0)
    ]);
  }

  @override
  void dispose() {
    _searchController.dispose();
    for (final entry in _entries) {
      entry.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        child: StatefulBuilder(
          builder: (context, setLocalState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              Text('${l10n.batchCostingReviewQuantityLabel}: ${widget.itemQuantity}'),
              Text('${l10n.batchCostingAssignmentCopiesLabel}: $_total'),
              const SizedBox(height: 12),
              TextField(
                key: const ValueKey('allocation_picker_search'),
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: l10n.batchCostingAllocationPickerSearchLabel,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (_) => setLocalState(() {}),
              ),
              const SizedBox(height: 12),
              Text(l10n.batchCostingAllocationPickerSelectedLabel, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              for (var i = 0; i < _entries.length; i += 1) ...[
                Row(
                  children: [
                    Expanded(child: Text(_entries[i].option.title, overflow: TextOverflow.ellipsis)),
                    if (_entries[i].option.subtitle != null) ...[
                      const SizedBox(width: 8),
                      Expanded(child: Text(_entries[i].option.subtitle!, overflow: TextOverflow.ellipsis)),
                    ],
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 72,
                      child: TextField(
                        key: ValueKey('allocation_picker_qty_$i'),
                        controller: _entries[i].controller,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (_) => _onQuantityChanged(i),
                      ),
                    ),
                    IconButton(onPressed: () => _removeEntry(i), icon: const Icon(Icons.remove_circle_outline)),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 4),
              Text(l10n.batchCostingAllocationPickerAvailableLabel, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              if (_filteredOptions.isEmpty)
                Text(l10n.batchCostingAllocationPickerNoResultsLabel)
              else
                for (final option in _filteredOptions) ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(option.title),
                  subtitle: option.subtitle == null ? null : Text(option.subtitle!),
                  trailing: OutlinedButton(
                    onPressed: () => _addOption(option),
                    child: Text(l10n.batchCostingAllocationPickerAddButton),
                  ),
                ),
              if (_errorText != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_errorText!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancelButton)),
        FilledButton(onPressed: _save, child: Text(l10n.saveButton)),
      ],
    );
  }
}

class _AllocationEntry {
  _AllocationEntry({required this.option, required this.controller});
  final BatchAllocationPickerOption option;
  final TextEditingController controller;
}
