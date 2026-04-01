import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

const String kHistorySearchNameField = 'searchName';
const String kHistorySearchPrinterField = 'searchPrinter';
const String kHistorySearchTextField = 'searchText';

final RegExp _kSearchWhitespacePattern = RegExp(r'\s+');
final RegExp _kSearchSeparatorPattern = RegExp(
  r'[^\p{L}\p{N}]+',
  unicode: true,
);

String normalizeHistorySearchValue(String value) {
  final trimmed = value.trim().toLowerCase();
  if (trimmed.isEmpty) return '';

  final separated = trimmed.replaceAll(_kSearchSeparatorPattern, ' ');
  return separated.replaceAll(_kSearchWhitespacePattern, ' ').trim();
}

Map<String, dynamic> withHistorySearchFields(Map<String, dynamic> data) {
  final searchName = normalizeHistorySearchValue(
    data['name']?.toString() ?? '',
  );
  final searchPrinter = normalizeHistorySearchValue(
    data['printer']?.toString() ?? '',
  );
  final searchText = [
    searchName,
    searchPrinter,
  ].where((value) => value.isNotEmpty).join(' ').trim();

  return {
    ...data,
    kHistorySearchNameField: searchName,
    kHistorySearchPrinterField: searchPrinter,
    kHistorySearchTextField: searchText,
  };
}

/// Helper for tokenized history search indexes covering both `name` and
/// `printer` fields.
///
/// Index store structure:
/// - store name: `history_search_index`
/// - record key: `<field>:<normalized token or token substring>`
/// - record value: `{ 'keys': [<historyRecordKeyAsString>...] }`
class HistorySearchIndexHelpers {
  final Database _database;

  HistorySearchIndexHelpers._(this._database);

  factory HistorySearchIndexHelpers.fromRef(Ref ref) {
    return HistorySearchIndexHelpers._(ref.read(databaseProvider));
  }

  factory HistorySearchIndexHelpers.fromContainer(ProviderContainer container) {
    return HistorySearchIndexHelpers._(container.read(databaseProvider));
  }

  static const String _kSearchIndexStoreName = 'history_search_index';

  Database get _db => _database;

  final StoreRef<String, Map<String, Object?>> _indexStore =
      stringMapStoreFactory.store(_kSearchIndexStoreName);

  final StoreRef<String, Map<String, Object?>> _historyStore =
      stringMapStoreFactory.store(DBName.history.name);

  String _indexKey(String field, String token) => '$field:$token';

  Set<String> _queryTokens(String value) {
    final normalized = normalizeHistorySearchValue(value);
    if (normalized.isEmpty) return const <String>{};

    return normalized.split(' ').where((token) => token.isNotEmpty).toSet();
  }

  Set<String> _tokensWithSubstrings(String value) {
    final rawTokens = _queryTokens(value);
    if (rawTokens.isEmpty) return const <String>{};

    final expanded = <String>{};
    for (final token in rawTokens) {
      for (var start = 0; start < token.length; start++) {
        for (var end = start + 1; end <= token.length; end++) {
          expanded.add(token.substring(start, end));
        }
      }
    }
    return expanded;
  }

  Set<String> _recordTokens(String value) => _tokensWithSubstrings(value);

  Map<String, Set<String>> _recordTokensByField({
    required String name,
    required String printer,
  }) {
    return {
      kHistorySearchNameField: _recordTokens(name),
      kHistorySearchPrinterField: _recordTokens(printer),
    };
  }

  List<String> _keysFromIndexValue(Map<String, dynamic>? value) {
    final raw = value?['keys'];
    if (raw is! List) return <String>[];
    return raw.map((entry) => entry.toString()).toList();
  }

  Future<void> _addTokens({
    required Transaction txn,
    required Set<String> tokens,
    required String recordKey,
  }) async {
    for (final token in tokens) {
      final existing =
          await _indexStore.record(token).get(txn) as Map<String, dynamic>?;
      final keys = _keysFromIndexValue(existing);
      if (!keys.contains(recordKey)) {
        keys.add(recordKey);
        await _indexStore.record(token).put(txn, {'keys': keys});
      }
    }
  }

  Future<void> _removeTokens({
    required Transaction txn,
    required Set<String> tokens,
    required String recordKey,
  }) async {
    for (final token in tokens) {
      final existing =
          await _indexStore.record(token).get(txn) as Map<String, dynamic>?;
      if (existing == null) continue;

      final keys = _keysFromIndexValue(existing);
      keys.removeWhere((k) => k == recordKey);

      if (keys.isEmpty) {
        await _indexStore.record(token).delete(txn);
      } else {
        await _indexStore.record(token).put(txn, {'keys': keys});
      }
    }
  }

  Future<void> rebuildIndex() async {
    final map = <String, Set<String>>{};
    final records = await _historyStore.find(_db);

    for (final record in records) {
      final value = record.value as Map<String, dynamic>;
      final searchName =
          value[kHistorySearchNameField]?.toString() ??
          normalizeHistorySearchValue(value['name']?.toString() ?? '');
      final searchPrinter =
          value[kHistorySearchPrinterField]?.toString() ??
          normalizeHistorySearchValue(value['printer']?.toString() ?? '');
      final recordTokens = _recordTokensByField(
        name: searchName,
        printer: searchPrinter,
      );

      final key = record.key.toString();
      for (final entry in recordTokens.entries) {
        for (final token in entry.value) {
          map
              .putIfAbsent(_indexKey(entry.key, token), () => <String>{})
              .add(key);
        }
      }
    }

    await _db.transaction((txn) async {
      final existing = await _indexStore.find(txn);
      for (final entry in existing) {
        await _indexStore.record(entry.key.toString()).delete(txn);
      }

      for (final entry in map.entries) {
        await _indexStore.record(entry.key).put(txn, {
          'keys': entry.value.toList(),
        });
      }
    });
  }

  Future<void> addRecord({
    required String name,
    required String printer,
    required dynamic recordKey,
  }) async {
    await _db.transaction((txn) async {
      await addRecordInTransaction(
        txn: txn,
        name: name,
        printer: printer,
        recordKey: recordKey,
      );
    });
  }

  Future<void> addRecordInTransaction({
    required Transaction txn,
    required String name,
    required String printer,
    required dynamic recordKey,
  }) async {
    final recordTokens = _recordTokensByField(name: name, printer: printer);
    final hasTokens = recordTokens.values.any((tokens) => tokens.isNotEmpty);
    if (!hasTokens) return;

    for (final entry in recordTokens.entries) {
      if (entry.value.isEmpty) continue;
      await _addTokens(
        txn: txn,
        tokens: entry.value.map((token) => _indexKey(entry.key, token)).toSet(),
        recordKey: recordKey.toString(),
      );
    }
  }

  Future<void> updateRecord({
    required String oldName,
    required String oldPrinter,
    required String newName,
    required String newPrinter,
    required dynamic recordKey,
  }) async {
    final oldTokens = _recordTokensByField(name: oldName, printer: oldPrinter);
    final newTokens = _recordTokensByField(name: newName, printer: newPrinter);
    final key = recordKey.toString();

    await _db.transaction((txn) async {
      for (final entry in oldTokens.entries) {
        if (entry.value.isEmpty) continue;
        await _removeTokens(
          txn: txn,
          tokens: entry.value
              .map((token) => _indexKey(entry.key, token))
              .toSet(),
          recordKey: key,
        );
      }
      for (final entry in newTokens.entries) {
        if (entry.value.isEmpty) continue;
        await _addTokens(
          txn: txn,
          tokens: entry.value
              .map((token) => _indexKey(entry.key, token))
              .toSet(),
          recordKey: key,
        );
      }
    });
  }

  Future<void> removeRecord({
    required String name,
    required String printer,
    required dynamic recordKey,
  }) async {
    final recordTokens = _recordTokens(name: name, printer: printer);
    if (recordTokens.isEmpty) return;

    await _db.transaction((txn) async {
      await _removeTokens(
        txn: txn,
        tokens: recordTokens,
        recordKey: recordKey.toString(),
      );
    });
  }

  Future<bool> _isLikelyUninitialized() async {
    final indexCount = await _indexStore.count(_db);
    if (indexCount > 0) return false;
    final historyCount = await _historyStore.count(_db);
    return historyCount > 0;
  }

  dynamic _typedKey(String value) {
    final intRegex = RegExp(r'^-?\d+$');
    if (intRegex.hasMatch(value)) return int.parse(value);
    return value;
  }

  Future<List<dynamic>> _queryField(String field, String query) async {
    final tokens = _queryTokens(query);
    if (tokens.isEmpty) return const <dynamic>[];

    Set<String>? intersection;
    for (final token in tokens) {
      final value =
          await _indexStore.record(_indexKey(field, token)).get(_db)
              as Map<String, dynamic>?;
      final keys = ((value?['keys'] as List?) ?? <Object?>[])
          .map((k) => k.toString())
          .toSet();
      if (keys.isEmpty) {
        return const <dynamic>[];
      }

      if (intersection == null) {
        intersection = keys;
      } else {
        intersection = intersection.intersection(keys);
      }

      if (intersection.isEmpty) {
        return const <dynamic>[];
      }
    }

    return (intersection ?? const <String>{}).map(_typedKey).toList();
  }

  /// Returns history record keys that match all normalized query terms.
  ///
  /// Matches are substring-based per token (because indexed record tokens
  /// include all token substrings).
  Future<List<dynamic>> getKeysMatchingQuery(String query) async {
    final firstPass = await _queryOnce(query);
    if (firstPass.isNotEmpty) return firstPass;

    if (await _isLikelyUninitialized()) {
      await rebuildIndex();
      return _queryOnce(query);
    }

    return firstPass;
  }
}
