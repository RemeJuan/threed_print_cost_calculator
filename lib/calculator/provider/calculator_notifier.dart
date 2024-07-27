import 'package:riverpod/riverpod.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/app/components/double_input.dart';
import 'package:threed_print_cost_calculator/app/components/int_input.dart';
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

    state = CalculatorState(
      watt: IntInput.dirty(value: state.watt.value),
      kwCost: DoubleInput.dirty(value: settings.electricityCost),
      printWeight: IntInput.dirty(value: state.printWeight.value),
      hours: IntInput.dirty(value: state.hours.value),
      minutes: IntInput.dirty(value: state.minutes.value),
      spoolWeight: IntInput.dirty(value: spoolWeightVal['value'] as int),
      spoolCost: IntInput.dirty(value: spoolCostVal['value'] as int),
      wearAndTear: DoubleInput.dirty(value: wearAndTearVal['value'] as double),
      failureRisk: DoubleInput.dirty(value: failureRiskVal['value'] as double),
      labourRate: DoubleInput.dirty(value: labourRateVal['value'] as double),
      labourTime: DoubleInput.dirty(value: state.labourTime.value),
      results: state.results,
    );
  }

  void updateWatt(String value) {
    state = state.copyWith(watt: IntInput.dirty(value: int.parse(value)));
  }

  void updateKwCost(String value) {
    state = state.copyWith(
      kwCost: DoubleInput.dirty(value: double.parse(value)),
    );
  }

  void updatePrintWeight(String value) {
    state =
        state.copyWith(printWeight: IntInput.dirty(value: int.parse(value)));
  }

  void updateHours(int value) {
    state = state.copyWith(hours: IntInput.dirty(value: value));
  }

  void updateMinutes(int value) {
    state = state.copyWith(minutes: IntInput.dirty(value: value));
  }

  void updateSpoolWeight(int value) {
    ref.read(calculatorHelpersProvider).addOrUpdateRecord(
          'spoolWeight',
          value.toString(),
        );
    state = state.copyWith(spoolWeight: IntInput.dirty(value: value));
  }

  void updateSpoolCost(String value) {
    ref.read(calculatorHelpersProvider).addOrUpdateRecord(
          'spoolCost',
          value.toString(),
        );
    state = state.copyWith(spoolCost: IntInput.dirty(value: int.parse(value)));
  }

  void updateWearAndTear(double value) {
    ref.read(calculatorHelpersProvider).addOrUpdateRecord(
          'wearAndTear',
          value.toString(),
        );
    state = state.copyWith(wearAndTear: DoubleInput.dirty(value: value));
  }

  void updateFailureRisk(double value) {
    ref.read(calculatorHelpersProvider).addOrUpdateRecord(
          'failureRisk',
          value.toString(),
        );
    state = state.copyWith(failureRisk: DoubleInput.dirty(value: value));
  }

  void updateLabourRate(double value) {
    ref.read(calculatorHelpersProvider).addOrUpdateRecord(
          'labourRate',
          value.toString(),
        );
    state = state.copyWith(labourRate: DoubleInput.dirty(value: value));
  }

  void updateLabourTime(double value) {
    ref.read(calculatorHelpersProvider).addOrUpdateRecord(
          'labourTime',
          value.toString(),
        );
    state = state.copyWith(labourTime: DoubleInput.dirty(value: value));
  }

  void updateResults(CalculationResult results) {
    state = state.copyWith(results: results);
  }

  void submit() {
    var electricityCost = 0.0;
    var filamentCost = 0.0;
    var labourCost = 0.0;

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
