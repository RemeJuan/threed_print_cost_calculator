import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/app/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
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

    final query = store.query();

    Future<void> getSettings() async {
      generalSettings.value = await dbHelpers.getSettings();
      loading.value = false;
    }

    useEffect(
      () {
        // ignore: unnecessary_statements
        getSettings();

        return null;
      },
      [],
    );

    return StreamBuilder(
      stream: query.onSnapshots(db),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty && !loading.value) {
          final none = MaterialModel(
            name: 'None',
            color: 'None',
            cost: '0',
            weight: '0',
            id: 'none',
            archived: false,
          );

          final data = [
            none,
            ...snapshot.data!.map(
              (e) => MaterialModel.fromMap(e.value, e.key),
            )
          ];

          return DropdownButton<String>(
            hint: const Text('Select Material'),
            alignment: AlignmentDirectional.centerStart,
            isExpanded: true,
            value: generalSettings.value.selectedMaterial.isEmpty
                ? null
                : generalSettings.value.selectedMaterial,
            items: data.map((e) {
              return DropdownMenuItem(
                value: e.id,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.name),
                    Text(e.color),
                  ],
                ),
              );
            }).toList(),
            onChanged: (v) async {
              final updated =
                  generalSettings.value.copyWith(selectedMaterial: v);
              generalSettings.value = updated;

              final dbHelpers = ref.read(dbHelpersProvider(DBName.settings));
              await dbHelpers.putRecord(updated.toMap());

              final materialWeight = data.firstWhere((e) => e.id == v).weight;
              final materialCost = data.firstWhere((e) => e.id == v).cost;

              ref.read(calculatorProvider.notifier)
                ..updateSpoolWeight(int.parse(materialWeight))
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
