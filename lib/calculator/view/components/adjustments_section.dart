import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/app/components/focus_safe_text_field.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/shared/utils/number_parsing.dart';
import 'package:threed_print_cost_calculator/shared/utils/text_input_normalizers.dart';

class AdjustmentsSection extends HookConsumerWidget {
  const AdjustmentsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorProvider);
    final notifier = ref.watch(calculatorProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    final isPremium = ref.watch(isPremiumProvider);

    if (!isPremium) {
      return const SizedBox.shrink();
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
            key: const ValueKey<String>(
              'calculator.adjustments.labourRate.input',
            ),
            controller: labourRateController,
            externalText: state.labourRate.value?.toString() ?? '',
            focusNode: labourRateFocus,
            keyboardType: TextInputType.number,
            inputNormalizer: normalizeLeadingZeroNumericInput,
            decoration: InputDecoration(labelText: l10n.labourRateLabel),
            onChanged: (value) async {
              notifier.setLabourRate(parseLocalizedNumOrFallback(value));
              notifier.submitDebounced();
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FocusSafeTextField(
            key: const ValueKey<String>(
              'calculator.adjustments.labourTime.input',
            ),
            controller: labourTimeController,
            externalText: state.labourTime.value?.toString() ?? '',
            focusNode: labourTimeFocus,
            keyboardType: TextInputType.number,
            inputNormalizer: normalizeLeadingZeroNumericInput,
            decoration: InputDecoration(labelText: l10n.labourTimeLabel),
            onChanged: (value) async {
              notifier
                ..updateLabourTime(parseLocalizedNumOrFallback(value))
                ..submitDebounced();
            },
          ),
        ),
      ],
    );
  }
}
