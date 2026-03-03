import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';

/// Loads materials from the local Sembast database.
final materialsListProvider = FutureProvider.autoDispose<List<MaterialModel>>((
  ref,
) async {
  final dbHelpers = ref.read(dbHelpersProvider(DBName.materials));
  final snapshots = await dbHelpers.getAllRecords();
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
