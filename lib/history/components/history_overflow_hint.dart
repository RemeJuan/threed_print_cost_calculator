import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';

class HistoryOverflowHint extends StatelessWidget {
  const HistoryOverflowHint({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        kAppSpace12,
        0,
        kAppSpace12,
        kAppSpace4,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(kAppSurfaceRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: kAppSpace12,
            vertical: kAppSpace12,
          ),
          child: Row(children: [Expanded(child: Text(message))]),
        ),
      ),
    );
  }
}
