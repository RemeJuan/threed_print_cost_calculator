import 'package:riverpod/riverpod.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/history/index/history_search_index.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';

// Holds the current free-text query used to filter history. Implemented as a
// NotifierProvider to match the project's Riverpod patterns.
final historyQueryProvider = NotifierProvider<HistoryQueryNotifier, String>(
  HistoryQueryNotifier.new,
);

class HistoryQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String q) => state = q;
}

final historyRecordsProvider = FutureProvider.autoDispose<List<RecordSnapshot>>(
  (ref) async {
    final dbHelpers = ref.read(dbHelpersProvider(DBName.history));
    final store =
        stringMapStoreFactory.store(DBName.history.name)
            as StoreRef<Object?, Map<String, Object?>>;

    final query = ref.watch(historyQueryProvider);
    final normalizedQuery = normalizeHistorySearchValue(query);

    if (normalizedQuery.isEmpty) {
      return store.find(
        dbHelpers.db,
        finder: Finder(sortOrders: [SortOrder('date', false)]),
      );
    }

    final keys = await HistorySearchIndexHelpers.fromRef(
      ref,
    ).getKeysMatchingQuery(normalizedQuery);
    if (keys.isEmpty) return const <RecordSnapshot>[];

    final records = <RecordSnapshot>[];
    for (final key in keys) {
      final snapshot = await store.record(key).getSnapshot(dbHelpers.db);
      if (snapshot != null) {
        records.add(snapshot);
      }
    }

    records.sort((a, b) {
      final aDate = HistoryModel.fromMap(a.value as Map<String, dynamic>).date;
      final bDate = HistoryModel.fromMap(b.value as Map<String, dynamic>).date;
      return bDate.compareTo(aDate);
    });
    return records;
  },
);
