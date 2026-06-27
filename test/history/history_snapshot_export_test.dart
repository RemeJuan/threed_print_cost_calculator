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

  setUp(() async {
    db = await openHistorySnapshotDatabase();
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    historyRepository = container.read(historyRepositoryProvider);
    csvUtils = container.read(csvUtilsProvider);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test(
    'exports_single_material_history_using_stored_snapshot_values',
    () async {
      final single = singleMaterialModel();

      await historyRepository.saveHistory(single);

      final csv = await csvForStoredHistory(csvUtils);
      final lines = csv.split('\n').where((line) => line.isNotEmpty).toList();

      expect(lines, [historyCsvHeader, expectedCsvRow(single)]);
    },
  );

  test(
    'exports_single_material_history_with_pricing_snapshot_values',
    () async {
      final single = singleMaterialModel();

      await historyRepository.saveHistory(single);

      final csv = await csvForStoredHistory(csvUtils);
      final lines = csv.split('\n').where((line) => line.isNotEmpty).toList();

      expect(lines, [historyCsvHeader, expectedCsvRow(single)]);
    },
  );

  test('exports_multi_material_history_using_stored_snapshot_values', () async {
    final multi = multiMaterialModel();

    await historyRepository.saveHistory(multi);

    final csv = await csvForStoredHistory(csvUtils);
    final lines = csv.split('\n').where((line) => line.isNotEmpty).toList();

    expect(lines, [historyCsvHeader, expectedCsvRow(multi)]);
  });
}
