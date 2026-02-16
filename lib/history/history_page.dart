import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/shared/utils/csv_utils.dart';

import 'components/history_item.dart';

class HistoryPage extends HookConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(context, ref) {
    final db = ref.read(databaseProvider);
    final store = stringMapStoreFactory.store('history');

    return Scaffold(
      body: FutureBuilder(
        future: store.find(
          db,
          finder: Finder(sortOrders: [SortOrder('date', false)]),
        ),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.upload_file),
                          tooltip: 'Export',
                          onPressed: () {
                            showModalBottomSheet<void>(
                              context: context,
                              builder: (context) {
                                return SafeArea(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Text(
                                          'Export Prints',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleLarge,
                                        ),
                                      ),
                                      ListTile(
                                        title: const Text('All'),
                                        onTap: () async {
                                          Navigator.pop(context);
                                          await ref
                                              .read(csvUtilsProvider)
                                              .exportForRange(ExportRange.all);
                                        },
                                      ),
                                      ListTile(
                                        title: const Text('Last 7 days'),
                                        onTap: () async {
                                          Navigator.pop(context);
                                          await ref
                                              .read(csvUtilsProvider)
                                              .exportForRange(
                                                ExportRange.last7Days,
                                              );
                                        },
                                      ),
                                      ListTile(
                                        title: const Text('Last 30 days'),
                                        onTap: () async {
                                          Navigator.pop(context);
                                          await ref
                                              .read(csvUtilsProvider)
                                              .exportForRange(
                                                ExportRange.last30Days,
                                              );
                                        },
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (_, index) {
                    final item =
                        snapshot.data![index].value as Map<String, dynamic>;

                    final data = HistoryModel.fromMap(item);

                    return HistoryItem(
                      dbKey: snapshot.data![index].key,
                      data: data,
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
}
