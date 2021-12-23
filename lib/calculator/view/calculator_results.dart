import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/l10n/l10n.dart';

class CalculatorResults extends StatelessWidget {
  const CalculatorResults({
    required this.results,
    Key? key,
  }) : super(key: key);

  final Map results;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SizedBox(
      width: 220,
      child: Column(
        children: [
          _itemRow(
            l10n.resultElectricityPrefix,
            results['electricity'].toString(),
          ),
          _itemRow(
            l10n.resultFilamentPrefix,
            results['filament'].toString(),
          ),
          _itemRow(
            l10n.resultTotalPrefix,
            results['total'].toString(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Row _itemRow(String prefix, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          prefix,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(value)
      ],
    );
  }
}
