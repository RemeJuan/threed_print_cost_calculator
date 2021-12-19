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

    final electricity =
        "${l10n.resultElectricityPrefix}${results['electricity']}";
    final filament = "${l10n.resultFilamentPrefix}${results['filament']}";
    final total = "${l10n.resultTotalPrefix}${results['total']}";

    return Column(
      children: [
        Text(electricity),
        Text(filament),
        Text(total),
        const SizedBox(height: 16),
      ],
    );
  }
}
