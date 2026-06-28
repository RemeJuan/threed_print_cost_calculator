import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:threed_print_cost_calculator/database/repositories/history_repository.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/shared/utils/csv_utils.dart';

import 'history_snapshot_regression_test_support.dart';

void main() {
  late Database db;
  late ProviderContainer container;
  late HistoryRepository historyRepository;
  late CsvUtils csvUtils;
  late StoreRef<String, Map<String, dynamic>> materialsStore;

  setUp(() async {
    db = await openHistorySnapshotDatabase();
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    historyRepository = container.read(historyRepositoryProvider);
    csvUtils = container.read(csvUtilsProvider);
    materialsStore = stringMapStoreFactory.store('materials');
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test(
    'historical_entry_remains_stable_after_material_price_changes',
    () async {
      final single = singleMaterialModel();

      await materialsStore.record('pla-black').put(db, {
        'name': 'PLA Black',
        'cost': '19.99',
        'color': '#000000',
        'weight': '1000',
        'archived': false,
      });

      await historyRepository.saveHistory(single);

      final csvBeforeMutation = await csvForStoredHistory(csvUtils);
      final beforeMutationEntry =
          (await historyRepository.getAllHistory()).single;

      await materialsStore.record('pla-black').put(db, {
        'name': 'PLA Black',
        'cost': '199.99',
        'color': '#000000',
        'weight': '750',
        'archived': false,
      });

      final csvAfterMutation = await csvForStoredHistory(csvUtils);
      final afterMutationEntry =
          (await historyRepository.getAllHistory()).single;

      expectSnapshotValues(beforeMutationEntry.model, single);
      expectSnapshotValues(afterMutationEntry.model, single);
      expect(csvAfterMutation, csvBeforeMutation);
    },
  );

  test(
    'multi_material_and_single_material_follow_same_snapshot_rules',
    () async {
      final single = singleMaterialModel();
      final multi = multiMaterialModel();

      await historyRepository.saveHistory(single);
      await historyRepository.saveHistory(multi);

      final entries = await historyRepository.getAllHistory();
      expect(entries, hasLength(2));
      expectSnapshotValues(entries[0].model, multi);
      expectSnapshotValues(entries[1].model, single);

      final csv = await csvForStoredHistory(csvUtils);
      final lines = csv.split('\n').where((line) => line.isNotEmpty).toList();
      expect(lines, [
        historyCsvHeader,
        expectedCsvRow(multi),
        expectedCsvRow(single),
      ]);
    },
  );
}
