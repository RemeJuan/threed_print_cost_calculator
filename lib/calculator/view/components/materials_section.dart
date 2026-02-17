import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/app/components/focus_safe_text_field.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';

class MaterialsSection extends HookConsumerWidget {
  const MaterialsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorProvider);
    final notifier = ref.read(calculatorProvider.notifier);
    final l10n = S.of(context);

    // Section-local controllers and focus nodes
    final spoolWeightController = useTextEditingController(
      text: state.spoolWeight.value?.toString() ?? '',
    );
    final spoolCostController = useTextEditingController(
      text: state.spoolCostText.isNotEmpty
          ? state.spoolCostText
          : (state.spoolCost.value?.toString() ?? ''),
    );
    final printWeightController = useTextEditingController(
      text: state.printWeight.value?.toString() ?? '',
    );

    final spoolWeightFocus = useFocusNode();
    final spoolCostFocus = useFocusNode();
    final printWeightFocus = useFocusNode();

    // Keep controllers in sync with external state only when not focused
    useEffect(() {
      if (!spoolWeightFocus.hasFocus) {
        spoolWeightController.text = state.spoolWeight.value?.toString() ?? '';
      }
      if (!spoolCostFocus.hasFocus) {
        spoolCostController.text = state.spoolCostText.isNotEmpty
            ? state.spoolCostText
            : (state.spoolCost.value?.toString() ?? '');
      }
      if (!printWeightFocus.hasFocus) {
        printWeightController.text = state.printWeight.value?.toString() ?? '';
      }
      return null;
    }, [state]);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            // Spool Weight
            Expanded(
              child: FocusSafeTextField(
                controller: spoolWeightController,
                externalText: state.spoolWeight.value?.toString() ?? '',
                focusNode: spoolWeightFocus,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.spoolWeightLabel,
                  suffixText: l10n.gramsSuffix,
                ),
                onChanged: (value) async {
                  notifier
                    ..updateSpoolWeight(num.tryParse(value) ?? 0)
                    ..submitDebounced();
                },
              ),
            ),
            const SizedBox(width: 16),
            // Spool cost
            Expanded(
              child: FocusSafeTextField(
                controller: spoolCostController,
                externalText: state.spoolCostText.isNotEmpty
                    ? state.spoolCostText
                    : (state.spoolCost.value?.toString() ?? ''),
                focusNode: spoolCostFocus,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(labelText: l10n.spoolCostLabel),
                onChanged: (value) async {
                  notifier
                    ..updateSpoolCost(value)
                    ..submitDebounced();
                },
              ),
            ),
          ],
        ),
        FocusSafeTextField(
          controller: printWeightController,
          externalText: state.printWeight.value?.toString() ?? '',
          focusNode: printWeightFocus,
          keyboardType: TextInputType.number,
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
