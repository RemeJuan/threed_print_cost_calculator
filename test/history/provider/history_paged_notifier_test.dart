import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:sembast/sembast_memory.dart';
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

  test('setQuery resets paging and filters by printer', () async {
    // Set query to 'Prusa' should return up to 25 (of 30) and hasMore true
    await container.read(historyPagedProvider.notifier).setQuery('Prusa');
    var state = container.read(historyPagedProvider);
    expect(state.items.length, 25);
    expect(state.hasMore, isTrue);

    // load remaining 5
    await container.read(historyPagedProvider.notifier).loadMore();
    state = container.read(historyPagedProvider);
    expect(state.items.length, 30);
    expect(state.hasMore, isFalse);

    // Now search for 'Ender' expect 25 results (only 25 exist) and hasMore false
    await container.read(historyPagedProvider.notifier).setQuery('Ender');
    state = container.read(historyPagedProvider);
    expect(state.items.length, 25);
    expect(state.hasMore, isFalse);
  });
}
