import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';
import 'package:threed_print_cost_calculator/settings/providers/materials_notifier.dart';
import 'package:threed_print_cost_calculator/shared/theme.dart';
import 'package:threed_print_cost_calculator/app/components/focus_safe_text_field.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class MaterialForm extends HookConsumerWidget {
  final String? dbRef;

  const MaterialForm({this.dbRef, super.key});

  @override
  Widget build(context, ref) {
    final notifier = ref.read(materialsProvider.notifier)..init(dbRef);
    final state = ref.watch(materialsProvider);
    final l10n = S.of(context);

    // Create controllers and focus nodes at the top-level of the build to keep
    // hook calls linear and avoid wrapping fields in Builders.
    final nameController = useTextEditingController(text: state.name.value);
    final nameFocus = useFocusNode();

    final colorController = useTextEditingController(text: state.color.value);
    final colorFocus = useFocusNode();

    final weightController = useTextEditingController(
      text: state.weight.value != null ? state.weight.value.toString() : '',
    );
    final weightFocus = useFocusNode();

    final costController = useTextEditingController(
      text: state.cost.value != null ? state.cost.value.toString() : '',
    );
    final costFocus = useFocusNode();

    return Dialog(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        physics: const ClampingScrollPhysics(),
        child: AutofillGroup(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FocusSafeTextField(
                controller: nameController,
                externalText: state.name.value,
                focusNode: nameFocus,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(labelText: l10n.materialNameLabel),
                onChanged: notifier.updateName,
              ),

              FocusSafeTextField(
                controller: colorController,
                externalText: state.color.value,
                focusNode: colorFocus,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(labelText: l10n.colorLabel),
                onChanged: notifier.updateColor,
              ),

              FocusSafeTextField(
                controller: weightController,
                externalText: state.weight.value != null
                    ? state.weight.value.toString()
                    : '',
                focusNode: weightFocus,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.weightLabel,
                  suffix: Text(l10n.gramsSuffix),
                ),
                onChanged: (v) => notifier.updateWeight(v),
              ),

              FocusSafeTextField(
                controller: costController,
                externalText: state.cost.value != null
                    ? state.cost.value.toString()
                    : '',
                focusNode: costFocus,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.costLabel),
                onChanged: (v) => notifier.updateCost(v),
              ),

              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: DEEP_BLUE,
                  textStyle: Theme.of(
                    context,
                  ).textTheme.displayMedium?.copyWith(fontSize: 16),
                ),
                onPressed: () => notifier.submit(dbRef),
                child: Text(l10n.saveButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
