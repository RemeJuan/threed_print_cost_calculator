import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_surface_card.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.title,
    required this.child,
    this.headerKey,
    this.bodyKey,
    this.action,
  });

  final Widget title;
  final Widget child;
  final Key? headerKey;
  final Key? bodyKey;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: const EdgeInsets.all(kAppSpace12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            key: headerKey,
            children: [
              Expanded(
                child: DefaultTextStyle(
                  style: Theme.of(context).textTheme.titleMedium!,
                  child: title,
                ),
              ),
              if (action != null) ...[const SizedBox(width: kAppSpace8), action!],
            ],
          ),
          const SizedBox(height: kAppSpace16),
          KeyedSubtree(key: bodyKey, child: child),
        ],
      ),
    );
  }
}
