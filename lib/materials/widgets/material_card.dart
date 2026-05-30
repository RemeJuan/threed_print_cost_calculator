import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/materials/color_utils.dart';
import 'package:threed_print_cost_calculator/materials/model/stock_status.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/theme.dart';

import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_surface_card.dart';
import 'package:threed_print_cost_calculator/shared/widgets/stock_status_badge.dart';

class MaterialCard extends ConsumerWidget {
  final MaterialModel material;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;

  const MaterialCard({
    required this.material,
    required this.onEdit,
    required this.onDelete,
    required this.onDuplicate,
    super.key,
  });

  @override
  Widget build(context, ref) {
    final l10n = AppLocalizations.of(context)!;
    final stockTrackingAllowed = ref.watch(premiumAccessPolicyProvider).stockTracking().allowed;

    final swatchColor = colorFromMaterial(
      MaterialColorInput(
        colorName: material.color,
        colorHex: material.colorHex,
      ),
    );

    Widget buildActionContent(IconData icon, String label, Color color) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }

    Future<void> confirmDelete() async {
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

      if (confirm == true) {
        onDelete();
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: kAppSpace16,
        vertical: kAppSpace4,
      ),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.65,
          children: [
            CustomSlidableAction(
              flex: 1,
              onPressed: (_) => onEdit(),
              backgroundColor: LIGHT_BLUE,
              foregroundColor: TEXT_INVERSE,
              padding: EdgeInsets.zero,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(kAppSurfaceRadius),
              ),
              child: buildActionContent(
                Icons.edit,
                l10n.editButton,
                TEXT_INVERSE,
              ),
            ),
            CustomSlidableAction(
              flex: 1,
              onPressed: (_) => onDuplicate(),
              backgroundColor: ACTION_DUPLICATE,
              foregroundColor: TEXT_INVERSE,
              padding: EdgeInsets.zero,
              borderRadius: BorderRadius.zero,
              child: buildActionContent(
                Icons.content_copy,
                l10n.duplicateButton,
                TEXT_INVERSE,
              ),
            ),
            CustomSlidableAction(
              flex: 1,
              onPressed: (_) => confirmDelete(),
              backgroundColor: STATUS_ERROR,
              foregroundColor: TEXT_INVERSE,
              padding: EdgeInsets.zero,
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(kAppSurfaceRadius),
              ),
              child: buildActionContent(
                Icons.delete,
                l10n.deleteButton,
                TEXT_INVERSE,
              ),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(kAppSurfaceRadius),
          onTap: onEdit,
          child: AppSurfaceCard(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: swatchColor,
                    borderRadius: BorderRadius.circular(kAppPillRadius),
                    border: Border.all(color: BORDER_SUBTLE, width: 1),
                  ),
                ),
                const SizedBox(width: kAppSpace12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        material.name,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(color: TEXT_PRIMARY),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: kAppSpace2),
                      _MergedInfoLine(material: material),
                    ],
                  ),
                ),
                if (stockTrackingAllowed) ...[
                  const SizedBox(width: kAppSpace8),
                  StockStatusBadge(
                    status: calculateStockStatus(material),
                    label: switch (calculateStockStatus(material)) {
                      StockStatus.outOfStock => l10n.stockBadgeOut,
                      StockStatus.lowStock => l10n.stockBadgeLow,
                      StockStatus.inStock => l10n.stockBadgeInStock,
                      StockStatus.noTracking => l10n.stockBadgeNoTracking,
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MergedInfoLine extends StatelessWidget {
  final MaterialModel material;

  const _MergedInfoLine({required this.material});

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    if (material.materialType.isNotEmpty) {
      parts.add(material.materialType);
    }
    if (material.brand.isNotEmpty) {
      parts.add(material.brand);
    }
    final cost = double.tryParse(material.cost);
    final weight = double.tryParse(material.weight);
    if (cost != null && weight != null && weight > 0 && cost > 0) {
      final perKg = cost / weight * 1000;
      parts.add('$perKg/kg');
    }
    if (material.autoDeductEnabled && material.weight.isNotEmpty) {
      parts.add('${material.remainingWeight} g');
    }
    if (parts.isEmpty) return const SizedBox.shrink();

    return Text(
      parts.join(' · '),
      style: Theme.of(
        context,
      ).textTheme.bodySmall?.copyWith(color: TEXT_TERTIARY),
    );
  }
}
