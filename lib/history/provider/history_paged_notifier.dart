import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart';
import 'package:threed_print_cost_calculator/database/repositories/history_repository.dart';
import 'package:threed_print_cost_calculator/history/model/history_entry.dart';

const int _pageSize = 25;

class HistoryPagedState {
  final List<HistoryEntry> items;
  final bool hasMore;
  final bool isLoading;
  final String? error;
  final String query;
  final int page;
  final int debugQueryCount;
  final bool debugUsedFallbackScan;
  final bool hasLoadedOnce;
  final bool isStale;

  const HistoryPagedState({
    required this.items,
    required this.hasMore,
    required this.isLoading,
    this.error,
    required this.query,
    required this.page,
    required this.debugQueryCount,
    required this.debugUsedFallbackScan,
    required this.hasLoadedOnce,
    required this.isStale,
  });

  factory HistoryPagedState.initial() => const HistoryPagedState(
    items: <HistoryEntry>[],
    hasMore: true,
    isLoading: false,
    error: null,
    query: '',
    page: 0,
    debugQueryCount: 0,
    debugUsedFallbackScan: false,
    hasLoadedOnce: false,
    isStale: false,
  );

  HistoryPagedState copyWith({
    List<HistoryEntry>? items,
    bool? hasMore,
    bool? isLoading,
    String? error,
    String? query,
    int? page,
    int? debugQueryCount,
    bool? debugUsedFallbackScan,
    bool? hasLoadedOnce,
    bool? isStale,
  }) {
    return HistoryPagedState(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      query: query ?? this.query,
      page: page ?? this.page,
      debugQueryCount: debugQueryCount ?? this.debugQueryCount,
      debugUsedFallbackScan:
          debugUsedFallbackScan ?? this.debugUsedFallbackScan,
      hasLoadedOnce: hasLoadedOnce ?? this.hasLoadedOnce,
      isStale: isStale ?? this.isStale,
    );
  }

  bool get shouldRefreshOnMount => !isLoading && (!hasLoadedOnce || isStale);
}

// Notifier that manages paged history loading and query changes.
class HistoryPagedNotifier extends Notifier<HistoryPagedState> {
  int _loadGeneration = 0; // generation counter to prevent stale updates

  @override
  HistoryPagedState build() => HistoryPagedState.initial();

  HistoryRepository get _historyRepository =>
      ref.read(historyRepositoryProvider);

  Future<void> setQuery(String q) async {
    state = state.copyWith(
      query: q,
      page: 0,
      items: [],
      hasMore: true,
      error: null,
    );
    _loadGeneration++;
    final currentGen = _loadGeneration;
    await _loadPage(reset: true, generation: currentGen);
  }

  Future<void> refresh() async {
    state = state.copyWith(page: 0, items: [], hasMore: true, error: null);
    _loadGeneration++;
    final currentGen = _loadGeneration;
    await _loadPage(reset: true, generation: currentGen);
  }

  Future<void> refreshIfNeeded() async {
    if (!state.shouldRefreshOnMount) return;
    await refresh();
  }

  void markStale() {
    state = state.copyWith(isStale: true);
  }

  Future<void> loadMore() async {
    if (state.isLoading) return;
    if (!state.hasMore) return;
    _loadGeneration++;
    final currentGen = _loadGeneration;
    await _loadPage(reset: false, generation: currentGen);
  }

  Future<void> _loadPage({required bool reset, required int generation}) async {
    try {
      final nextPage = reset ? 0 : state.page + 1;
      state = state.copyWith(isLoading: true, error: null);

      final offset = nextPage * _pageSize;

      int totalCount = 0;
      var queryCount = 0;
      var usedFallbackScan = false;
      final pageEntries = <HistoryEntry>[];

      final q = state.query.trim();
      if (q.isEmpty) {
        totalCount = await _historyRepository.countHistory();
        queryCount++;
        pageEntries.addAll(
          await _historyRepository.getHistoryPage(
            limit: _pageSize,
            offset: offset,
          ),
        );
        queryCount++;
      } else {
        final allEntries = await _historyRepository.getHistoryMatchingQuery(q);
        queryCount += 2;
        totalCount = allEntries.length;
        final slice = allEntries.skip(offset).take(_pageSize).toList();
        pageEntries.addAll(slice);
      }

      // Ensure generation matches before applying results — otherwise this load is stale
      if (generation != _loadGeneration) return;

      final combined = reset ? pageEntries : [...state.items, ...pageEntries];
      final hasMore = combined.length < totalCount;

      state = state.copyWith(
        items: combined,
        isLoading: false,
        hasMore: hasMore,
        page: nextPage,
        debugQueryCount: queryCount,
        debugUsedFallbackScan: usedFallbackScan,
        hasLoadedOnce: true,
        isStale: false,
      );
    } catch (e, st) {
      if (kDebugMode) print('HistoryPagedNotifier._loadPage error: $e\n$st');
      // Only update state for the generation that started this load — ignore
      // stale failures from earlier loads.
      if (generation != _loadGeneration) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final historyPagedProvider =
    NotifierProvider<HistoryPagedNotifier, HistoryPagedState>(
      HistoryPagedNotifier.new,
    );
