import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/paywall_comparison_table.dart';
import 'package:threed_print_cost_calculator/purchases/paywall_plan_selector.dart';
import 'package:threed_print_cost_calculator/purchases/paywall_screen_actions.dart';
import 'package:threed_print_cost_calculator/purchases/paywall_screen_controller.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
import 'package:threed_print_cost_calculator/purchases/widgets/paywall_bottom_bar.dart';
import 'package:threed_print_cost_calculator/purchases/widgets/paywall_header.dart';
import 'package:threed_print_cost_calculator/purchases/widgets/paywall_offering_error.dart';
import 'package:threed_print_cost_calculator/purchases/widgets/paywall_pitch_section.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({
    super.key,
    this.offeringId = 'pro',
    this.triggerFeature = 'custom_paywall_preview',
    this.purchaseSource = 'custom_paywall_preview',
    this.defaultEntryPoint = 'admin_preview',
    this.source = 'custom_paywall_preview',
    this.launchCount,
  });

  final String offeringId;
  final String triggerFeature;
  final String purchaseSource;
  final String defaultEntryPoint;
  final String source;
  final int? launchCount;

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  late final PaywallScreenControllerArgs _args;

  @override
  void initState() {
    super.initState();
    _args = PaywallScreenControllerArgs(
      offerId: widget.offeringId,
      purchaseSource: widget.purchaseSource,
      defaultEntryPoint: widget.defaultEntryPoint,
      source: widget.source,
    );
    AppAnalytics.safeLog(
      () => AppAnalytics.paywallShown(
        widget.triggerFeature,
        source: widget.source,
        defaultEntryPoint: widget.defaultEntryPoint,
        launchCount: widget.launchCount,
      ),
    );
  }

  Future<void> _handleOutcome(PaywallActionOutcome outcome) async {
    if (!mounted) return;
    if (outcome is PaywallActionSuccess) {
      Navigator.of(context).pop();
    } else if (outcome is PaywallActionIntegrityBlocked) {
      showPlayIntegrityActionBlocked(context);
    } else if (outcome is PaywallActionFailure) {
      if (outcome.isRestore) {
        showPaywallRestoreError(context);
      } else {
        showPaywallPurchaseError(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final policy = ref.read(premiumAccessPolicyProvider);
    final state = ref.watch(paywallScreenControllerProvider(_args));
    final controller = ref.read(
      paywallScreenControllerProvider(_args).notifier,
    );
    final packages = state.offering?.availablePackages ?? [];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            PaywallHeader(onClose: () => Navigator.of(context).pop()),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  kAppSpace16,
                  kAppSpace8,
                  kAppSpace16,
                  kAppSpace16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PaywallPitchSection(l10n: l10n),
                    const SizedBox(height: kAppSpace16),
                    PaywallComparisonTable(policy: policy, l10n: l10n),
                    const SizedBox(height: kAppSpace16),
                    PaywallPlanSelector(
                      packages: packages,
                      selectedPackage: state.selectedPackage,
                      onSelectPackage: controller.selectPackage,
                    ),
                  ],
                ),
              ),
            ),
            if (state.loadingOfferings)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: kAppSpace12),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.offeringsError != null)
              PaywallOfferingError(
                l10n: l10n,
                onRetry: controller.retryOfferings,
              )
            else
              PaywallBottomBar(
                l10n: l10n,
                selectedPackage: state.selectedPackage,
                purchasing: state.purchasing,
                onPurchase: state.selectedPackage != null
                    ? () async => _handleOutcome(await controller.purchase())
                    : null,
                onRestore: () async =>
                    _handleOutcome(await controller.restore()),
                logger: ref.read(appLoggerProvider),
              ),
          ],
        ),
      ),
    );
  }
}
