import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/materials/color_utils.dart';
import 'package:threed_print_cost_calculator/materials/model/stock_status.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/shared/theme.dart';
import 'package:threed_print_cost_calculator/shared/utils/weight_formatting.dart';

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
    final status = calculateStockStatus(material);

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
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
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
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.cancelButton),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.deleteButton),
            ),
          ],
        ),
      );

      if (confirm == true) {
        onDelete();
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Slidable(
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            extentRatio: 0.65,
            children: [
              CustomSlidableAction(
                flex: 1,
                onPressed: (_) => onEdit(),
                backgroundColor: LIGHT_BLUE,
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(12),
                ),
                child: buildActionContent(
                  Icons.edit,
                  l10n.editButton,
                  Colors.white,
                ),
              ),
              CustomSlidableAction(
                flex: 1,
                onPressed: (_) => onDuplicate(),
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
                borderRadius: BorderRadius.zero,
                child: buildActionContent(
                  Icons.content_copy,
                  l10n.duplicateButton,
                  Colors.white,
                ),
              ),
              CustomSlidableAction(
                flex: 1,
                onPressed: (_) => confirmDelete(),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(12),
                ),
                child: buildActionContent(
                  Icons.delete,
                  l10n.deleteButton,
                  Colors.white,
                ),
              ),
            ],
          ),
          child: Card(
            color: DARK_BLUE,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onEdit,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: swatchColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white24, width: 1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            material.name,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: Colors.white),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          _MergedInfoLine(material: material),
                          const SizedBox(height: 4),
                          if (material.autoDeductEnabled)
                            Text(
                              '${formatWeight(material.remainingWeight)}${l10n.gramsSuffix}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StockBadge(status: status, l10n: l10n),
                  ],
                ),
              ),
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

    if (parts.isEmpty) return const SizedBox.shrink();

    return Text(
      parts.join(' · '),
      style: const TextStyle(color: Colors.white54, fontSize: 12),
    );
  }
}

class _StockBadge extends StatelessWidget {
  final StockStatus status;
  final AppLocalizations l10n;

  const _StockBadge({required this.status, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final (Color color, String label) = switch (status) {
      StockStatus.outOfStock => (Colors.red, l10n.stockBadgeOut),
      StockStatus.lowStock => (Colors.orange, l10n.stockBadgeLow),
      StockStatus.inStock => (Colors.green, l10n.stockBadgeInStock),
      StockStatus.noTracking => (Colors.grey, l10n.stockBadgeNoTracking),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(80), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
