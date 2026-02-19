import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart' hide Key;
import 'package:riverpod/riverpod.dart';
import 'package:sembast/sembast.dart';

// ignore: implementation_imports
import 'package:sembast/src/type.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/history/index/printer_index.dart';

final dbHelpersProvider = Provider.family<DataBaseHelpers, DBName>(
  (ref, name) => DataBaseHelpers(ref, name),
);

enum DBName { materials, history, settings, printers }

class DataBaseHelpers {
  final Ref ref;

  DataBaseHelpers(this.ref, this.dbName);

  final DBName dbName;

  Database get db => ref.read(databaseProvider);

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

  Future<void> insertRecord(Map<String, dynamic> data) async {
    final store = stringMapStoreFactory.store(dbName.name);

    try {
      final key = await store.add(db, data);
      // If this is the history store, maintain the printer index
      if (dbName == DBName.history) {
        final printer = (data['printer']?.toString() ?? '').trim();
        if (printer.isNotEmpty) {
          final helpers = PrinterIndexHelpers.fromRef(ref);
          await helpers.addKey(printer, key);
        }
      }
    } catch (e) {
      BotToast.showText(text: 'Error saving print');
      rethrow;
    }
  }

  Future<void> updateRecord(String key, Map<String, dynamic> data) async {
    final store = stringMapStoreFactory.store(dbName.name);
    try {
      // If history, detect printer changes and update index
      if (dbName == DBName.history) {
        final existing =
            await store.record(key).get(db) as Map<String, dynamic>?;
        final oldPrinter = (existing?['printer']?.toString() ?? '').trim();
        final newPrinter = (data['printer']?.toString() ?? oldPrinter).trim();

        await store.record(key).update(db, data);

        final helpers = PrinterIndexHelpers.fromRef(ref);
        if (oldPrinter.isNotEmpty && oldPrinter != newPrinter) {
          await helpers.removeKey(oldPrinter, key);
        }
        if (newPrinter.isNotEmpty && oldPrinter != newPrinter) {
          await helpers.addKey(newPrinter, key);
        }
      } else {
        await store.record(key).update(db, data);
      }
    } catch (e) {
      BotToast.showText(text: 'Error saving print');
    }
  }

  Future<void> deleteRecord(String key) async {
    final store = stringMapStoreFactory.store(dbName.name);

    try {
      // Read existing so we know the printer before deletion
      final existing = await store.record(key).get(db) as Map<String, dynamic>?;

      // First, delete the history entry from the store
      await store.record(key).delete(db);

      // Then, if this is history, remove the key from the printer index
      if (dbName == DBName.history) {
        final printer = (existing?['printer']?.toString() ?? '').trim();
        if (printer.isNotEmpty) {
          final helpers = PrinterIndexHelpers.fromRef(ref);
          await helpers.removeKey(printer, key);
        }
      }
    } catch (e) {
      BotToast.showText(text: 'Error removing record');
    }
  }

  Future<RecordSnapshot<Key?, Value?>?> getRecord(String key) async {
    final store = stringMapStoreFactory.store(dbName.name);

    try {
      return await store.record(key).getSnapshot(db);
    } catch (e) {
      BotToast.showText(text: 'Error saving print');
    }
    return null;
  }

  Future<void> putRecord(Map<String, dynamic> data) async {
    final store = StoreRef.main();
    debugPrint("the put data: $data - ${dbName.name}");
    try {
      await store.record(dbName.name).put(db, data);
    } catch (e) {
      BotToast.showText(text: 'Error saving material');
    }
  }

  Future<GeneralSettingsModel> getSettings() async {
    final store = StoreRef.main();
    final settings = await store.record(DBName.settings.name).get(db);
    if (settings == null) {
      return GeneralSettingsModel.initial();
    }

    // Read printer IDs from the dedicated 'printers' store so we validate
    // activePrinter against actual stored printer records.
    final printersStore = stringMapStoreFactory.store(DBName.printers.name);
    final printerSnapshots = await printersStore.find(db);
    final printerIds = printerSnapshots.isNotEmpty
        ? printerSnapshots.map((r) => r.key.toString()).toList()
        : <String>[];

    final generalSettings = GeneralSettingsModel.fromMap(
      settings as Map<String, dynamic>,
    );

    if (printerIds.isEmpty) {
      return generalSettings.copyWith(activePrinter: '');
    }

    if (!printerIds.contains(generalSettings.activePrinter)) {
      return generalSettings.copyWith(activePrinter: printerIds.first);
    }
    return generalSettings;
  }

  Future<Map<String, Object?>> getValue(String key) async {
    final store = stringMapStoreFactory.store(dbName.name);

    if (await store.record(key).exists(db)) {
      // ignore: cast_nullable_to_non_nullable
      return await store.record(key).get(db) as Map<String, Object>;
    }

    return {'value': ''};
  }
}
