import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/l10n/l10n.dart';
import 'package:threed_print_cost_calculator/locator.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';

class GeneralSettings extends HookWidget {
  const GeneralSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final db = sl<Database>();
    final store = StoreRef.main();
    final dbHelper = DataBaseHelpers(DBName.settings);

    return StreamBuilder(
      stream: store.record(describeEnum(DBName.settings)).onSnapshot(db),
      builder: (context, snapshot) {
        var data = GeneralSettingsModel.initial();

        if (snapshot.hasData) {
          debugPrint(snapshot.data!.value.toString());
          data = GeneralSettingsModel.fromMap(
            // ignore: cast_nullable_to_non_nullable
            snapshot.data!.value as Map<String, dynamic>,
          );
        }

        return Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: data.electricityCost,
                onChanged: (value) async {
                  final updated = data.copyWith(electricityCost: value);
                  await dbHelper.updateDb(updated.toMap(), DBName.settings);
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
                initialValue: data.wattage,
                onChanged: (value) async {
                  final updated = data.copyWith(wattage: value);
                  await dbHelper.updateDb(updated.toMap(), DBName.settings);
                },
                decoration: InputDecoration(
                  labelText: l10n.wattLabel,
                  suffixText: l10n.watt,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
