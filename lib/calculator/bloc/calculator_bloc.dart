import 'dart:convert';

import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:threed_print_cost_calculator/calculator/helpers/calculator_helpers.dart';

class CalculatorBloc extends FormBloc<String, num> {
  CalculatorBloc() {
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
  void onSubmitting() async {
    await Future<void>.delayed(const Duration(seconds: 1));
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
        'total': electricityCost + filamentCost,
      }),
    );
  }
}
