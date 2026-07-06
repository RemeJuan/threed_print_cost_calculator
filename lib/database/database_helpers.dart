import 'package:riverpod/riverpod.dart';
import 'package:sembast/sembast.dart';
// ignore: implementation_imports
import 'package:sembast/src/type.dart';
import 'package:threed_print_cost_calculator/database/history_record_store.dart';
import 'package:threed_print_cost_calculator/history/provider/history_paged_notifier.dart';
import 'package:threed_print_cost_calculator/database/settings_store_reader.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';

final dbHelpersProvider = Provider.family<DataBaseHelpers, DBName>(
  (ref, name) => DataBaseHelpers(ref, name),
);

enum DBName { materials, history, settings, printers, interfaceSettings }

class DataBaseHelpers {
  final Ref ref;

  DataBaseHelpers(this.ref, this.dbName);

  final DBName dbName;

  Database get db => ref.read(databaseProvider);

  HistoryRecordStore get _historyStore => HistoryRecordStore(ref);

  SettingsStoreReader get _settingsReader => SettingsStoreReader(ref);

  void _markHistoryPagedStateStale() {
    ref.read(historyPagedProvider.notifier).markStale();
  }

  Future<void> addOrUpdateRecord(String key, String value) async {
    final store = stringMapStoreFactory.store(dbName.name);
    // Check if the record exists before adding or updating it.
    await db.transaction((txn) async {
      // Look of existing record
      final existing = await store.record(key).getSnapshot(txn);
      if (existing == null) {
        // code not found, add
        await store.record(key).add(txn, {'value': value});
      } else {
        // Update existing
        await existing.ref.update(txn, {'value': value});
      }
    });
  }

  Future<Object?> insertRecord(Map<String, dynamic> data) async {
    if (dbName == DBName.history) {
      final key = await _historyStore.insert(data);
      _markHistoryPagedStateStale();
      return key;
    }

    return stringMapStoreFactory.store(dbName.name).add(db, data);
  }

  Future<void> updateRecord(Object key, Map<String, dynamic> data) async {
    if (dbName == DBName.history) {
      final didUpdate = await _historyStore.update(key, data);
      if (didUpdate) {
        _markHistoryPagedStateStale();
      }
      return;
    }

    final store =
        stringMapStoreFactory.store(dbName.name)
            as StoreRef<Object?, Map<String, Object?>>;
    await store.record(key).update(db, data);
  }

  // Accept generic Sembast keys (int or String) so callers that use numeric keys
  // (auto-incremented) don't accidentally stringify them and fail to find records.
  Future<void> deleteRecord(Object key) async {
    if (dbName == DBName.history) {
      final didDelete = await _historyStore.delete(key);
      if (didDelete) {
        _markHistoryPagedStateStale();
      }
      return;
    }

    final store =
        stringMapStoreFactory.store(dbName.name)
            as StoreRef<Object?, Map<String, Object?>>;
    await store.record(key).delete(db);
  }

  Future<RecordSnapshot<Key?, Value?>?> getRecord(Object key) async {
    final store =
        stringMapStoreFactory.store(dbName.name)
            as StoreRef<Object?, Map<String, Object?>>;

    return await store.record(key).getSnapshot(db);
  }

  Future<void> putRecord(Map<String, dynamic> data) async {
    await StoreRef.main().record(dbName.name).put(db, data);
  }

  Future<GeneralSettingsModel> getSettings() async {
    return _settingsReader.getSettings();
  }

  Future<Map<String, Object?>> getValue(String key) async {
    final store = stringMapStoreFactory.store(dbName.name);

    if (await store.record(key).exists(db)) {
      // ignore: cast_nullable_to_non_nullable
      return await store.record(key).get(db) as Map<String, Object>;
    }

    return {'value': ''};
  }

  // New helper: return all records from the configured store
  Future<List<RecordSnapshot<Key?, Value?>>> getAllRecords() async {
    return stringMapStoreFactory.store(dbName.name).find(db);
  }
}
