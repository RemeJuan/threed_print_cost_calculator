import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/shared/theme.dart';

class AppScreenHeader extends StatelessWidget {
  const AppScreenHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).appBarTheme.titleTextStyle ??
        const TextStyle(fontSize: 20, fontWeight: FontWeight.bold);

    final words = title.trim().split(RegExp(r'\s+'));

    if (words.length <= 1) {
      return Text(title, style: style.copyWith(color: LIGHT_BLUE));
    }

    return Text.rich(
      TextSpan(
        children: [
          for (int i = 0; i < words.length; i++) ...[
            if (i > 0)
              TextSpan(text: ' ', style: style.copyWith(color: OFF_WHITE)),
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
