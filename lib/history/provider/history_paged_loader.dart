import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/database/repositories/history_repository.dart';
import 'package:threed_print_cost_calculator/history/model/history_entry.dart';

const int historyPageSize = 25;

class HistoryPagedPageRequest {
  final int nextPage;
  final int totalCount;
  final List<HistoryEntry> pageEntries;
  final bool hasQuery;

  const HistoryPagedPageRequest({
    required this.nextPage,
    required this.totalCount,
    required this.pageEntries,
    required this.hasQuery,
  });
}

Future<HistoryPagedPageRequest> fetchHistoryPagedPage({
  required HistoryRepository repository,
  required AppLogger logger,
  required String query,
  required bool reset,
  required int currentPage,
}) async {
  final nextPage = reset ? 0 : currentPage + 1;
  final offset = nextPage * historyPageSize;
  final q = query.trim();
  logger.debug(
    AppLogCategory.provider,
    'History page load started',
    context: {'reset': reset, 'page': nextPage, 'hasQuery': q.isNotEmpty},
  );

  if (q.isEmpty) {
    final totalCount = await repository.countHistory();
    final pageEntries = await repository.getHistoryPage(
      limit: historyPageSize,
      offset: offset,
    );
    return HistoryPagedPageRequest(
      nextPage: nextPage,
      totalCount: totalCount,
      pageEntries: pageEntries,
      hasQuery: false,
    );
  }

  final searchPage = await repository.getHistoryMatchingQueryPage(
    query: q,
    limit: historyPageSize,
    offset: offset,
  );
  return HistoryPagedPageRequest(
    nextPage: nextPage,
    totalCount: searchPage.totalCount,
    pageEntries: searchPage.items,
    hasQuery: true,
  );
}

void logHistoryPagedLoadFailure({
  required AppLogger logger,
  required Object error,
  required StackTrace stackTrace,
  required bool reset,
  required int page,
  required String query,
}) {
  logger.error(
    AppLogCategory.provider,
    'History page load failed',
    context: {
      'reset': reset,
      'page': page,
      'hasQuery': query.trim().isNotEmpty,
    },
    error: error,
    stackTrace: stackTrace,
  );
}
