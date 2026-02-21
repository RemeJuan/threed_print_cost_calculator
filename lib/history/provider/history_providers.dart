import 'package:riverpod/riverpod.dart';
import 'package:sembast/sembast.dart';
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

// Returns the list of history RecordSnapshot filtered by the current query.
// It reads the database and applies the same name/printer filtering as the UI.
final historyRecordsProvider = FutureProvider.autoDispose<List<RecordSnapshot>>(
  (ref) async {
    // Use the DB helpers provider so we avoid magic string store names and get
    // a centralized place to access the DB.
    final dbHelpers = ref.read(dbHelpersProvider(DBName.history));
    final store = stringMapStoreFactory.store(DBName.history.name);

    final query = ref.watch(historyQueryProvider);

    final records = await store.find(
      dbHelpers.db,
      finder: Finder(sortOrders: [SortOrder('date', false)]),
    );

    final q = query.trim().toLowerCase();
    if (q.isEmpty) return records;

    return records.where((r) {
      final item = r.value as Map<String, dynamic>;
      final data = HistoryModel.fromMap(item);
      final name = data.name.toLowerCase();
      final printer = data.printer.toLowerCase();
      return name.contains(q) || printer.contains(q);
    }).toList();
  },
);
