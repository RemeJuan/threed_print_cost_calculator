import 'package:riverpod/riverpod.dart';
import 'package:threed_print_cost_calculator/app/components/num_input.dart';
import 'package:threed_print_cost_calculator/app/components/string_input.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/settings/state/material_state.dart';

final materialsProvider =
    NotifierProvider<MaterialsProvider, MaterialState>(MaterialsProvider.new);

class MaterialsProvider extends Notifier<MaterialState> {
  @override
  MaterialState build() {
    return MaterialState();
  }

  DataBaseHelpers get dbHelpers =>
      ref.read(dbHelpersProvider(DBName.materials));

  void init(final String? key) async {
    if (key != null) {
      final record = await dbHelpers.getRecord(key);

      final material = MaterialModel.fromMap(
        // ignore: cast_nullable_to_non_nullable
        record!.value as Map<String, dynamic>,
        key,
      );

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
        cost: NumberInput.dirty(value: num.tryParse(value) ?? 0));
  }

  void updateColor(String value) {
    state = state.copyWith(color: StringInput.dirty(value: value));
  }

  void updateWeight(String value) {
    state = state.copyWith(
        weight: NumberInput.dirty(value: num.tryParse(value) ?? 0));
  }

  void submit(String? dbRef) {
    final data = {
      'name': state.name.value,
      'cost': state.cost.value,
      'color': state.color.value,
      'weight': state.weight.value,
    };

    if (dbRef != null) {
      dbHelpers.updateRecord(dbRef, data);
    } else {
      dbHelpers.insertRecord(data);
    }
  }
}
