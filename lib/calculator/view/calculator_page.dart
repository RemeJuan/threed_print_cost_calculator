import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/calculator/bloc/calculator_bloc.dart';
import 'package:threed_print_cost_calculator/calculator/view/advert.dart';
import 'package:threed_print_cost_calculator/calculator/view/calculator_results.dart';
import 'package:threed_print_cost_calculator/l10n/l10n.dart';
import 'package:threed_print_cost_calculator/locator.dart';

class CalculatorPage extends HookWidget {
  const CalculatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final results = useState<Map<dynamic, dynamic>>({});

    final db = sl<Database>();
    final store = stringMapStoreFactory.store();

    return BlocProvider<CalculatorBloc>(
      create: (_) => CalculatorBloc(db, store),
      child: Builder(
        builder: (context) {
          final bloc = context.read<CalculatorBloc>();
          final l10n = context.l10n;

          return Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(title: Text(l10n.calculatorAppBarTitle)),
            body: FormBlocListener<CalculatorBloc, String, num>(
              onSubmitting: (context, state) {},
              onSuccess: (context, state) {
                results.value = jsonDecode(state.successResponse!) as Map;
              },
              onFailure: (context, state) {},
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
                      // Printer Wattage
                      TextFieldBlocBuilder(
                        textFieldBloc: bloc.watt,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: l10n.wattLabel,
                        ),
                        onChanged: (value) async {
                          bloc.submit();
                          await _addOrUpdateRecord(db, store, 'watt', value);
                        },
                      ),
                      // Electricity Cost
                      TextFieldBlocBuilder(
                        textFieldBloc: bloc.kwCost,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: l10n.electricityCostLabel,
                        ),
                        onChanged: (value) async {
                          bloc.submit();
                          await _addOrUpdateRecord(
                            db,
                            store,
                            'kwCost',
                            value,
                          );
                        },
                      ),
                      // Spool Weight
                      TextFieldBlocBuilder(
                        textFieldBloc: bloc.spoolWeight,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: l10n.spoolWeightLabel,
                        ),
                        onChanged: (value) async {
                          bloc.submit();
                          await _addOrUpdateRecord(
                            db,
                            store,
                            'spoolWeight',
                            value,
                          );
                        },
                      ),
                      // Spool cost
                      TextFieldBlocBuilder(
                        textFieldBloc: bloc.spoolCost,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: l10n.spoolCostLabel,
                        ),
                        onChanged: (value) async {
                          bloc.submit();
                          await _addOrUpdateRecord(
                            db,
                            store,
                            'spoolCost',
                            value,
                          );
                        },
                      ),
                      // Print Weight
                      TextFieldBlocBuilder(
                        textFieldBloc: bloc.printWeight,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: l10n.printWeightLabel,
                        ),
                        onChanged: (_) => bloc.submit(),
                      ),
                      //Print Time
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: TextFieldBlocBuilder(
                              textFieldBloc: bloc.hours,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: l10n.hoursLabel,
                              ),
                              onChanged: (_) => bloc.submit(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFieldBlocBuilder(
                              textFieldBloc: bloc.minutes,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: l10n.minutesLabel,
                              ),
                              onChanged: (_) => bloc.submit(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CalculatorResults(results: results.value),
                      const AdContainer(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _addOrUpdateRecord(
    Database db,
    StoreRef store,
    String key,
    String value,
  ) async {
    // Check if the record exists before adding or updating it.
    await db.transaction((txn) async {
      // Look of existing record
      final existing = await store.record(key).getSnapshot(txn);
      if (existing == null) {
        // code not found, add
        await store.record(key).add(txn, {'value': value});
      } else {
        // Update existing
        await existing.ref.update(txn, {'value': value});
      }
    });
  }
}
