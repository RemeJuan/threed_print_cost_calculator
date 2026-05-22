import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';

class HistoryItemSummary extends StatelessWidget {
  const HistoryItemSummary({
    required this.data,
    required this.itemKeyPrefix,
    super.key,
  });

  final HistoryModel data;
  final String itemKeyPrefix;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final weightKg = (data.weight / 1000);
    String timeLabel;
    try {
      final parts = data.timeHours.split(':');
      final h = int.tryParse(parts[0]) ?? 0;
      final m = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
      timeLabel = '${h}h ${m}m';
    } catch (_) {
      timeLabel = data.timeHours;
    }

    final summary =
        '${weightKg.toStringAsFixed(2)} kg • $timeLabel • ${data.printer} • ${data.material}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.totalCostLabel,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: TEXT_PRIMARY,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            Text(
              key: ValueKey<String>('$itemKeyPrefix.totalCost'),
              data.totalCost.toStringAsFixed(2),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: TEXT_PRIMARY,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          key: ValueKey<String>('$itemKeyPrefix.summary'),
          summary,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
