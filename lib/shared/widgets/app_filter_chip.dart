import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';

class AppFilterChip extends StatelessWidget {
  const AppFilterChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? LIGHT_BLUE : MUTED_BLUE_GREY;
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(
          color: selected ? LIGHT_BLUE.withValues(alpha: 0.5) : SHELL_BORDER,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? OFF_WHITE : color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );

    if (onTap == null) return chip;

    return Material(
      color: selected ? LIGHT_BLUE.withValues(alpha: 0.12) : CARD_BACKGROUND,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: chip,
      ),
    );
  }
}
