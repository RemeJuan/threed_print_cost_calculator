import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/database/database_record_mapper.dart';
import 'package:threed_print_cost_calculator/history/index/history_search_index.dart';
import 'package:threed_print_cost_calculator/history/model/history_entry.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

final historyRepositoryProvider = Provider<HistoryRepository>(
  HistoryRepository.new,
);

class HistoryRepository {
  HistoryRepository(this.ref);

  final Ref ref;

  Database get _db => ref.read(databaseProvider);

  StoreRef<Object?, Object?> get _store =>
      StoreRef<Object?, Object?>(DBName.history.name);

  Future<int> countHistory() => _store.count(_db);

  Future<HistoryEntry?> getHistoryByKey(Object key) async {
    final snapshot = await _store.record(key).getSnapshot(_db);
    return _mapSnapshot(snapshot);
  }

  Future<List<HistoryEntry>> getHistoryPage({
    required int limit,
    required int offset,
  }) async {
    final snapshots = await _store.find(
      _db,
      finder: Finder(
        sortOrders: [SortOrder('date', false)],
        limit: limit,
        offset: offset,
      ),
    );
    return _mapSnapshots(snapshots);
  }

  Future<List<HistoryEntry>> getAllHistory() async {
    final snapshots = await _store.find(
      _db,
      finder: Finder(sortOrders: [SortOrder('date', false)]),
    );
    return _mapSnapshots(snapshots);
  }

  Future<List<HistoryEntry>> getHistoryByKeys(Iterable<Object?> keys) async {
    final uniqueKeys = <Object>[];
    final seenKeys = <Object>{};

    for (final key in keys) {
      if (key == null) continue;
      if (seenKeys.add(key)) {
        uniqueKeys.add(key);
      }
    }

    final entries = <HistoryEntry>[];
    for (final key in uniqueKeys) {
      final entry = await getHistoryByKey(key);
      if (entry != null) {
        entries.add(entry);
      }
    }

    entries.sort((a, b) => b.model.date.compareTo(a.model.date));
    return entries;
  }

  Future<List<HistoryEntry>> getHistoryMatchingQuery(String query) async {
    final normalizedQuery = normalizeHistorySearchValue(query);
    if (normalizedQuery.isEmpty) {
      return getAllHistory();
    }

    final keys = await HistorySearchIndexHelpers.fromRef(
      ref,
    ).getKeysMatchingQuery(normalizedQuery);
    return getHistoryByKeys(keys);
  }

  Future<Object?> saveHistory(HistoryModel model) {
    return ref
        .read(dbHelpersProvider(DBName.history))
        .insertRecord(model.toMap());
  }

  HistoryEntry? _mapSnapshot(RecordSnapshot<Object?, Object?>? snapshot) {
    if (snapshot == null) return null;

    final map = castDatabaseRecord(
      snapshot.value,
      storeName: DBName.history.name,
      key: snapshot.key,
    );
    if (map == null) return null;

    try {
      return HistoryEntry(
        key: snapshot.key ?? '',
        model: HistoryModel.fromMap(map),
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          'Skipping malformed history record for key=${snapshot.key}: $error\n$stackTrace',
        );
      }
      return null;
    }
  }

  List<HistoryEntry> _mapSnapshots(
    List<RecordSnapshot<Object?, Object?>> snapshots,
  ) => snapshots.map(_mapSnapshot).whereType<HistoryEntry>().toList();
}
