import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:threed_print_cost_calculator/app/help_support/help_support_links.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/paywall_plan_selector.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';

class PaywallBottomBar extends StatelessWidget {
  const PaywallBottomBar({
    super.key,
    required this.l10n,
    required this.selectedPackage,
    required this.purchasing,
    required this.onPurchase,
    required this.onRestore,
    required this.logger,
  });

  final AppLocalizations l10n;
  final Package? selectedPackage;
  final bool purchasing;
  final VoidCallback? onPurchase;
  final VoidCallback onRestore;
  final AppLogger logger;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedStyle = theme.textTheme.bodySmall?.copyWith(
      color: TEXT_TERTIARY,
    );

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
              onPressed: onPurchase,
              label: ctaLabel(l10n, selectedPackage),
              loading: purchasing,
            ),
          ),
          const SizedBox(height: 4),
          AppInlineButton(
            onPressed: onRestore,
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
