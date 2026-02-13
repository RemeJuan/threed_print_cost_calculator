import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/app/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/app/view/app.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';
import 'package:threed_print_cost_calculator/settings/materials/material_form.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';

class Materials extends HookConsumerWidget {
  const Materials({super.key});

  @override
  Widget build(context, ref) {
    final db = ref.read(databaseProvider);
    final store = stringMapStoreFactory.store(DBName.materials.name);
    final dbHelpers = ref.read(dbHelpersProvider(DBName.materials));
    final l10n = S.of(context);

    final query = store.query(finder: Finder(sortOrders: [SortOrder('name')]));

    return StreamBuilder(
      stream: query.onSnapshots(db),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(
            children: [
              SizedBox(
                height: 100,
                child: ListView.builder(
                  itemCount: snapshot.data?.length ?? 0,
                  itemBuilder: (_, index) {
                    final item = snapshot.data![index].value;
                    final key = snapshot.data![index].key;
                    final data = MaterialModel.fromMap(item, key);

                    return Slidable(
                      key: ValueKey(key),
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (_) {
                              dbHelpers.deleteRecord(key);
                            },
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                          ),
                          SlidableAction(
                            onPressed: (_) {
                              showDialog<void>(
                                context: context,
                                builder: (_) => MaterialForm(dbRef: key),
                              );
                            },
                            backgroundColor: LIGHT_BLUE,
                            foregroundColor: Colors.white,
                            icon: Icons.edit,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data.name,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(color: Colors.white),
                              ),
                              Text(
                                data.color,
                                style: Theme.of(
                                  context,
                                ).textTheme.titleSmall?.copyWith(fontSize: 12),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                data.cost,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(color: Colors.white),
                              ),
                              Text(
                                '${data.weight}${l10n.gramsSuffix}',
                                style: Theme.of(
                                  context,
                                ).textTheme.titleSmall?.copyWith(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
