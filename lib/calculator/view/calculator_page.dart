import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/calculator/bloc/calculator_bloc.dart';
import 'package:threed_print_cost_calculator/calculator/view/advert.dart';
import 'package:threed_print_cost_calculator/calculator/view/calculator_results.dart';
import 'package:threed_print_cost_calculator/calculator/view/header_actions.dart';
import 'package:threed_print_cost_calculator/l10n/l10n.dart';
import 'package:threed_print_cost_calculator/locator.dart';

class CalculatorPage extends HookWidget {
  const CalculatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final results = useState<Map<dynamic, dynamic>>({});
    final premium = useState<bool>(false);

    final db = sl<Database>();
    final store = stringMapStoreFactory.store();

    Purchases.addCustomerInfoUpdateListener((info) {
      premium.value = info.entitlements.all['Premium']?.isActive ?? false;
    });

    return BlocProvider<CalculatorBloc>(
      create: (_) => CalculatorBloc(db, store),
      child: Builder(
        builder: (context) {
          final bloc = context.read<CalculatorBloc>();
          final l10n = context.l10n;

          return Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              centerTitle: true,
              title: Text(l10n.calculatorAppBarTitle),
              actions: const [HeaderActions()],
            ),
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
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Printer Wattage
                          Expanded(
                            child: TextFieldBlocBuilder(
                              textFieldBloc: bloc.watt,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: l10n.wattLabel,
                                suffixText: 'watt',
                              ),
                              onChanged: (value) async {
                                bloc.submit();
                                await _addOrUpdateRecord(
                                  db,
                                  store,
                                  'watt',
                                  value,
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Electricity Cost
                          Expanded(
                            child: TextFieldBlocBuilder(
                              textFieldBloc: bloc.kwCost,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: InputDecoration(
                                labelText: l10n.electricityCostLabel,
                                suffixText: 'kW/h',
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
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          // Spool Weight
                          Expanded(
                            child: TextFieldBlocBuilder(
                              textFieldBloc: bloc.spoolWeight,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: l10n.spoolWeightLabel,
                                suffixText: 'g',
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
                          ),
                          const SizedBox(width: 16),
                          // Spool cost
                          Expanded(
                            child: TextFieldBlocBuilder(
                              textFieldBloc: bloc.spoolCost,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
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
                          ),
                        ],
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
                      if (premium.value) ..._premiumWidgets(context, premium),
                      const SizedBox(height: 16),
                      CalculatorResults(
                        results: results.value,
                        premium: premium.value,
                      ),
                      if (!premium.value) ...[
                        Text(l10n.premiumHeader),
                        ..._premiumWidgets(context, premium),
                      ],
                      if (!premium.value) const AdContainer(),
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

  List<Widget> _premiumWidgets(
    BuildContext context,
    ValueNotifier<bool> premium,
  ) {
    final db = sl<Database>();
    final store = stringMapStoreFactory.store();
    final bloc = context.read<CalculatorBloc>();
    final l10n = context.l10n;

    return [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: TextFieldBlocBuilder(
              textFieldBloc: bloc.labourRate,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.labourRateLabel,
              ),
              onChanged: (value) async {
                bloc.submit();
                await _addOrUpdateRecord(
                  db,
                  store,
                  'labourRate',
                  value,
                );
              },
              isEnabled: premium.value,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextFieldBlocBuilder(
              textFieldBloc: bloc.labourTime,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.labourTimeLabel,
              ),
              onChanged: (_) => bloc.submit(),
              isEnabled: premium.value,
            ),
          ),
        ],
      ),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: TextFieldBlocBuilder(
              textFieldBloc: bloc.wearAndTear,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.wearAndTearLabel,
              ),
              onChanged: (value) async {
                bloc.submit();
                await _addOrUpdateRecord(
                  db,
                  store,
                  'wearAndTear',
                  value,
                );
              },
              isEnabled: premium.value,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextFieldBlocBuilder(
              textFieldBloc: bloc.failureRisk,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.failureRiskLabel,
              ),
              onChanged: (value) async {
                bloc.submit();
                await _addOrUpdateRecord(
                  db,
                  store,
                  'failureRisk',
                  value,
                );
              },
              isEnabled: premium.value,
            ),
          ),
        ],
      ),
    ];
  }
}
