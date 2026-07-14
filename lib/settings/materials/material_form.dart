import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/app/components/focus_safe_text_field.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
import 'package:threed_print_cost_calculator/settings/materials/material_form_sections.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/providers/materials_notifier.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';
import 'package:threed_print_cost_calculator/shared/utils/form_validation.dart';

class MaterialForm extends HookConsumerWidget {
  final String? dbRef;

  const MaterialForm({this.dbRef, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(materialsProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    final currencyAsync = ref.watch(settingsStreamProvider);
    final currencySettings = currencyAsync is AsyncData<GeneralSettingsModel>
        ? currencyAsync.value
        : GeneralSettingsModel.initial();
    final stockTrackingAccess = ref
        .watch(premiumAccessPolicyProvider)
        .stockTracking();
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final hasSubmitted = useState(false);

    final loadFuture = useMemoized(() => notifier.init(dbRef), [dbRef]);
    final loadSnapshot = useFuture(loadFuture);
    final state = ref.watch(materialsProvider);

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
    final notesController = useTextEditingController(text: state.notes.value);
    final notesFocus = useFocusNode();
    final colorHexController = useTextEditingController(
      text: state.colorHex.value,
    );
    final colorHexFocus = useFocusNode();

    if (loadSnapshot.connectionState != ConnectionState.done) {
      return const Center(child: CircularProgressIndicator());
    }

    String? requiredTextValidator(String? value) =>
        localizedValidationMessage(l10n, notifier.validateName(value));
    String? colorValidator(String? value) =>
        localizedValidationMessage(l10n, notifier.validateColor(value));
    String? positiveNumberValidator(String? value) =>
        localizedValidationMessage(l10n, notifier.validateWeight(value));
    String? costValidator(String? value) =>
        localizedValidationMessage(l10n, notifier.validateCost(value));
    String? optionalNonNegativeValidator(String? value) =>
        localizedValidationMessage(
          l10n,
          notifier.validateRemainingWeight(value),
        );

    final isFormValid = notifier.isValidForSubmit;

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
                MaterialFormIdentitySection(
                  nameController: nameController,
                  nameFocusNode: nameFocus,
                  nameExternalText: state.name.value,
                  nameValidator: requiredTextValidator,
                  nameAutovalidateMode: hasSubmitted.value
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  onNameChanged: notifier.updateName,
                  brandInitialValue: state.brand.value,
                  onBrandChanged: notifier.updateBrand,
                  materialTypeInitialValue: state.materialType.value,
                  onMaterialTypeChanged: notifier.updateMaterialType,
                  colorController: colorController,
                  colorFocusNode: colorFocus,
                  colorExternalText: state.color.value,
                  colorValidator: colorValidator,
                  colorAutovalidateMode: hasSubmitted.value
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  onColorChanged: notifier.updateColor,
                  colorHexController: colorHexController,
                  colorHexFocusNode: colorHexFocus,
                  colorHexExternalText: state.colorHex.value,
                  onColorHexChanged: notifier.updateColorHex,
                  l10n: l10n,
                ),
                MaterialFormPricingSection(
                  weightController: weightController,
                  weightFocusNode: weightFocus,
                  weightExternalText: state.weightText,
                  weightValidator: positiveNumberValidator,
                  weightAutovalidateMode: hasSubmitted.value
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  onWeightChanged: notifier.updateWeight,
                  costController: costController,
                  costFocusNode: costFocus,
                  costExternalText: state.costText,
                  costValidator: costValidator,
                  costAutovalidateMode: hasSubmitted.value
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  onCostChanged: notifier.updateCost,
                  currencySettings: currencySettings,
                  l10n: l10n,
                ),
                MaterialFormStockTrackingSection(
                  allowed: stockTrackingAccess.allowed,
                  autoDeductEnabled: state.autoDeductEnabled,
                  onAutoDeductEnabledChanged: notifier.updateAutoDeductEnabled,
                  remainingWeightController: remainingWeightController,
                  remainingWeightFocusNode: remainingWeightFocus,
                  remainingWeightExternalText: state.remainingWeightText,
                  remainingWeightValidator: optionalNonNegativeValidator,
                  remainingWeightAutovalidateMode: hasSubmitted.value
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  onRemainingWeightChanged: notifier.updateRemainingWeight,
                  l10n: l10n,
                ),
                const SizedBox(height: 8),
                FocusSafeTextField(
                  key: const ValueKey<String>('settings.materials.notes.input'),
                  controller: notesController,
                  externalText: state.notes.value,
                  focusNode: notesFocus,
                  keyboardType: TextInputType.multiline,
                  maxLines: 3,
                  decoration: InputDecoration(labelText: l10n.notesLabel),
                  onChanged: notifier.updateNotes,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppTertiaryButton(
                      onPressed: () =>
                          Navigator.of(context, rootNavigator: true).pop(null),
                      label: l10n.cancelButton,
                    ),
                    const SizedBox(width: 8),
                    AppPrimaryButton(
                      key: const ValueKey<String>(
                        'settings.materials.save.button',
                      ),
                      onPressed: !hasSubmitted.value || isFormValid
                          ? () async {
                              hasSubmitted.value = true;
                              if (!(formKey.currentState?.validate() ??
                                  false)) {
                                return;
                              }
                              final key = await notifier.submit(dbRef);
                              if (key == null) return;
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
                      label: l10n.saveButton,
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
