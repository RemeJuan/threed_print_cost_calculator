import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:threed_print_cost_calculator/shared/theme.dart';
import 'package:threed_print_cost_calculator/shared/utils/csv_utils.dart';
import 'package:threed_print_cost_calculator/history/provider/history_paged_notifier.dart';
import 'package:threed_print_cost_calculator/history/provider/history_providers.dart';

class HistoryItem extends HookConsumerWidget {
  final String dbKey;
  final HistoryModel data;

  const HistoryItem({required this.dbKey, required this.data, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = S.of(context);

    return Slidable(
      key: ValueKey(dbKey),
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (context) async {
              // export this single entry with error handling and user feedback
              try {
                await exportCSVFile([data]);
                if (!context.mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.exportSuccess)));
              } catch (e, st) {
                debugPrint('Export failed: $e\n$st');
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.exportError)));
              }
            },
            backgroundColor: LIGHT_BLUE,
            foregroundColor: Colors.white,
            icon: Icons.share,
            label: l10n.exportButton,
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (context) async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: Text(l10n.deleteDialogTitle),
                  content: Text(l10n.deleteDialogContent),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: Text(l10n.cancelButton),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      child: Text(l10n.deleteButton),
                    ),
                  ],
                ),
              );

              if (!context.mounted) return;

              if (confirm == true) {
                final dbHelpers = ref.read(dbHelpersProvider(DBName.history));
                await dbHelpers.deleteRecord(dbKey);

                if (!context.mounted) return;

                // Refresh paged provider so the deleted item disappears from the list
                ref.read(historyPagedProvider.notifier).refresh();

                // Also refresh the historyRecordsProvider in case other parts of the UI rely on it
                ref.invalidate(historyRecordsProvider);
              }
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: l10n.deleteButton,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(8, 8, 18, 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      data.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    // Format date string
                    Text(
                      DateFormat('dd MMM yyyy').format(data.date),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _row(context, l10n.electricityCostLabel, data.electricityCost),
                _row(context, l10n.filamentCostLabel, data.filamentCost),
                _row(context, l10n.labourCostLabel, data.labourCost),
                _row(context, l10n.riskCostLabel, data.riskCost),
                const SizedBox(height: 4),
                Divider(),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      l10n.totalCostLabel,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      data.totalCost.toStringAsFixed(2),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Additional summary line: weight (kg) • time (e.g. 6h 20m) • printer • material
                Builder(
                  builder: (context) {
                    final weightKg = (data.weight / 1000);
                    // parse timeHours which should be in "hh:mm" format
                    String timeLabel;
                    try {
                      final parts = data.timeHours.split(':');
                      final h = int.tryParse(parts[0]) ?? 0;
                      final m =
                          int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
                      timeLabel = '${h}h ${m}m';
                    } catch (_) {
                      timeLabel = data.timeHours;
                    }

                    // Build material label: multi-material badge or legacy name
                    String materialLabel;
                    if (data.materialUsages.length > 1) {
                      final first = data.materialUsages.first.materialName;
                      final extra = data.materialUsages.length - 1;
                      materialLabel = '$first +$extra';
                    } else if (data.materialUsages.length == 1) {
                      materialLabel = data.materialUsages.first.materialName;
                    } else {
                      materialLabel = data.material;
                    }

                    final summary =
                        '${weightKg.toStringAsFixed(2)} kg • $timeLabel • ${data.printer} • $materialLabel';

                    return Text(
                      summary,
                      style: Theme.of(context).textTheme.bodySmall,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _row(BuildContext context, String label, num value) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        Text(
          value.toStringAsFixed(2),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.white),
        ),
      ],
    ),
  );
}
