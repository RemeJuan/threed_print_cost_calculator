import 'package:riverpod/riverpod.dart';
import 'package:threed_print_cost_calculator/database/history_record_store.dart';
import 'package:threed_print_cost_calculator/history/provider/history_paged_notifier.dart';

/// Owns history persistence side effects and paging invalidation.
class HistoryMutationBoundary {
  HistoryMutationBoundary(this.ref);

  final Ref ref;

  HistoryRecordStore get _store => HistoryRecordStore(ref);

  Future<Object?> insert(Map<String, dynamic> data) async {
    final key = await _store.insert(data);
    _markStale();
    return key;
  }

  Future<void> update(Object key, Map<String, dynamic> data) async {
    if (await _store.update(key, data)) _markStale();
  }

  Future<void> delete(Object key) async {
    if (await _store.delete(key)) {
      await ref.read(historyPagedProvider.notifier).refresh();
    }
  }

  void _markStale() => ref.read(historyPagedProvider.notifier).markStale();
}

final historyMutationBoundaryProvider = Provider<HistoryMutationBoundary>(
  HistoryMutationBoundary.new,
);
