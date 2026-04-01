import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:sembast/sembast.dart' as sembast;
import 'package:threed_print_cost_calculator/history/index/history_search_index.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/history/provider/history_paged_notifier.dart';

void main() {
  late Database db;
  late ProviderContainer container;
  final store = stringMapStoreFactory.store('history');

  setUp(() async {
    final name = 'test_paged_${DateTime.now().microsecondsSinceEpoch}.db';
    db = await databaseFactoryMemory.openDatabase(name);

    // Insert 30 Prusa and 25 Ender records (total 55)
    final now = DateTime.now().toUtc().toIso8601String();
    for (var i = 0; i < 30; i++) {
      await store.add(db, {
        'name': 'Prusa Item $i',
        'totalCost': i + 1.0,
        'riskCost': 0.0,
        'filamentCost': 0.0,
        'electricityCost': 0.0,
        'labourCost': 0.0,
        'date': now,
        'printer': 'Prusa',
        'material': 'PLA',
        'weight': 10,
        'timeHours': '01:00',
      });
    }

    for (var i = 0; i < 25; i++) {
      await store.add(db, {
        'name': 'Ender Item $i',
        'totalCost': i + 1.0,
        'riskCost': 0.0,
        'filamentCost': 0.0,
        'electricityCost': 0.0,
        'labourCost': 0.0,
        'date': now,
        'printer': 'Ender',
        'material': 'PETG',
        'weight': 20,
        'timeHours': '02:00',
      });
    }

    // sanity: ensure the expected number of records are present for the test
    final total = await store.count(db);
    expect(total, 55);

    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );

    final indexHelpers = HistorySearchIndexHelpers.fromContainer(container);
    await indexHelpers.backfillSearchFields();
    await indexHelpers.rebuildIndex();
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('loads first page with 25 items by default', () async {
    // refresh to load first page
    await container.read(historyPagedProvider.notifier).refresh();

    final state = container.read(historyPagedProvider);
    expect(state.items.length, 25);
    expect(state.hasMore, isTrue);
    expect(state.page, 0);
  });

  test('loadMore fetches subsequent pages until no more', () async {
    await container.read(historyPagedProvider.notifier).refresh();
    await container
        .read(historyPagedProvider.notifier)
        .loadMore(); // second page
    var state = container.read(historyPagedProvider);
    expect(state.items.length, 50);
    expect(state.hasMore, isTrue);
    expect(state.page, 1);

    await container
        .read(historyPagedProvider.notifier)
        .loadMore(); // third page (remaining 5)
    state = container.read(historyPagedProvider);
    expect(state.items.length, 55);
    expect(state.hasMore, isFalse);
    expect(state.page, 2);
  });

  test(
    'search by printer uses the search index and preserves paging',
    () async {
      await container.read(historyPagedProvider.notifier).setQuery('Prusa');
      var state = container.read(historyPagedProvider);
      expect(state.items.length, 25);
      expect(state.hasMore, isTrue);
      expect(state.debugQueryCount, 2);
      expect(state.debugUsedFallbackScan, isFalse);

      await container.read(historyPagedProvider.notifier).loadMore();
      state = container.read(historyPagedProvider);
      expect(state.items.length, 30);
      expect(state.hasMore, isFalse);
      expect(state.debugQueryCount, 2);
      expect(state.debugUsedFallbackScan, isFalse);

      expect(
        state.items.every((entry) => entry.value['printer'] == 'Prusa'),
        isTrue,
      );
    },
  );

  test('search by name uses the search index', () async {
    await container.read(historyPagedProvider.notifier).setQuery('Item 12');

    final state = container.read(historyPagedProvider);
    expect(state.items.length, 2);
    expect(state.hasMore, isFalse);
    expect(state.debugQueryCount, 2);
    expect(state.debugUsedFallbackScan, isFalse);
    expect(
      state.items.map((entry) => entry.value['name']).toList(),
      containsAll(['Prusa Item 12', 'Ender Item 12']),
    );
  });

  test('mixed-case queries match normalized indexed values', () async {
    await container.read(historyPagedProvider.notifier).setQuery('eNdEr');

    final state = container.read(historyPagedProvider);
    expect(state.items.length, 25);
    expect(state.hasMore, isFalse);
    expect(state.debugQueryCount, 2);
    expect(state.debugUsedFallbackScan, isFalse);
  });

  test(
    'indexed search keeps constant query count for large datasets',
    () async {
      final largeDbName =
          'test_large_paged_${DateTime.now().microsecondsSinceEpoch}.db';
      final largeDb = await databaseFactoryMemory.openDatabase(largeDbName);
      final largeStore = stringMapStoreFactory.store('history');

      for (var i = 0; i < 1200; i++) {
        await largeStore.add(largeDb, {
          'name': 'Prusa Batch $i',
          'totalCost': i + 1.0,
          'riskCost': 0.0,
          'filamentCost': 0.0,
          'electricityCost': 0.0,
          'labourCost': 0.0,
          'date': DateTime.utc(
            2024,
            1,
            1,
          ).add(Duration(minutes: i)).toIso8601String(),
          'printer': i.isEven ? 'Prusa XL' : 'Ender 3',
          'material': i.isEven ? 'PLA' : 'PETG',
          'weight': i,
          'timeHours': '01:00',
        });
      }

      final largeContainer = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(largeDb)],
      );

      try {
        final indexHelpers = HistorySearchIndexHelpers.fromContainer(
          largeContainer,
        );
        await indexHelpers.backfillSearchFields();
        await indexHelpers.rebuildIndex();

        await largeContainer
            .read(historyPagedProvider.notifier)
            .setQuery('Prusa');
        final state = largeContainer.read(historyPagedProvider);
        expect(state.items.length, 25);
        expect(state.hasMore, isTrue);
        expect(state.debugQueryCount, 2);
        expect(state.debugUsedFallbackScan, isFalse);

        final allRecords = await largeStore.find(
          largeDb,
          finder: sembast.Finder(
            sortOrders: [sembast.SortOrder('date', false)],
          ),
        );
        final expectedFirstPage = allRecords
            .where(
              (record) =>
                  (record.value['name']?.toString().toLowerCase() ?? '')
                      .contains('prusa') ||
                  (record.value['printer']?.toString().toLowerCase() ?? '')
                      .contains('prusa'),
            )
            .take(25)
            .map((record) => record.key)
            .toList();

        expect(
          state.items.map((entry) => entry.key).toList(),
          orderedEquals(expectedFirstPage),
        );
      } finally {
        largeContainer.dispose();
        await largeDb.close();
      }
    },
  );

  test('non-index misses do not trigger a full-table fallback scan', () async {
    await container
        .read(historyPagedProvider.notifier)
        .setQuery('NoSuchPrinter');

    final state = container.read(historyPagedProvider);
    expect(state.items, isEmpty);
    expect(state.hasMore, isFalse);
    expect(state.debugQueryCount, 2);
    expect(state.debugUsedFallbackScan, isFalse);
  });

  test(
    'legacy rows become searchable after lazy backfill and rebuild',
    () async {
      final legacyDbName =
          'test_legacy_paged_${DateTime.now().microsecondsSinceEpoch}.db';
      final legacyDb = await databaseFactoryMemory.openDatabase(legacyDbName);
      final legacyStore = stringMapStoreFactory.store('history');

      await legacyStore.add(legacyDb, {
        'name': 'Legacy Gear',
        'totalCost': 1.0,
        'riskCost': 0.0,
        'filamentCost': 0.0,
        'electricityCost': 0.0,
        'labourCost': 0.0,
        'date': DateTime.utc(2024, 1, 1).toIso8601String(),
        'printer': 'Legacy Printer',
        'material': 'PLA',
        'weight': 10,
        'timeHours': '01:00',
      });

      final legacyContainer = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(legacyDb)],
      );

      try {
        await legacyContainer
            .read(historyPagedProvider.notifier)
            .setQuery('legacy');

        final state = legacyContainer.read(historyPagedProvider);
        expect(state.items.length, 1);
        expect(state.items.first.value['name'], 'Legacy Gear');
        expect(state.debugUsedFallbackScan, isFalse);

        final storedRecord = (await legacyStore.find(legacyDb)).single.value;
        expect(storedRecord[kHistorySearchNameField], 'legacy gear');
        expect(storedRecord[kHistorySearchPrinterField], 'legacy printer');
      } finally {
        legacyContainer.dispose();
        await legacyDb.close();
      }
    },
  );
}
