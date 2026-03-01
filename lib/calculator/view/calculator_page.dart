import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/calculator/view/components/adjustments_section.dart';
import 'package:threed_print_cost_calculator/calculator/view/printer_select.dart';
import 'package:threed_print_cost_calculator/calculator/view/save_form.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';
import 'package:threed_print_cost_calculator/shared/theme.dart';

import 'calculator_results.dart';
import 'components/multi_material_section.dart';
import 'components/rates_section.dart';
import 'components/time_section.dart';

class CalculatorPage extends HookConsumerWidget {
  const CalculatorPage({super.key});

  @override
  Widget build(context, ref) {
    final premium = useState<bool>(false);
    final showSave = useState<bool>(false);
    final prefs = ref.read(sharedPreferencesProvider);

    useEffect(() {
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
    }, []);

    final state = ref.watch(calculatorProvider);
    final notifier = ref.read(calculatorProvider.notifier);
    final l10n = S.of(context);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier
          ..init()
          ..submit();
      });
      return null;
    }, []);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      physics: const ClampingScrollPhysics(),
      child: AutofillGroup(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (premium.value) const PrinterSelect(),
            // Multi-material section replaces the old single-material selector
            // and spool weight/cost inputs. Always shown (free + premium).
            const MultiMaterialSection(),
            const SizedBox(height: 8),
            TimeSection(),
            const SizedBox(height: 8),
            RatesSection(premium: premium.value),
            const SizedBox(height: 8),
            AdjustmentsSection(premium: premium.value),
            const SizedBox(height: 16),
            CalculatorResults(results: state.results, premium: premium.value),
            if (premium.value && !showSave.value)
              ElevatedButton.icon(
                onPressed: () {
                  showSave.value = true;
                },
                icon: const Icon(Icons.save),
                label: Text(l10n.savePrintButton),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DEEP_BLUE,
                  foregroundColor: LIGHT_BLUE,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            if (showSave.value)
              SaveForm(data: state.results, showSave: showSave),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
