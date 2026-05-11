import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:threed_print_cost_calculator/history/components/history_item_actions.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/shared/utils/csv_utils.dart';

class HistoryItemHeader extends StatelessWidget {
  const HistoryItemHeader({
    required this.dbKey,
    required this.data,
    required this.itemKeyPrefix,
    this.onHistoryLoaded,
    this.onOverflowMenuOpened,
    this.deleteHistoryEntry,
    this.exportCsv = exportCSVFile,
    super.key,
  });

  final String dbKey;
  final HistoryModel data;
  final String itemKeyPrefix;
  final Future<void> Function()? onHistoryLoaded;
  final VoidCallback? onOverflowMenuOpened;
  final Future<void> Function(WidgetRef ref, String dbKey)? deleteHistoryEntry;
  final HistoryItemExportCsv exportCsv;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          key: ValueKey<String>('$itemKeyPrefix.name'),
          data.name,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        HistoryItemActions(
          dbKey: dbKey,
          data: data,
          itemKeyPrefix: itemKeyPrefix,
          onHistoryLoaded: onHistoryLoaded,
          onOverflowMenuOpened: onOverflowMenuOpened,
          deleteHistoryEntry: deleteHistoryEntry,
          exportCsv: exportCsv,
        ),
        Text(
          DateFormat('dd MMM yyyy').format(data.date),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
