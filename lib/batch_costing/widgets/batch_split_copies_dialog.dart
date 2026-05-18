import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:threed_print_cost_calculator/batch_costing/state/batch_costing_state.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';
import 'package:threed_print_cost_calculator/shared/utils/text_input_normalizers.dart';

class BatchSplitCopiesDialog extends StatefulWidget {
  const BatchSplitCopiesDialog({
    super.key,
    required this.itemName,
    required this.itemQuantity,
    required this.allocations,
    required this.printers,
  });

  final String itemName;
  final int itemQuantity;
  final List<BatchAssignmentAllocation> allocations;
  final List<PrinterModel> printers;

  @override
  State<BatchSplitCopiesDialog> createState() => _BatchSplitCopiesDialogState();
}

class _BatchSplitCopiesDialogState extends State<BatchSplitCopiesDialog> {
  late List<_PrinterCopyEntry> _entries;
  final Set<int> _userEditedIndices = {};
  String? _errorText;
  bool _isBalancing = false;

  @override
  void initState() {
    super.initState();
    _entries = _buildEntries();
  }

  List<_PrinterCopyEntry> _buildEntries() {
    final usedPrinters = <String>{};
    final entries = <_PrinterCopyEntry>[];

    for (final allocation in widget.allocations) {
      if (allocation.targetId.isEmpty) continue;
      final printer = widget.printers.firstWhere(
        (p) => p.id == allocation.targetId,
        orElse: () => PrinterModel(
          id: allocation.targetId,
          name: allocation.targetId,
          bedSize: '',
          wattage: '',
          archived: false,
        ),
      );
      usedPrinters.add(printer.id);
      entries.add(
        _PrinterCopyEntry(
          printerId: printer.id,
          printerName: printer.name,
          controller: TextEditingController(
            text: allocation.quantity.toString(),
          ),
        ),
      );
    }

    for (final printer in widget.printers) {
      if (!usedPrinters.contains(printer.id)) {
        entries.add(
          _PrinterCopyEntry(
            printerId: printer.id,
            printerName: printer.name,
            controller: TextEditingController(text: '0'),
          ),
        );
      }
    }

    return entries;
  }

  int get _totalCopies {
    var total = 0;
    for (final entry in _entries) {
      final value = int.tryParse(entry.controller.text) ?? 0;
      total += value;
    }
    return total;
  }

  void _onChanged(int index) {
    if (_isBalancing) return;

    _userEditedIndices.add(index);

    _isBalancing = true;

    final normalized = normalizeLeadingZeroNumericInput(
      _entries[index].controller.text,
      allowDecimal: false,
    );
    final needsNormalize = normalized != _entries[index].controller.text;

    if (needsNormalize) {
      _entries[index].controller.value = TextEditingValue(
        text: normalized,
        selection: TextSelection.collapsed(offset: normalized.length),
        composing: TextRange.empty,
      );
    }

    if (!_userEditedIndices.contains(0)) {
      final othersSum = _entries
          .skip(1)
          .fold<int>(0, (s, e) => s + (int.tryParse(e.controller.text) ?? 0));
      final defaultVal = widget.itemQuantity - othersSum;
      _entries[0].controller.text = defaultVal
          .clamp(0, widget.itemQuantity)
          .toString();
    }

    _isBalancing = false;
    _validate();
  }

  void _validate() {
    final total = _totalCopies;
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      if (total != widget.itemQuantity) {
        _errorText = l10n.batchCostingAssignmentSplitCopiesTotalError(
          widget.itemQuantity.toString(),
        );
      } else {
        _errorText = null;
      }
    });
  }

  void _save() {
    _validate();
    if (_errorText != null) return;

    final result = <BatchAssignmentAllocation>[];
    for (final entry in _entries) {
      final quantity = int.tryParse(entry.controller.text) ?? 0;
      if (quantity > 0 && entry.printerId.isNotEmpty) {
        result.add(
          BatchAssignmentAllocation(
            targetId: entry.printerId,
            quantity: quantity,
          ),
        );
      }
    }

    Navigator.of(context).pop(result);
  }

  @override
  void dispose() {
    for (final entry in _entries) {
      entry.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(
        l10n.batchCostingAssignmentSplitCopiesDialogTitle(widget.itemName),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${l10n.batchCostingReviewQuantityLabel}: ${widget.itemQuantity}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                '${l10n.batchCostingAssignmentSplitCopiesButton}: $_totalCopies',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              for (var i = 0; i < _entries.length; i += 1) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _entries[i].printerName,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 80,
                      child: TextField(
                        controller: _entries[i].controller,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                        ),
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (_) => _onChanged(i),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              if (_errorText != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorText!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancelButton),
        ),
        FilledButton(onPressed: _save, child: Text(l10n.saveButton)),
      ],
    );
  }
}

class _PrinterCopyEntry {
  _PrinterCopyEntry({
    required this.printerId,
    required this.printerName,
    required this.controller,
  });

  final String printerId;
  final String printerName;
  final TextEditingController controller;
}
