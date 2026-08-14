import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/batch_costing/batch_costing_page.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';

class BatchCostingEntryButton extends StatelessWidget {
  final bool isVisible;

  const BatchCostingEntryButton({required this.isVisible, super.key});

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSecondaryButton(
          key: const ValueKey<String>('calculator.batch_costing.open.button'),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const BatchCostingPage()),
            );
          },
          icon: const Icon(Icons.inventory_2_outlined),
          label: l10n.batchCostingEntryButton,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
