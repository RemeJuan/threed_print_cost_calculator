import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:threed_print_cost_calculator/database/repositories/history_repository.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/shared/utils/csv_utils.dart';

void main() {
  const historyCsvHeader =
      'Date,Printer,Material,Materials,Weight (g),Time,Electricity,Filament,Labour,Risk,Total';

  late Database db;
  late ProviderContainer container;
  late HistoryRepository historyRepository;
  late CsvUtils csvUtils;
  late StoreRef<Object?, Map<String, dynamic>> historyStore;
  late StoreRef<String, Map<String, dynamic>> materialsStore;

  setUp(() async {
    db = await databaseFactoryMemory.openDatabase(
      'history_snapshot_${DateTime.now().microsecondsSinceEpoch}.db',
    );
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    historyRepository = container.read(historyRepositoryProvider);
    csvUtils = container.read(csvUtilsProvider);
    historyStore = StoreRef<Object?, Map<String, dynamic>>('history');
    materialsStore = stringMapStoreFactory.store('materials');
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  HistoryModel singleMaterialModel() {
    return HistoryModel(
      name: 'Single snapshot',
      totalCost: 14.11,
      riskCost: 1.41,
      filamentCost: 8.19,
      electricityCost: 1.23,
      labourCost: 3.28,
      date: DateTime.parse('2024-01-02T03:04:05.000Z'),
      printer: 'Prusa MK4',
      material: 'PLA Black',
      weight: 123,
      materialUsages: const [
        {
          'materialId': 'pla-black',
          'materialName': 'PLA Black',
          'costPerKg': 66.58536585365853,
          'weightGrams': 123,
        },
      ],
      timeHours: '01:45',
    );
  }

  HistoryModel multiMaterialModel() {
    return HistoryModel(
      name: 'Multi snapshot',
      totalCost: 21.17,
      riskCost: 2.12,
      filamentCost: 12.47,
      electricityCost: 1.85,
      labourCost: 4.73,
      date: DateTime.parse('2024-01-03T04:05:06.000Z'),
      printer: 'Bambu Lab A1',
      material: 'PLA Black +1',
      weight: 155,
      materialUsages: const [
        {
          'materialId': 'pla-black',
          'materialName': 'PLA Black',
          'costPerKg': 60,
          'weightGrams': 100,
        },
        {
          'materialId': 'pla-white',
          'materialName': 'PLA White',
          'costPerKg': 117.63636363636364,
          'weightGrams': 55,
        },
      ],
      timeHours: '02:10',
    );
  }

  Future<Map<String, dynamic>> rawHistoryRecord(Object? key) async {
    return (await historyStore.record(key).get(db))!;
  }

  void expectSnapshotValues(HistoryModel actual, HistoryModel expected) {
    expect(actual.totalCost, expected.totalCost);
    expect(actual.electricityCost, expected.electricityCost);
    expect(actual.filamentCost, expected.filamentCost);
    expect(actual.labourCost, expected.labourCost);
    expect(actual.riskCost, expected.riskCost);
    expect(actual.weight, expected.weight);
    expect(actual.timeHours, expected.timeHours);
    expect(actual.materialUsages, expected.materialUsages);
  }

  String expectedCsvRow(HistoryModel item) {
    final materials = item.materialUsages
        .map((usage) => '${usage['materialName']}:${usage['weightGrams']}g')
        .join('; ');
    return '"${item.date.toIso8601String()}",'
        '"${item.printer}",'
        '"${item.material}",'
        '"$materials",'
        '"${item.weight}",'
        '"${item.timeHours}",'
        '"${item.electricityCost}",'
        '"${item.filamentCost}",'
        '"${item.labourCost}",'
        '"${item.riskCost}",'
        '"${item.totalCost}"';
  }

  Future<String> csvForStoredHistory() async {
    final items = await csvUtils.queryHistory(ExportRange.all);
    return csvUtils.generateCsvForItems(items, historyCsvHeader);
  }

  group('History snapshot regression', () {
    test(
      'save snapshot integrity persists raw single and multi material values',
      () async {
        final single = singleMaterialModel();
        final multi = multiMaterialModel();

        final singleKey = await historyRepository.saveHistory(single);
        final multiKey = await historyRepository.saveHistory(multi);

        final rawSingle = await rawHistoryRecord(singleKey!);
        final rawMulti = await rawHistoryRecord(multiKey!);

        expect(rawSingle['totalCost'], single.totalCost);
        expect(rawSingle['electricityCost'], single.electricityCost);
        expect(rawSingle['filamentCost'], single.filamentCost);
        expect(rawSingle['labourCost'], single.labourCost);
        expect(rawSingle['riskCost'], single.riskCost);
        expect(rawSingle['weight'], single.weight);
        expect(rawSingle['timeHours'], single.timeHours);
        expect(rawSingle['materialUsages'], single.materialUsages);

        expect(rawMulti['totalCost'], multi.totalCost);
        expect(rawMulti['electricityCost'], multi.electricityCost);
        expect(rawMulti['filamentCost'], multi.filamentCost);
        expect(rawMulti['labourCost'], multi.labourCost);
        expect(rawMulti['riskCost'], multi.riskCost);
        expect(rawMulti['weight'], multi.weight);
        expect(rawMulti['timeHours'], multi.timeHours);
        expect(rawMulti['materialUsages'], multi.materialUsages);
      },
    );

    test(
      'rehydrates_single_material_history_without_recomputing_filament_cost',
      () async {
        final single = singleMaterialModel();

        await historyRepository.saveHistory(single);

        final entry = (await historyRepository.getAllHistory()).single;
        expectSnapshotValues(entry.model, single);
      },
    );

    test(
      'rehydrates_multi_material_history_without_recomputing_filament_cost',
      () async {
        final multi = multiMaterialModel();

        await historyRepository.saveHistory(multi);

        final entry = (await historyRepository.getAllHistory()).single;
        expectSnapshotValues(entry.model, multi);
      },
    );

    test(
      'exports_single_material_history_using_stored_snapshot_values',
      () async {
        final single = singleMaterialModel();

        await historyRepository.saveHistory(single);

        final csv = await csvForStoredHistory();
        final lines = csv.split('\n').where((line) => line.isNotEmpty).toList();

        expect(lines, [historyCsvHeader, expectedCsvRow(single)]);
      },
    );

    test(
      'exports_multi_material_history_using_stored_snapshot_values',
      () async {
        final multi = multiMaterialModel();

        await historyRepository.saveHistory(multi);

        final csv = await csvForStoredHistory();
        final lines = csv.split('\n').where((line) => line.isNotEmpty).toList();

        expect(lines, [historyCsvHeader, expectedCsvRow(multi)]);
      },
    );

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

        final csvBeforeMutation = await csvForStoredHistory();
        final beforeMutationEntry =
            (await historyRepository.getAllHistory()).single;

        await materialsStore.record('pla-black').put(db, {
          'name': 'PLA Black',
          'cost': '199.99',
          'color': '#000000',
          'weight': '750',
          'archived': false,
        });

        final csvAfterMutation = await csvForStoredHistory();
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

        final csv = await csvForStoredHistory();
        final lines = csv.split('\n').where((line) => line.isNotEmpty).toList();
        expect(lines, [
          historyCsvHeader,
          expectedCsvRow(multi),
          expectedCsvRow(single),
        ]);
      },
    );
  });
}
