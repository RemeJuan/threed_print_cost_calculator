import 'package:riverpod/riverpod.dart';
import 'package:sembast/sembast.dart';
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
/// - record value: `Map<String, dynamic>{ 'keys': [<recordKey>...] }`
class PrinterIndexHelpers {
  // Internal untyped read function to avoid Riverpod generic type issues in
  // tests and builds. We cast results where needed.
  final dynamic Function(dynamic provider) _read;

  PrinterIndexHelpers._(this._read);

  factory PrinterIndexHelpers.fromRef(Ref ref) {
    return PrinterIndexHelpers._((provider) => ref.read(provider));
  }

  factory PrinterIndexHelpers.fromContainer(ProviderContainer container) {
    return PrinterIndexHelpers._((provider) => container.read(provider));
  }

  Database get _db => _read(databaseProvider);

  final StoreRef<String, Map<String, Object?>> _indexStore =
      stringMapStoreFactory.store('printer_index');

  final StoreRef<String, Map<String, Object?>> _historyStore =
      stringMapStoreFactory.store('history');

  String _normalize(String s) => s.trim().toLowerCase();

  /// Rebuild the entire index from the history store. This is idempotent.
  Future<void> rebuildIndex() async {
    final Map<String, List<dynamic>> map = {};

    final records = await _historyStore.find(_db);

    for (final r in records) {
      final value = r.value as Map<String, dynamic>;
      final printer = (value['printer']?.toString() ?? '').trim();
      final key = r.key;
      final norm = _normalize(printer);
      if (norm.isEmpty) continue;
      map.putIfAbsent(norm, () => <dynamic>[]).add(key);
    }

    // Clear existing index and write fresh. Ensure keys are treated as strings.
    final existing = await _indexStore.find(_db);
    for (final e in existing) {
      final k = e.key.toString();
      if (k.isNotEmpty) {
        await _indexStore.record(k).delete(_db);
      }
    }

    for (final entry in map.entries) {
      final k = entry.key.toString();
      await _indexStore.record(k).put(_db, {'keys': entry.value});
    }
  }

  /// Add a mapping from [printer] -> [recordKey] to the index.
  Future<void> addKey(String printer, dynamic recordKey) async {
    final norm = _normalize(printer);
    if (norm.isEmpty) return;

    final existing =
        await _indexStore.record(norm).get(_db) as Map<String, dynamic>?;
    final keys = <dynamic>[...?existing?['keys'] as List?];

    if (!keys.contains(recordKey)) {
      keys.add(recordKey);
      await _indexStore.record(norm).put(_db, {'keys': keys});
    }
  }

  /// Remove a mapping from [printer] -> [recordKey] from the index.
  Future<void> removeKey(String printer, dynamic recordKey) async {
    final norm = _normalize(printer);
    if (norm.isEmpty) return;

    final existing =
        await _indexStore.record(norm).get(_db) as Map<String, dynamic>?;
    if (existing == null) return;

    final keys = <dynamic>[...?existing['keys'] as List?];
    keys.removeWhere((k) => k == recordKey);

    if (keys.isEmpty) {
      await _indexStore.record(norm).delete(_db);
    } else {
      await _indexStore.record(norm).put(_db, {'keys': keys});
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

    return matches.toList();
  }

  /// Helper: get all indexed printers (normalized)
  Future<List<String>> getAllIndexedPrinters() async {
    final all = await _indexStore.find(_db);
    return all.map((e) => e.key.toString()).toSet().toList();
  }
}
