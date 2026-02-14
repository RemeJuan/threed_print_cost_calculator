import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';

class AdjustmentsSection extends HookConsumerWidget {
  final bool premium;

  const AdjustmentsSection({required this.premium, super.key});

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
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l10n.labourRateLabel),
            initialValue: state.labourRate.value != null
                ? state.labourRate.value.toString()
                : '',
            onChanged: (value) async {
              await notifier.updateLabourRate(num.tryParse(value) ?? 0);
              notifier.submit();
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            initialValue: state.labourTime.value != null
                ? state.labourTime.value.toString()
                : '',
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l10n.labourTimeLabel),
            onChanged: (value) async {
              notifier
                ..updateLabourTime(num.tryParse(value) ?? 0)
                ..submit();
            },
          ),
        ),
      ],
    );
  }
}
