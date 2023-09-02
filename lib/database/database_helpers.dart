import 'package:flutter/foundation.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/locator.dart';

enum DBName { materials, history, settings }

class DataBaseHelpers {
  DataBaseHelpers(this.dbName);

  final DBName dbName;

  Future<void> addOrUpdateRecord(
    String key,
    String value,
  ) async {
    final db = sl<Database>();
    final store = stringMapStoreFactory.store(describeEnum(dbName));
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

  Future<Map<String, Object?>> getValue(String key) async {
    final db = sl<Database>();
    final store = stringMapStoreFactory.store(describeEnum(dbName));

    if (await store.record(key).exists(db)) {
      return await store.record(key).get(db) as Map<String, Object?>;
    }

    return {'value': ''};
  }
}
