import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:threed_print_cost_calculator/calculator/bloc/calculator_bloc.dart';
import 'package:threed_print_cost_calculator/calculator/view/calculator_results.dart';
import 'package:threed_print_cost_calculator/l10n/l10n.dart';

class CalculatorPage extends HookWidget {
  const CalculatorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final showResults = useState<bool>(false);
    final results = useState<Map>(<dynamic, dynamic>{});

    return BlocProvider<CalculatorBloc>(
      create: (_) => CalculatorBloc(),
      child: Builder(
        builder: (context) {
          final bloc = context.read<CalculatorBloc>();
          final l10n = context.l10n;

          return Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(title: Text(l10n.calculatorAppBarTitle)),
            body: FormBlocListener<CalculatorBloc, String, num>(
              onSubmitting: (context, state) {
                showResults.value = false;
              },
              onSuccess: (context, state) {
                showResults.value = true;
                results.value = jsonDecode(state.successResponse!) as Map;
              },
              onFailure: (context, state) {
                showResults.value = false;
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                physics: const ClampingScrollPhysics(),
                child: AutofillGroup(
                  child: Column(
                    children: [
                      TextFieldBlocBuilder(
                        textFieldBloc: bloc.watt,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: l10n.wattLabel,
                        ),
                      ),
                      TextFieldBlocBuilder(
                        textFieldBloc: bloc.printWeight,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: l10n.printWeightLabel,
                        ),
                      ),
                      TextFieldBlocBuilder(
                        textFieldBloc: bloc.time,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: l10n.timeLabel,
                        ),
                      ),
                      TextFieldBlocBuilder(
                        textFieldBloc: bloc.spoolWeight,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: l10n.spoolWeightLabel,
                        ),
                      ),
                      TextFieldBlocBuilder(
                        textFieldBloc: bloc.spoolCost,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: l10n.spoolCostLabel,
                        ),
                      ),
                      TextFieldBlocBuilder(
                        textFieldBloc: bloc.kwCost,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: l10n.electricityCostLabel,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (showResults.value)
                        CalculatorResults(results: results.value),
                      ElevatedButton(
                        onPressed: bloc.submit,
                        child: Text(l10n.submitButton),
                      ),
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
}
