import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/app/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';

class HistoryPage extends HookConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(context, ref) {
    final db = ref.read(databaseProvider);
    final store = stringMapStoreFactory.store('history');
    final l10n = S.of(context);

    return Scaffold(
      body: FutureBuilder(
        future: store.find(db),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return CustomScrollView(
              slivers: [
                SliverList.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (_, index) {
                    final item = snapshot.data![index].value;

                    final data = HistoryModel.fromMap(
                      {
                        ...item,
                        'date': DateTime.now().toString(),
                      },
                    );

                    return Dismissible(
                      onDismissed: (_) async {
                        await store
                            .record(snapshot.data![index].key)
                            .delete(db);
                      },
                      background: const ColoredBox(
                        color: Colors.red,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: EdgeInsets.only(right: 16),
                            child: Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
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
                            padding: const EdgeInsets.only(
                              top: 16,
                              bottom: 8,
                              left: 16,
                              right: 16,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      data.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    // Format date string
                                    Text(
                                      DateFormat('dd MMM yyyy')
                                          .format(data.date),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _row(
                                  l10n.electricityCostLabel,
                                  data.electricityCost,
                                ),
                                _row(l10n.filamentCostLabel, data.filamentCost),
                                _row(l10n.labourCostLabel, data.labourCost),
                                _row(l10n.riskCostLabel, data.riskCost),
                                _row(l10n.totalCostLabel, data.totalCost, 0),
                              ],
                            ),
                          ),
                          const Divider(),
                        ],
                      ),
                    );
                  },
                ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _row(String label, num value, [double border = 1]) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: border == 0 ? Colors.transparent : Colors.grey,
            width: border,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Text(value.toString())],
      ),
    );
  }
}
