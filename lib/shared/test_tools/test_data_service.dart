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
import 'package:threed_print_cost_calculator/purchases/premium_local_store.dart';
import 'package:threed_print_cost_calculator/purchases/premium_local_store_keys.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

import 'package:threed_print_cost_calculator/shared/test_tools/seed_loader.dart';

String formatTestPremiumOverrideDay(DateTime now) {
  return '${now.year.toString().padLeft(4, '0')}'
      '${now.month.toString().padLeft(2, '0')}'
      '${now.day.toString().padLeft(2, '0')}';
}

bool isTestPremiumOverrideActiveForDate(String? enabledOn, DateTime now) {
  if (enabledOn == null) return false;
  return enabledOn == formatTestPremiumOverrideDay(now);
}

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
  PremiumLocalStore get _premiumLocalStore =>
      ref.read(premiumLocalStoreProvider);

  bool _isPremiumSeedKey(String key) {
    return switch (key) {
      hideProPromotionsPreferenceKey => true,
      testPremiumOverrideEnabledOnPreferenceKey => true,
      calculationCountPreferenceKey => true,
      hasUsedGcodeImportPreferenceKey => true,
      cancelFeedbackPromptShownStatePreferenceKey => true,
      cancelFeedbackPromptSubmittedStatePreferenceKey => true,
      runCountPreferenceKey => true,
      paywallPreferenceKey => true,
      _ => false,
    };
  }

  Future<TestDataOperationResult> seed() async {
    try {
      final bundle = await loader.load(subdirectory: 'free');
      await _db.transaction((txn) async {
        await _clearDbInTransaction(txn);
        await _writeSeedData(txn, bundle);
      });

      await _prefs.clear();
      await _clearPremiumLocalStore();
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
      await _clearPremiumLocalStore();
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
      final bundle = await loader.load(subdirectory: 'premium');
      await _db.transaction((txn) async {
        await _clearDbInTransaction(txn);
        await _writeSeedData(txn, bundle);
      });

      await _prefs.clear();
      await _clearPremiumLocalStore();
      await _writeSeedPreferences(bundle.sharedPreferences);

      await _premiumLocalStore.write(
        testPremiumOverrideEnabledOnPreferenceKey,
        formatTestPremiumOverrideDay(DateTime.now()),
      );
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
    await _clearStore(StoreRef<String, Object?>.main(), txn);
    await _clearStore(stringMapStoreFactory.store(DBName.printers.name), txn);
    await _clearStore(stringMapStoreFactory.store(DBName.materials.name), txn);
    await _clearStore(StoreRef<Object?, Object?>(DBName.history.name), txn);
    await _clearStore(stringMapStoreFactory.store('printer_index'), txn);
    await _clearStore(stringMapStoreFactory.store('history_search_index'), txn);
  }

  Future<void> _clearStore<K, V>(StoreRef<K, V> store, Transaction txn) async {
    final snapshots = await store.find(txn);
    for (final snapshot in snapshots) {
      await store.record(snapshot.key).delete(txn);
    }
  }

  Future<void> _writeSeedData(Transaction txn, SeedDataBundle bundle) async {
    final printersStore = stringMapStoreFactory.store(DBName.printers.name);
    final materialsStore = stringMapStoreFactory.store(DBName.materials.name);
    final historyStore = StoreRef<Object?, Map<String, Object?>>(
      DBName.history.name,
    );
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
        if (_isPremiumSeedKey(key)) {
          await _premiumLocalStore.write(key, value.toString());
        } else {
          await _prefs.setBool(key, value);
          await _premiumLocalStore.write(key, value.toString());
        }
      } else if (value is int) {
        if (_isPremiumSeedKey(key)) {
          await _premiumLocalStore.write(key, value.toString());
        } else {
          await _prefs.setInt(key, value);
          await _premiumLocalStore.write(key, value.toString());
        }
      } else if (value is double) {
        await _prefs.setDouble(key, value);
      } else if (value is String) {
        if (_isPremiumSeedKey(key)) {
          await _premiumLocalStore.write(key, value);
        } else {
          await _prefs.setString(key, value);
          await _premiumLocalStore.write(key, value);
        }
      } else if (value is List) {
        await _prefs.setStringList(
          key,
          value.map((entry) => entry.toString()).toList(),
        );
      }
    }
  }

  Future<void> _clearPremiumLocalStore() async {
    final values = await _premiumLocalStore.readAll();
    for (final key in values.keys) {
      await _premiumLocalStore.delete(key);
    }
  }
}
