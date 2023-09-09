import 'dart:convert';

import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';

class PrinterBloc extends FormBloc<String, dynamic> {
  PrinterBloc(this.database, this.store, [this.key]) : super(isLoading: true) {
    addFieldBlocs(
      fieldBlocs: [
        name,
        bedSize,
        wattage,
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

  final bedSize = TextFieldBloc<double>(
    validators: [
      FieldBlocValidators.required,
    ],
  );

  final wattage = TextFieldBloc<String>(
    validators: [
      FieldBlocValidators.required,
    ],
  );

  @override
// ignore: avoid_void_async
  void onLoading() async {
    final dbHelpers = DataBaseHelpers(DBName.printers);

    if (key != null) {
      final record = await dbHelpers.getRecord(key!);

      final printer = PrinterModel.fromMap(
        // ignore: cast_nullable_to_non_nullable
        record!.value as Map<String, dynamic>,
        key!,
      );

      name.updateValue(printer.name);
      bedSize.updateValue(printer.bedSize);
      wattage.updateValue(printer.wattage);
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
        'bedSize': bedSize.value,
        'wattage': wattage.value,
        'archived': false,
      }),
    );
  }
}
