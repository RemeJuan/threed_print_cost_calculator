import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_surface_card.dart';

class AppExpansionCard extends StatelessWidget {
  const AppExpansionCard({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.initiallyExpanded = false,
    this.onExpansionChanged,
    this.tilePadding = const EdgeInsets.symmetric(horizontal: kAppSpace16),
    this.childrenPadding = const EdgeInsets.fromLTRB(
      kAppSpace16,
      0,
      kAppSpace16,
      kAppSpace16,
    ),
    this.margin,
  });

  final Widget title;
  final Widget? subtitle;
  final List<Widget> children;
  final bool initiallyExpanded;
  final ValueChanged<bool>? onExpansionChanged;
  final EdgeInsetsGeometry tilePadding;
  final EdgeInsetsGeometry childrenPadding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: EdgeInsets.zero,
      margin: margin,
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        onExpansionChanged: onExpansionChanged,
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: tilePadding,
        childrenPadding: childrenPadding,
        visualDensity: VisualDensity.compact,
        title: title,
        subtitle: subtitle,
        children: children,
      ),
    );
  }
}
