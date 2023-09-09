// ignore_for_file: cast_nullable_to_non_nullable
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/calculator/helpers/calculator_helpers.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';

class CalculatorBloc extends FormBloc<String, num> {
  CalculatorBloc(this.database, this.store) : super(isLoading: true) {
    addFieldBlocs(
      fieldBlocs: [
        watt,
        printWeight,
        hours,
        minutes,
        spoolWeight,
        spoolCost,
        kwCost,
        wearAndTear,
        failureRisk,
        labourRate,
        labourTime,
      ],
    );
  }

  final Database database;
  final StoreRef store;

  final watt = TextFieldBloc<int>();
  final kwCost = TextFieldBloc<double>();

  final printWeight = TextFieldBloc<double>();

  final hours = TextFieldBloc<int>();

  final minutes = TextFieldBloc<int>();

  final spoolWeight = TextFieldBloc<int>();

  final spoolCost = TextFieldBloc<double>();

  final wearAndTear = TextFieldBloc<double>();

  final failureRisk = TextFieldBloc<double>();

  final labourRate = TextFieldBloc<double>();

  final labourTime = TextFieldBloc<double>();

  @override
  // ignore: avoid_void_async
  void onSubmitting() async {
    var electricityCost = 0.0;
    var filamentCost = 0.0;
    var labourCost = 0.0;

    final w = watt.value;

    final kw = kwCost.value;
    final pw = printWeight.value;
    final sw = spoolWeight.value;
    final sc = spoolCost.value;
    final h = hours.value;
    final m = minutes.value;

    final wt = double.tryParse(wearAndTear.value) ?? 0.0;
    final lr = double.tryParse(labourRate.value) ?? 0.0;
    final lt = double.tryParse(labourTime.value) ?? 0.0;
    final fr = double.tryParse(failureRisk.value) ?? 0.0;

    if (w.isNotEmpty && (h.isNotEmpty || m.isNotEmpty) && kw.isNotEmpty) {
      electricityCost = CalculatorHelpers.electricityCost(
        watt.value,
        hours.value,
        minutes.value,
        kwCost.value,
      );
    }

    if (pw.isNotEmpty && sw.isNotEmpty && sc.isNotEmpty) {
      filamentCost = CalculatorHelpers.filamentCost(pw, sw, sc);
    }

    if (lt > 0 && lr > 0) {
      labourCost = CalculatorHelpers.labourCost(lr, lt);
    }

    final totalCost = electricityCost + filamentCost + wt + labourCost;
    final frCost = fr / 100 * totalCost;

    emitSuccess(
      successResponse: jsonEncode({
        'electricity': electricityCost.toStringAsFixed(2),
        'filament': filamentCost.toStringAsFixed(2),
        'risk': frCost.toStringAsFixed(2),
        'labour': labourCost.toStringAsFixed(2),
        'total': totalCost.toStringAsFixed(2),
      }),
      canSubmitAgain: true,
    );
  }

  @override
// ignore: avoid_void_async
  void onLoading() async {
    final dbHelpers = DataBaseHelpers(DBName.settings);

    final settings = await dbHelpers.getSettings();
    final printerKey = settings.activePrinter;

    final spoolWeightVal = await _getValue('spoolWeight');
    final spoolCostVal = await _getValue('spoolCost');
    final wearAndTearVal = await _getValue('wearAndTear');
    final failureRiskVal = await _getValue('failureRisk');
    final labourRateVal = await _getValue('labourRate');

    if (printerKey.isNotEmpty) {
      final store = stringMapStoreFactory.store(describeEnum(DBName.printers));
      final data = await store
          .query(finder: Finder(filter: Filter.byKey(printerKey)))
          .getSnapshot(database);

      final printer = PrinterModel.fromMap(data!.value, printerKey);

      watt.updateValue(printer.wattage);
    } else {
      watt.updateValue(settings.wattage);
    }
    spoolWeight.updateValue(spoolWeightVal['value'].toString());
    spoolCost.updateValue(spoolCostVal['value'].toString());
    kwCost.updateValue(settings.electricityCost);
    wearAndTear.updateValue(wearAndTearVal['value'].toString());
    failureRisk.updateValue(failureRiskVal['value'].toString());
    labourRate.updateValue(labourRateVal['value'].toString());

    emitLoaded();
  }

  Future<Map<String, Object?>> _getValue(String key) async {
    if (await store.record(key).exists(database)) {
      return await store.record(key).get(database) as Map<String, Object?>;
    }

    return {'value': ''};
  }
}
