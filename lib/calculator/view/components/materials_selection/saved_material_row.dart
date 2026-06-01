import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage_input.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/app/components/focus_safe_text_field.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/constants.dart';
import 'package:threed_print_cost_calculator/shared/utils/number_parsing.dart';
import 'package:threed_print_cost_calculator/shared/utils/text_input_normalizers.dart';
import 'package:threed_print_cost_calculator/shared/utils/weight_formatting.dart';

class SavedMaterialRow extends StatefulWidget {
  const SavedMaterialRow({
    required this.index,
    required this.usage,
    required this.material,
    required this.onPick,
    required this.onWeightChanged,
    super.key,
  });

  final int index;
  final MaterialUsageInput usage;
  final MaterialModel? material;
  final VoidCallback onPick;
  final ValueChanged<int> onWeightChanged;

  @override
  State<SavedMaterialRow> createState() => _SavedMaterialRowState();
}

class _SavedMaterialRowState extends State<SavedMaterialRow> {
  late final TextEditingController _weightController;
  late final FocusNode _weightFocusNode;

  String get _weightText =>
      widget.usage.weightGrams == 0 ? '' : widget.usage.weightGrams.toString();

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(text: _weightText);
    _weightFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _weightFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isUnassigned =
        widget.usage.materialName.isEmpty ||
        widget.usage.materialName == kUnassignedLabel;

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: InkWell(
            key: ValueKey<String>(
              'calculator.materials.item.${widget.index}.pick.button',
            ),
            onTap: widget.onPick,
            child: Row(
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        key: ValueKey<String>(
                          'calculator.materials.item.${widget.index}.name',
                        ),
                        isUnassigned
                            ? l10n.selectMaterialHint
                            : widget.usage.materialName,
                        style: isUnassigned
                            ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).hintColor,
                              )
                            : Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (widget.material?.autoDeductEnabled == true)
                        Text(
                          key: ValueKey<String>(
                            'calculator.materials.item.${widget.index}.remaining',
                          ),
                          '${l10n.remainingLabel} ${formatWeight(widget.material!.remainingWeight)}${l10n.gramsSuffix}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
                if ((widget.material?.color ?? '').isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: kAppSpace8),
                    child: Text(
                      '(${widget.material!.color})',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ],
            ),
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
            inputNormalizer: (value) =>
                normalizeLeadingZeroNumericInput(value, allowDecimal: false),
            decoration: InputDecoration(suffixText: l10n.gramsSuffix),
            onChanged: (value) {
              final parsedVal = parseLocalizedInt(value);
              widget.onWeightChanged(parsedVal);
            },
          ),
        ),
      ],
    );
  }
}
