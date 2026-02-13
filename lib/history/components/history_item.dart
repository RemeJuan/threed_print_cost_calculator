import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/app/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';

class HistoryItem extends HookConsumerWidget {
  final String dbKey;
  final HistoryModel data;

  const HistoryItem({required this.dbKey, required this.data, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.read(databaseProvider);
    final store = stringMapStoreFactory.store('history');
    final l10n = S.of(context);

    return Dismissible(
      onDismissed: (_) async {
        await store.record(dbKey).delete(db);
      },
      background: const ColoredBox(
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.delete, color: Colors.white),
          ),
        ),
      ),
      confirmDismiss: (_) async {
        return showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(l10n.deleteDialogTitle),
            content: Text(l10n.deleteDialogContent),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: Text(l10n.cancelButton),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: Text(l10n.deleteButton),
              ),
            ],
          ),
        );
      },
      key: ValueKey(data.date),
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
