import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/calculator/view/components/adjustments_section.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/calculator/view/printer_select.dart';
import 'package:threed_print_cost_calculator/calculator/view/save_form.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/shared/theme.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

import 'calculator_results.dart';
import 'components/history_load_warning_banner.dart';
import 'components/materials_selection/materials_section.dart';
import 'components/rates_section.dart';
import 'components/time_section.dart';

abstract class PaywallPresenter {
  Future<void> present(String offeringId);
}

final paywallPresenterProvider = Provider<PaywallPresenter>((ref) {
  return const _RevenueCatPaywallPresenter();
});

class _RevenueCatPaywallPresenter implements PaywallPresenter {
  const _RevenueCatPaywallPresenter();

  @override
  Future<void> present(String offeringId) {
    return RevenueCatUI.presentPaywallIfNeeded(offeringId);
  }
}

class CalculatorPage extends HookConsumerWidget {
  const CalculatorPage({super.key});

  @override
  Widget build(context, ref) {
    final showSave = useState<bool>(false);
    final prefs = ref.read(sharedPreferencesProvider);
    final logger = ref.read(appLoggerProvider);

    final state = ref.watch(calculatorProvider);
    final notifier = ref.read(calculatorProvider.notifier);
    final l10n = S.of(context);
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
              () => AppAnalytics.premiumFeatureTapped('multi_printer'),
            );
            await prefs.setBool('paywall', true);
            await Future.delayed(const Duration(seconds: 2));
            AppAnalytics.safeLog(
              () => AppAnalytics.paywallShown('multi_printer'),
            );
            await ref.read(paywallPresenterProvider).present("pro");
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
    }, []);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      physics: const ClampingScrollPhysics(),
      child: AutofillGroup(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.showHistoryLoadReplacementWarning)
              const HistoryLoadWarningBanner(),
            if (isPremium) const PrinterSelect(),
            // Let MaterialsSection manage its own controllers and focus state
            const MaterialsSection(),
            const SizedBox(height: 8),
            TimeSection(),
            const SizedBox(height: 8),
            const RatesSection(),
            const SizedBox(height: 8),
            const AdjustmentsSection(),
            const SizedBox(height: 16),
            CalculatorResults(results: state.results),
            if (isPremium && !showSave.value)
              ElevatedButton.icon(
                key: const ValueKey<String>('calculator.save.open.button'),
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
