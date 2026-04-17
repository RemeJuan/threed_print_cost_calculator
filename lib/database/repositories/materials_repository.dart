import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/database/database_record_mapper.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

final materialsRepositoryProvider = Provider<MaterialsRepository>(
  MaterialsRepository.new,
);

class MaterialsRepository {
  MaterialsRepository(this.ref);

  final Ref ref;

  AppLogger get _logger => ref.read(appLoggerProvider);

  Database get _db => ref.read(databaseProvider);

  StoreRef<Object?, Object?> get _store =>
      StoreRef<Object?, Object?>(DBName.materials.name);

  Future<List<MaterialModel>> getMaterials() async {
    final snapshots = await _store.find(
      _db,
      finder: Finder(sortOrders: [SortOrder('name')]),
    );
    return _mapSnapshots(snapshots);
  }

  Stream<List<MaterialModel>> watchMaterials() async* {
    yield await getMaterials();
    await for (final snapshots
        in _store
            .query(finder: Finder(sortOrders: [SortOrder('name')]))
            .onSnapshots(_db)) {
      yield _mapSnapshots(snapshots);
    }
  }

  Future<MaterialModel?> getMaterialById(String id) async {
    final snapshot = await _store.record(id).getSnapshot(_db);
    return _mapSnapshot(snapshot);
  }

  Future<Object?> saveMaterial(MaterialModel material, {String? id}) async {
    if (id != null) {
      await ref
          .read(dbHelpersProvider(DBName.materials))
          .updateRecord(id, material.toMap());
      return id;
    }

    return ref
        .read(dbHelpersProvider(DBName.materials))
        .insertRecord(material.toMap());
  }

  Future<void> deleteMaterial(String id) {
    return ref.read(dbHelpersProvider(DBName.materials)).deleteRecord(id);
  }

  MaterialModel? _mapSnapshot(RecordSnapshot<Object?, Object?>? snapshot) {
    if (snapshot == null) return null;

    final map = castDatabaseRecord(
      snapshot.value,
      storeName: DBName.materials.name,
      key: snapshot.key,
      logger: _logger,
    );
    if (map == null) return null;

    try {
      return MaterialModel.fromMap(map, snapshot.key.toString());
    } catch (error, stackTrace) {
      _logger.warn(
        AppLogCategory.migration,
        'Skipping malformed material record',
        context: {'store': DBName.materials.name, 'key': snapshot.key},
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  List<MaterialModel> _mapSnapshots(
    List<RecordSnapshot<Object?, Object?>> snapshots,
  ) => snapshots.map(_mapSnapshot).whereType<MaterialModel>().toList();
}

final materialsStreamProvider = StreamProvider<List<MaterialModel>>((ref) {
  ref.watch(appRefreshProvider);
  return ref.read(materialsRepositoryProvider).watchMaterials();
});
