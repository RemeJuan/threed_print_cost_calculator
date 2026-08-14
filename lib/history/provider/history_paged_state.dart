import 'package:threed_print_cost_calculator/history/model/history_entry.dart';

class HistoryPagedState {
  static const Object _errorSentinel = Object();

  final List<HistoryEntry> items;
  final bool hasMore;
  final bool isLoading;
  final String? error;
  final String query;
  final int page;
  final bool hasLoadedOnce;
  final bool isStale;

  const HistoryPagedState({
    required this.items,
    required this.hasMore,
    required this.isLoading,
    this.error,
    required this.query,
    required this.page,
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
    hasLoadedOnce: false,
    isStale: false,
  );

  HistoryPagedState copyWith({
    List<HistoryEntry>? items,
    bool? hasMore,
    bool? isLoading,
    Object? error = _errorSentinel,
    String? query,
    int? page,
    bool? hasLoadedOnce,
    bool? isStale,
  }) {
    final nextError = identical(error, _errorSentinel)
        ? this.error
        : error as String?;
    return HistoryPagedState(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      error: nextError,
      query: query ?? this.query,
      page: page ?? this.page,
      hasLoadedOnce: hasLoadedOnce ?? this.hasLoadedOnce,
      isStale: isStale ?? this.isStale,
    );
  }

  bool get shouldRefreshOnMount => !isLoading && (!hasLoadedOnce || isStale);

  HistoryPagedState markStale() => copyWith(isStale: true);

  HistoryPagedState prepareForReset({String? query}) {
    return copyWith(
      query: query ?? this.query,
      page: 0,
      items: <HistoryEntry>[],
      hasMore: true,
      error: null,
    );
  }

  HistoryPagedState startLoading() => copyWith(isLoading: true, error: null);

  HistoryPagedState applyPageResult({
    required bool reset,
    required List<HistoryEntry> pageEntries,
    required int totalCount,
    required int nextPage,
  }) {
    final combined = reset ? pageEntries : [...items, ...pageEntries];
    return copyWith(
      items: combined,
      isLoading: false,
      hasMore: combined.length < totalCount,
      page: nextPage,
      hasLoadedOnce: true,
      isStale: false,
    );
  }

  HistoryPagedState fail(Object error) =>
      copyWith(isLoading: false, error: error.toString());
}
