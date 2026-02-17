import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';
import 'package:threed_print_cost_calculator/app/components/focus_safe_text_field.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

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

    // Local controllers and focus nodes
    final labourRateController = useTextEditingController(
      text: state.labourRate.value?.toString() ?? '',
    );
    final labourRateFocus = useFocusNode();
    final labourTimeController = useTextEditingController(
      text: state.labourTime.value?.toString() ?? '',
    );
    final labourTimeFocus = useFocusNode();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: FocusSafeTextField(
            controller: labourRateController,
            externalText: state.labourRate.value?.toString() ?? '',
            focusNode: labourRateFocus,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l10n.labourRateLabel),
            onChanged: (value) async {
              notifier.setLabourRate(num.tryParse(value) ?? 0);
              notifier.submitDebounced();
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FocusSafeTextField(
            controller: labourTimeController,
            externalText: state.labourTime.value?.toString() ?? '',
            focusNode: labourTimeFocus,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l10n.labourTimeLabel),
            onChanged: (value) async {
              notifier
                ..updateLabourTime(num.tryParse(value) ?? 0)
                ..submitDebounced();
            },
          ),
        ),
      ],
    );
  }
}
