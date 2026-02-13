import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/app/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';

class WorkCostsSettings extends HookConsumerWidget {
  const WorkCostsSettings({super.key});

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
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                TextFormField(
                  initialValue: data.wearAndTear.toString(),
                  onChanged: (value) async {
                    final updated = data.copyWith(
                      wearAndTear: value,
                    );
                    await dbHelper.putRecord(updated.toMap());
                  },
                  decoration: InputDecoration(
                    labelText: l10n.wearAndTearLabel,
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: data.failureRisk.toString(),
                  onChanged: (value) async {
                    final updated = data.copyWith(
                      failureRisk: value,
                    );
                    await dbHelper.putRecord(updated.toMap());
                  },
                  decoration: InputDecoration(
                    labelText: l10n.failureRiskLabel,
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: data.hourlyRate.toString(),
                  onChanged: (value) async {
                    final updated = data.copyWith(
                      hourlyRate: value,
                    );
                    await dbHelper.putRecord(updated.toMap());
                  },
                  decoration: InputDecoration(
                    labelText: l10n.labourRateLabel,
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
