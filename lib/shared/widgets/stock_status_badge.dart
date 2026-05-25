import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/materials/model/stock_status.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';

const _badgeColors = {
  StockStatus.inStock: STATUS_SUCCESS,
  StockStatus.lowStock: STATUS_WARNING,
  StockStatus.outOfStock: STATUS_NEUTRAL,
  StockStatus.noTracking: STATUS_INFO,
};

class StockStatusBadge extends StatelessWidget {
  const StockStatusBadge({
    super.key,
    required this.status,
    required this.label,
  });

  final StockStatus status;
  final String label;

  @override
  Widget build(BuildContext context) {
    final baseColor = _badgeColors[status]!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: kAppSpace8, vertical: 4),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(kAppBadgeRadius),
        border: Border.all(color: baseColor.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: baseColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
