import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/materials/model/stock_status.dart';

const _badgeColors = {
  StockStatus.inStock: Color(0xFF2E7D32),
  StockStatus.lowStock: Color(0xFFE65100),
  StockStatus.outOfStock: Color(0xFF616161),
  StockStatus.noTracking: Color(0xFF546E7A),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: baseColor.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: baseColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
