import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart' hide Key;
import 'package:sembast/sembast.dart';
// ignore: implementation_imports
import 'package:sembast/src/type.dart';
import 'package:threed_print_cost_calculator/locator.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';

enum DBName { materials, history, settings, printers }

class DataBaseHelpers {
  DataBaseHelpers(this.dbName);

  final DBName dbName;

  Future<void> addOrUpdateRecord(
    String key,
    String value,
  ) async {
    final db = sl<Database>();
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

  Future<void> insertRecord(Map<String, dynamic> data) async {
    final db = sl<Database>();
    final store = stringMapStoreFactory.store(dbName.name);

    try {
      await store.add(db, data);
    } catch (e) {
      BotToast.showText(text: 'Error saving print');
    }
  }

  Future<void> updateRecord(String key, Map<String, dynamic> data) async {
    final db = sl<Database>();
    final store = stringMapStoreFactory.store(dbName.name);

    try {
      await store.record(key).update(db, data);
    } catch (e) {
      BotToast.showText(text: 'Error saving print');
    }
  }

  Future<void> deleteRecord(String key) async {
    final db = sl<Database>();
    final store = stringMapStoreFactory.store(dbName.name);

    try {
      await store.record(key).delete(db);
    } catch (e) {
      BotToast.showText(text: 'Error saving print');
    }
  }

  Future<RecordSnapshot<Key?, Value?>?> getRecord(String key) async {
    final db = sl<Database>();
    final store = stringMapStoreFactory.store(dbName.name);

    try {
      return await store.record(key).getSnapshot(db);
    } catch (e) {
      BotToast.showText(text: 'Error saving print');
    }
    return null;
  }

  Future<void> putRecord(
    Map<String, dynamic> data,
  ) async {
    final db = sl<Database>();
    final store = StoreRef.main();

    try {
      await store.record(dbName.name).put(db, data);
    } catch (e) {
      BotToast.showText(text: 'Error saving print');
    }
  }

  Future<GeneralSettingsModel> getSettings() async {
    final store = StoreRef.main();
    final settings =
        await store.record(DBName.settings).getSnapshot(sl<Database>());

    return GeneralSettingsModel.fromMap(
      // ignore: cast_nullable_to_non_nullable
      settings!.value as Map<String, dynamic>,
    );
  }

  Future<Map<String, Object?>> getValue(String key) async {
    final db = sl<Database>();
    final store = stringMapStoreFactory.store(dbName.name);

    if (await store.record(key).exists(db)) {
      // ignore: cast_nullable_to_non_nullable
      return await store.record(key).get(db) as Map<String, Object>;
    }

    return {'value': ''};
  }
}
