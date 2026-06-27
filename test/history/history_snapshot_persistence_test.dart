import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:threed_print_cost_calculator/database/repositories/history_repository.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

import 'history_snapshot_regression_test_support.dart';

void main() {
  late Database db;
  late ProviderContainer container;
  late HistoryRepository historyRepository;
  late StoreRef<Object?, Map<String, dynamic>> historyStore;

  setUp(() async {
    db = await openHistorySnapshotDatabase();
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    historyRepository = container.read(historyRepositoryProvider);
    historyStore = StoreRef<Object?, Map<String, dynamic>>('history');
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test(
    'save snapshot integrity persists raw single and multi material values',
    () async {
      final single = singleMaterialModel();
      final multi = multiMaterialModel();

      final singleKey = await historyRepository.saveHistory(single);
      final multiKey = await historyRepository.saveHistory(multi);

      final rawSingle = await rawHistoryRecord(historyStore, db, singleKey!);
      final rawMulti = await rawHistoryRecord(historyStore, db, multiKey!);

      expect(rawSingle['totalCost'], single.totalCost);
      expect(rawSingle['electricityCost'], single.electricityCost);
      expect(rawSingle['filamentCost'], single.filamentCost);
      expect(rawSingle['labourCost'], single.labourCost);
      expect(rawSingle['riskCost'], single.riskCost);
      expect(rawSingle['weight'], single.weight);
      expect(rawSingle['timeHours'], single.timeHours);
      expect(rawSingle['materialUsages'], single.materialUsages);
      expect(rawSingle['pricingMarkupPercent'], single.pricingMarkupPercent);
      expect(rawSingle['pricingMarkupAmount'], single.pricingMarkupAmount);
      expect(rawSingle['pricingSetupFee'], single.pricingSetupFee);
      expect(rawSingle['pricingRoundingMode'], single.pricingRoundingMode);
      expect(
        rawSingle['pricingSubtotalBeforeRounding'],
        single.pricingSubtotalBeforeRounding,
      );
      expect(
        rawSingle['pricingRoundingAdjustment'],
        single.pricingRoundingAdjustment,
      );
      expect(rawSingle['finalPrice'], single.finalPrice);
      expect(rawSingle['pricingUsedOverrides'], single.pricingUsedOverrides);

      expect(rawMulti['totalCost'], multi.totalCost);
      expect(rawMulti['electricityCost'], multi.electricityCost);
      expect(rawMulti['filamentCost'], multi.filamentCost);
      expect(rawMulti['labourCost'], multi.labourCost);
      expect(rawMulti['riskCost'], multi.riskCost);
      expect(rawMulti['weight'], multi.weight);
      expect(rawMulti['timeHours'], multi.timeHours);
      expect(rawMulti['materialUsages'], multi.materialUsages);
      expect(rawMulti['pricingMarkupPercent'], isNull);
      expect(rawMulti['pricingMarkupAmount'], isNull);
      expect(rawMulti['pricingSetupFee'], isNull);
      expect(rawMulti['pricingRoundingMode'], isNull);
      expect(rawMulti['pricingSubtotalBeforeRounding'], isNull);
      expect(rawMulti['pricingRoundingAdjustment'], isNull);
      expect(rawMulti['finalPrice'], isNull);
      expect(rawMulti['pricingUsedOverrides'], isNull);
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
    'rehydrates_single_material_history_with_pricing_snapshot_values',
    () async {
      final single = singleMaterialModel();

      await historyRepository.saveHistory(single);

      final entry = (await historyRepository.getAllHistory()).single;
      expect(entry.model.pricingMarkupPercent, single.pricingMarkupPercent);
      expect(entry.model.pricingMarkupAmount, single.pricingMarkupAmount);
      expect(entry.model.pricingSetupFee, single.pricingSetupFee);
      expect(entry.model.pricingRoundingMode, single.pricingRoundingMode);
      expect(
        entry.model.pricingSubtotalBeforeRounding,
        single.pricingSubtotalBeforeRounding,
      );
      expect(
        entry.model.pricingRoundingAdjustment,
        single.pricingRoundingAdjustment,
      );
      expect(entry.model.finalPrice, single.finalPrice);
      expect(entry.model.pricingUsedOverrides, single.pricingUsedOverrides);
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
}
