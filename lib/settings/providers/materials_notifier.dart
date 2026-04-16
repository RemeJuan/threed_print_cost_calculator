import 'dart:math' as math;

import 'package:riverpod/riverpod.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/shared/components/num_input.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/shared/components/string_input.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/settings/state/material_state.dart';
import 'package:threed_print_cost_calculator/shared/utils/form_validation.dart';
import 'package:threed_print_cost_calculator/shared/utils/number_parsing.dart';

final materialsProvider = NotifierProvider<MaterialsProvider, MaterialState>(
  MaterialsProvider.new,
);

class MaterialsProvider extends Notifier<MaterialState> {
  @override
  MaterialState build() {
    return MaterialState();
  }

  MaterialsRepository get _materialsRepository =>
      ref.read(materialsRepositoryProvider);

  void init(final String? key) async {
    if (key != null) {
      final material = await _materialsRepository.getMaterialById(key);
      if (material == null) return;

      state = state.copyWith(
        name: StringInput.dirty(value: material.name),
        color: StringInput.dirty(value: material.color),
        cost: NumberInput.dirty(value: parseLocalizedNum(material.cost)),
        costText: material.cost,
        weight: NumberInput.dirty(value: parseLocalizedNum(material.weight)),
        weightText: material.weight,
        autoDeductEnabled: material.autoDeductEnabled,
        remainingWeight: material.autoDeductEnabled
            ? NumberInput.dirty(value: material.remainingWeight)
            : const NumberInput.pure(),
        remainingWeightText: material.autoDeductEnabled
            ? material.remainingWeight.toString()
            : '',
      );
    }
  }

  void updateName(String value) {
    state = state.copyWith(name: StringInput.dirty(value: value));
  }

  void updateCost(String value) {
    state = state.copyWith(
      cost: NumberInput.dirty(value: parseLocalizedNum(value)),
      costText: value,
    );
  }

  void updateColor(String value) {
    state = state.copyWith(color: StringInput.dirty(value: value));
  }

  void updateWeight(String value) {
    final parsedValue = parseLocalizedNum(value);
    state = state.copyWith(
      weight: NumberInput.dirty(value: parsedValue),
      weightText: value,
      remainingWeight: state.autoDeductEnabled
          ? state.remainingWeight
          : NumberInput.dirty(
              value: parsedValue == null ? null : math.max(0, parsedValue),
            ),
      remainingWeightText: state.autoDeductEnabled
          ? state.remainingWeightText
          : value,
    );
  }

  void updateAutoDeductEnabled(bool value) {
    final parsedWeight = parseLocalizedNum(state.weightText);
    state = state.copyWith(
      autoDeductEnabled: value,
      remainingWeight: value
          ? NumberInput.dirty(
              value: parsedWeight == null ? null : math.max(0, parsedWeight),
            )
          : const NumberInput.pure(),
      remainingWeightText: value ? state.weightText : '',
    );
  }

  void updateRemainingWeight(String value) {
    state = state.copyWith(
      remainingWeight: NumberInput.dirty(value: parseLocalizedNum(value)),
      remainingWeightText: value,
    );
  }

  Future<Object?> submit(String? dbRef) async {
    if (!_isValidForSubmit) {
      return null;
    }

    final existing = dbRef == null
        ? null
        : await _materialsRepository.getMaterialById(dbRef);
    final parsedCost = parseLocalizedNum(state.costText)!;
    final parsedWeight = parseLocalizedNum(state.weightText)!;
    final wasTrackingEnabled = existing?.autoDeductEnabled ?? false;
    final isTrackingEnabled = state.autoDeductEnabled;
    final parsedRemainingWeight = state.autoDeductEnabled
        ? (state.remainingWeightText.trim().isEmpty
              ? parsedWeight
              : parseLocalizedNum(state.remainingWeightText)!)
        : parsedWeight;

    final material = MaterialModel(
      id: dbRef ?? '',
      name: state.name.value.trim(),
      cost: parsedCost.toString(),
      color: state.color.value.trim(),
      weight: parsedWeight.toString(),
      archived: false,
      autoDeductEnabled: isTrackingEnabled,
      originalWeight: isTrackingEnabled && wasTrackingEnabled
          ? existing!.originalWeight
          : parsedWeight,
      remainingWeight: isTrackingEnabled
          ? math.max(0, parsedRemainingWeight)
          : parsedWeight,
    );

    final key = await _materialsRepository.saveMaterial(material, id: dbRef);
    AppAnalytics.safeLog(AppAnalytics.materialCreated);
    return key;
  }

  bool get _isValidForSubmit {
    return validateRequiredText(state.name.value) == null &&
        validateRequiredText(state.color.value) == null &&
        validatePositiveNumber(state.weightText) == null &&
        validatePositiveNumber(state.costText) == null &&
        (!state.autoDeductEnabled ||
            validateOptionalNonNegativeNumber(state.remainingWeightText) ==
                null);
  }
}
