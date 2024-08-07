import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:sembast/sembast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/calculator/bloc/calculator_bloc.dart';
import 'package:threed_print_cost_calculator/calculator/helpers/calculator_helpers.dart';
import 'package:threed_print_cost_calculator/calculator/view/calculator_results.dart';
import 'package:threed_print_cost_calculator/calculator/view/premium_widgets.dart';
import 'package:threed_print_cost_calculator/calculator/view/save_form.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';
import 'package:threed_print_cost_calculator/locator.dart';

import 'material_select.dart';
import 'printer_select.dart';

class CalculatorPage extends HookWidget {
  const CalculatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final premium = useState<bool>(false);
    final results = useState<Map<dynamic, dynamic>>({});
    final showSave = useState<bool>(false);

    final db = sl<Database>();
    final store = stringMapStoreFactory.store();

    useEffect(
      () {
        Purchases.addCustomerInfoUpdateListener((info) async {
          final prefs = await SharedPreferences.getInstance();
          final paywall = prefs.getBool('paywall') ?? false;
          final runCount = prefs.getInt('run_count') ?? 0;
          premium.value = info.entitlements.active.isNotEmpty;

          if (runCount > 2 && info.entitlements.active.isEmpty && !paywall) {
            try {
              await prefs.setBool('paywall', true);
              await Future.delayed(const Duration(seconds: 2));
              await RevenueCatUI.presentPaywallIfNeeded("pro");
            } catch (e) {
              debugPrint('paywall failed ${e.toString()}');
            }
          }
        });
        return null;
      },
      [],
    );

    return BlocProvider<CalculatorBloc>(
      create: (_) => CalculatorBloc(db, store),
      child: Builder(
        builder: (context) {
          final bloc = context.watch<CalculatorBloc>();
          final l10n = S.of(context);

          return FormBlocListener<CalculatorBloc, String, num>(
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
                    if (premium.value) const PrinterSelect(),
                    if (premium.value) const MaterialSelect(),
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
                              await CalculatorHelpers.addOrUpdateRecord(
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
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: l10n.spoolCostLabel,
                            ),
                            onChanged: (value) async {
                              bloc.submit();
                              await CalculatorHelpers.addOrUpdateRecord(
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
                    if (premium.value) PremiumWidgets(premium: premium.value),
                    const SizedBox(height: 16),
                    CalculatorResults(
                      results: results.value,
                      premium: premium.value,
                    ),
                    if (premium.value && !showSave.value)
                      MaterialButton(
                        onPressed: () {
                          showSave.value = true;
                        },
                        child: const Text('Save Print'),
                      ),
                    if (showSave.value)
                      SaveForm(
                        data: results.value,
                        showSave: showSave,
                      ),
                    if (!premium.value) ...[
                      Text(
                        l10n.premiumHeader,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      PremiumWidgets(premium: premium.value),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
