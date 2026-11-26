import 'package:riverpod/riverpod.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/history/index/history_index_store_names.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

// Local generic Reader type to match ProviderContainer.read / Ref.read signatures.
// Use a broad `Object?` parameter so tests can pass `container.read` without
// requiring internal Riverpod types to be in scope.
//typedef ReaderFunc = T Function<T>(Object? provider);

/// Helper that manages a printer -> [record keys] index in Sembast.
///
/// Index store structure:
/// - store name: 'printer_index'
/// - record key: normalized printer name (lowercased, trimmed)
/// - record value: `Map<String, dynamic>{ 'keys': [<typed recordKey>...] }`
class PrinterIndexHelpers {
  // Internal untyped read function to avoid Riverpod generic type issues in
  // tests and builds. We cast results where needed.
  final dynamic Function(dynamic provider) _read;
  final AppLogger _logger;

  PrinterIndexHelpers._(this._read, this._logger);

  factory PrinterIndexHelpers.fromRef(Ref ref) {
    return PrinterIndexHelpers._(
      (provider) => ref.read(provider),
      ref.read(appLoggerProvider),
    );
  }

  factory PrinterIndexHelpers.fromContainer(ProviderContainer container) {
    return PrinterIndexHelpers._(
      (provider) => container.read(provider),
      container.read(appLoggerProvider),
    );
  }

  Database get _db => _read(databaseProvider);

  final StoreRef<String, Map<String, Object?>> _indexStore =
      stringMapStoreFactory.store(kPrinterIndexStoreName);

  final StoreRef<Object?, Map<String, Object?>> _historyStore =
      StoreRef<Object?, Map<String, Object?>>(DBName.history.name);

  String _normalize(String s) => s.trim().toLowerCase();

  Map<String, dynamic>? _recordValueMap(Object? value, Object? key) {
    if (value is! Map) {
      _logger.warn(
        AppLogCategory.db,
        'Skipping printer index record ${key ?? '<unknown>'}: expected Map, got ${value.runtimeType}',
      );
      return null;
    }

    return Map<String, dynamic>.from(value);
  }

  /// Rebuild the entire index from the history store. This is idempotent.
  Future<void> rebuildIndex() async {
    await _db.transaction((txn) async {
      final Map<String, List<dynamic>> map = {};
      final records = await _historyStore.find(txn);
      for (final record in records) {
        final value = _recordValueMap(record.value, record.key);
        if (value == null) continue;
        final printer = (value['printer']?.toString() ?? '').trim();
        final norm = _normalize(printer);
        if (norm.isEmpty) continue;
        map.putIfAbsent(norm, () => <dynamic>[]).add(record.key);
      }

      // Clear existing index and write fresh. Ensure keys are treated as strings.
      await _indexStore.delete(txn);

      for (final entry in map.entries) {
        final k = entry.key.toString();
        await _indexStore.record(k).put(txn, {'keys': entry.value});
      }
    });
  }

  /// Add a mapping from [printer] -> [recordKey] to the index.
  Future<void> addKey(String printer, dynamic recordKey) async {
    final norm = _normalize(printer);
    if (norm.isEmpty) return;

    await _db.transaction((txn) async {
      await addKeyInTransaction(txn, printer, recordKey);
    });
  }

  Future<void> addKeyInTransaction(
    Transaction txn,
    String printer,
    dynamic recordKey,
  ) async {
    final norm = _normalize(printer);
    if (norm.isEmpty) return;

    final existing =
        await _indexStore.record(norm).get(txn) as Map<String, dynamic>?;
    final keys = <dynamic>[...?existing?['keys'] as List?];

    if (!keys.contains(recordKey)) {
      keys.add(recordKey);
      await _indexStore.record(norm).put(txn, {'keys': keys});
    }
  }

  /// Remove a mapping from [printer] -> [recordKey] from the index.
  Future<void> removeKey(String printer, dynamic recordKey) async {
    final norm = _normalize(printer);
    if (norm.isEmpty) return;

    await _db.transaction((txn) async {
      await removeKeyInTransaction(txn, printer, recordKey);
    });
  }

  Future<void> removeKeyInTransaction(
    Transaction txn,
    String printer,
    dynamic recordKey,
  ) async {
    final norm = _normalize(printer);
    if (norm.isEmpty) return;

    final existing =
        await _indexStore.record(norm).get(txn) as Map<String, dynamic>?;
    if (existing == null) return;

    final keys = <dynamic>[...?existing['keys'] as List?];
    keys.removeWhere((k) => k == recordKey);

    if (keys.isEmpty) {
      await _indexStore.record(norm).delete(txn);
    } else {
      await _indexStore.record(norm).put(txn, {'keys': keys});
    }
  }

  /// Return all record keys that belong to any printer whose normalized
  /// name contains [query] (case-insensitive). Returns unique keys.
  Future<List<dynamic>> getKeysMatchingPrinter(String query) async {
    final q = _normalize(query);
    if (q.isEmpty) return [];

    final all = await _indexStore.find(_db);
    final matches = <dynamic>{};

    for (final e in all) {
      final k = e.key;
      if (k.contains(q)) {
        final value = e.value as Map<String, dynamic>;
        final keys = (value['keys'] as List?) ?? [];
        matches.addAll(keys);
      }
    }

    // matched keys

    return matches.toList();
  }

  /// Helper: get all indexed printers (normalized)
  Future<List<String>> getAllIndexedPrinters() async {
    final all = await _indexStore.find(_db);
    return all.map((e) => e.key.toString()).toSet().toList();
  }
}
