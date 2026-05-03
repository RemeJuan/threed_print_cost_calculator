import 'package:flutter/material.dart';

class HelpSupportSectionHeader extends StatelessWidget {
  const HelpSupportSectionHeader({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}
