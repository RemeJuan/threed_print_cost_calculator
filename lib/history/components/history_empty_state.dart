import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/history/components/history_upsell_banner.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';

class HistoryEmptyState extends StatelessWidget {
  const HistoryEmptyState({
    required this.showUpsell,
    required this.onUpsellTap,
    super.key,
  });

  final bool showUpsell;
  final VoidCallback onUpsellTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.historyEmptyTitle,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.historyEmptyDescription,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (showUpsell) ...[
              const SizedBox(height: 16),
              HistoryUpsellBanner(onTap: onUpsellTap),
            ],
          ],
        ),
      ),
    );
  }
}
