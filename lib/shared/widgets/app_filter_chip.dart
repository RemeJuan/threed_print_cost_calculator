import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';

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
    final textStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
      color: selected ? OFF_WHITE : color,
      fontWeight: FontWeight.w600,
    );
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: kAppSpace12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(
          color: selected ? LIGHT_BLUE.withValues(alpha: 0.5) : SHELL_BORDER,
        ),
        borderRadius: BorderRadius.circular(kAppPillRadius),
      ),
      child: Text(label, style: textStyle),
    );

    if (onTap == null) return chip;

    return Material(
      color: selected ? LIGHT_BLUE.withValues(alpha: 0.12) : CARD_BACKGROUND,
      borderRadius: BorderRadius.circular(kAppPillRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(kAppPillRadius),
        onTap: onTap,
        child: chip,
      ),
    );
  }
}
