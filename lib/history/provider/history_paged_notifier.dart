import 'package:riverpod/riverpod.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/database/repositories/history_repository.dart';
import 'package:threed_print_cost_calculator/history/provider/history_paged_loader.dart';
import 'package:threed_print_cost_calculator/history/provider/history_paged_state.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

export 'history_paged_state.dart';

// Notifier that manages paged history loading and query changes.
class HistoryPagedNotifier extends Notifier<HistoryPagedState> {
  int _loadGeneration = 0;

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
    state = state.markStale();
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
    state = state.prepareForReset(
      query: preserveQuery ? query ?? state.query : state.query,
    );
    await _loadPage(reset: true, generation: _nextGeneration());
  }

  Future<void> _loadPage({required bool reset, required int generation}) async {
    try {
      state = state.startLoading();
      final request = await fetchHistoryPagedPage(
        repository: _historyRepository,
        logger: _logger,
        query: state.query,
        reset: reset,
        currentPage: state.page,
      );
      if (generation != _loadGeneration) return;
      _applyPageResult(reset: reset, request: request);
    } catch (e, st) {
      logHistoryPagedLoadFailure(
        logger: _logger,
        error: e,
        stackTrace: st,
        reset: reset,
        page: reset ? 0 : state.page + 1,
        query: state.query,
      );
      if (generation != _loadGeneration) return;
      state = state.fail(e);
    }
  }

  void _applyPageResult({
    required bool reset,
    required HistoryPagedPageRequest request,
  }) {
    final combined = reset
        ? request.pageEntries
        : [...state.items, ...request.pageEntries];
    final hasMore = combined.length < request.totalCount;
    state = state.applyPageResult(
      reset: reset,
      pageEntries: request.pageEntries,
      totalCount: request.totalCount,
      nextPage: request.nextPage,
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

final historyPagedProvider =
    NotifierProvider<HistoryPagedNotifier, HistoryPagedState>(
      HistoryPagedNotifier.new,
    );
