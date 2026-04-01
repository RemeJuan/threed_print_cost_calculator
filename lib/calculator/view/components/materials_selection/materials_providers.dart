import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';

/// Loads materials from the local Sembast database as a stream so UI updates
/// automatically when materials are added/updated/removed.
final materialsListProvider = materialsStreamProvider;

/// Computed lookup map (id -> MaterialModel) from the materials list.
final materialsByIdProvider = Provider.autoDispose<Map<String, MaterialModel>>((
  ref,
) {
  final list = ref
      .watch(materialsListProvider)
      .maybeWhen(data: (v) => v, orElse: () => <MaterialModel>[]);

  final map = <String, MaterialModel>{};
  for (final m in list) {
    map[m.id] = m;
  }
  return map;
});
