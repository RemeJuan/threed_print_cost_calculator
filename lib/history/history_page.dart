import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';

import 'components/history_item.dart';

class HistoryPage extends HookConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(context, ref) {
    final db = ref.read(databaseProvider);
    final store = stringMapStoreFactory.store('history');

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

                    final data = HistoryModel.fromMap({
                      ...item,
                      'date': DateTime.now().toString(),
                    });

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
