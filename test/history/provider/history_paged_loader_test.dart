import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:sembast/sembast.dart' as sembast;
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/database/repositories/history_repository.dart';
import 'package:threed_print_cost_calculator/history/index/history_search_index.dart';
import 'package:threed_print_cost_calculator/history/provider/history_paged_loader.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

void main() {
  test('fetchHistoryPagedPage uses repository paging semantics', () async {
    final db = await databaseFactoryMemory.openDatabase('loader_page');
    addTearDown(db.close);
    final store = stringMapStoreFactory.store('history');
    await store.add(db, {
      'name': 'A',
      'totalCost': 1,
      'riskCost': 0,
      'filamentCost': 0,
      'electricityCost': 0,
      'labourCost': 0,
      'date': DateTime.utc(2024).toIso8601String(),
      'printer': 'p',
      'material': 'm',
      'weight': 1,
      'timeHours': '01:00',
    });

    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    final repo = container.read(historyRepositoryProvider);
    final logger = AppLogger(
      sink: const _NoopSink(),
      config: const AppLoggerConfig(minLevel: AppLogLevel.error),
    );

    final page = await fetchHistoryPagedPage(
      repository: repo,
      logger: logger,
      query: '',
      reset: true,
      currentPage: 0,
    );

    expect(page.nextPage, 0);
    expect(page.totalCount, 1);
    expect(page.pageEntries.single.model.name, 'A');
    expect(page.hasQuery, isFalse);
  });

  test('fetchHistoryPagedPage uses query paging semantics', () async {
    final db = await databaseFactoryMemory.openDatabase('loader_query');
    addTearDown(db.close);
    final store = stringMapStoreFactory.store('history');
    for (var i = 0; i < 26; i++) {
      await store.add(db, {
        'name': 'Needle $i',
        'totalCost': 1,
        'riskCost': 0,
        'filamentCost': 0,
        'electricityCost': 0,
        'labourCost': 0,
        'date': DateTime.utc(2024).add(Duration(minutes: i)).toIso8601String(),
        'printer': 'p',
        'material': 'm',
        'weight': 1,
        'timeHours': '01:00',
      });
    }

    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    final indexHelpers = HistorySearchIndexHelpers.fromContainer(container);
    await indexHelpers.backfillSearchFields();
    await indexHelpers.rebuildIndex();
    final repo = container.read(historyRepositoryProvider);
    final logger = AppLogger(
      sink: const _NoopSink(),
      config: const AppLoggerConfig(minLevel: AppLogLevel.error),
    );

    final page = await fetchHistoryPagedPage(
      repository: repo,
      logger: logger,
      query: 'needle',
      reset: false,
      currentPage: 0,
    );

    expect(page.nextPage, 1);
    expect(page.totalCount, 26);
    expect(page.pageEntries.length, 1);
    expect(page.hasQuery, isTrue);
  });
}

class _NoopSink extends AppLogSink {
  const _NoopSink();

  @override
  void log(AppLogEvent event) {}
}
