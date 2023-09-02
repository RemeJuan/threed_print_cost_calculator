import 'package:flutter/material.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/locator.dart';
import 'package:threed_print_cost_calculator/settings/material_form.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';

class Materials extends StatelessWidget {
  const Materials({super.key});

  @override
  Widget build(BuildContext context) {
    final db = sl<Database>();
    final store = stringMapStoreFactory.store('materials');

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
                  const Text('Materials'),
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
              SizedBox(
                height: 100,
                child: ListView.builder(
                  itemCount: snapshot.data?.length ?? 0,
                  itemBuilder: (_, index) {
                    final item = snapshot.data![index].value;
                    final data = MaterialModel.fromMap(item);
                    return ListTile(
                      title: Text(data.name),
                      subtitle: Text(data.color),
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
