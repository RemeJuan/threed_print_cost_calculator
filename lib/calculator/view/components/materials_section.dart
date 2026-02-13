import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';

class MaterailsSection extends HookConsumerWidget {
  final TextEditingController spoolWeightController;
  final TextEditingController spoolCostController;
  final TextEditingController printWeightController;

  const MaterailsSection({
    required this.spoolWeightController,
    required this.spoolCostController,
    required this.printWeightController,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(calculatorProvider.notifier);
    final l10n = S.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            // Spool Weight
            Expanded(
              child: TextFormField(
                controller: spoolWeightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.spoolWeightLabel,
                  suffixText: l10n.gramsSuffix,
                ),
                onChanged: (value) async {
                  notifier
                    ..updateSpoolWeight(num.tryParse(value) ?? 0)
                    ..submit();
                },
              ),
            ),
            const SizedBox(width: 16),
            // Spool cost
            Expanded(
              child: TextFormField(
                controller: spoolCostController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(labelText: l10n.spoolCostLabel),
                onChanged: (value) async {
                  // bloc.submit();
                  notifier
                    ..updateSpoolCost(value)
                    ..submit();
                },
              ),
            ),
          ],
        ),
        TextFormField(
          controller: printWeightController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: l10n.printWeightLabel),
          onChanged: (value) {
            notifier
              ..updatePrintWeight(value)
              ..submit();
          },
        ),
      ],
    );
  }
}
