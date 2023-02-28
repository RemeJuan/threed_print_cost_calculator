import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/l10n/l10n.dart';

class CalculatorResults extends StatelessWidget {
  const CalculatorResults({
    required this.results,
    super.key,
  });

  final Map<dynamic, dynamic> results;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const width = kIsWeb ? 250.0 : null;

    return SizedBox(
      width: width,
      child: Column(
        children: [
          _itemRow(
            l10n.resultElectricityPrefix,
            (results['electricity'] ?? '0').toString(),
          ),
          _itemRow(
            l10n.resultFilamentPrefix,
            (results['filament'] ?? '0').toString(),
          ),
          _itemRow(
            l10n.resultTotalPrefix,
            (results['total'] ?? '0').toString(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Padding _itemRow(String prefix, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            prefix,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value)
        ],
      ),
    );
  }
}
