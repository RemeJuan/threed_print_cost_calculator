import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage_input.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/app/components/focus_safe_text_field.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/utils/number_parsing.dart';
import 'package:threed_print_cost_calculator/shared/utils/text_input_normalizers.dart';

class UnsavedMaterialRow extends StatefulWidget {
  const UnsavedMaterialRow({
    required this.index,
    required this.usage,
    required this.onWeightChanged,
    required this.onSpoolWeightChanged,
    required this.onSpoolCostChanged,
    this.currencySymbol = '',
    this.currencyPosition = 'before',
    this.currencySpacing = false,
    super.key,
  });

  final int index;
  final MaterialUsageInput usage;
  final ValueChanged<int> onWeightChanged;
  final ValueChanged<num> onSpoolWeightChanged;
  final ValueChanged<num> onSpoolCostChanged;
  final String currencySymbol;
  final String currencyPosition;
  final bool currencySpacing;

  @override
  State<UnsavedMaterialRow> createState() => _UnsavedMaterialRowState();
}

class _UnsavedMaterialRowState extends State<UnsavedMaterialRow> {
  late final TextEditingController _spoolWeightController;
  late final FocusNode _spoolWeightFocusNode;
  late final TextEditingController _spoolCostController;
  late final FocusNode _spoolCostFocusNode;
  late final TextEditingController _weightController;
  late final FocusNode _weightFocusNode;

  String get _spoolWeightText {
    if (widget.usage.unsavedSpoolWeight == 0) return '';
    final v = widget.usage.unsavedSpoolWeight;
    return v == v.toInt() ? v.toInt().toString() : v.toString();
  }

  String get _spoolCostText {
    if (widget.usage.unsavedSpoolCost == 0) return '';
    final v = widget.usage.unsavedSpoolCost;
    return v == v.toInt() ? v.toInt().toString() : v.toString();
  }

  String get _weightText =>
      widget.usage.weightGrams == 0 ? '' : widget.usage.weightGrams.toString();

  @override
  void initState() {
    super.initState();
    _spoolWeightController = TextEditingController(text: _spoolWeightText);
    _spoolWeightFocusNode = FocusNode();
    _spoolCostController = TextEditingController(text: _spoolCostText);
    _spoolCostFocusNode = FocusNode();
    _weightController = TextEditingController(text: _weightText);
    _weightFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _spoolWeightController.dispose();
    _spoolWeightFocusNode.dispose();
    _spoolCostController.dispose();
    _spoolCostFocusNode.dispose();
    _weightController.dispose();
    _weightFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          key: ValueKey<String>(
            'calculator.materials.item.${widget.index}.unsaved.header',
          ),
          l10n.unsavedMaterialHeader,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: TEXT_SECONDARY),
        ),
        const SizedBox(height: kAppSpace8),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Expanded(
                    child: FocusSafeTextField(
                      key: ValueKey<String>(
                        'calculator.materials.item.${widget.index}.spoolWeight.input',
                      ),
                      controller: _spoolWeightController,
                      focusNode: _spoolWeightFocusNode,
                      externalText: _spoolWeightText,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: l10n.customMaterialWeightLabel,
                        suffixText: l10n.gramsSuffix,
                        isDense: true,
                      ),
                      onChanged: (value) {
                        final parsed = parseLocalizedNum(value) ?? 0;
                        widget.onSpoolWeightChanged(parsed);
                      },
                    ),
                  ),
                  const SizedBox(width: kAppSpace12),
                  Expanded(
                    child: FocusSafeTextField(
                      key: ValueKey<String>(
                        'calculator.materials.item.${widget.index}.spoolCost.input',
                      ),
                      controller: _spoolCostController,
                      focusNode: _spoolCostFocusNode,
                      externalText: _spoolCostText,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: l10n.customMaterialCostLabel,
                        isDense: true,
                        prefixText:
                            widget.currencySymbol.isNotEmpty &&
                                widget.currencyPosition == 'before'
                            ? widget.currencySymbol +
                                  (widget.currencySpacing ? ' ' : '')
                            : null,
                        suffixText:
                            widget.currencyPosition == 'after' &&
                                widget.currencySymbol.isNotEmpty
                            ? (widget.currencySpacing ? ' ' : '') +
                                  widget.currencySymbol
                            : null,
                      ),
                      onChanged: (value) {
                        final parsed = parseLocalizedNum(value) ?? 0;
                        widget.onSpoolCostChanged(parsed);
                      },
                    ),
                  ),
                  const SizedBox(width: kAppSpace12),
                ],
              ),
            ),
            const SizedBox(width: kAppSpace8),
            Expanded(
              flex: 2,
              child: FocusSafeTextField(
                key: ValueKey<String>(
                  'calculator.materials.item.${widget.index}.weight.input',
                ),
                controller: _weightController,
                focusNode: _weightFocusNode,
                externalText: _weightText,
                keyboardType: TextInputType.number,
                inputNormalizer: (value) => normalizeLeadingZeroNumericInput(
                  value,
                  allowDecimal: false,
                ),
                decoration: InputDecoration(
                  labelText: l10n.customMaterialUsedLabel,
                  suffixText: l10n.gramsSuffix,
                  isDense: true,
                ),
                onChanged: (value) {
                  final parsedVal = parseLocalizedInt(value);
                  widget.onWeightChanged(parsedVal);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
