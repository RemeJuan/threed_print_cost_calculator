import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';

/// A small header widget for the Materials accordion.
///
/// Props:
/// - [count]: number of material rows
/// - [totalWeight]: total grams across rows
/// - [expanded]: whether the accordion is expanded
/// - [onAdd]: called when the add button is pressed
/// - [onToggle]: called when the header area is tapped to toggle expansion
class MaterialsHeader extends StatelessWidget {
  const MaterialsHeader({
    required this.count,
    required this.totalWeight,
    required this.expanded,
    required this.onAdd,
    required this.onToggle,
    super.key,
  });

  final int count;
  final int totalWeight;
  final bool expanded;
  final VoidCallback onAdd;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    final rawCountLabel = l10n.materialsCountLabel(count);
    final countText = rawCountLabel.contains('#')
        ? rawCountLabel.replaceAll('#', count.toString())
        : rawCountLabel;
    final summary = '$countText · ${totalWeight}g';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: DefaultTextStyle(
                  style: Theme.of(context).textTheme.titleMedium!,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.materialsHeader),
                            const SizedBox(height: 4),
                            Text(
                              summary,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color:
                                        (Theme.of(
                                                  context,
                                                ).textTheme.bodySmall?.color ??
                                                Colors.black)
                                            .withAlpha((0.7 * 255).round()),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add),
                ),
              ),
              AnimatedRotation(
                turns: expanded ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: Icon(
                  Icons.expand_more,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
