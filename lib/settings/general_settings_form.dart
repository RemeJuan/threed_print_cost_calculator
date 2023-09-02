import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/l10n/l10n.dart';
import 'package:threed_print_cost_calculator/locator.dart';

class GeneralSettings extends HookWidget {
  const GeneralSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final costController = useTextEditingController();
    final wattController = useTextEditingController();

    final db = sl<Database>();
    final store = stringMapStoreFactory.store(describeEnum(DBName.settings));
    final dbHelpers = DataBaseHelpers(DBName.settings);

    final query = store.query();

    store.query().onSnapshots(db).listen((event) {
      event.forEach((element) {
        if (element.key == 'electricityCost') {
          costController.text = element.value['value'] as String;
        }
        if (element.key == 'wattage') {
          wattController.text = element.value['value'] as String;
        }
      });
    });

    return StreamBuilder(
      stream: query.onSnapshots(db),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: costController,
                  onChanged: (value) async {
                    await dbHelpers.addOrUpdateRecord(
                      'electricityCost',
                      value,
                    );
                  },
                  decoration: InputDecoration(
                    labelText: l10n.electricityCostLabel,
                    suffixText: l10n.kwh,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: wattController,
                  onChanged: (value) async {
                    await dbHelpers.addOrUpdateRecord(
                      'wattage',
                      value,
                    );
                  },
                  decoration: InputDecoration(
                    labelText: l10n.wattLabel,
                    suffixText: l10n.watt,
                  ),
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
