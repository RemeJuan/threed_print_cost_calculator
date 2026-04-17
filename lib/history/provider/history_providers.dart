import 'package:riverpod/riverpod.dart';
import 'package:threed_print_cost_calculator/database/repositories/history_repository.dart';
import 'package:threed_print_cost_calculator/history/model/history_entry.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

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

final historyRecordsProvider = FutureProvider.autoDispose<List<HistoryEntry>>((
  ref,
) async {
  ref.watch(appRefreshProvider);
  final repository = ref.read(historyRepositoryProvider);
  final query = ref.watch(historyQueryProvider);
  return repository.getHistoryMatchingQuery(query);
});
