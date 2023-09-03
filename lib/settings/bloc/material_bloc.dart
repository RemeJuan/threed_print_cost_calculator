import 'dart:convert';

import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:sembast/sembast.dart';

class MaterialBloc extends FormBloc<String, dynamic> {
  MaterialBloc(this.database, this.store) : super(isLoading: true) {
    addFieldBlocs(
      fieldBlocs: [
        name,
        cost,
        color,
      ],
    );
  }

  final Database database;
  final StoreRef store;

  final name = TextFieldBloc<String>(
    validators: [
      FieldBlocValidators.required,
    ],
  );

  final cost = TextFieldBloc<double>(
    validators: [
      FieldBlocValidators.required,
    ],
  );

  final color = TextFieldBloc<String>(
    validators: [
      FieldBlocValidators.required,
    ],
  );

  @override
  // ignore: avoid_void_async
  void onSubmitting() async {
    emitSuccess(
      canSubmitAgain: true,
      successResponse: jsonEncode({
        'name': name.value,
        'cost': cost.value,
        'color': color.value,
      }),
    );
  }
}
