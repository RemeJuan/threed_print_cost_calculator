import 'package:riverpod/riverpod.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/database/repositories/history_repository.dart';
import 'package:threed_print_cost_calculator/history/model/history_entry.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

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

  AppLogger get _logger => ref.read(appLoggerProvider);

  @override
  HistoryPagedState build() {
    ref.watch(appRefreshProvider);
    return HistoryPagedState.initial();
  }

  HistoryRepository get _historyRepository =>
      ref.read(historyRepositoryProvider);

  Future<void> setQuery(String q) async {
    await _resetAndLoad(query: q, preserveQuery: true);
  }

  Future<void> refresh() async {
    await _resetAndLoad();
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
    await _loadPage(reset: false, generation: _nextGeneration());
  }

  int _nextGeneration() => ++_loadGeneration;

  Future<void> _resetAndLoad({
    String? query,
    bool preserveQuery = false,
  }) async {
    state = state.copyWith(
      query: preserveQuery ? query ?? state.query : state.query,
      page: 0,
      items: [],
      hasMore: true,
      error: null,
    );
    await _loadPage(reset: true, generation: _nextGeneration());
  }

  Future<void> _loadPage({required bool reset, required int generation}) async {
    try {
      final request = await _fetchPage(reset: reset);
      if (generation != _loadGeneration) return;
      _applyPageResult(reset: reset, request: request);
    } catch (e, st) {
      _logger.error(
        AppLogCategory.provider,
        'History page load failed',
        context: {
          'reset': reset,
          'page': reset ? 0 : state.page + 1,
          'hasQuery': state.query.trim().isNotEmpty,
        },
        error: e,
        stackTrace: st,
      );
      // Only update state for the generation that started this load — ignore
      // stale failures from earlier loads.
      if (generation != _loadGeneration) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<_HistoryPageRequest> _fetchPage({required bool reset}) async {
    final nextPage = reset ? 0 : state.page + 1;
    state = state.copyWith(isLoading: true, error: null);

    final offset = nextPage * _pageSize;
    final q = state.query.trim();
    _logger.debug(
      AppLogCategory.provider,
      'History page load started',
      context: {'reset': reset, 'page': nextPage, 'hasQuery': q.isNotEmpty},
    );

    if (q.isEmpty) {
      final totalCount = await _historyRepository.countHistory();
      final pageEntries = await _historyRepository.getHistoryPage(
        limit: _pageSize,
        offset: offset,
      );
      return _HistoryPageRequest(
        nextPage: nextPage,
        totalCount: totalCount,
        pageEntries: pageEntries,
        queryCount: 2,
        usedFallbackScan: false,
        hasQuery: false,
      );
    }

    final searchPage = await _historyRepository.getHistoryMatchingQueryPage(
      query: q,
      limit: _pageSize,
      offset: offset,
    );
    return _HistoryPageRequest(
      nextPage: nextPage,
      totalCount: searchPage.totalCount,
      pageEntries: searchPage.items,
      queryCount: 2,
      usedFallbackScan: false,
      hasQuery: true,
    );
  }

  void _applyPageResult({
    required bool reset,
    required _HistoryPageRequest request,
  }) {
    final combined = reset
        ? request.pageEntries
        : [...state.items, ...request.pageEntries];
    final hasMore = combined.length < request.totalCount;

    state = state.copyWith(
      items: combined,
      isLoading: false,
      hasMore: hasMore,
      page: request.nextPage,
      debugQueryCount: request.queryCount,
      debugUsedFallbackScan: request.usedFallbackScan,
      hasLoadedOnce: true,
      isStale: false,
    );
    _logger.debug(
      AppLogCategory.provider,
      'History page load completed',
      context: {
        'reset': reset,
        'page': request.nextPage,
        'itemCount': request.pageEntries.length,
        'totalLoaded': combined.length,
        'hasMore': hasMore,
        'hasQuery': request.hasQuery,
      },
    );
  }
}

class _HistoryPageRequest {
  final int nextPage;
  final int totalCount;
  final List<HistoryEntry> pageEntries;
  final int queryCount;
  final bool usedFallbackScan;
  final bool hasQuery;

  const _HistoryPageRequest({
    required this.nextPage,
    required this.totalCount,
    required this.pageEntries,
    required this.queryCount,
    required this.usedFallbackScan,
    required this.hasQuery,
  });
}

final historyPagedProvider =
    NotifierProvider<HistoryPagedNotifier, HistoryPagedState>(
      HistoryPagedNotifier.new,
    );
