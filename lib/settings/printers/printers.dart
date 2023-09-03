import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/app/app.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/locator.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';
import 'package:threed_print_cost_calculator/settings/printers/add_printer.dart';

class Printers extends StatelessWidget {
  const Printers({super.key});

  @override
  Widget build(BuildContext context) {
    final db = sl<Database>();
    final store = stringMapStoreFactory.store(describeEnum(DBName.printers));
    final dbHelpers = DataBaseHelpers(DBName.printers);

    final query = store.query();

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
                    'Printers',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    onPressed: () async {
                      await showDialog<void>(
                        context: context,
                        builder: (_) => const AddPrinter(),
                      );
                    },
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const Divider(color: Colors.white54),
              SizedBox(
                height: MediaQuery.sizeOf(context).height / 4,
                child: ListView.builder(
                  itemCount: snapshot.data?.length ?? 0,
                  itemBuilder: (_, index) {
                    final item = snapshot.data![index].value;
                    final key = snapshot.data![index].key;
                    final data = PrinterModel.fromMap(item);

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
                                builder: (_) => AddPrinter(ref: key),
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
                          Text(
                            data.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                data.bedSize,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              Text(
                                '${data.wattage}w',
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
