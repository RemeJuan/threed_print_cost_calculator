import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/app/components/focus_safe_text_field.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/settings/materials/brand_typeahead.dart';
import 'package:threed_print_cost_calculator/settings/materials/material_type_typeahead.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/shared/utils/numeric_input_formatters.dart';
import 'package:threed_print_cost_calculator/shared/utils/text_input_normalizers.dart';

class MaterialFormIdentitySection extends StatelessWidget {
  const MaterialFormIdentitySection({
    super.key,
    required this.nameController,
    required this.nameFocusNode,
    required this.nameExternalText,
    required this.nameValidator,
    required this.nameAutovalidateMode,
    required this.onNameChanged,
    required this.brandInitialValue,
    required this.onBrandChanged,
    required this.materialTypeInitialValue,
    required this.onMaterialTypeChanged,
    required this.colorController,
    required this.colorFocusNode,
    required this.colorExternalText,
    required this.colorValidator,
    required this.colorAutovalidateMode,
    required this.onColorChanged,
    required this.colorHexController,
    required this.colorHexFocusNode,
    required this.colorHexExternalText,
    required this.onColorHexChanged,
    required this.l10n,
  });
  final TextEditingController nameController;
  final FocusNode nameFocusNode;
  final String nameExternalText;
  final String? Function(String?) nameValidator;
  final AutovalidateMode nameAutovalidateMode;
  final ValueChanged<String> onNameChanged;
  final String brandInitialValue;
  final ValueChanged<String> onBrandChanged;
  final String materialTypeInitialValue;
  final ValueChanged<String> onMaterialTypeChanged;
  final TextEditingController colorController;
  final FocusNode colorFocusNode;
  final String colorExternalText;
  final String? Function(String?) colorValidator;
  final AutovalidateMode colorAutovalidateMode;
  final ValueChanged<String> onColorChanged;
  final TextEditingController colorHexController;
  final FocusNode colorHexFocusNode;
  final String colorHexExternalText;
  final ValueChanged<String> onColorHexChanged;
  final AppLocalizations l10n;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      FocusSafeTextField(
        key: const ValueKey('settings.materials.name.input'),
        controller: nameController,
        externalText: nameExternalText,
        focusNode: nameFocusNode,
        keyboardType: TextInputType.text,
        validator: nameValidator,
        autovalidateMode: nameAutovalidateMode,
        decoration: InputDecoration(labelText: l10n.materialNameLabel),
        onChanged: onNameChanged,
      ),
      BrandTypeahead(
        initialValue: brandInitialValue,
        onChanged: onBrandChanged,
      ),
      MaterialTypeTypeahead(
        initialValue: materialTypeInitialValue,
        onChanged: onMaterialTypeChanged,
      ),
      FocusSafeTextField(
        key: const ValueKey('settings.materials.color.input'),
        controller: colorController,
        externalText: colorExternalText,
        focusNode: colorFocusNode,
        keyboardType: TextInputType.text,
        validator: colorValidator,
        autovalidateMode: colorAutovalidateMode,
        decoration: InputDecoration(labelText: l10n.colorLabel),
        onChanged: onColorChanged,
      ),
      FocusSafeTextField(
        key: const ValueKey('settings.materials.color_hex.input'),
        controller: colorHexController,
        externalText: colorHexExternalText,
        focusNode: colorHexFocusNode,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(labelText: l10n.colorHexLabel),
        onChanged: onColorHexChanged,
      ),
    ],
  );
}

class MaterialFormPricingSection extends StatelessWidget {
  const MaterialFormPricingSection({
    super.key,
    required this.weightController,
    required this.weightFocusNode,
    required this.weightExternalText,
    required this.weightValidator,
    required this.weightAutovalidateMode,
    required this.onWeightChanged,
    required this.costController,
    required this.costFocusNode,
    required this.costExternalText,
    required this.costValidator,
    required this.costAutovalidateMode,
    required this.onCostChanged,
    required this.currencySettings,
    required this.l10n,
  });
  final TextEditingController weightController;
  final FocusNode weightFocusNode;
  final String weightExternalText;
  final String? Function(String?) weightValidator;
  final AutovalidateMode weightAutovalidateMode;
  final ValueChanged<String> onWeightChanged;
  final TextEditingController costController;
  final FocusNode costFocusNode;
  final String costExternalText;
  final String? Function(String?) costValidator;
  final AutovalidateMode costAutovalidateMode;
  final ValueChanged<String> onCostChanged;
  final GeneralSettingsModel currencySettings;
  final AppLocalizations l10n;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      FocusSafeTextField(
        key: const ValueKey('settings.materials.weight.input'),
        controller: weightController,
        externalText: weightExternalText,
        focusNode: weightFocusNode,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: localizedDecimalInputFormatters,
        inputNormalizer: normalizeLeadingZeroNumericInput,
        validator: weightValidator,
        autovalidateMode: weightAutovalidateMode,
        decoration: InputDecoration(
          labelText: l10n.weightLabel,
          suffix: Text(l10n.gramsSuffix),
        ),
        onChanged: onWeightChanged,
      ),
      FocusSafeTextField(
        key: const ValueKey('settings.materials.cost.input'),
        controller: costController,
        externalText: costExternalText,
        focusNode: costFocusNode,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: localizedDecimalInputFormatters,
        inputNormalizer: normalizeLeadingZeroNumericInput,
        validator: costValidator,
        autovalidateMode: costAutovalidateMode,
        decoration: InputDecoration(
          labelText: l10n.costLabel,
          prefixText:
              currencySettings.currencySymbol.isNotEmpty &&
                  currencySettings.currencyPosition == 'before'
              ? currencySettings.currencySymbol +
                    (currencySettings.currencySpacing ? ' ' : '')
              : null,
          suffixText:
              currencySettings.currencyPosition == 'after' &&
                  currencySettings.currencySymbol.isNotEmpty
              ? (currencySettings.currencySpacing
                    ? ' ${currencySettings.currencySymbol}'
                    : currencySettings.currencySymbol)
              : null,
        ),
        onChanged: onCostChanged,
      ),
    ],
  );
}

class MaterialFormStockTrackingSection extends StatelessWidget {
  const MaterialFormStockTrackingSection({
    super.key,
    required this.allowed,
    required this.autoDeductEnabled,
    required this.onAutoDeductEnabledChanged,
    required this.remainingWeightController,
    required this.remainingWeightFocusNode,
    required this.remainingWeightExternalText,
    required this.remainingWeightValidator,
    required this.remainingWeightAutovalidateMode,
    required this.onRemainingWeightChanged,
    required this.l10n,
  });
  final bool allowed;
  final bool autoDeductEnabled;
  final ValueChanged<bool> onAutoDeductEnabledChanged;
  final TextEditingController remainingWeightController;
  final FocusNode remainingWeightFocusNode;
  final String remainingWeightExternalText;
  final String? Function(String?) remainingWeightValidator;
  final AutovalidateMode remainingWeightAutovalidateMode;
  final ValueChanged<String> onRemainingWeightChanged;
  final AppLocalizations l10n;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (allowed)
        SwitchListTile.adaptive(
          key: const ValueKey('settings.materials.track_remaining.toggle'),
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.trackRemainingFilamentLabel),
          value: autoDeductEnabled,
          onChanged: onAutoDeductEnabledChanged,
        ),
      if (autoDeductEnabled)
        FocusSafeTextField(
          key: const ValueKey('settings.materials.remaining_weight.input'),
          controller: remainingWeightController,
          externalText: remainingWeightExternalText,
          focusNode: remainingWeightFocusNode,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: localizedDecimalInputFormatters,
          inputNormalizer: normalizeLeadingZeroNumericInput,
          validator: remainingWeightValidator,
          autovalidateMode: remainingWeightAutovalidateMode,
          decoration: InputDecoration(
            labelText: l10n.remainingFilamentLabel,
            suffix: Text(l10n.gramsSuffix),
          ),
          onChanged: onRemainingWeightChanged,
        ),
    ],
  );
}
