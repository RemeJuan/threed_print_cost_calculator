import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';
import 'package:threed_print_cost_calculator/app/components/focus_safe_text_field.dart';

class RatesSection extends HookConsumerWidget {
  final bool premium;

  const RatesSection({required this.premium, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorProvider);
    final notifier = ref.read(calculatorProvider.notifier);
    final l10n = S.of(context);

    if (!premium) {
      return const SizedBox.shrink();
    }

    // Local controllers and focus nodes for these fields
    final wearController = useTextEditingController(
      text: state.wearAndTear.value?.toString() ?? '',
    );
    final wearFocus = useFocusNode();
    final failureController = useTextEditingController(
      text: state.failureRisk.value?.toString() ?? '',
    );
    final failureFocus = useFocusNode();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: FocusSafeTextField(
            controller: wearController,
            externalText: state.wearAndTear.value?.toString() ?? '',
            focusNode: wearFocus,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l10n.wearAndTearLabel),
            onChanged: (value) async {
              notifier.setWearAndTear(num.tryParse(value) ?? 0);
              notifier.submitDebounced();
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FocusSafeTextField(
            controller: failureController,
            externalText: state.failureRisk.value?.toString() ?? '',
            focusNode: failureFocus,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l10n.failureRiskLabel),
            onChanged: (value) async {
              notifier.setFailureRisk(num.tryParse(value) ?? 0);
              notifier.submitDebounced();
            },
          ),
        ),
      ],
    );
  }
}
