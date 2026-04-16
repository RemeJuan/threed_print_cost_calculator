import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/settings/providers/materials_notifier.dart';
import 'package:threed_print_cost_calculator/app/components/focus_safe_text_field.dart';
import 'package:threed_print_cost_calculator/shared/utils/form_validation.dart';
import 'package:threed_print_cost_calculator/shared/utils/text_input_normalizers.dart';
import 'package:threed_print_cost_calculator/shared/theme.dart';

class MaterialForm extends HookConsumerWidget {
  final String? dbRef;

  const MaterialForm({this.dbRef, super.key});

  @override
  Widget build(context, ref) {
    final notifier = ref.read(materialsProvider.notifier);
    final state = ref.watch(materialsProvider);
    final l10n = AppLocalizations.of(context)!;
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final hasSubmitted = useState(false);

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

    final weightController = useTextEditingController(text: state.weightText);
    final weightFocus = useFocusNode();

    final remainingWeightController = useTextEditingController(
      text: state.remainingWeightText,
    );
    final remainingWeightFocus = useFocusNode();

    final costController = useTextEditingController(text: state.costText);
    final costFocus = useFocusNode();

    String? requiredTextValidator(String? value) {
      return localizedValidationMessage(l10n, validateRequiredText(value));
    }

    String? positiveNumberValidator(String? value) {
      return localizedValidationMessage(l10n, validatePositiveNumber(value));
    }

    String? optionalNonNegativeValidator(String? value) {
      return localizedValidationMessage(
        l10n,
        validateOptionalNonNegativeNumber(value),
      );
    }

    final isFormValid =
        validateRequiredText(state.name.value) == null &&
        validateRequiredText(state.color.value) == null &&
        validatePositiveNumber(state.weightText) == null &&
        validatePositiveNumber(state.costText) == null &&
        (!state.autoDeductEnabled ||
            validateOptionalNonNegativeNumber(state.remainingWeightText) ==
                null);

    return Dialog(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        physics: const ClampingScrollPhysics(),
        child: Form(
          key: formKey,
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
                  validator: requiredTextValidator,
                  autovalidateMode: hasSubmitted.value
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  decoration: InputDecoration(
                    labelText: l10n.materialNameLabel,
                  ),
                  onChanged: notifier.updateName,
                ),

                FocusSafeTextField(
                  key: const ValueKey<String>('settings.materials.color.input'),
                  controller: colorController,
                  externalText: state.color.value,
                  focusNode: colorFocus,
                  keyboardType: TextInputType.text,
                  validator: requiredTextValidator,
                  autovalidateMode: hasSubmitted.value
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  decoration: InputDecoration(labelText: l10n.colorLabel),
                  onChanged: notifier.updateColor,
                ),

                FocusSafeTextField(
                  key: const ValueKey<String>(
                    'settings.materials.weight.input',
                  ),
                  controller: weightController,
                  externalText: state.weightText,
                  focusNode: weightFocus,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  inputNormalizer: normalizeLeadingZeroNumericInput,
                  validator: positiveNumberValidator,
                  autovalidateMode: hasSubmitted.value
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  decoration: InputDecoration(
                    labelText: l10n.weightLabel,
                    suffix: Text(l10n.gramsSuffix),
                  ),
                  onChanged: (v) => notifier.updateWeight(v),
                ),

                FocusSafeTextField(
                  key: const ValueKey<String>('settings.materials.cost.input'),
                  controller: costController,
                  externalText: state.costText,
                  focusNode: costFocus,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  inputNormalizer: normalizeLeadingZeroNumericInput,
                  validator: positiveNumberValidator,
                  autovalidateMode: hasSubmitted.value
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  decoration: InputDecoration(labelText: l10n.costLabel),
                  onChanged: (v) => notifier.updateCost(v),
                ),

                SwitchListTile.adaptive(
                  key: const ValueKey<String>(
                    'settings.materials.track_remaining.toggle',
                  ),
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.trackRemainingFilamentLabel),
                  value: state.autoDeductEnabled,
                  onChanged: notifier.updateAutoDeductEnabled,
                ),

                if (state.autoDeductEnabled)
                  FocusSafeTextField(
                    key: const ValueKey<String>(
                      'settings.materials.remaining_weight.input',
                    ),
                    controller: remainingWeightController,
                    externalText: state.remainingWeightText,
                    focusNode: remainingWeightFocus,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    inputNormalizer: normalizeLeadingZeroNumericInput,
                    validator: optionalNonNegativeValidator,
                    autovalidateMode: hasSubmitted.value
                        ? AutovalidateMode.onUserInteraction
                        : AutovalidateMode.disabled,
                    decoration: InputDecoration(
                      labelText: l10n.remainingFilamentLabel,
                      suffix: Text(l10n.gramsSuffix),
                    ),
                    onChanged: notifier.updateRemainingWeight,
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
                      onPressed: !hasSubmitted.value || isFormValid
                          ? () async {
                              hasSubmitted.value = true;
                              if (!(formKey.currentState?.validate() ??
                                  false)) {
                                return;
                              }

                              // Submit and get the resulting key (new record id or existing dbRef)
                              final key = await notifier.submit(dbRef);

                              if (key == null) {
                                return;
                              }

                              // Fetch the saved record and return the constructed MaterialModel
                              final material = await ref
                                  .read(materialsRepositoryProvider)
                                  .getMaterialById(key.toString());

                              if (material == null) {
                                if (!context.mounted) return;
                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pop(null);
                                return;
                              }

                              if (!context.mounted) return;

                              Navigator.of(
                                context,
                                rootNavigator: true,
                              ).pop(material);
                            }
                          : null,
                      child: Text(l10n.saveButton),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
