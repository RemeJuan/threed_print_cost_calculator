import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';

class PremiumWidgets extends HookConsumerWidget {
  const PremiumWidgets({required this.premium, super.key});

  final bool premium;

  @override
  Widget build(context, ref) {
    final state = ref.watch(calculatorProvider);
    final notifier = ref.watch(calculatorProvider.notifier);
    final l10n = S.of(context);

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: TextFormField(
                initialValue: state.watt.value.toString(),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.labourRateLabel,
                ),
                onChanged: (value) async {
                  notifier
                    ..updateLabourRate(double.parse(value))
                    ..submit();
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                initialValue: state.labourTime.value.toString(),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.labourTimeLabel,
                ),
                onChanged: (value) async {
                  notifier
                    ..updateLabourTime(double.parse(value))
                    ..submit();
                },
              ),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: TextFormField(
                initialValue: state.spoolCost.value.toString(),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.wearAndTearLabel,
                ),
                onChanged: (value) async {
                  notifier
                    ..updateWearAndTear(double.parse(value))
                    ..submit();
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                initialValue: state.failureRisk.value.toString(),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.failureRiskLabel,
                ),
                onChanged: (value) async {
                  notifier
                    ..updateFailureRisk(double.parse(value))
                    ..submit;
                },
              ),
            ),
          ],
        ),
        if (!premium)
          const MaterialButton(
            onPressed: null,
            child: Text('Save Print'),
          ),
      ],
    );
  }
}
