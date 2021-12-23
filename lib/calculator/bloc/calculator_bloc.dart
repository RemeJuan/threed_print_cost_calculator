import 'dart:convert';

import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/calculator/helpers/calculator_helpers.dart';

class CalculatorBloc extends FormBloc<String, num> {
  CalculatorBloc(this.database, this.store) : super(isLoading: true) {
    addFieldBlocs(
      fieldBlocs: [
        watt,
        printWeight,
        time,
        spoolWeight,
        spoolCost,
        kwCost,
      ],
    );
  }

  final Database database;
  final StoreRef store;

  final watt = TextFieldBloc<int>(
    validators: [
      FieldBlocValidators.required,
    ],
  );

  final printWeight = TextFieldBloc<double>(
    validators: [
      FieldBlocValidators.required,
    ],
  );

  final time = TextFieldBloc<int>(
    validators: [
      FieldBlocValidators.required,
    ],
  );

  final spoolWeight = TextFieldBloc<int>(
    validators: [
      FieldBlocValidators.required,
    ],
  );

  final spoolCost = TextFieldBloc<double>(
    validators: [
      FieldBlocValidators.required,
    ],
  );

  final kwCost = TextFieldBloc<double>(
    validators: [
      FieldBlocValidators.required,
    ],
  );

  @override
  // ignore: avoid_void_async
  void onSubmitting() async {
    final electricityCost = CalculatorHelpers.electricityCost(
      watt.value,
      time.value,
      kwCost.value,
    );
    final filamentCost = CalculatorHelpers.filamentCost(
      printWeight.value,
      spoolWeight.value,
      spoolCost.value,
    );

    emitSuccess(
      successResponse: jsonEncode({
        'electricity': electricityCost,
        'filament': filamentCost,
        'total': (electricityCost + filamentCost).toStringAsFixed(2),
      }),
    );
  }

  @override
// ignore: avoid_void_async
  void onLoading() async {
    final wattVal = await _getValue('watt');
    final spoolWeightVal = await _getValue('spoolWeight');
    final spoolCostVal = await _getValue('spoolCost');
    final kwCostVal = await _getValue('kwCost');

    watt.updateValue(wattVal['value'].toString());
    spoolWeight.updateValue(spoolWeightVal['value'].toString());
    spoolCost.updateValue(spoolCostVal['value'].toString());
    kwCost.updateValue(kwCostVal['value'].toString());

    emitLoaded();
  }

  Future<Map<String, Object?>> _getValue(String key) async {
    if (await store.record(key).exists(database)) {
      return await store.record(key).get(database) as Map<String, Object?>;
    }

    return {'value': ''};
  }
}
