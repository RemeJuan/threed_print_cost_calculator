import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';

class AppScreenHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.bottom,
    this.centerTitle = true,
    this.automaticallyImplyLeading = true,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final bool centerTitle;
  final bool automaticallyImplyLeading;

  static const _toolbarHeight = kToolbarHeight;
  static const _subtitleExtra = 24.0;

  @override
  Size get preferredSize {
    final extra = subtitle != null ? _subtitleExtra : 0.0;
    final bottomExtra = bottom?.preferredSize.height ?? 0.0;
    return Size.fromHeight(_toolbarHeight + extra + bottomExtra);
  }

  @override
  Widget build(BuildContext context) {
    final style =
        Theme.of(context).textTheme.headlineSmall ??
        const TextStyle(fontSize: 20, fontWeight: FontWeight.bold);

    final titleWidget = _buildTitle(style);

    return AppBar(
      centerTitle: centerTitle,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading,
      title: subtitle != null
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                titleWidget,
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: MUTED_BLUE_GREY),
                ),
              ],
            )
          : titleWidget,
      actions: actions,
      bottom: bottom,
    );
  }

  Widget _buildTitle(TextStyle style) {
    final words = title.trim().split(RegExp(r'\s+'));

    if (words.length <= 1) {
      return Text(title, style: style.copyWith(color: LIGHT_BLUE));
    }

    return Text.rich(
      TextSpan(
        children: [
          for (int i = 0; i < words.length; i++) ...[
            if (i > 0)
              TextSpan(
                text: ' ',
                style: style.copyWith(color: OFF_WHITE),
              ),
            TextSpan(
              text: words[i],
              style: style.copyWith(
                color: i < words.length - 1 ? OFF_WHITE : LIGHT_BLUE,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
