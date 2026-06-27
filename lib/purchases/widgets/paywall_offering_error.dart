import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';

class PaywallOfferingError extends StatelessWidget {
  const PaywallOfferingError({
    super.key,
    required this.l10n,
    required this.onRetry,
  });

  final AppLocalizations l10n;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
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
          AppTertiaryButton(onPressed: onRetry, label: l10n.retryButton),
        ],
      ),
    );
  }
}
