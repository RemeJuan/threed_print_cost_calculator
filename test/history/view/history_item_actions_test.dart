import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/history/components/history_item_actions.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/purchases/paywall_presenter.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';

import '../../helpers/helpers.dart';
import '../../helpers/lower_level_test_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupTest();
  });

  testWidgets('free user sees paywall when exporting non-batch item', (
    tester,
  ) async {
    final paywallPresenter = FakePaywallPresenter();
    var exportCsvCalled = false;

    final data = HistoryModel(
      name: 'Test Print',
      totalCost: 10.0,
      riskCost: 0,
      filamentCost: 5.0,
      electricityCost: 2.0,
      labourCost: 3.0,
      date: DateTime.now(),
      printer: 'P1',
      material: 'M1',
      weight: 10,
      timeHours: '01:00',
    );

    await tester.pumpApp(
      Scaffold(
        body: HistoryItemActions(
          dbKey: '1',
          data: data,
          itemKeyPrefix: 'test.export',
          exportCsv: (items, {required csvHeader, required shareText}) async {
            exportCsvCalled = true;
          },
        ),
      ),
      [
        paywallPresenterProvider.overrideWithValue(paywallPresenter),
        isPremiumProvider.overrideWithValue(false),
      ],
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('test.export.menu')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Export'));
    await tester.pumpAndSettle();

    expect(paywallPresenter.calls, 1);
    expect(exportCsvCalled, false);
  });

  testWidgets('free user sees paywall when exporting batch quote', (
    tester,
  ) async {
    final paywallPresenter = FakePaywallPresenter();
    var exportCsvCalled = false;

    final data = HistoryModel(
      name: 'Test Batch Quote',
      totalCost: 20.0,
      riskCost: 0,
      filamentCost: 10.0,
      electricityCost: 4.0,
      labourCost: 6.0,
      date: DateTime.now(),
      printer: 'P1',
      material: 'M1',
      weight: 15,
      timeHours: '02:00',
      batchQuote: true,
      batchQuoteItems: const [],
      batchQuoteSummary: const {},
    );

    await tester.pumpApp(
      Scaffold(
        body: HistoryItemActions(
          dbKey: '2',
          data: data,
          itemKeyPrefix: 'test.batch.export',
          exportCsv: (items, {required csvHeader, required shareText}) async {
            exportCsvCalled = true;
          },
        ),
      ),
      [
        paywallPresenterProvider.overrideWithValue(paywallPresenter),
        isPremiumProvider.overrideWithValue(false),
      ],
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('test.batch.export.menu')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Export'));
    await tester.pumpAndSettle();

    expect(paywallPresenter.calls, 1);
    expect(exportCsvCalled, false);
  });
}
