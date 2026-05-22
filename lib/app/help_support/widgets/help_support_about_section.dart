import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_filter_chip.dart';

class HelpSupportAboutSection extends StatelessWidget {
  const HelpSupportAboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(l10n.helpSupportAboutIntro),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                [
                      l10n.helpSupportTrustNoAccounts,
                      l10n.helpSupportTrustNoCloudSync,
                      l10n.helpSupportTrustNoTracking,
                      l10n.helpSupportTrustLocalData,
                    ]
                    .map(
                      (label) => AppFilterChip(label: label),
                    )
                    .toList(growable: false),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(l10n.helpSupportAboutCalculator),
        ),
        Text(l10n.helpSupportAboutOutcome),
      ],
    );
  }
}
