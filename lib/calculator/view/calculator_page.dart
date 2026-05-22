import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/calculator/view/printer_select.dart';
import 'package:threed_print_cost_calculator/calculator/view/save_form.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_surface_card.dart';

import 'calculator_results.dart';
import 'components/history_load_warning_banner.dart';
import 'components/job_pricing_overrides_section.dart';
import 'components/materials_selection/materials_section.dart';
import 'components/time_section.dart';
import 'package:threed_print_cost_calculator/purchases/paywall_presenter.dart';
import 'package:threed_print_cost_calculator/batch_costing/batch_costing_page.dart';

class CalculatorPage extends HookConsumerWidget {
  const CalculatorPage({super.key});

  @override
  Widget build(context, ref) {
    final showSave = useState<bool>(false);
    final prefs = ref.read(sharedPreferencesProvider);
    final logger = ref.read(appLoggerProvider);
    final appRefreshTick = ref.watch(appRefreshProvider);

    final state = ref.watch(calculatorProvider);
    final notifier = ref.read(calculatorProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    final premiumState = ref.watch(premiumStateProvider);
    final isPremium = premiumState.isPremium;

    useEffect(() {
      if (premiumState.isLoading || !premiumState.isPremium) return null;

      Future<void>(() async {
        final paywall = prefs.getBool('paywall') ?? false;
        final runCount = prefs.getInt('run_count') ?? 0;

        if (runCount > 2 && !paywall) {
          try {
            AppAnalytics.safeLog(
              () => AppAnalytics.premiumFeatureTapped(
                'multi_printer',
                isPro: isPremium,
                source: 'premium_feature',
              ),
            );
            await prefs.setBool('paywall', true);
            await Future.delayed(const Duration(seconds: 2));
            await ref
                .read(paywallPresenterProvider)
                .present(
                  'pro',
                  triggerFeature: 'multi_printer',
                  purchaseSource: 'calculator',
                  source: 'premium_feature',
                  launchCount: runCount,
                );
          } catch (e) {
            logger.warn(
              AppLogCategory.billing,
              'Paywall presentation failed',
              context: {'trigger': 'multi_printer'},
              error: e,
            );
          }
        }
      });

      return null;
    }, [premiumState.isLoading, premiumState.isPremium]);

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
                  if (isPremium) const PrinterSelect(),
                  const MaterialsSection(),
                  const SizedBox(height: kAppSpace8),
                  const TimeSection(),
                  const SizedBox(height: kAppSpace8),
                ],
              ),
            ),
            if (isPremium)
              AppSurfaceCard(
                padding: const EdgeInsets.symmetric(horizontal: kAppSpace12),
                child: const JobPricingOverridesSection(),
              ),
            CalculatorResults(results: state.results, pricing: state.pricing),
            const SizedBox(height: kAppSpace8),
            Row(
              children: [
                Expanded(
                  child: AppSecondaryButton(
                    key: const ValueKey<String>('calculator.reset.button'),
                    onPressed: () async {
                      final shouldReset = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: Text(l10n.resetCalculationTitle),
                          content: Text(l10n.resetCalculationBody),
                          actions: [
                            AppTertiaryButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(false),
                              label: l10n.cancelButton,
                            ),
                            AppPrimaryButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(true),
                              label: l10n.resetButtonLabel,
                            ),
                          ],
                        ),
                      );

                      if (shouldReset != true) return;
                      showSave.value = false;
                      await notifier.resetToDefaults();
                    },
                    icon: const Icon(Icons.refresh),
                    label: l10n.resetButtonLabel,
                  ),
                ),
                if (isPremium && !showSave.value) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppPrimaryButton(
                      key: const ValueKey<String>(
                        'calculator.save.open.button',
                      ),
                      onPressed: () {
                        showSave.value = true;
                      },
                      icon: const Icon(Icons.save),
                      label: l10n.savePrintButton,
                    ),
                  ),
                ],
              ],
            ),
            if (isPremium) ...[
              const SizedBox(height: 12),
              AppSecondaryButton(
                key: const ValueKey<String>(
                  'calculator.batch_costing.open.button',
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const BatchCostingPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.view_list_outlined),
                label: l10n.batchCostingEntryButton,
              ),
            ],
            if (showSave.value)
              SaveForm(
                data: state.results,
                pricing: state.pricing,
                showSave: showSave,
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
