import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/history/index/history_index_store_names.dart';
import 'package:threed_print_cost_calculator/history/index/history_search_index.dart';
import 'package:threed_print_cost_calculator/history/index/printer_index.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';

Future<void> restoreBackupToDatabase({
  required Ref ref,
  required Transaction txn,
  required GeneralSettingsModel settings,
  required List<PrinterModel> printers,
  required List<MaterialModel> materials,
  required List<HistoryModel> history,
  required List<Map<String, dynamic>> historyRaw,
}) async {
  await _clearDb(txn);
  await _writeRestore(
    ref: ref,
    txn: txn,
    settings: settings,
    printers: printers,
    materials: materials,
    history: history,
    historyRaw: historyRaw,
  );
}

Future<void> _clearDb(Transaction txn) async {
  for (final store in [
    StoreRef<String, Object?>.main(),
    stringMapStoreFactory.store(DBName.printers.name),
    stringMapStoreFactory.store(DBName.materials.name),
    StoreRef<Object?, Object?>(DBName.history.name),
    stringMapStoreFactory.store(kPrinterIndexStoreName),
    stringMapStoreFactory.store(kHistorySearchIndexStoreName),
  ]) {
    await store.delete(txn);
  }
}

Future<void> _writeRestore({
  required Ref ref,
  required Transaction txn,
  required GeneralSettingsModel settings,
  required List<PrinterModel> printers,
  required List<MaterialModel> materials,
  required List<HistoryModel> history,
  required List<Map<String, dynamic>> historyRaw,
}) async {
  final settingsStore = StoreRef<String, Object?>.main();
  final printersStore = stringMapStoreFactory.store(DBName.printers.name);
  final materialsStore = stringMapStoreFactory.store(DBName.materials.name);
  final historyStore = StoreRef<Object?, Map<String, Object?>>(
    DBName.history.name,
  );
  final printerIndex = PrinterIndexHelpers.fromRef(ref);
  final historyIndex = HistorySearchIndexHelpers.fromRef(ref);

  await settingsStore.record(DBName.settings.name).put(txn, settings.toMap());
  for (final printer in printers) {
    await printersStore.record(printer.id).put(txn, printer.toMap());
  }
  for (final material in materials) {
    await materialsStore.record(material.id).put(txn, material.toMap());
  }
  final seenIds = <String>{};
  for (var i = 0; i < history.length; i++) {
    final item = history[i];
    final raw = historyRaw[i];
    final id = raw['id']?.toString().trim().isNotEmpty == true
        ? raw['id'].toString()
        : 'history_$i';
    if (!seenIds.add(id)) {
      throw FormatException('Duplicate history entry id: $id');
    }
    await historyStore.record(id).put(txn, item.toMap());
    if (item.printer.trim().isNotEmpty) {
      await printerIndex.addKeyInTransaction(txn, item.printer, id);
    }
    await historyIndex.addRecordInTransaction(
      txn: txn,
      name: item.name,
      printer: item.printer,
      recordKey: id,
    );
  }
}
