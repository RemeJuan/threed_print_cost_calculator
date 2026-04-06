import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/history/index/history_search_index.dart';
import 'package:threed_print_cost_calculator/history/index/printer_index.dart';
import 'package:threed_print_cost_calculator/shared/constants.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/shared/utils/number_parsing.dart';

abstract class StartupMigrationHooks {
  Future<void> rebuildPrinterIndex();
  Future<void> backfillSearchFields();
  Future<void> rebuildHistorySearchIndex();
}

class DefaultStartupMigrationHooks implements StartupMigrationHooks {
  DefaultStartupMigrationHooks(ProviderContainer container)
    : _printerIndexHelpers = PrinterIndexHelpers.fromContainer(container),
      _historySearchIndexHelpers = HistorySearchIndexHelpers.fromContainer(
        container,
      );

  final PrinterIndexHelpers _printerIndexHelpers;
  final HistorySearchIndexHelpers _historySearchIndexHelpers;

  @override
  Future<void> rebuildPrinterIndex() => _printerIndexHelpers.rebuildIndex();

  @override
  Future<void> backfillSearchFields() =>
      _historySearchIndexHelpers.backfillSearchFields();

  @override
  Future<void> rebuildHistorySearchIndex() =>
      _historySearchIndexHelpers.rebuildIndex();
}

Future<void> startupMigration(
  Database db, {
  StartupMigrationHooks? hooks,
  Future<void> Function(Database db)? migrateLegacyHistoryRecordsFn,
  void Function(FlutterErrorDetails details)? reportError,
}) async {
  final tempContainer = hooks == null
      ? ProviderContainer(overrides: [databaseProvider.overrideWithValue(db)])
      : null;

  final effectiveHooks = hooks ?? DefaultStartupMigrationHooks(tempContainer!);
  final migrateFn =
      migrateLegacyHistoryRecordsFn ?? migrateLegacyHistoryRecords;
  final errorReporter = reportError ?? FlutterError.reportError;

  try {
    await effectiveHooks.rebuildPrinterIndex();
    await effectiveHooks.backfillSearchFields();
    await effectiveHooks.rebuildHistorySearchIndex();
    await migrateFn(db);
  } catch (e, st) {
    errorReporter(
      FlutterErrorDetails(
        exception: e,
        stack: st,
        library: 'startupMigration',
        context: ErrorDescription(
          'History search/printer index rebuild / migration',
        ),
      ),
    );
    rethrow;
  } finally {
    tempContainer?.dispose();
  }
}

Future<void> migrateLegacyHistoryRecords(Database db) async {
  final historyStore = stringMapStoreFactory.store('history');
  final records = await historyStore.find(db);

  for (final record in records) {
    final value = record.value as Map<String, dynamic>;
    final usages = value['materialUsages'];
    if (usages is List && usages.isNotEmpty) {
      continue;
    }

    final rawWeight = value['weight'];
    final parsedWeight = rawWeight is num
        ? rawWeight.toInt()
        : parseLocalizedInt(rawWeight);

    final migrated = {
      ...value,
      'materialUsages': [
        {
          'materialId': value['materialId']?.toString() ?? '',
          'materialName': value['material']?.toString() ?? kUnassignedLabel,
          'costPerKg': 0,
          'weightGrams': parsedWeight,
        },
      ],
    };
    await historyStore.record(record.key).put(db, migrated);
  }
}
