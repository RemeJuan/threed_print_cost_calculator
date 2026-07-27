import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:riverpod/riverpod.dart';
import 'package:sembast/sembast.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/history/index/history_search_index.dart';
import 'package:threed_print_cost_calculator/history/index/printer_index.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

import 'legacy_history_records_migrator.dart';

const _startupPhaseYield = Duration.zero;

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

  final transaction = Sentry.startTransaction(
    'startup_migration',
    'task',
    bindToScope: true,
  );

  try {
    await _runVersionedMigration(
      preferences: prefs,
      key: printerIndexMigrationKey,
      version: printerIndexMigrationVersion,
      migration: effectiveHooks.rebuildPrinterIndex,
    );
    await _runVersionedMigration(
      preferences: prefs,
      key: searchFieldBackfillMigrationKey,
      version: searchFieldBackfillMigrationVersion,
      migration: effectiveHooks.backfillSearchFields,
    );
    await _runVersionedMigration(
      preferences: prefs,
      key: historySearchRebuildMigrationKey,
      version: historySearchRebuildMigrationVersion,
      migration: effectiveHooks.rebuildHistorySearchIndex,
    );
    await _runVersionedMigration(
      preferences: prefs,
      key: legacyHistoryMigrationKey,
      version: legacyHistoryMigrationVersion,
      migration: () => migrateFn(db),
    );
  } catch (e, st) {
    transaction.throwable = e;
    transaction.status = const SpanStatus.internalError();
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
    await transaction.finish();
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
      Future<void>.delayed(_startupPhaseYield)
          .then((_) {
            return startupMigration(
              db,
              prefs: prefs,
              hooks: hooks,
              migrateLegacyHistoryRecordsFn: migrateLegacyHistoryRecordsFn,
              reportError: reportError,
            );
          })
          .catchError((_) {}),
    );
  });
}

Future<void> _yieldBetweenStartupPhases() =>
    Future<void>.delayed(_startupPhaseYield);

Future<void> _runVersionedMigration({
  required SharedPreferences? preferences,
  required String key,
  required int version,
  required Future<void> Function() migration,
}) async {
  if (preferences?.getInt(key) == version) {
    return;
  }

  await _yieldBetweenStartupPhases();
  await migration();
  await preferences?.setInt(key, version);
}
