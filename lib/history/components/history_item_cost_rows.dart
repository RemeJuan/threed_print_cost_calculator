import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';

class HistoryItemCostRows extends StatelessWidget {
  const HistoryItemCostRows({
    required this.data,
    required this.itemKeyPrefix,
    super.key,
  });

  final HistoryModel data;
  final String itemKeyPrefix;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        _costRow(
          context,
          l10n.electricityCostLabel,
          data.electricityCost,
          key: ValueKey<String>('$itemKeyPrefix.electricityCost'),
        ),
        _costRow(
          context,
          l10n.filamentCostLabel,
          data.filamentCost,
          key: ValueKey<String>('$itemKeyPrefix.filamentCost'),
        ),
        _costRow(
          context,
          l10n.labourCostLabel,
          data.labourCost,
          key: ValueKey<String>('$itemKeyPrefix.labourCost'),
        ),
        _costRow(
          context,
          l10n.riskCostLabel,
          data.riskCost,
          key: ValueKey<String>('$itemKeyPrefix.riskCost'),
        ),
      ],
    );
  }
}

Widget _costRow(BuildContext context, String label, num value, {Key? key}) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        Text(
          key: key,
          value.toStringAsFixed(2),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.white),
        ),
      ],
    ),
  );
}
