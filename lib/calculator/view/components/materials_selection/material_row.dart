import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage_input.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';
import 'package:threed_print_cost_calculator/shared/constants.dart';

/// Single material row used inside the materials list.
///
/// This widget is intentionally dumb: it accepts callbacks for actions and
/// does not own any business logic.
class MaterialRow extends StatelessWidget {
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

  Color? _tryParseHexColor(String input) {
    final hex = input.replaceAll('#', '').trim();
    if (hex.isEmpty) return null;
    final isHex = RegExp(r'^[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$').hasMatch(hex);
    if (!isHex) return null;
    try {
      final value = int.parse(hex, radix: 16);
      return Color(hex.length == 6 ? (0xFF000000 | value) : value);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final colorString = material?.color ?? '';
    final parsed = _tryParseHexColor(colorString);
    final id = usage.materialId.trim();
    final rowKey = id.isNotEmpty ? id : '__row_$index';

    final isMaterialUnassigned =
        usage.materialName.isEmpty || usage.materialName == kUnassignedLabel;

    Widget rowContent = Row(
      children: [
        Expanded(
          flex: 3,
          child: InkWell(
            onTap: onPick,
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    isMaterialUnassigned
                        ? l10n.selectMaterialHint
                        : usage.materialName,
                    style: isMaterialUnassigned
                        ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).hintColor,
                          )
                        : Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                if (parsed != null) ...[
                  Container(
                    width: 14,
                    height: 14,
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: parsed,
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: Colors.black12),
                    ),
                  ),
                ] else if (colorString.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      '- ($colorString)',
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
          child: TextFormField(
            // Use a key tied to the usage so the field is reconstructed when
            // the parent updates the usage (weight changes). This keeps the
            // simple StatelessWidget pattern without managing controllers here.
            key: Key('weight-${usage.materialId}-$index-${usage.weightGrams}'),
            initialValue: usage.weightGrams == 0
                ? ''
                : usage.weightGrams.toString(),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(suffixText: l10n.gramsSuffix),
            onChanged: (value) {
              final parsedVal =
                  num.tryParse(value.replaceAll(',', '.'))?.toInt() ?? 0;
              onWeightChanged(parsedVal);
            },
          ),
        ),
      ],
    );

    final keyedRow = KeyedSubtree(key: ValueKey(rowKey), child: rowContent);

    final idTrim = usage.materialId.trim();
    final isDeletable =
        idTrim.isNotEmpty && idTrim.toLowerCase() != kNoneMaterialId;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: isDeletable
          ? Slidable(
              key: ValueKey('material_slidable_$index'),
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
                      onRemove();
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
