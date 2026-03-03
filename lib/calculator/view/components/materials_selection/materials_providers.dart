import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:sembast/sembast.dart';

/// Loads materials from the local Sembast database as a stream so UI updates
/// automatically when materials are added/updated/removed.
final materialsListProvider = StreamProvider<List<MaterialModel>>((ref) {
  final db = ref.read(databaseProvider);
  final store = stringMapStoreFactory.store(DBName.materials.name);
  final query = store.query();

  return (() async* {
    // Emit initial snapshot immediately using store.find (QueryRef doesn't
    // expose a public `find` method).
    try {
      final initial = await store.find(db);
      yield _mapSnapshotsToModels(initial);
    } catch (_) {
      // swallow initial load errors; we'll still listen to updates
    }

    // Then forward live updates`
    await for (final snapshots in query.onSnapshots(db)) {
      yield _mapSnapshotsToModels(snapshots);
    }
  })();
});

List<MaterialModel> _mapSnapshotsToModels(
  List<RecordSnapshot<dynamic, dynamic>> snapshots,
) => snapshots
    .map(
      (e) => MaterialModel.fromMap(
        e.value as Map<String, dynamic>,
        e.key.toString(),
      ),
    )
    .toList();

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
