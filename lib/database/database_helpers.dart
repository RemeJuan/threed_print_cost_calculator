import 'package:bot_toast/bot_toast.dart';
import 'package:riverpod/riverpod.dart';
import 'package:sembast/sembast.dart';
import 'package:flutter/widgets.dart' hide Key;

// ignore: implementation_imports
import 'package:sembast/src/type.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/history/index/history_search_index.dart';
import 'package:threed_print_cost_calculator/history/index/printer_index.dart';
import 'package:threed_print_cost_calculator/history/provider/history_paged_notifier.dart';

final dbHelpersProvider = Provider.family<DataBaseHelpers, DBName>(
  (ref, name) => DataBaseHelpers(ref, name),
);

enum DBName { materials, history, settings, printers }

class DataBaseHelpers {
  final Ref ref;

  DataBaseHelpers(this.ref, this.dbName);

  final DBName dbName;

  Database get db => ref.read(databaseProvider);

  AppLocalizations get _l10n {
    return lookupAppLocalizations(
      WidgetsBinding.instance.platformDispatcher.locale,
    );
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
    final store = stringMapStoreFactory.store(dbName.name);
    final payload = dbName == DBName.history
        ? withHistorySearchFields(data)
        : data;

    try {
      if (dbName != DBName.history) {
        return store.add(db, payload);
      }

      final printerHelpers = PrinterIndexHelpers.fromRef(ref);
      final searchHelpers = HistorySearchIndexHelpers.fromRef(ref);

      final key = await db.transaction((txn) async {
        final key = await store.add(txn, payload);
        final printer = (payload['printer']?.toString() ?? '').trim();
        if (printer.isNotEmpty) {
          await printerHelpers.addKeyInTransaction(txn, printer, key);
        }

        await searchHelpers.addRecordInTransaction(
          txn: txn,
          name: payload[kHistorySearchNameField]?.toString() ?? '',
          printer: payload[kHistorySearchPrinterField]?.toString() ?? '',
          recordKey: key,
        );

        return key;
      });

      ref.read(historyPagedProvider.notifier).markStale();
      return key;
    } catch (e) {
      BotToast.showText(text: _l10n.savePrintErrorMessage);
      rethrow;
    }
  }

  Future<void> updateRecord(String key, Map<String, dynamic> data) async {
    final store = stringMapStoreFactory.store(dbName.name);
    try {
      if (dbName == DBName.history) {
        final existing =
            await store.record(key).get(db) as Map<String, dynamic>?;
        if (existing == null) return;

        final merged = withHistorySearchFields({...existing, ...data});
        final oldPrinter = (existing['printer']?.toString() ?? '').trim();
        final newPrinter = (merged['printer']?.toString() ?? '').trim();

        await store.record(key).put(db, merged);

        final helpers = PrinterIndexHelpers.fromRef(ref);
        if (oldPrinter.isNotEmpty && oldPrinter != newPrinter) {
          await helpers.removeKey(oldPrinter, key);
        }
        if (newPrinter.isNotEmpty && oldPrinter != newPrinter) {
          await helpers.addKey(newPrinter, key);
        }

        await HistorySearchIndexHelpers.fromRef(ref).updateRecord(
          oldName:
              existing[kHistorySearchNameField]?.toString() ??
              normalizeHistorySearchValue(existing['name']?.toString() ?? ''),
          oldPrinter:
              existing[kHistorySearchPrinterField]?.toString() ??
              normalizeHistorySearchValue(
                existing['printer']?.toString() ?? '',
              ),
          newName: merged[kHistorySearchNameField]?.toString() ?? '',
          newPrinter: merged[kHistorySearchPrinterField]?.toString() ?? '',
          recordKey: key,
        );

        ref.read(historyPagedProvider.notifier).markStale();
      } else {
        await store.record(key).update(db, data);
      }
    } catch (e) {
      BotToast.showText(text: _l10n.savePrintErrorMessage);
    }
  }

  // Accept generic Sembast keys (int or String) so callers that use numeric keys
  // (auto-incremented) don't accidentally stringify them and fail to find records.
  Future<void> deleteRecord(Object key) async {
    // Use a dynamically-typed StoreRef so record(key) accepts both int and String
    final store =
        stringMapStoreFactory.store(dbName.name)
            as StoreRef<Object?, Map<String, Object?>>;

    try {
      // Read existing so we know the printer before deletion
      final existing = await store.record(key).get(db) as Map<String, dynamic>?;

      // First, delete the history entry from the store
      await store.record(key).delete(db);

      // Then, if this is history, remove the key from the printer index
      if (dbName == DBName.history) {
        final printer = (existing?['printer']?.toString() ?? '').trim();
        final helpers = PrinterIndexHelpers.fromRef(ref);
        if (printer.isNotEmpty) {
          await helpers.removeKey(printer, key);
        }

        await HistorySearchIndexHelpers.fromRef(ref).removeRecord(
          name:
              existing?[kHistorySearchNameField]?.toString() ??
              normalizeHistorySearchValue(existing?['name']?.toString() ?? ''),
          printer:
              existing?[kHistorySearchPrinterField]?.toString() ??
              normalizeHistorySearchValue(
                existing?['printer']?.toString() ?? '',
              ),
          recordKey: key,
        );

        // Defensive: some index entries may have stale keys or the record's printer
        // field may be empty. To ensure the index doesn't retain the deleted key,
        // scan the entire printer_index store and remove any occurrences of this key.
        // Compare keys by their string representation to tolerate mixed types.
        final indexStore = stringMapStoreFactory.store('printer_index');
        await db.transaction((txn) async {
          final all = await indexStore.find(txn);
          for (final e in all) {
            final entryKeys = (e.value['keys'] as List?) ?? [];
            final hasMatch = entryKeys.any(
              (k) => k.toString() == key.toString(),
            );
            if (hasMatch) {
              final newKeys = entryKeys
                  .where((k) => k.toString() != key.toString())
                  .toList();
              if (newKeys.isEmpty) {
                await indexStore.record(e.key).delete(txn);
                // removed empty index entry
              } else {
                await indexStore.record(e.key).put(txn, {'keys': newKeys});
                // updated index entry
              }
            }
          }
        });

        ref.read(historyPagedProvider.notifier).markStale();
      }
    } catch (e) {
      BotToast.showText(text: 'Error removing record');
    }
  }

  Future<RecordSnapshot<Key?, Value?>?> getRecord(Object key) async {
    final store =
        stringMapStoreFactory.store(dbName.name)
            as StoreRef<Object?, Map<String, Object?>>;

    try {
      return await store.record(key).getSnapshot(db);
    } catch (e) {
      BotToast.showText(text: _l10n.savePrintErrorMessage);
    }
    return null;
  }

  Future<void> putRecord(Map<String, dynamic> data) async {
    final store = StoreRef.main();
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

  // New helper: return all records from the configured store
  Future<List<RecordSnapshot<Key?, Value?>>> getAllRecords() async {
    final store = stringMapStoreFactory.store(dbName.name);
    try {
      return await store.find(db);
    } catch (e) {
      BotToast.showText(text: 'Error reading records');
      // Propagate the error so callers can handle migration/backfill failures
      // instead of silently receiving an empty list.
      rethrow;
    }
  }
}
