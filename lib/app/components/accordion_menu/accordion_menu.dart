import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:threed_print_cost_calculator/app/components/accordion_menu/providers/accordion_notifier.dart';

import 'model/accordion_item_model.dart';

/// AccordionMenu displays a list of [AccordionItem]s using an
/// [ExpansionPanelList]. By default it allows only one open panel at a time
/// (accordion behaviour). Set [allowMultipleOpen] to true to allow multiple
/// expanded panels.
class AccordionMenu extends HookConsumerWidget {
  final List<AccordionItem> items;
  final bool allowMultipleOpen;
  final EdgeInsetsGeometry padding;

  const AccordionMenu({
    super.key,
    required this.items,
    this.allowMultipleOpen = false,
    this.padding = const EdgeInsets.all(8),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final openIndices = ref.watch(accordionOpenPanelProvider);

    // Initialize provider with any items that requested `initiallyExpanded`.
    // Use a local ref to ensure we only initialize once per widget mount.
    final initialized = useRef<bool>(false);
    useEffect(() {
      if (initialized.value) return null;

      final initial = items
          .asMap()
          .entries
          .where((e) => e.value.initiallyExpanded || e.value.isLocked)
          .map((e) => e.key)
          .toSet();

      if (initial.isNotEmpty) {
        // Schedule setting initial open indices after the first frame to
        // avoid modifying providers during the widget build lifecycle.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(accordionOpenPanelProvider.notifier).setOpen(initial);
        });
      }

      initialized.value = true;
      return null;
    }, const []);

    // Custom implementation: for each item, render a single unified touch
    // header (InkWell) with a chevron that we rotate using
    // AnimatedRotation. The body is shown/hidden with AnimatedCrossFade and
    // AnimatedSize so the expand/collapse animation is smooth and in sync
    // with the chevron rotation and the header ripple.
    return Card(
      color: const Color.fromRGBO(8, 8, 18, 1),
      margin: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          // Expansion is now driven solely by the provider (Set<int>).
          // "initiallyExpanded" is applied once on mount into the provider
          // so we don't rely on a fallback here.
          final isExpanded = openIndices.contains(index);

          return Column(
            key: ValueKey(index),
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: item.isLocked
                      ? null
                      : () => ref
                            .read(accordionOpenPanelProvider.notifier)
                            .toggle(index),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: DefaultTextStyle(
                            style: Theme.of(context).textTheme.titleMedium!,
                            child: item.header,
                          ),
                        ),
                        // Optional action widget (e.g., IconButton) shown to the left of the chevron.
                        if (item.action != null) ...[
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: item.action,
                          ),
                        ],
                        if (!item.isLocked)
                          AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0.0,
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
              ),

              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: item.body,
                ),
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
                firstCurve: Curves.easeInOut,
                secondCurve: Curves.easeInOut,
                sizeCurve: Curves.easeInOut,
              ),
              if (index != items.length - 1) const Divider(height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }
}

/// Example usage:
///
/// AccordionMenu(
///   items: [
///     AccordionItem(
///       header: Text('Printer settings'),
///       body: Text('Configure bed size, wattage, etc.'),
///     ),
///     AccordionItem(
///       header: Text('Material profiles'),
///       body: Text('Manage filament costs and densities.'),
///     ),
///   ],
/// )
