import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/paywall_comparison_table.dart';
import 'package:threed_print_cost_calculator/purchases/paywall_plan_selector.dart';
import 'package:threed_print_cost_calculator/purchases/paywall_screen_actions.dart';
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
  Offering? _currentOffering;
  Package? _selectedPackage;
  bool _loadingOfferings = true;
  PaywallOfferingsLoadError? _offeringsError;
  bool _purchasing = false;

  @override
  void initState() {
    super.initState();
    AppAnalytics.safeLog(
      () => AppAnalytics.paywallShown(
        widget.triggerFeature,
        source: widget.source,
        defaultEntryPoint: widget.defaultEntryPoint,
        launchCount: widget.launchCount,
      ),
    );
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    final result = await loadPaywallOfferings(
      read: <T>(provider) => ref.read(provider),
      offeringId: widget.offeringId,
    );
    if (!mounted) return;
    setState(() {
      _currentOffering = result.offering;
      _selectedPackage = preferredPackage(result.offering?.availablePackages);
      _offeringsError = result.error;
      _loadingOfferings = false;
    });
  }

  Future<void> _purchase() async {
    if (_selectedPackage == null || _purchasing) return;
    setState(() => _purchasing = true);
    try {
      await completePaywallPurchase(
        read: <T>(provider) => ref.read(provider),
        package: _selectedPackage!,
        purchaseSource: widget.purchaseSource,
        defaultEntryPoint: widget.defaultEntryPoint,
        onSuccess: () => Navigator.of(context).pop(),
      );
    } on PlayIntegrityActionBlockedException {
      if (!mounted) return;
      showPlayIntegrityActionBlocked(context);
    } catch (e) {
      if (!mounted) return;
      showPaywallPurchaseError(context);
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  Future<void> _restore() async {
    if (_purchasing) return;
    setState(() => _purchasing = true);
    try {
      await completePaywallRestore(
        read: <T>(provider) => ref.read(provider),
        source: widget.source,
        defaultEntryPoint: widget.defaultEntryPoint,
        onSuccess: () => Navigator.of(context).pop(),
      );
    } on PlayIntegrityActionBlockedException {
      if (!mounted) return;
      showPlayIntegrityActionBlocked(context);
    } catch (e, st) {
      if (!mounted) return;
      logPaywallRestoreFailure(
        read: <T>(provider) => ref.read(provider),
        error: e,
        stackTrace: st,
      );
      showPaywallRestoreError(context);
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final policy = ref.read(premiumAccessPolicyProvider);
    final packages = _currentOffering?.availablePackages ?? [];

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
                      selectedPackage: _selectedPackage,
                      onSelectPackage: (pkg) =>
                          setState(() => _selectedPackage = pkg),
                    ),
                  ],
                ),
              ),
            ),
            if (_loadingOfferings)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: kAppSpace12),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_offeringsError != null)
              PaywallOfferingError(
                l10n: l10n,
                onRetry: _retryOfferings,
              )
            else
              PaywallBottomBar(
                l10n: l10n,
                selectedPackage: _selectedPackage,
                purchasing: _purchasing,
                onPurchase: _selectedPackage != null ? _purchase : null,
                onRestore: _restore,
                logger: ref.read(appLoggerProvider),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _retryOfferings() async {
    setState(() {
      _loadingOfferings = true;
      _offeringsError = null;
    });
    await _loadOfferings();
  }
}
