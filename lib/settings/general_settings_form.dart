import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';

class GeneralSettings extends HookConsumerWidget {
  const GeneralSettings({super.key});

  @override
  Widget build(context, ref) {
    final l10n = S.of(context);

    final db = ref.read(databaseProvider);
    final store = StoreRef.main();
    final dbHelper = ref.read(dbHelpersProvider(DBName.settings));

    return StreamBuilder(
      stream: store.record(DBName.settings.name).onSnapshot(db),
      builder: (context, snapshot) {
        late GeneralSettingsModel data;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        } else {
          if (snapshot.hasData) {
            data = GeneralSettingsModel.fromMap(
              snapshot.data!.value as Map<String, dynamic>,
            );
          } else {
            data = GeneralSettingsModel.initial();
          }

          return Container(
            padding: EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: data.electricityCost.toString(),
                    onChanged: (value) async {
                      final updated = data.copyWith(electricityCost: value);
                      await dbHelper.putRecord(updated.toMap());
                    },
                    decoration: InputDecoration(
                      labelText: l10n.electricityCostSettingsLabel,
                      suffixText: l10n.kwh,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: data.wattage.toString(),
                    onChanged: (value) async {
                      final updated = data.copyWith(wattage: value);
                      await dbHelper.putRecord(updated.toMap());
                    },
                    decoration: InputDecoration(
                      labelText: l10n.wattLabel,
                      suffixText: l10n.watt,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
