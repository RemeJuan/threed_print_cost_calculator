import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/utils/text_input_normalizers.dart';

class BatchCostingItemEditorResult {
  const BatchCostingItemEditorResult({
    required this.displayName,
    required this.quantity,
    required this.printWeightG,
    required this.printDuration,
  });

  final String displayName;
  final int quantity;
  final double printWeightG;
  final Duration printDuration;
}

class BatchCostingItemEditorDialog extends StatefulWidget {
  const BatchCostingItemEditorDialog({
    required this.title,
    required this.initialDisplayName,
    required this.initialQuantity,
    this.initialPrintWeightG,
    this.initialPrintDuration,
    super.key,
  });

  final String title;
  final String initialDisplayName;
  final int initialQuantity;
  final double? initialPrintWeightG;
  final Duration? initialPrintDuration;

  @override
  State<BatchCostingItemEditorDialog> createState() =>
      _BatchCostingItemEditorDialogState();
}

class _BatchCostingItemEditorDialogState
    extends State<BatchCostingItemEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _displayNameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _printWeightController;
  late final TextEditingController _durationHoursController;
  late final TextEditingController _durationMinutesController;
  late final FocusNode _displayNameFocusNode;
  late final FocusNode _quantityFocusNode;
  late final FocusNode _printWeightFocusNode;
  late final FocusNode _durationHoursFocusNode;
  late final FocusNode _durationMinutesFocusNode;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(
      text: widget.initialDisplayName,
    );
    _quantityController = TextEditingController(
      text: widget.initialQuantity.toString(),
    );
    _printWeightController = TextEditingController(
      text: widget.initialPrintWeightG != null
          ? widget.initialPrintWeightG.toString().replaceFirst(
              RegExp(r'\.0$'),
              '',
            )
          : '',
    );
    _durationHoursController = TextEditingController(
      text: widget.initialPrintDuration?.inHours.toString() ?? '',
    );
    _durationMinutesController = TextEditingController(
      text:
          widget.initialPrintDuration?.inMinutes.remainder(60).toString() ?? '',
    );
    _displayNameFocusNode = FocusNode();
    _quantityFocusNode = FocusNode();
    _printWeightFocusNode = FocusNode();
    _durationHoursFocusNode = FocusNode();
    _durationMinutesFocusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _displayNameFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _quantityController.dispose();
    _printWeightController.dispose();
    _durationHoursController.dispose();
    _durationMinutesController.dispose();
    _displayNameFocusNode.dispose();
    _quantityFocusNode.dispose();
    _printWeightFocusNode.dispose();
    _durationHoursFocusNode.dispose();
    _durationMinutesFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                key: const ValueKey<String>('batch-costing-item-name'),
                controller: _displayNameController,
                focusNode: _displayNameFocusNode,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: l10n.batchCostingItemNameLabel,
                  hintText: l10n.printNameHint,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.csvNameRequiredError;
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _quantityFocusNode.requestFocus(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey<String>('batch-costing-item-quantity'),
                controller: _quantityController,
                focusNode: _quantityFocusNode,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: l10n.batchCostingReviewQuantityLabel,
                ),
                validator: (value) {
                  final quantity = int.tryParse(value ?? '');
                  if (quantity == null || quantity < 1) {
                    return l10n.invalidNumber;
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _printWeightFocusNode.requestFocus(),
                onChanged: (_) => _normalizeIntegerController(
                  _quantityController,
                  allowDecimal: false,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey<String>('batch-costing-item-weight'),
                controller: _printWeightController,
                focusNode: _printWeightFocusNode,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d\.,]')),
                ],
                decoration: InputDecoration(
                  labelText: l10n.printWeightLabel,
                  suffixText: l10n.gramsSuffix,
                ),
                validator: (value) {
                  final parsed = _parseDouble(value);
                  if (parsed == null || parsed <= 0) {
                    return l10n.invalidNumber;
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _durationHoursFocusNode.requestFocus(),
                onChanged: (_) => _normalizeWeightController(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      key: const ValueKey<String>(
                        'batch-costing-item-duration-hours',
                      ),
                      controller: _durationHoursController,
                      focusNode: _durationHoursFocusNode,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: l10n.durationHoursLabel,
                      ),
                      validator: (value) {
                        final hours = int.tryParse(value ?? '');
                        if (hours == null || hours < 0) {
                          return l10n.invalidNumber;
                        }
                        final minutes = int.tryParse(
                          _durationMinutesController.text,
                        );
                        if (hours == 0 && (minutes == null || minutes == 0)) {
                          return l10n.invalidNumber;
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) =>
                          _durationMinutesFocusNode.requestFocus(),
                      onChanged: (_) => _normalizeIntegerController(
                        _durationHoursController,
                        allowDecimal: false,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      key: const ValueKey<String>(
                        'batch-costing-item-duration-minutes',
                      ),
                      controller: _durationMinutesController,
                      focusNode: _durationMinutesFocusNode,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: l10n.durationMinutesLabel,
                      ),
                      validator: (value) {
                        final minutes = int.tryParse(value ?? '');
                        if (minutes == null || minutes < 0 || minutes > 59) {
                          return l10n.invalidNumber;
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _save(context),
                      onChanged: (_) => _normalizeIntegerController(
                        _durationMinutesController,
                        allowDecimal: false,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        FilledButton(
          key: const ValueKey<String>('batch-costing-item-editor-save'),
          onPressed: () => _save(context),
          child: Text(l10n.saveButton),
        ),
      ],
    );
  }

  void _normalizeIntegerController(
    TextEditingController controller, {
    required bool allowDecimal,
  }) {
    final normalized = normalizeLeadingZeroNumericInput(
      controller.text,
      allowDecimal: allowDecimal,
    );
    if (normalized == controller.text) return;

    controller.value = TextEditingValue(
      text: normalized,
      selection: TextSelection.collapsed(offset: normalized.length),
      composing: TextRange.empty,
    );
  }

  void _normalizeWeightController() {
    final normalized = normalizeLeadingZeroNumericInput(
      _printWeightController.text,
      allowDecimal: true,
    );
    if (normalized == _printWeightController.text) return;

    _printWeightController.value = TextEditingValue(
      text: normalized,
      selection: TextSelection.collapsed(offset: normalized.length),
      composing: TextRange.empty,
    );
  }

  double? _parseDouble(String? value) {
    final normalized = value?.replaceAll(',', '.');
    return double.tryParse(normalized ?? '');
  }

  void _save(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final quantity = int.parse(_quantityController.text);
    final printWeightG = _parseDouble(_printWeightController.text)!;
    final duration = Duration(
      hours: int.parse(_durationHoursController.text),
      minutes: int.parse(_durationMinutesController.text),
    );

    Navigator.of(context).pop(
      BatchCostingItemEditorResult(
        displayName: _displayNameController.text.trim(),
        quantity: quantity,
        printWeightG: printWeightG,
        printDuration: duration,
      ),
    );
  }
}
