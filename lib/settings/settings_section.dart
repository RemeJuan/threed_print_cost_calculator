import 'package:flutter/material.dart';

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
    return Card(
      color: const Color.fromRGBO(8, 8, 18, 1),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                if (action != null) ...[const SizedBox(width: 8), action!],
              ],
            ),
            const SizedBox(height: 16),
            KeyedSubtree(key: bodyKey, child: child),
          ],
        ),
      ),
    );
  }
}
