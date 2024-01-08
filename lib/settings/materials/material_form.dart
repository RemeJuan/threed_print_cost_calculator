import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/app/view/app.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/locator.dart';
import 'package:threed_print_cost_calculator/settings/bloc/material_bloc.dart';

class MaterialForm extends StatelessWidget {
  const MaterialForm({this.ref, super.key});

  final String? ref;

  @override
  Widget build(BuildContext context) {
    final db = sl<Database>();
    final store = stringMapStoreFactory.store(DBName.materials.name);
    final dbHelper = DataBaseHelpers(DBName.materials);

    return Dialog(
      child: BlocProvider(
        create: (_) => MaterialBloc(db, store, ref),
        child: Builder(
          builder: (context) {
            final bloc = context.read<MaterialBloc>();
            // final l10n = context.l10n;

            return FormBlocListener<MaterialBloc, String, dynamic>(
              onSubmitting: (context, state) {},
              onSuccess: (context, state) {
                final data =
                    jsonDecode(state.successResponse!) as Map<String, dynamic>;

                if (ref != null) {
                  dbHelper.updateRecord(ref!, data);
                } else {
                  dbHelper.insertRecord(data);
                }

                Navigator.pop(context);
              },
              onFailure: (context, state) {
                debugPrint(state.failureResponse as String);
                BotToast.showSimpleNotification(
                  title: state.failureResponse as String,
                  duration: const Duration(seconds: 5),
                  align: Alignment.bottomCenter,
                );
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                physics: const ClampingScrollPhysics(),
                child: AutofillGroup(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFieldBlocBuilder(
                        textFieldBloc: bloc.name,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          labelText: 'Name *',
                          prefixIcon: Icon(Icons.text_fields),
                        ),
                      ),
                      TextFieldBlocBuilder(
                        textFieldBloc: bloc.color,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          labelText: 'Color *',
                          prefixIcon: Icon(Icons.color_lens),
                        ),
                      ),
                      TextFieldBlocBuilder(
                        textFieldBloc: bloc.weight,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Weight *',
                          prefixIcon: Icon(Icons.scale),
                          suffix: Text('g'),
                        ),
                      ),
                      TextFieldBlocBuilder(
                        textFieldBloc: bloc.cost,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Cost *',
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DEEP_BLUE,
                          textStyle: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(
                                fontSize: 16,
                              ),
                        ),
                        onPressed: bloc.submit,
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
