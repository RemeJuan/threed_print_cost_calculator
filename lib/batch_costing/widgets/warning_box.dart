import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';

class WarningBox extends StatelessWidget {
  const WarningBox({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(kAppSpace12),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(kAppSurfaceRadius),
      ),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: colors.onErrorContainer),
      ),
    );
  }
}
