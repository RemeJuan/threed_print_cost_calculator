import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/app/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';

class PrinterSelect extends HookConsumerWidget {
  const PrinterSelect({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final loading = useState<bool>(true);
    final db = ref.read(databaseProvider);
    final store = stringMapStoreFactory.store(DBName.printers.name);
    final dbHelpers = ref.read(dbHelpersProvider(DBName.settings));
    final generalSettings = useState(GeneralSettingsModel.initial());
    final l10n = S.of(context);

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
          final data = snapshot.data!.map(
            (e) => PrinterModel.fromMap(e.value, e.key),
          );

          return DropdownButton<String>(
            alignment: AlignmentDirectional.centerEnd,
            isExpanded: true,
            value: generalSettings.value.activePrinter.isEmpty
                ? null
                : generalSettings.value.activePrinter,
            items: data.map((e) {
              return DropdownMenuItem(
                value: e.id,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.name),
                    Text('${e.wattage}${l10n.wattsSuffix}'),
                  ],
                ),
              );
            }).toList(),
            onChanged: (v) async {
              final updated = generalSettings.value.copyWith(activePrinter: v);
              generalSettings.value = updated;
              await dbHelpers.putRecord(updated.toMap());

              final wattage = data.firstWhere((e) => e.id == v).wattage;

              ref
                  .read(calculatorProvider.notifier)
                  .updateWatt(wattage.toString());
            },
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
