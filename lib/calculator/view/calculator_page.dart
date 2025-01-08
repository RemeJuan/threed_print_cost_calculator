import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:threed_print_cost_calculator/app/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/calculator/view/premium_widgets.dart';
import 'package:threed_print_cost_calculator/calculator/view/printer_select.dart';
import 'package:threed_print_cost_calculator/calculator/view/save_form.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';

import 'calculator_results.dart';
import 'material_select.dart';

class CalculatorPage extends HookConsumerWidget {
  const CalculatorPage({super.key});

  @override
  Widget build(context, ref) {
    final premium = useState<bool>(false);
    final showSave = useState<bool>(false);
    final prefs = ref.read(sharedPreferencesProvider);

    useEffect(
      () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Purchases.addCustomerInfoUpdateListener((info) async {
            if (info.entitlements.active.isEmpty) return;

            final paywall = prefs.getBool('paywall') ?? false;
            final runCount = prefs.getInt('run_count') ?? 0;
            premium.value = info.entitlements.active.isNotEmpty;

            if (runCount > 2 && !paywall) {
              try {
                await prefs.setBool('paywall', true);
                await Future.delayed(const Duration(seconds: 2));
                await RevenueCatUI.presentPaywallIfNeeded("pro");
              } catch (e) {
                debugPrint('paywall failed ${e.toString()}');
              }
            }
          });
        });
        return null;
      },
      [],
    );

    final state = ref.watch(calculatorProvider);
    final notifier = ref.read(calculatorProvider.notifier);
    final l10n = S.of(context);

    final spoolWeightController = useTextEditingController(
      text: state.spoolWeight.value?.toString() ?? '',
    );
    final spoolCostController = useTextEditingController(
      text: state.spoolCost.value?.toString() ?? '',
    );
    final printWeightController = useTextEditingController(
      text: state.printWeight.value?.toString() ?? '',
    );
    final hoursController = useTextEditingController(
      text: state.hours.value?.toString() ?? '',
    );
    final minutesController = useTextEditingController(
      text: state.minutes.value?.toString() ?? '',
    );

    useEffect(() {
      spoolWeightController.text = state.spoolWeight.value?.toString() ?? '';
      spoolCostController.text = state.spoolCost.value?.toString() ?? '';
      printWeightController.text = state.printWeight.value?.toString() ?? '';
      hoursController.text = state.hours.value?.toString() ?? '';
      minutesController.text = state.minutes.value?.toString() ?? '';
      return null;
    }, [state]);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier
          ..init()
          ..submit();
      });
      return null;
    }, []);

    return SingleChildScrollView(
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
                  child: TextFormField(
                    controller: spoolWeightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.spoolWeightLabel,
                      suffixText: 'g',
                    ),
                    onChanged: (value) async {
                      notifier
                        ..updateSpoolWeight(num.tryParse(value) ?? 0)
                        ..submit();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Spool cost
                Expanded(
                  child: TextFormField(
                    controller: spoolCostController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.spoolCostLabel,
                    ),
                    onChanged: (value) async {
                      // bloc.submit();
                      notifier
                        ..updateSpoolCost(value)
                        ..submit();
                    },
                  ),
                ),
              ],
            ),
            TextFormField(
              controller: printWeightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.printWeightLabel,
              ),
              onChanged: (value) {
                notifier
                  ..updatePrintWeight(value)
                  ..submit();
              },
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: hoursController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.hoursLabel,
                    ),
                    onChanged: (value) {
                      notifier
                        ..updateHours(num.tryParse(value) ?? 0)
                        ..submit();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: minutesController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.minutesLabel,
                    ),
                    onChanged: (value) {
                      notifier
                        ..updateMinutes(num.tryParse(value) ?? 0)
                        ..submit();
                    },
                  ),
                ),
              ],
            ),
            if (premium.value) PremiumWidgets(premium: premium.value),
            const SizedBox(height: 16),
            CalculatorResults(
              results: state.results,
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
                data: state.results,
                showSave: showSave,
              ),
          ],
        ),
      ),
    );
  }
}
