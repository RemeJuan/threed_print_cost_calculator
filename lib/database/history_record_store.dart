import 'package:riverpod/riverpod.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/database/database_record_mapper.dart';
import 'package:threed_print_cost_calculator/history/index/history_search_index.dart';
import 'package:threed_print_cost_calculator/history/index/printer_index.dart';
import 'package:threed_print_cost_calculator/history/provider/history_paged_notifier.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

class HistoryRecordStore {
  HistoryRecordStore(this.ref);

  final Ref ref;

  Database get _db => ref.read(databaseProvider);

  StoreRef<Object?, Map<String, Object?>> get _store =>
      StoreRef<Object?, Map<String, Object?>>(DBName.history.name);

  PrinterIndexHelpers get _printerIndex => PrinterIndexHelpers.fromRef(ref);

  HistorySearchIndexHelpers get _searchIndex =>
      HistorySearchIndexHelpers.fromRef(ref);

  Future<Object?> insert(Map<String, dynamic> data) async {
    final payload = withHistorySearchFields(data);

    final key = await _db.transaction((txn) async {
      final key = await _store.add(txn, payload);
      final printer = (payload['printer']?.toString() ?? '').trim();
      if (printer.isNotEmpty) {
        await _printerIndex.addKeyInTransaction(txn, printer, key);
      }

      await _searchIndex.addRecordInTransaction(
        txn: txn,
        name: payload[kHistorySearchNameField]?.toString() ?? '',
        printer: payload[kHistorySearchPrinterField]?.toString() ?? '',
        recordKey: key,
      );

      return key;
    });

    ref.read(historyPagedProvider.notifier).markStale();
    return key;
  }

  Future<void> update(Object key, Map<String, dynamic> data) async {
    final didUpdate = await _db.transaction((txn) async {
      final existing = castDatabaseRecord(
        await _store.record(key).get(txn),
        storeName: DBName.history.name,
        key: key,
      );
      if (existing == null) return false;

      final merged = withHistorySearchFields({...existing, ...data});
      final oldPrinter = (existing['printer']?.toString() ?? '').trim();
      final newPrinter = (merged['printer']?.toString() ?? '').trim();

      await _store.record(key).put(txn, merged);

      if (oldPrinter.isNotEmpty && oldPrinter != newPrinter) {
        await _printerIndex.removeKeyInTransaction(txn, oldPrinter, key);
      }
      if (newPrinter.isNotEmpty && oldPrinter != newPrinter) {
        await _printerIndex.addKeyInTransaction(txn, newPrinter, key);
      }

      await _searchIndex.updateRecordInTransaction(
        txn: txn,
        oldName:
            existing[kHistorySearchNameField]?.toString() ??
            normalizeHistorySearchValue(existing['name']?.toString() ?? ''),
        oldPrinter:
            existing[kHistorySearchPrinterField]?.toString() ??
            normalizeHistorySearchValue(existing['printer']?.toString() ?? ''),
        newName: merged[kHistorySearchNameField]?.toString() ?? '',
        newPrinter: merged[kHistorySearchPrinterField]?.toString() ?? '',
        recordKey: key,
      );

      return true;
    });

    if (didUpdate) {
      ref.read(historyPagedProvider.notifier).markStale();
    }
  }

  Future<void> delete(Object key) async {
    final didDelete = await _db.transaction((txn) async {
      final existing = castDatabaseRecord(
        await _store.record(key).get(txn),
        storeName: DBName.history.name,
        key: key,
      );
      if (existing == null) return false;

      await _store.record(key).delete(txn);

      final printer = (existing['printer']?.toString() ?? '').trim();
      if (printer.isNotEmpty) {
        await _printerIndex.removeKeyInTransaction(txn, printer, key);
      }

      await _searchIndex.removeRecordInTransaction(
        txn: txn,
        name:
            existing[kHistorySearchNameField]?.toString() ??
            normalizeHistorySearchValue(existing['name']?.toString() ?? ''),
        printer:
            existing[kHistorySearchPrinterField]?.toString() ??
            normalizeHistorySearchValue(existing['printer']?.toString() ?? ''),
        recordKey: key,
      );

      return true;
    });

    if (!didDelete) return;

    ref.read(historyPagedProvider.notifier).markStale();
  }
}
