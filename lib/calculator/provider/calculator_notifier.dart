import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/app/components/num_input.dart';
import 'package:threed_print_cost_calculator/app/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/calculator/helpers/calculator_helpers.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculator_state.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculation_results_state.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';

final calculatorProvider =
    StateNotifierProvider<CalculatorProvider, CalculatorState>(
  (ref) {
    final db = ref.read(databaseProvider);
    final store = stringMapStoreFactory.store();
    return CalculatorProvider(ref, db, store);
  },
);

class CalculatorProvider extends StateNotifier<CalculatorState> {
  final Ref ref;
  final Database database;
  final StoreRef store;

  CalculatorProvider(this.ref, this.database, this.store)
      : super(CalculatorState());

  void init() async {
    final dbHelpers = ref.read(dbHelpersProvider(DBName.settings));
    final settings = await dbHelpers.getSettings();
    final printerKey = settings.activePrinter;

    final spoolWeightVal = await _getValue('spoolWeight');
    final spoolCostVal = await _getValue('spoolCost');
    final wearAndTearVal = await _getValue('wearAndTear');
    final failureRiskVal = await _getValue('failureRisk');
    final labourRateVal = await _getValue('labourRate');

    if (printerKey.isNotEmpty) {
      final store = stringMapStoreFactory.store(DBName.printers.name);

      final data = await store
          .query(finder: Finder(filter: Filter.byKey(printerKey)))
          .getSnapshot(database);

      final printer = PrinterModel.fromMap(data!.value, printerKey);

      updateWatt(printer.wattage.toString());
    } else {
      updateWatt(settings.wattage.toString());
    }
    debugPrint('spoolWeightVal: $spoolWeightVal');
    state = CalculatorState(
      watt: NumberInput.dirty(value: state.watt.value),
      kwCost: NumberInput.dirty(value: settings.electricityCost),
      printWeight: NumberInput.dirty(value: state.printWeight.value),
      hours: NumberInput.dirty(value: state.hours.value),
      minutes: NumberInput.dirty(value: state.minutes.value),
      spoolWeight: NumberInput.dirty(
        value: num.tryParse(spoolWeightVal['value'] as String),
      ),
      spoolCost: NumberInput.dirty(
        value: num.tryParse(spoolCostVal['value'] as String),
      ),
      wearAndTear: NumberInput.dirty(
        value: num.tryParse(wearAndTearVal['value'] as String),
      ),
      failureRisk: NumberInput.dirty(
        value: num.tryParse(failureRiskVal['value'] as String),
      ),
      labourRate: NumberInput.dirty(
        value: num.tryParse(labourRateVal['value'] as String),
      ),
      labourTime: NumberInput.dirty(value: state.labourTime.value),
      results: state.results,
    );
    debugPrint(
        'CalculatorProvider init completed - ${state.spoolWeight.value}');
  }

  void updateWatt(String value) {
    state = state.copyWith(
        watt: NumberInput.dirty(value: num.tryParse(value) ?? 0));
  }

  void updateKwCost(String value) {
    state = state.copyWith(
      kwCost: NumberInput.dirty(value: num.tryParse(value) ?? 0),
    );
  }

  void updatePrintWeight(String value) {
    state = state.copyWith(
        printWeight: NumberInput.dirty(value: num.tryParse(value) ?? 0));
  }

  void updateHours(num value) {
    state = state.copyWith(hours: NumberInput.dirty(value: value));
  }

  void updateMinutes(num value) {
    state = state.copyWith(minutes: NumberInput.dirty(value: value));
  }

  void updateSpoolWeight(num value) {
    ref.read(calculatorHelpersProvider).addOrUpdateRecord(
          'spoolWeight',
          value.toString(),
        );
    state = state.copyWith(spoolWeight: NumberInput.dirty(value: value));
  }

  void updateSpoolCost(String value) {
    ref.read(calculatorHelpersProvider).addOrUpdateRecord(
          'spoolCost',
          value.toString(),
        );
    state = state.copyWith(
        spoolCost: NumberInput.dirty(value: num.tryParse(value) ?? 0));
  }

  void updateWearAndTear(num value) {
    ref.read(calculatorHelpersProvider).addOrUpdateRecord(
          'wearAndTear',
          value.toString(),
        );
    state = state.copyWith(wearAndTear: NumberInput.dirty(value: value));
  }

  void updateFailureRisk(num value) {
    ref.read(calculatorHelpersProvider).addOrUpdateRecord(
          'failureRisk',
          value.toString(),
        );
    state = state.copyWith(failureRisk: NumberInput.dirty(value: value));
  }

  void updateLabourRate(num value) {
    ref.read(calculatorHelpersProvider).addOrUpdateRecord(
          'labourRate',
          value.toString(),
        );
    state = state.copyWith(labourRate: NumberInput.dirty(value: value));
  }

  void updateLabourTime(num value) {
    ref.read(calculatorHelpersProvider).addOrUpdateRecord(
          'labourTime',
          value.toString(),
        );
    state = state.copyWith(labourTime: NumberInput.dirty(value: value));
  }

  void updateResults(CalculationResult results) {
    state = state.copyWith(results: results);
  }

  void submit() {
    num electricityCost = 0;
    num filamentCost = 0;
    num labourCost = 0;

    final w = state.watt.value ?? 0;

    final kw = state.kwCost.value ?? 0;
    final pw = state.printWeight.value ?? 0;
    final sw = state.spoolWeight.value ?? 0;
    final sc = state.spoolCost.value ?? 0;
    final h = state.hours.value ?? 0;
    final m = state.minutes.value ?? 0;

    final wt = state.wearAndTear.value ?? 0;
    final lr = state.labourRate.value ?? 0;
    final lt = state.labourTime.value ?? 0;
    final fr = state.failureRisk.value ?? 0;

    if (w > -1 && (h > -1 || m > -1) && kw > -1) {
      electricityCost = ref.read(calculatorHelpersProvider).electricityCost(
            w,
            h,
            m,
            kw,
          );
    }

    if (pw > -1 && sw > -1 && sc > -1) {
      filamentCost =
          ref.read(calculatorHelpersProvider).filamentCost(pw, sw, sc);
    }

    if (lt > -1 && lr > -1) {
      labourCost = CalculatorHelpers.labourCost(lr, lt);
    }

    final totalCost = electricityCost + filamentCost + wt + labourCost;
    final frCost = fr / 100 * totalCost;

    final results = CalculationResult(
      electricity: electricityCost,
      filament: filamentCost,
      risk: frCost,
      labour: labourCost,
      total: totalCost,
    );

    updateResults(results);
  }

  Future<Map<String, Object?>> _getValue(String key) async {
    if (await store.record(key).exists(database)) {
      return await store.record(key).get(database) as Map<String, Object?>;
    }

    return {'value': ''};
  }
}
