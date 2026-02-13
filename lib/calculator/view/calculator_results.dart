import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculation_results_state.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';

class CalculatorResults extends StatelessWidget {
  final CalculationResult results;
  final bool premium;

  const CalculatorResults({
    required this.results,
    required this.premium,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    const width = kIsWeb ? 250.0 : null;

    return Container(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(8, 8, 18, 1),
        borderRadius: BorderRadius.circular(8),
      ),
      width: width,
      child: Column(
        children: [
          _itemRow(context, l10n.resultElectricityPrefix, results.electricity),
          _itemRow(context, l10n.resultFilamentPrefix, results.filament),
          if (premium) ...[
            _itemRow(context, l10n.riskTotalPrefix, results.risk),
            _itemRow(context, l10n.labourCostPrefix, results.labour),
          ],
          Divider(),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.resultTotalPrefix,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  results.total.toString(),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Padding _itemRow(BuildContext context, String prefix, num value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            prefix,
            style:
                Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.white70) ??
                const TextStyle(color: Colors.white70),
          ),
          Text(value.toString()),
        ],
      ),
    );
  }
}
