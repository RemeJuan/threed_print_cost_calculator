import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_policy.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_surface_card.dart';

class PaywallComparisonTable extends StatelessWidget {
  const PaywallComparisonTable({
    super.key,
    required this.policy,
    required this.l10n,
  });

  final PremiumAccessPolicy policy;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final rows = [...policy.paywallComparisonRows]
      ..sort((a, b) => a.order.compareTo(b.order));

    return AppSurfaceCard(
      padding: const EdgeInsets.only(top: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < rows.length; i++)
            _buildRow(
              context,
              rows[i],
              isEven: i.isEven,
              isLast: i == rows.length - 1,
            ),
        ],
      ),
    );
  }

  Widget _buildRow(
    BuildContext context,
    PaywallComparisonRow row, {
    required bool isEven,
    required bool isLast,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: kAppSpace16,
        vertical: isLast ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: isEven ? OFF_WHITE.withValues(alpha: 0.02) : Colors.transparent,
        borderRadius: BorderRadius.circular(kAppBadgeRadius),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              _paywallRowLabel(l10n, row.labelKey),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: row.emphasis ? FontWeight.w600 : FontWeight.w400,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _cellDisplayValue(row.freeCell, l10n),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: TEXT_SECONDARY),
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              _cellDisplayValue(row.premiumCell, l10n),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: LIGHT_BLUE,
              ),
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

String _cellDisplayValue(ComparisonCell cell, AppLocalizations l10n) {
  return switch (cell.type) {
    CellType.text => _cellText(l10n, cell.textKey!),
    CellType.count => '${cell.limit}',
    CellType.saves => l10n.paywallValueSaves(cell.limit!),
    CellType.upTo => l10n.paywallValueUpToModels(cell.limit!),
  };
}

String _cellText(AppLocalizations l10n, String key) {
  return switch (key) {
    'paywallValueUnlimited' => l10n.paywallValueUnlimited,
    'paywallValueYes' => l10n.paywallValueYes,
    'paywallValueNo' => l10n.paywallValueNo,
    'paywallValueBasic' => l10n.paywallValueBasic,
    'paywallValueFull' => l10n.paywallValueFull,
    'paywallValueSingleJob' => l10n.paywallValueSingleJob,
    'paywallValueFullSuite' => l10n.paywallValueFullSuite,
    _ => key,
  };
}

String _paywallRowLabel(AppLocalizations l10n, String key) {
  return switch (key) {
    'paywallRowPrintersLabel' => l10n.paywallRowPrintersLabel,
    'paywallRowMaterialsLabel' => l10n.paywallRowMaterialsLabel,
    'paywallRowHistoryLabel' => l10n.paywallRowHistoryLabel,
    'paywallRowBatchCostingLabel' => l10n.paywallRowBatchCostingLabel,
    'paywallRowAdvancedPricingLabel' => l10n.paywallRowAdvancedPricingLabel,
    'paywallRowExportToolsLabel' => l10n.paywallRowExportToolsLabel,
    'paywallRowInventoryTrackingLabel' => l10n.paywallRowInventoryTrackingLabel,
    _ => key,
  };
}
