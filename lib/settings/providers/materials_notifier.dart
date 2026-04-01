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

      updateName(material.name);
      updateColor(material.color);
      updateCost(material.cost.toString());
      updateWeight(material.weight.toString());
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
    state = state.copyWith(
      weight: NumberInput.dirty(value: parseLocalizedNum(value)),
    );
  }

  Future<Object?> submit(String? dbRef) async {
    final material = MaterialModel(
      id: dbRef ?? '',
      name: state.name.value,
      cost: state.cost.value.toString(),
      color: state.color.value,
      weight: state.weight.value.toString(),
      archived: false,
    );

    final key = await _materialsRepository.saveMaterial(material, id: dbRef);
    AppAnalytics.safeLog(AppAnalytics.materialCreated);
    return key;
  }
}
