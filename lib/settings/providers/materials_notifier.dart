import 'dart:math' as math;

import 'package:riverpod/riverpod.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/shared/components/num_input.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/shared/components/string_input.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/settings/state/material_state.dart';
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
        weight: NumberInput.dirty(value: parseLocalizedNum(material.weight)),
        autoDeductEnabled: material.autoDeductEnabled,
        remainingWeight: material.autoDeductEnabled
            ? NumberInput.dirty(value: material.remainingWeight)
            : const NumberInput.pure(),
      );
    }
  }

  void updateName(String value) {
    state = state.copyWith(name: StringInput.dirty(value: value));
  }

  void updateCost(String value) {
    state = state.copyWith(
      cost: NumberInput.dirty(value: parseLocalizedNum(value)),
    );
  }

  void updateColor(String value) {
    state = state.copyWith(color: StringInput.dirty(value: value));
  }

  void updateWeight(String value) {
    final parsedValue = parseLocalizedNum(value);
    state = state.copyWith(
      weight: NumberInput.dirty(value: parsedValue),
      remainingWeight: state.autoDeductEnabled
          ? state.remainingWeight
          : NumberInput.dirty(value: math.max(0, parsedValue)),
    );
  }

  void updateAutoDeductEnabled(bool value) {
    state = state.copyWith(
      autoDeductEnabled: value,
      remainingWeight: value
          ? NumberInput.dirty(value: math.max(0, state.weight.value ?? 0))
          : const NumberInput.pure(),
    );
  }

  void updateRemainingWeight(String value) {
    state = state.copyWith(
      remainingWeight: NumberInput.dirty(
        value: math.max(0, parseLocalizedNum(value)),
      ),
    );
  }

  Future<Object?> submit(String? dbRef) async {
    final existing = dbRef == null
        ? null
        : await _materialsRepository.getMaterialById(dbRef);
    final parsedWeight = (state.weight.value ?? 0).toDouble();
    final wasTrackingEnabled = existing?.autoDeductEnabled ?? false;
    final isTrackingEnabled = state.autoDeductEnabled;

    final material = MaterialModel(
      id: dbRef ?? '',
      name: state.name.value,
      cost: state.cost.value.toString(),
      color: state.color.value,
      weight: state.weight.value.toString(),
      archived: false,
      autoDeductEnabled: isTrackingEnabled,
      originalWeight: isTrackingEnabled && wasTrackingEnabled
          ? existing!.originalWeight
          : parsedWeight,
      remainingWeight: isTrackingEnabled
          ? math.max(
              0,
              (state.remainingWeight.value ?? parsedWeight).toDouble(),
            )
          : parsedWeight,
    );

    final key = await _materialsRepository.saveMaterial(material, id: dbRef);
    AppAnalytics.safeLog(AppAnalytics.materialCreated);
    return key;
  }
}
