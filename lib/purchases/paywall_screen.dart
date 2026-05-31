import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:threed_print_cost_calculator/app/help_support/help_support_links.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/paywall_comparison_table.dart';
import 'package:threed_print_cost_calculator/purchases/paywall_plan_selector.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
import 'package:threed_print_cost_calculator/purchases/premium_purchase_gateway.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';

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
  String? _offeringsError;
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
    try {
      final gateway = ref.read(premiumPurchaseGatewayProvider);
      final current = await gateway.getOffering(widget.offeringId);
      if (!mounted) return;
      setState(() {
        _currentOffering = current;
        _selectedPackage = preferredPackage(current?.availablePackages);
        _loadingOfferings = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _offeringsError = e.toString();
        _loadingOfferings = false;
      });
    }
  }

  Future<void> _purchase() async {
    if (_selectedPackage == null || _purchasing) return;
    setState(() => _purchasing = true);
    try {
      final gateway = ref.read(premiumPurchaseGatewayProvider);
      await gateway.purchasePackage(_selectedPackage!);
      if (!mounted) return;
      AppAnalytics.safeLog(
        () => AppAnalytics.purchaseCompleted(
          widget.purchaseSource,
          defaultEntryPoint: widget.defaultEntryPoint,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.purchaseError)),
      );
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  Future<void> _restore() async {
    if (_purchasing) return;
    setState(() => _purchasing = true);
    try {
      final gateway = ref.read(premiumPurchaseGatewayProvider);
      await gateway.restorePurchases();
      if (!mounted) return;
      AppAnalytics.safeLog(
        () => AppAnalytics.restoreCompleted(
          source: widget.source,
          defaultEntryPoint: widget.defaultEntryPoint,
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e, st) {
      ref
          .read(appLoggerProvider)
          .warn(
            AppLogCategory.billing,
            'Restore failed',
            error: e,
            stackTrace: st,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.paywallRestoreError),
        ),
      );
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
            _buildHeader(context),
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
                    _buildPitchSection(l10n),
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
              _buildOfferingError(l10n)
            else
              _buildBottomSection(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: kAppSpace8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildPitchSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.paywallTitle,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.paywallPitchLine,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: TEXT_SECONDARY, height: 1.25),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.paywallSubtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: TEXT_TERTIARY,
            height: 1.25,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildOfferingError(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        kAppSpace16,
        kAppSpace12,
        kAppSpace16,
        kAppSpace12,
      ),
      child: Column(
        children: [
          Text(
            l10n.paywallOfferingError,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: STATUS_ERROR),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: kAppSpace8),
          AppTertiaryButton(
            onPressed: () {
              setState(() {
                _loadingOfferings = true;
                _offeringsError = null;
              });
              _loadOfferings();
            },
            label: l10n.retryButton,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final mutedStyle = theme.textTheme.bodySmall?.copyWith(
      color: TEXT_TERTIARY,
    );
    final logger = ref.read(appLoggerProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(kAppSpace16, 4, kAppSpace16, 0),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: SHELL_BORDER)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              l10n.paywallTrustLine,
              textAlign: TextAlign.center,
              style: mutedStyle,
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: AppPrimaryButton(
              onPressed: _selectedPackage != null ? _purchase : null,
              label: ctaLabel(l10n, _selectedPackage),
              loading: _purchasing,
            ),
          ),
          const SizedBox(height: 4),
          AppInlineButton(
            onPressed: _restore,
            label: l10n.paywallRestore,
            foregroundColor: TEXT_TERTIARY,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            minHeight: 32,
            textAlign: TextAlign.center,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: AppInlineButton(
                  onPressed: () =>
                      openUrl(helpSupportPrivacyUrl, logger: logger),
                  label: l10n.helpSupportPrivacyPolicyLabel,
                  foregroundColor: TEXT_TERTIARY,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  minHeight: 32,
                  maxLines: 2,
                  overflow: TextOverflow.visible,
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Text(l10n.separator, style: mutedStyle),
              ),
              Flexible(
                child: AppInlineButton(
                  onPressed: () => openUrl(helpSupportTermsUrl, logger: logger),
                  label: l10n.helpSupportTermsOfUseLabel,
                  foregroundColor: TEXT_TERTIARY,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  minHeight: 32,
                  maxLines: 2,
                  overflow: TextOverflow.visible,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
