import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/calculator/bloc/calculator_bloc.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/locator.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';

class PrinterSelect extends HookWidget {
  const PrinterSelect({super.key});

  @override
  Widget build(BuildContext context) {
    final loading = useState<bool>(true);
    final db = sl<Database>();
    final store = stringMapStoreFactory.store(describeEnum(DBName.printers));
    final dbHelpers = DataBaseHelpers(DBName.settings);
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
        if (snapshot.hasData && !loading.value) {
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
                    Text('${e.wattage}w'),
                  ],
                ),
              );
            }).toList(),
            onChanged: (v) async {
              final updated = generalSettings.value.copyWith(activePrinter: v);
              generalSettings.value = updated;
              await dbHelpers.putRecord(updated.toMap());

              final wattage = data.firstWhere((e) => e.id == v).wattage;
              context.read<CalculatorBloc>().watt.updateInitialValue(wattage);
            },
          );
        } else {
          return const SizedBox(
            height: 40,
          );
        }
      },
    );
  }
}
