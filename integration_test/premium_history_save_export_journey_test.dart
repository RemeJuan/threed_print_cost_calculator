import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:threed_print_cost_calculator/database/repositories/history_repository.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/history/components/history_export_options_sheet.dart';
import 'package:threed_print_cost_calculator/purchases/paywall_presenter.dart';
import 'package:threed_print_cost_calculator/shared/utils/csv_history_export_service.dart';

import 'helpers/integration_test_harness.dart';
import 'helpers/integration_test_ui.dart';

class _SpyCsvUtils extends CsvUtils {
  _SpyCsvUtils(super.ref);

  int exportMixedHistoryForRangeCalls = 0;
  ExportRange? lastRange;
  List<HistoryModel>? lastHistory;

  @override
  Future<void> exportMixedHistoryForRange(
    ExportRange range, {
    required String shareText,
  }) async {
    exportMixedHistoryForRangeCalls += 1;
    lastRange = range;
    lastHistory = await queryHistory(range);
  }
}

class _CountingPaywallPresenter implements PaywallPresenter {
  var calls = 0;

  @override
  Future<void> present(
    String offeringId, {
    required String triggerFeature,
    required String purchaseSource,
    String defaultEntryPoint = 'manual',
    String source = 'unknown',
    int? launchCount,
  }) async {
    calls += 1;
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('premium user saves history and exports all records', (
    tester,
  ) async {
    const savedName = 'Saved Export Entry';

    final paywallPresenter = _CountingPaywallPresenter();
    late _SpyCsvUtils csvUtils;

    final harness = await IntegrationTestHarness.premium(
      overrides: [
        paywallPresenterProvider.overrideWithValue(paywallPresenter),
        csvUtilsProvider.overrideWith((ref) {
          csvUtils = _SpyCsvUtils(ref);
          return csvUtils;
        }),
      ],
    );
    addTearDown(harness.dispose);

    await tester.launchHarnessApp(harness);
    await tester.tapByKey('nav.calculator.button');

    await tester.tapByKey('calculator.save.open.button');
    await tester.enterTextByKey('calculator.save.name.input', savedName);
    await tester.tapByKey('calculator.save.confirm.button');

    final historyRepository = harness.container.read(historyRepositoryProvider);
    expect(await historyRepository.countHistory(), 1);

    final savedRecord = (await historyRepository.getAllHistory()).single.model;
    expect(savedRecord.name, savedName);
    expect(savedRecord.weight, 0);
    expect(savedRecord.timeHours, '00:00');
    expect(savedRecord.totalCost, 0);
    expect(savedRecord.filamentCost, 0);
    expect(savedRecord.electricityCost, 0);
    expect(savedRecord.labourCost, 0);
    expect(savedRecord.riskCost, 0);

    await tester.tapByKey('nav.history.button');
    expect(find.byKey(historyCardKey(savedName)), findsOneWidget);

    await tester.tapByKey('history.export.button');
    await tester.pumpAndSettle();
    await tester.tap(
      find
          .descendant(
            of: find.byType(HistoryExportOptionsSheet),
            matching: find.byType(ListTile),
          )
          .first,
    );
    await tester.pumpAndSettle();

    expect(csvUtils.exportMixedHistoryForRangeCalls, 1);
    expect(csvUtils.lastRange, ExportRange.all);
    expect(csvUtils.lastHistory, isNotNull);
    expect(csvUtils.lastHistory, hasLength(1));
    expect(csvUtils.lastHistory!.single.name, savedName);
    expect(csvUtils.lastHistory!.single.weight, 0);
    expect(csvUtils.lastHistory!.single.timeHours, '00:00');
    expect(csvUtils.lastHistory!.single.totalCost, 0);
    expect(csvUtils.lastHistory!.single.filamentCost, 0);
    expect(csvUtils.lastHistory!.single.electricityCost, 0);
    expect(csvUtils.lastHistory!.single.labourCost, 0);
    expect(csvUtils.lastHistory!.single.riskCost, 0);
    expect(paywallPresenter.calls, 0);
  });
}
