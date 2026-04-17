import 'dart:async';

import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/history/components/history_item.dart';
import 'package:threed_print_cost_calculator/history/model/history_entry.dart';

class HistoryListView extends StatelessWidget {
  const HistoryListView({
    required this.items,
    this.onHistoryLoaded,
    this.onOverflowMenuOpened,
    super.key,
  });

  final List<HistoryEntry> items;
  final Future<void> Function()? onHistoryLoaded;
  final Future<void> Function()? onOverflowMenuOpened;

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: items.length,
      itemBuilder: (_, index) {
        final entry = items[index];
        return HistoryItem(
          dbKey: entry.key.toString(),
          data: entry.model,
          onHistoryLoaded: onHistoryLoaded,
          onOverflowMenuOpened: onOverflowMenuOpened == null
              ? null
              : () {
                  unawaited(onOverflowMenuOpened!.call());
                },
        );
      },
    );
  }
}
