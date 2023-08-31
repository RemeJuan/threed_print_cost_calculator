import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/l10n/l10n.dart';
import 'package:threed_print_cost_calculator/locator.dart';
import 'package:threed_print_cost_calculator/settings/bloc/material_bloc.dart';
import 'package:threed_print_cost_calculator/settings/helpers/settings_helpers.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';

class MaterialForm extends StatelessWidget {
  const MaterialForm({super.key});

  @override
  Widget build(BuildContext context) {
    final db = sl<Database>();
    final store = stringMapStoreFactory.store();

    return Dialog(
      child: BlocProvider(
        create: (_) => MaterialBloc(db, store),
        child: Builder(
          builder: (context) {
            final bloc = context.read<MaterialBloc>();
            final l10n = context.l10n;

            return FormBlocListener<MaterialBloc, String, dynamic>(
              onSubmitting: (context, state) {},
              onSuccess: (context, state) {
                SettingsHelpers.saveMaterial(MaterialModel.fromMap(
                  jsonDecode(state.successResponse!) as Map<String, dynamic>,
                ));
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
                          backgroundColor: Theme.of(context).primaryColor,
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
