import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';

class AppSurfaceCard extends StatelessWidget {
  const AppSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(kAppSpace16),
    this.margin,
    this.backgroundColor = CARD_BACKGROUND,
    this.borderRadius = kAppSurfaceRadius,
    this.elevation = 0,
    this.width,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color backgroundColor;
  final double borderRadius;
  final double elevation;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      width: width,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        elevation: elevation,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
