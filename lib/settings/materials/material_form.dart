import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';
import 'package:threed_print_cost_calculator/settings/providers/materials_notifier.dart';
import 'package:threed_print_cost_calculator/app/components/focus_safe_text_field.dart';
import 'package:threed_print_cost_calculator/shared/theme.dart';

class MaterialForm extends HookConsumerWidget {
  final String? dbRef;

  const MaterialForm({this.dbRef, super.key});

  @override
  Widget build(context, ref) {
    final notifier = ref.read(materialsProvider.notifier);
    final state = ref.watch(materialsProvider);
    final l10n = S.of(context);

    useEffect(() {
      notifier.init(dbRef);
      return null;
    }, [dbRef]);

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
                key: const ValueKey<String>('settings.materials.name.input'),
                controller: nameController,
                externalText: state.name.value,
                focusNode: nameFocus,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(labelText: l10n.materialNameLabel),
                onChanged: notifier.updateName,
              ),

              FocusSafeTextField(
                key: const ValueKey<String>('settings.materials.color.input'),
                controller: colorController,
                externalText: state.color.value,
                focusNode: colorFocus,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(labelText: l10n.colorLabel),
                onChanged: notifier.updateColor,
              ),

              FocusSafeTextField(
                key: const ValueKey<String>('settings.materials.weight.input'),
                controller: weightController,
                externalText: state.weight.value != null
                    ? state.weight.value.toString()
                    : '',
                focusNode: weightFocus,
                keyboardType: TextInputType.number,
                inputNormalizer: normalizeLeadingZeroNumericInput,
                decoration: InputDecoration(
                  labelText: l10n.weightLabel,
                  suffix: Text(l10n.gramsSuffix),
                ),
                onChanged: (v) => notifier.updateWeight(v),
              ),

              FocusSafeTextField(
                key: const ValueKey<String>('settings.materials.cost.input'),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context, rootNavigator: true).pop(null),
                    child: Text(l10n.cancelButton),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    key: const ValueKey<String>(
                      'settings.materials.save.button',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DEEP_BLUE,
                      textStyle: Theme.of(
                        context,
                      ).textTheme.displayMedium?.copyWith(fontSize: 16),
                    ),
                    onPressed: () async {
                      // Submit and get the resulting key (new record id or existing dbRef)
                      final key = await notifier.submit(dbRef);

                      if (key == null) {
                        if (!context.mounted) return;
                        // Submission failed for some reason; close with null
                        Navigator.of(context, rootNavigator: true).pop(null);
                        return;
                      }

                      // Fetch the saved record and return the constructed MaterialModel
                      final material = await ref
                          .read(materialsRepositoryProvider)
                          .getMaterialById(key.toString());

                      if (material == null) {
                        if (!context.mounted) return;
                        Navigator.of(context, rootNavigator: true).pop(null);
                        return;
                      }

                      if (!context.mounted) return;

                      Navigator.of(context, rootNavigator: true).pop(material);
                    },
                    child: Text(l10n.saveButton),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
