import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';

/// Loads materials from the local Sembast database.
final materialsListProvider = FutureProvider.autoDispose<List<MaterialModel>>((
  ref,
) async {
  final db = ref.read(databaseProvider);
  final store = stringMapStoreFactory.store(DBName.materials.name);
  final snapshots = await store.find(db);
  return snapshots
      .map(
        (e) => MaterialModel.fromMap(
          e.value as Map<String, dynamic>,
          e.key.toString(),
        ),
      )
      .toList();
});

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
