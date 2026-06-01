import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage_input.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';
import 'saved_material_row.dart';
import 'unsaved_material_row.dart';

class MaterialRow extends StatelessWidget {
  const MaterialRow({
    required this.index,
    required this.usage,
    required this.material,
    this.isUnsaved = false,
    required this.onPick,
    required this.onWeightChanged,
    required this.onRemove,
    this.onSpoolWeightChanged,
    this.onSpoolCostChanged,
    this.currencySymbol = '',
    this.currencyPosition = 'before',
    this.currencySpacing = false,
    super.key,
  });

  final int index;
  final MaterialUsageInput usage;
  final MaterialModel? material;
  final bool isUnsaved;
  final VoidCallback onPick;
  final ValueChanged<int> onWeightChanged;
  final VoidCallback onRemove;
  final ValueChanged<num>? onSpoolWeightChanged;
  final ValueChanged<num>? onSpoolCostChanged;
  final String currencySymbol;
  final String currencyPosition;
  final bool currencySpacing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final id = usage.materialId.trim();
    final rowKey = id.isNotEmpty ? id : '__row_$index';
    final isDeletable = id.isNotEmpty;

    final rowContent = isUnsaved
        ? UnsavedMaterialRow(
            index: index,
            usage: usage,
            onWeightChanged: onWeightChanged,
            onSpoolWeightChanged: onSpoolWeightChanged ?? (_) {},
            onSpoolCostChanged: onSpoolCostChanged ?? (_) {},
            currencySymbol: currencySymbol,
            currencyPosition: currencyPosition,
            currencySpacing: currencySpacing,
          )
        : SavedMaterialRow(
            index: index,
            usage: usage,
            material: material,
            onPick: onPick,
            onWeightChanged: onWeightChanged,
          );

    final keyedRow = KeyedSubtree(key: ValueKey(rowKey), child: rowContent);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kAppSpace8),
      child: isDeletable ? _buildSwipableRow(context, keyedRow, l10n) : keyedRow,
    );
  }

  Widget _buildSwipableRow(
    BuildContext context,
    Widget child,
    AppLocalizations l10n,
  ) {
    return Slidable(
      key: ValueKey('material_slidable_$index'),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.3,
        children: [
          const SizedBox(width: kAppSpace12),
          CustomSlidableAction(
            flex: 1,
            onPressed: (ctx) async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: Text(l10n.deleteDialogTitle),
                  content: Text(l10n.deleteDialogContent),
                  actions: [
                    AppTertiaryButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      label: l10n.cancelButton,
                    ),
                    AppTertiaryButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      label: l10n.deleteButton,
                    ),
                  ],
                ),
              );
              if (confirm != true) return;
              onRemove();
            },
            backgroundColor: STATUS_ERROR,
            foregroundColor: TEXT_INVERSE,
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(kAppSurfaceRadius),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: kAppSpace8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.delete, size: 20, color: TEXT_INVERSE),
                  const SizedBox(height: kAppSpace4),
                  Text(
                    l10n.deleteButton,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: TEXT_INVERSE,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      child: child,
    );
  }
}
