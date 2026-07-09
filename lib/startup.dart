import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:riverpod/riverpod.dart';
import 'package:sembast/sembast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/history/index/history_search_index.dart';
import 'package:threed_print_cost_calculator/history/index/printer_index.dart';
import 'package:threed_print_cost_calculator/shared/constants.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/shared/utils/number_parsing.dart';

const printerIndexMigrationVersion = 1;
const searchFieldBackfillMigrationVersion = 1;
const historySearchRebuildMigrationVersion = 1;
const legacyHistoryMigrationVersion = 1;

const printerIndexMigrationKey = 'startup_migration_printer_index_version';
const searchFieldBackfillMigrationKey =
    'startup_migration_search_field_backfill_version';
const historySearchRebuildMigrationKey =
    'startup_migration_history_search_rebuild_version';
const legacyHistoryMigrationKey = 'startup_migration_legacy_history_version';

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
  SharedPreferences? prefs,
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
  final preferences = prefs;

  try {
    await _runVersionedMigration(
      preferences: preferences,
      key: printerIndexMigrationKey,
      version: printerIndexMigrationVersion,
      migration: effectiveHooks.rebuildPrinterIndex,
    );
    await _runVersionedMigration(
      preferences: preferences,
      key: searchFieldBackfillMigrationKey,
      version: searchFieldBackfillMigrationVersion,
      migration: effectiveHooks.backfillSearchFields,
    );
    await _runVersionedMigration(
      preferences: preferences,
      key: historySearchRebuildMigrationKey,
      version: historySearchRebuildMigrationVersion,
      migration: effectiveHooks.rebuildHistorySearchIndex,
    );
    await _runVersionedMigration(
      preferences: preferences,
      key: legacyHistoryMigrationKey,
      version: legacyHistoryMigrationVersion,
      migration: () => migrateFn(db),
    );
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

void scheduleDeferredStartupMigration({
  required Database db,
  required SharedPreferences prefs,
  StartupMigrationHooks? hooks,
  Future<void> Function(Database db)? migrateLegacyHistoryRecordsFn,
  void Function(FlutterErrorDetails details)? reportError,
}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(
      startupMigration(
        db,
        prefs: prefs,
        hooks: hooks,
        migrateLegacyHistoryRecordsFn: migrateLegacyHistoryRecordsFn,
        reportError: reportError,
      ).catchError((_) {
        // startupMigration already reports via reportError before rethrowing.
      }),
    );
  });
}

Future<void> _runVersionedMigration({
  required SharedPreferences? preferences,
  required String key,
  required int version,
  required Future<void> Function() migration,
}) async {
  if (preferences?.getInt(key) == version) {
    return;
  }

  await migration();
  await preferences?.setInt(key, version);
}

Future<void> migrateLegacyHistoryRecords(Database db) async {
  final historyStore = StoreRef<Object?, Object?>('history');
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
