import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/calculator/view/printer_select.dart';
import 'package:threed_print_cost_calculator/calculator/view/save_form.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
import 'package:threed_print_cost_calculator/settings/interface_settings/interface_settings_repository.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_surface_card.dart';

import 'calculator_results.dart';
import 'calculator_banner_ad.dart';
import 'components/batch_costing_entry_button.dart';
import 'components/history_load_warning_banner.dart';
import 'components/job_pricing_overrides_section.dart';
import 'components/materials_selection/materials_section.dart';
import 'components/reset_calculation_button.dart';
import 'components/save_actions_row.dart';
import 'components/time_section.dart';

class CalculatorPage extends HookConsumerWidget {
  const CalculatorPage({super.key});

  @override
  Widget build(context, ref) {
    final showSave = useState<bool>(false);
    final appRefreshTick = ref.watch(appRefreshProvider);

    final state = ref.watch(calculatorProvider);
    final notifier = ref.read(calculatorProvider.notifier);
    final policy = ref.watch(premiumAccessPolicyProvider);
    final interfaceSettings = ref.watch(interfaceSettingsProvider);

    // Section-level inputs manage their own controllers and focus nodes to
    // avoid prop drilling. MaterialsSection will create its own controllers.

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await notifier.init();
        notifier.submit();
      });
      return null;
    }, [appRefreshTick]);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: kAppSpace16,
        vertical: kAppSpace16,
      ),
      physics: const ClampingScrollPhysics(),
      child: AutofillGroup(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.showHistoryLoadReplacementWarning)
              const HistoryLoadWarningBanner(),
            AppSurfaceCard(
              padding: const EdgeInsets.fromLTRB(
                kAppSpace12,
                kAppSpace4,
                kAppSpace12,
                kAppSpace12,
              ),
              margin: const EdgeInsets.symmetric(vertical: kAppSpace8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (policy.printers().allowed &&
                      interfaceSettings.showPrinterSelect)
                    const PrinterSelect(),
                  const MaterialsSection(),
                  const SizedBox(height: kAppSpace8),
                  const TimeSection(),
                  const SizedBox(height: kAppSpace8),
                ],
              ),
            ),
            if (policy.advancedPricingConfig().allowed &&
                interfaceSettings.showAdvancedBreakdown)
              AppSurfaceCard(
                padding: const EdgeInsets.symmetric(horizontal: kAppSpace12),
                child: const JobPricingOverridesSection(),
              ),
            CalculatorResults(results: state.results, pricing: state.pricing),
            const SizedBox(height: kAppSpace8),
            BatchCostingEntryButton(
              isVisible:
                  policy.batchCosting().allowed &&
                  interfaceSettings.showBatchButton,
            ),
            Row(
              children: [
                Expanded(
                  child: ResetCalculationButton(
                    onResetRequested: () {
                      showSave.value = false;
                    },
                  ),
                ),
                if (policy.saveToHistory().allowed) ...[
                  if (!showSave.value) ...[
                    const SizedBox(width: kAppSpace12),
                    SaveActionsRow(
                      isVisible: true,
                      onOpenSave: () {
                        showSave.value = true;
                      },
                    ),
                  ],
                ],
              ],
            ),
            if (showSave.value)
              SaveForm(
                data: state.results,
                pricing: state.pricing,
                showSave: showSave,
              ),
            const SizedBox(height: 32),
            const CalculatorBannerAd(),
          ],
        ),
      ),
    );
  }
}
