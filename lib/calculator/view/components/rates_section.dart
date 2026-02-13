import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';

class RatesSection extends HookConsumerWidget {
  final bool premium;

  const RatesSection({required this.premium, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorProvider);
    final notifier = ref.watch(calculatorProvider.notifier);
    final l10n = S.of(context);

    if (!premium) {
      return SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: TextFormField(
            initialValue: state.wearAndTear.value != null
                ? state.wearAndTear.value.toString()
                : '',
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l10n.wearAndTearLabel),
            onChanged: (value) async {
              notifier
                ..updateWearAndTear(num.tryParse(value) ?? 0)
                ..submit();
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            initialValue: state.failureRisk.value != null
                ? state.failureRisk.value.toString()
                : '',
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l10n.failureRiskLabel),
            onChanged: (value) async {
              notifier
                ..updateFailureRisk(num.tryParse(value) ?? 0)
                ..submit();
            },
          ),
        ),
      ],
    );
  }
}
