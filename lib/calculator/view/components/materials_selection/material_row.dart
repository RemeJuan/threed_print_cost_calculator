import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage_input.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/app/components/focus_safe_text_field.dart';
import 'package:threed_print_cost_calculator/shared/constants.dart';
import 'package:threed_print_cost_calculator/shared/utils/number_parsing.dart';
import 'package:threed_print_cost_calculator/shared/utils/text_input_normalizers.dart';

/// Single material row used inside the materials list.
///
/// This widget is intentionally dumb: it accepts callbacks for actions and
/// does not own any business logic.
class MaterialRow extends StatefulWidget {
  const MaterialRow({
    required this.index,
    required this.usage,
    required this.material,
    required this.onPick,
    required this.onWeightChanged,
    required this.onRemove,
    super.key,
  });

  final int index;
  final MaterialUsageInput usage;
  final MaterialModel? material;
  final VoidCallback onPick;
  final ValueChanged<int> onWeightChanged;
  final VoidCallback onRemove;

  @override
  State<MaterialRow> createState() => _MaterialRowState();
}

class _MaterialRowState extends State<MaterialRow> {
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
    final colorString = widget.material?.color ?? '';
    final remainingWeight = widget.material?.remainingWeight ?? 0;
    final id = widget.usage.materialId.trim();
    final rowKey = id.isNotEmpty ? id : '__row_${widget.index}';

    String formatWeight(num value) {
      return value % 1 == 0
          ? value.toStringAsFixed(0)
          : value.toStringAsFixed(1);
    }

    final isMaterialUnassigned =
        widget.usage.materialName.isEmpty ||
        widget.usage.materialName == kUnassignedLabel;

    Widget rowContent = Row(
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
                        isMaterialUnassigned
                            ? l10n.selectMaterialHint
                            : widget.usage.materialName,
                        style: isMaterialUnassigned
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
                          '${l10n.remainingLabel} ${formatWeight(remainingWeight)}${l10n.gramsSuffix}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
                if (colorString.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      '($colorString)',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
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

    final keyedRow = KeyedSubtree(key: ValueKey(rowKey), child: rowContent);

    final idTrim = widget.usage.materialId.trim();
    // Deletable when a material id is present. Allow empty lists and do not
    // special-case a literal 'none'.
    final isDeletable = idTrim.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: isDeletable
          ? Slidable(
              key: ValueKey('material_slidable_${widget.index}'),
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (ctx) async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: Text(l10n.deleteDialogTitle),
                          content: Text(l10n.deleteDialogContent),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext, false),
                              child: Text(l10n.cancelButton),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext, true),
                              child: Text(l10n.deleteButton),
                            ),
                          ],
                        ),
                      );
                      if (confirm != true) return;
                      widget.onRemove();
                    },
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: l10n.deleteButton,
                  ),
                ],
              ),
              child: keyedRow,
            )
          : keyedRow,
    );
  }
}
