import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/helpers/calculator_helpers.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculation_results_state.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage_input.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:sembast/sembast.dart';

class SaveForm extends HookConsumerWidget {
  final CalculationResult data;
  final ValueNotifier<bool> showSave;

  const SaveForm({required this.data, required this.showSave, super.key});

  @override
  Widget build(context, ref) {
    final name = useState<String>('');
    final l10n = S.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(hintText: l10n.printNameHint),
              onChanged: (value) {
                name.value = value;
              },
            ),
          ),
          IconButton(
            onPressed: name.value.isEmpty
                ? null
                : () async {
                    // Gather printer and material names from settings and DB
                    final db = ref.read(databaseProvider);
                    final settingsHelpers = ref.read(
                      dbHelpersProvider(DBName.settings),
                    );
                    final settings = await settingsHelpers.getSettings();

                    String printerName = 'NotSelected';
                    String materialName = 'NotSelected';

                    if (settings.activePrinter.isNotEmpty) {
                      final store = stringMapStoreFactory.store(
                        DBName.printers.name,
                      );
                      final snapshot = await store
                          .query(
                            finder: Finder(
                              filter: Filter.byKey(settings.activePrinter),
                            ),
                          )
                          .getSnapshot(db);
                      if (snapshot != null) {
                        final map = snapshot.value as Map<String, dynamic>;
                        printerName = (map['name'] ?? 'NotSelected').toString();
                      }
                    }

                    // Read calculator state for weight and time
                    final calcState = ref.read(calculatorProvider);
                    final num weightVal = calcState.materialUsages.fold<int>(
                      0,
                      (sum, usage) => sum + usage.weightGrams,
                    );

                    final usages = calcState.materialUsages
                        .map((usage) => usage.toMap())
                        .toList();

                    if (calcState.materialUsages.isNotEmpty) {
                      final firstName = calcState.materialUsages.first.materialName;
                      final count = calcState.materialUsages.length;
                      materialName = count > 1
                          ? '$firstName +${count - 1}'
                          : firstName;
                    } else if (settings.selectedMaterial.isNotEmpty) {
                      final store = stringMapStoreFactory.store(
                        DBName.materials.name,
                      );
                      final snapshot = await store
                          .query(
                            finder: Finder(
                              filter: Filter.byKey(settings.selectedMaterial),
                            ),
                          )
                          .getSnapshot(db);
                      if (snapshot != null) {
                        final map = snapshot.value as Map<String, dynamic>;
                        materialName = (map['name'] ?? 'NotSelected').toString();
                        usages.add(
                          MaterialUsageInput(
                            materialId: settings.selectedMaterial,
                            materialName: materialName,
                            costPerKg: 0,
                            weightGrams: weightVal.toInt(),
                          ).toMap(),
                        );
                      }
                    }
                    final int hours = (calcState.hours.value ?? 0).toInt();
                    final int minutes = (calcState.minutes.value ?? 0).toInt();

                    String twoDigits(int n) => n.toString().padLeft(2, '0');
                    final timeStr = '${twoDigits(hours)}:${twoDigits(minutes)}';

                    final model = HistoryModel(
                      name: name.value,
                      electricityCost: data.electricity,
                      filamentCost: data.filament,
                      totalCost: data.total,
                      riskCost: data.risk,
                      labourCost: data.labour,
                      date: DateTime.now(),
                      printer: printerName,
                      material: materialName,
                      weight: weightVal,
                      materialUsages: usages,
                      timeHours: timeStr,
                    );
                    await ref.read(calculatorHelpersProvider).savePrint(model);
                    showSave.value = false;
                  },
            icon: const Icon(Icons.save),
          ),
          IconButton(
            onPressed: () {
              showSave.value = false;
            },
            icon: const Icon(Icons.cancel),
          ),
        ],
      ),
    );
  }
}
