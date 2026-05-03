import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/materials/color_utils.dart';
import 'package:threed_print_cost_calculator/materials/model/stock_status.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/shared/theme.dart';
import 'package:threed_print_cost_calculator/shared/utils/format_utils.dart';

class MaterialCard extends ConsumerWidget {
  final MaterialModel material;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MaterialCard({
    required this.material,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(context, ref) {
    final l10n = AppLocalizations.of(context)!;
    final status = calculateStockStatus(material);
    final currencyAsync = ref.watch(settingsStreamProvider);
    final currencySettings = currencyAsync is AsyncData<GeneralSettingsModel>
        ? currencyAsync.value
        : GeneralSettingsModel.initial();

    String formatWeight(double value) {
      return value % 1 == 0
          ? value.toStringAsFixed(0)
          : value.toStringAsFixed(1);
    }

    final swatchColor = colorFromMaterial(
      MaterialColorInput(
        colorName: material.color,
        colorHex: material.colorHex,
      ),
    );

    return Card(
      color: DARK_BLUE,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(color: Colors.white),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    _MergedInfoLine(
                      material: material,
                      currencySettings: currencySettings,
                    ),
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
    );
  }
}

class _MergedInfoLine extends StatelessWidget {
  final MaterialModel material;
  final GeneralSettingsModel currencySettings;

  const _MergedInfoLine({required this.material, required this.currencySettings});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
      parts.add(
        l10n.materialCostPerKilogramLabel(
          formatCurrencyValue(
            perKg,
            currencySymbol: currencySettings.currencySymbol,
            currencyPosition: currencySettings.currencyPosition,
            currencySpacing: currencySettings.currencySpacing,
          ),
        ),
      );
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
