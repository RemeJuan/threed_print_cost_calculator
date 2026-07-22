import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/database/database_record_mapper.dart';
import 'package:threed_print_cost_calculator/materials/csv_import/csv_import_parser.dart';
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

  Future<int> count() async {
    final snapshots = await _store.find(_db);
    return _mapSnapshots(snapshots).length;
  }

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

  Future<Map<String, bool>> existingIds(Set<String> ids) async {
    if (ids.isEmpty) return const {};
    final found = <String, bool>{};
    for (final id in ids) {
      found[id] = await _store.record(id).exists(_db);
    }
    return found;
  }

  Future<MaterialsUpsertResult> upsertMaterials({
    required List<CsvImportRow> creates,
    required List<CsvImportRow> updates,
    Future<void> Function(CsvImportRow row)? onBeforeWrite,
  }) async {
    final saveFailures = <CsvImportRow>[];
    var created = 0;
    var updated = 0;
    final skippedRows = <CsvImportRow>[];

    final store =
        stringMapStoreFactory.store(DBName.materials.name)
            as StoreRef<Object?, Map<String, Object?>>;

    await _db.transaction((txn) async {
      for (final row in updates) {
        if (onBeforeWrite != null) {
          await onBeforeWrite(row);
        }
        if (!await store.record(row.sourceId).exists(txn)) {
          skippedRows.add(row);
          continue;
        }
        await store.record(row.sourceId).update(txn, _toMaterialMap(row));
        updated++;
      }
      for (final row in creates) {
        if (onBeforeWrite != null) {
          await onBeforeWrite(row);
        }
        final key = await store.add(txn, _toMaterialMap(row));
        if (key != null) created++;
      }
    });

    return MaterialsUpsertResult(
      created: created,
      updated: updated,
      skippedRows: skippedRows,
      saveFailures: saveFailures,
    );
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

  Map<String, dynamic> _toMaterialMap(CsvImportRow row) {
    return MaterialModel(
      id: '',
      name: row.name,
      cost: row.cost.toString(),
      color: row.color,
      weight: row.spoolWeight.toString(),
      archived: row.archived,
      autoDeductEnabled: row.trackRemaining,
      originalWeight: row.spoolWeight,
      remainingWeight: row.remainingWeight,
      brand: row.brand,
      materialType: row.materialType,
      colorHex: row.colorHex,
      notes: row.notes,
    ).toMap();
  }
}

class MaterialsUpsertResult {
  const MaterialsUpsertResult({
    required this.created,
    required this.updated,
    required this.skippedRows,
    required this.saveFailures,
  });

  final int created;
  final int updated;
  final List<CsvImportRow> skippedRows;
  final List<CsvImportRow> saveFailures;
}

final materialsStreamProvider = StreamProvider<List<MaterialModel>>((ref) {
  ref.watch(appRefreshProvider);
  return ref.read(materialsRepositoryProvider).watchMaterials();
});
