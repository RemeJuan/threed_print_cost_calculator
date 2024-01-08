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
      stream: store.record(DBName.settings.name).onSnapshot(db),
      builder: (context, snapshot) {
        late GeneralSettingsModel data;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        } else {
          if (snapshot.hasData) {
            data = GeneralSettingsModel.fromMap(
                snapshot.data!.value as Map<String, dynamic>);
          } else {
            data = GeneralSettingsModel.initial();
          }

          return Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: data.electricityCost,
                  onChanged: (value) async {
                    final updated = data.copyWith(electricityCost: value);
                    await dbHelper.putRecord(updated.toMap());
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
                    await dbHelper.putRecord(updated.toMap());
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
      },
    );
  }
}
