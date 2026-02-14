import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/services.dart';
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

    // Controller for wearAndTear so the field reflects external updates
    final wearController = useTextEditingController();

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

          // Keep controller in sync with the latest data; avoid overwriting while typing
          final wearText = data.wearAndTear.toString();
          if (wearController.text != wearText) {
            wearController.text = wearText;
          }

          return Container(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                TextFormField(
                  controller: wearController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  validator: (value) {
                    final v = value?.replaceAll(',', '.') ?? '';
                    if (v.isEmpty) return 'Please enter a number';
                    if (num.tryParse(v) == null) return 'Invalid number';
                    return null;
                  },
                  onChanged: (value) async {
                    // Parse value and persist if valid
                    final v = value.replaceAll(',', '.');
                    final parsed = num.tryParse(v);
                    if (parsed == null) return;
                    final updated = data.copyWith(
                      wearAndTear: parsed.toString(),
                    );
                    await dbHelper.putRecord(updated.toMap());
                  },
                  decoration: InputDecoration(labelText: l10n.wearAndTearLabel),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: data.failureRisk.toString(),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  validator: (value) {
                    final v = value?.replaceAll(',', '.') ?? '';
                    if (v.isEmpty) return 'Please enter a number';
                    if (num.tryParse(v) == null) return 'Invalid number';
                    return null;
                  },
                  onChanged: (value) async {
                    final v = value.replaceAll(',', '.');
                    final parsed = num.tryParse(v);
                    if (parsed == null) return;
                    final updated = data.copyWith(
                      failureRisk: parsed.toString(),
                    );
                    await dbHelper.putRecord(updated.toMap());
                  },
                  decoration: InputDecoration(labelText: l10n.failureRiskLabel),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: data.labourRate.toString(),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  validator: (value) {
                    final v = value?.replaceAll(',', '.') ?? '';
                    if (v.isEmpty) return 'Please enter a number';
                    if (num.tryParse(v) == null) return 'Invalid number';
                    return null;
                  },
                  onChanged: (value) async {
                    final v = value.replaceAll(',', '.');
                    final parsed = num.tryParse(v);
                    if (parsed == null) return;
                    final updated = data.copyWith(
                      labourRate: parsed.toString(),
                    );
                    await dbHelper.putRecord(updated.toMap());
                  },
                  decoration: InputDecoration(labelText: l10n.labourRateLabel),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
