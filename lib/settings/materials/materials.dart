import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/app/view/app.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/locator.dart';
import 'package:threed_print_cost_calculator/settings/materials/material_form.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';

class Materials extends StatelessWidget {
  const Materials({super.key});

  @override
  Widget build(BuildContext context) {
    final db = sl<Database>();
    final store = stringMapStoreFactory.store(DBName.materials.name);
    final dbHelpers = DataBaseHelpers(DBName.materials);

    final query = store.query(
      finder: Finder(
        sortOrders: [
          SortOrder('name'),
        ],
      ),
    );

    return StreamBuilder(
      stream: query.onSnapshots(db),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Materials',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    onPressed: () async {
                      await showDialog<void>(
                        context: context,
                        builder: (_) => const MaterialForm(),
                      );
                    },
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const Divider(color: Colors.white54),
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
                                builder: (_) => MaterialForm(ref: key),
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
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                data.color,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                data.cost,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                '${data.weight}g',
                                style: Theme.of(context).textTheme.titleSmall,
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
