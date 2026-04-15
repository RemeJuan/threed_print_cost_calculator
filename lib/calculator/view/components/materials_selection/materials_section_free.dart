import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/app/components/focus_safe_text_field.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/utils/number_parsing.dart';
import 'package:threed_print_cost_calculator/shared/utils/text_input_normalizers.dart';

class MaterialsSectionFree extends HookConsumerWidget {
  const MaterialsSectionFree({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorProvider);
    final notifier = ref.read(calculatorProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    final spoolWeightController = useTextEditingController(
      text: state.spoolWeight.value?.toString() ?? '',
    );
    final spoolCostController = useTextEditingController(
      text: state.spoolCostText.isNotEmpty
          ? state.spoolCostText
          : (state.spoolCost.value?.toString() ?? ''),
    );
    final spoolWeightFocus = useFocusNode();
    final spoolCostFocus = useFocusNode();
    final printWeightController = useTextEditingController(
      text: state.printWeight.value?.toString() ?? '',
    );
    final printWeightFocus = useFocusNode();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: FocusSafeTextField(
                key: const ValueKey<String>('calculator.spoolWeight.input'),
                controller: spoolWeightController,
                externalText: state.spoolWeight.value?.toString() ?? '',
                focusNode: spoolWeightFocus,
                keyboardType: TextInputType.number,
                inputNormalizer: normalizeLeadingZeroNumericInput,
                decoration: InputDecoration(
                  labelText: l10n.spoolWeightLabel,
                  suffixText: l10n.gramsSuffix,
                ),
                onChanged: (value) {
                  notifier
                    ..updateSpoolWeight(parseLocalizedNum(value))
                    ..submitDebounced();
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FocusSafeTextField(
                key: const ValueKey<String>('calculator.spoolCost.input'),
                controller: spoolCostController,
                externalText: state.spoolCostText.isNotEmpty
                    ? state.spoolCostText
                    : (state.spoolCost.value?.toString() ?? ''),
                focusNode: spoolCostFocus,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputNormalizer: normalizeLeadingZeroNumericInput,
                decoration: InputDecoration(labelText: l10n.spoolCostLabel),
                onChanged: (value) {
                  notifier
                    ..updateSpoolCost(value)
                    ..submitDebounced();
                },
              ),
            ),
          ],
        ),
        FocusSafeTextField(
          key: const ValueKey<String>('calculator.printWeight.input'),
          controller: printWeightController,
          externalText: state.printWeight.value?.toString() ?? '',
          focusNode: printWeightFocus,
          keyboardType: TextInputType.number,
          inputNormalizer: normalizeLeadingZeroNumericInput,
          decoration: InputDecoration(labelText: l10n.printWeightLabel),
          onChanged: (value) {
            notifier
              ..updatePrintWeight(value)
              ..submitDebounced();
          },
        ),
      ],
    );
  }
}
