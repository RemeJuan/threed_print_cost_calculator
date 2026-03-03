import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';

class MaterialSelect extends HookConsumerWidget {
  const MaterialSelect({super.key});

  @override
  Widget build(context, ref) {
    final loading = useState<bool>(true);
    final db = ref.read(databaseProvider);
    final store = stringMapStoreFactory.store(DBName.materials.name);
    final dbHelpers = ref.read(dbHelpersProvider(DBName.materials));
    final generalSettings = useState(GeneralSettingsModel.initial());
    final l10n = S.of(context);

    final query = store.query();

    Future<void> getSettings() async {
      generalSettings.value = await dbHelpers.getSettings();
      loading.value = false;
    }

    useEffect(() {
      // ignore: unnecessary_statements
      getSettings();

      return null;
    }, []);

    return StreamBuilder(
      stream: query.onSnapshots(db),
      builder: (context, snapshot) {
        // If we have snapshot data (possibly empty) and finished loading settings
        if (snapshot.hasData && !loading.value) {
          // Map DB snapshots to models; allow the resulting list to be empty
          final data = snapshot.data!
              .map((e) => MaterialModel.fromMap(e.value, e.key))
              .toList();

          // If there are no materials, render nothing
          if (data.isEmpty) {
            return const SizedBox.shrink();
          }

          // Only use the selected value if it exists in the current data set
          final selectedValue =
              data.any((e) => e.id == generalSettings.value.selectedMaterial)
              ? generalSettings.value.selectedMaterial
              : null;

          return DropdownButton<String>(
            hint: Text(l10n.selectMaterialHint),
            alignment: AlignmentDirectional.centerStart,
            isExpanded: true,
            value: selectedValue,
            items: data.map((e) {
              return DropdownMenuItem(
                value: e.id,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text(e.name), Text(e.color)],
                ),
              );
            }).toList(),
            onChanged: (v) async {
              if (v == null) return;

              final updated = generalSettings.value.copyWith(
                selectedMaterial: v,
              );
              generalSettings.value = updated;

              final dbHelpers = ref.read(dbHelpersProvider(DBName.settings));
              await dbHelpers.putRecord(updated.toMap());

              final materialWeight = data.firstWhere((e) => e.id == v).weight;
              final materialCost = data.firstWhere((e) => e.id == v).cost;

              ref.read(calculatorProvider.notifier)
                ..updateSpoolWeight(num.parse(materialWeight))
                ..updateSpoolCost(materialCost)
                ..submit();
            },
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
