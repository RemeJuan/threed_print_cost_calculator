import 'dart:convert';

import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';

class MaterialBloc extends FormBloc<String, dynamic> {
  MaterialBloc(this.database, this.store, [this.key]) : super(isLoading: true) {
    addFieldBlocs(
      fieldBlocs: [
        name,
        cost,
        color,
        weight,
      ],
    );
  }

  final Database database;
  final StoreRef store;
  final String? key;

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

  final weight = TextFieldBloc<String>(
    validators: [
      FieldBlocValidators.required,
    ],
  );

  @override
  void onLoading() async {
    final dbHelpers = DataBaseHelpers(DBName.materials);

    if (key != null) {
      final record = await dbHelpers.getRecord(key!);

      final material = MaterialModel.fromMap(
        // ignore: cast_nullable_to_non_nullable
        record!.value as Map<String, dynamic>,
        key!,
      );

      name.updateValue(material.name);
      color.updateValue(material.color);
      cost.updateValue(material.cost);
      weight.updateValue(material.weight);
    }
    emitLoaded();
  }

  @override
  // ignore: avoid_void_async
  void onSubmitting() async {
    emitSuccess(
      canSubmitAgain: true,
      successResponse: jsonEncode({
        'name': name.value,
        'cost': cost.value,
        'color': color.value,
        'weight': weight.value,
        'archived': false,
      }),
    );
  }
}
