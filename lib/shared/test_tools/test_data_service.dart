import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sembast/sembast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/history/index/history_search_index.dart';
import 'package:threed_print_cost_calculator/history/index/printer_index.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

import 'package:threed_print_cost_calculator/shared/test_tools/seed_loader.dart';

const testPremiumOverridePreferenceKey = 'testPremiumOverride';

final seedLoaderProvider = Provider<SeedLoader>((_) => SeedLoader());

final testDataServiceProvider = Provider<TestDataService>((ref) {
  return TestDataService(ref, loader: ref.watch(seedLoaderProvider));
});

class TestDataOperationResult {
  const TestDataOperationResult({required this.success, this.error});

  final bool success;
  final Object? error;

  const TestDataOperationResult.success() : this(success: true);

  const TestDataOperationResult.failure([Object? error])
    : this(success: false, error: error);
}

class TestDataService {
  TestDataService(this.ref, {required this.loader});

  final Ref ref;
  final SeedLoader loader;

  AppLogger get _logger => ref.read(appLoggerProvider);
  Database get _db => ref.read(databaseProvider);
  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  Future<TestDataOperationResult> seed() async {
    try {
      final bundle = await loader.load();
      await _db.transaction((txn) async {
        await _clearDbInTransaction(txn);
        await _writeSeedData(txn, bundle);
      });

      await _prefs.clear();
      await _writeSeedPreferences(bundle.sharedPreferences);
      return const TestDataOperationResult.success();
    } catch (error, stackTrace) {
      _logger.error(
        AppLogCategory.db,
        'Test data seed failed',
        error: error,
        stackTrace: stackTrace,
      );
      return TestDataOperationResult.failure(error);
    }
  }

  Future<TestDataOperationResult> purge() async {
    try {
      await _db.transaction((txn) async {
        await _clearDbInTransaction(txn);
      });
      await _prefs.clear();
      return const TestDataOperationResult.success();
    } catch (error, stackTrace) {
      _logger.error(
        AppLogCategory.db,
        'Test data purge failed',
        error: error,
        stackTrace: stackTrace,
      );
      return TestDataOperationResult.failure(error);
    }
  }

  Future<TestDataOperationResult> enablePremiumAndSeed() async {
    try {
      final result = await seed();
      if (!result.success) return result;

      await _prefs.setBool(testPremiumOverridePreferenceKey, true);
      return const TestDataOperationResult.success();
    } catch (error, stackTrace) {
      _logger.error(
        AppLogCategory.db,
        'Enable premium test mode failed',
        error: error,
        stackTrace: stackTrace,
      );
      return TestDataOperationResult.failure(error);
    }
  }

  Future<void> _clearDbInTransaction(Transaction txn) async {
    final stores = <StoreRef<String, Object?>>[
      StoreRef<String, Object?>.main(),
      stringMapStoreFactory.store(DBName.printers.name),
      stringMapStoreFactory.store(DBName.materials.name),
      stringMapStoreFactory.store(DBName.history.name),
      stringMapStoreFactory.store('printer_index'),
      stringMapStoreFactory.store('history_search_index'),
    ];

    for (final store in stores) {
      final snapshots = await store.find(txn);
      for (final snapshot in snapshots) {
        await store.record(snapshot.key).delete(txn);
      }
    }
  }

  Future<void> _writeSeedData(Transaction txn, SeedDataBundle bundle) async {
    final printersStore = stringMapStoreFactory.store(DBName.printers.name);
    final materialsStore = stringMapStoreFactory.store(DBName.materials.name);
    final historyStore = stringMapStoreFactory.store(DBName.history.name);
    final mainStore = StoreRef<String, Object?>.main();

    final printerIndex = PrinterIndexHelpers.fromRef(ref);
    final historyIndex = HistorySearchIndexHelpers.fromRef(ref);

    for (final rawPrinter in bundle.printers) {
      final id = rawPrinter['id']?.toString().trim() ?? '';
      if (id.isEmpty) continue;
      final printer = PrinterModel.fromMap(rawPrinter, id);
      await printersStore.record(id).put(txn, printer.toMap());
    }

    for (final rawMaterial in bundle.materials) {
      final id = rawMaterial['id']?.toString().trim() ?? '';
      if (id.isEmpty) continue;
      final material = MaterialModel.fromMap(rawMaterial, id);
      await materialsStore.record(id).put(txn, material.toMap());
    }

    await mainStore
        .record(DBName.settings.name)
        .put(txn, bundle.generalSettings);

    for (final rawHistory in bundle.history) {
      final id = rawHistory['id']?.toString().trim() ?? '';
      if (id.isEmpty) continue;

      final record = withHistorySearchFields({...rawHistory});
      final history = HistoryModel.fromMap(record);
      await historyStore.record(id).put(txn, history.toMap());

      final printer = history.printer.trim();
      if (printer.isNotEmpty) {
        await printerIndex.addKeyInTransaction(txn, printer, id);
      }
      await historyIndex.addRecordInTransaction(
        txn: txn,
        name: history.name,
        printer: history.printer,
        recordKey: id,
      );
    }
  }

  Future<void> _writeSeedPreferences(Map<String, dynamic> values) async {
    for (final entry in values.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value is bool) {
        await _prefs.setBool(key, value);
      } else if (value is int) {
        await _prefs.setInt(key, value);
      } else if (value is double) {
        await _prefs.setDouble(key, value);
      } else if (value is String) {
        await _prefs.setString(key, value);
      } else if (value is List) {
        await _prefs.setStringList(
          key,
          value.map((entry) => entry.toString()).toList(),
        );
      }
    }
  }
}
