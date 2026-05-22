import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';

class HistoryItemMaterialBreakdown extends StatelessWidget {
  const HistoryItemMaterialBreakdown({
    required this.materialUsages,
    required this.materialsById,
    super.key,
  });

  final List<Map<String, dynamic>> materialUsages;
  final Map<String, MaterialModel> materialsById;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: TRANSPARENT_COLOR),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        backgroundColor: TRANSPARENT_COLOR,
        collapsedBackgroundColor: TRANSPARENT_COLOR,
        iconColor: ICON_PRIMARY,
        collapsedIconColor: ICON_MUTED,
        title: Text(
          l10n.materialBreakdownLabel,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: TEXT_SECONDARY),
        ),
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(materialUsages.length, (idx) {
                final usage = materialUsages[idx];
                final weight =
                    int.tryParse(usage['weightGrams'].toString()) ?? 0;

                String materialLabel;
                final materialId = usage['materialId']?.toString();
                if (materialId != null &&
                    materialsById.containsKey(materialId)) {
                  final mat = materialsById[materialId]!;
                  materialLabel = '${mat.name} (${mat.color})';
                } else {
                  materialLabel =
                      usage['materialName']?.toString() ??
                      materialId ??
                      l10n.materialFallback;
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              materialLabel,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: TEXT_SECONDARY),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${weight}g',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: TEXT_TERTIARY),
                          ),
                        ],
                      ),
                    ),
                    if (idx < materialUsages.length - 1)
                      const Divider(height: 1, color: DIVIDER_SUBTLE),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
