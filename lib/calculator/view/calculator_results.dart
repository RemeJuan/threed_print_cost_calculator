import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';

class CalculatorResults extends StatelessWidget {
  const CalculatorResults({
    required this.results,
    required this.premium,
    super.key,
  });

  final Map<dynamic, dynamic> results;
  final bool premium;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    const width = kIsWeb ? 250.0 : null;

    return SizedBox(
      width: width,
      child: Column(
        children: [
          _itemRow(
            context,
            l10n.resultElectricityPrefix,
            (results['electricity'] ?? '0').toString(),
          ),
          _itemRow(
            context,
            l10n.resultFilamentPrefix,
            (results['filament'] ?? '0').toString(),
          ),
          _itemRow(
            context,
            l10n.resultTotalPrefix,
            (results['total'] ?? '0').toString(),
          ),
          if (premium) ...[
            _itemRow(
              context,
              l10n.riskTotalPrefix,
              (results['risk'] ?? '0').toString(),
            ),
            _itemRow(
              context,
              l10n.labourCostPrefix,
              (results['labour'] ?? '0').toString(),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Padding _itemRow(BuildContext context, String prefix, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            prefix,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(value),
        ],
      ),
    );
  }
}
