import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';

class PaywallPitchSection extends StatelessWidget {
  const PaywallPitchSection({super.key, required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
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
}
