import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/history/components/history_item_actions.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/paywall_presenter.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/shared/utils/csv_history_export_service.dart';

import '../../helpers/helpers.dart';
import '../../helpers/lower_level_test_fakes.dart';

class _FakeCsvUtils extends CsvUtils {
  _FakeCsvUtils(super.ref);

  var exportBatchQuoteCalls = 0;

  @override
  Future<void> exportBatchQuote(
    HistoryModel item, {
    required String shareText,
  }) async {
    exportBatchQuoteCalls += 1;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupTest();
  });

  Future<({BuildContext context, WidgetRef ref, AppLogger logger})>
  pumpControllerHarness(WidgetTester tester, List<Override> overrides) async {
    BuildContext? capturedContext;
    WidgetRef? capturedRef;
    AppLogger? capturedLogger;

    await tester.pumpApp(
      Consumer(
        builder: (context, ref, _) {
          capturedContext = context;
          capturedRef = ref;
          capturedLogger = ref.read(appLoggerProvider);
          return const SizedBox.shrink();
        },
      ),
      overrides,
    );
    await tester.pumpAndSettle();

    return (
      context: capturedContext!,
      ref: capturedRef!,
      logger: capturedLogger!,
    );
  }

  testWidgets('free user single-job export succeeds without paywall', (
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

    final controller = HistoryItemActionsController(
      dbKey: '1',
      data: data,
      exportCsv: (items, {required csvHeader, required shareText}) async {
        exportCsvCalled = true;
      },
    );

    final harness = await pumpControllerHarness(tester, [
      paywallPresenterProvider.overrideWithValue(paywallPresenter),
      isPremiumProvider.overrideWithValue(false),
    ]);

    await controller.exportEntry(harness.context, harness.ref, harness.logger);
    await tester.pumpAndSettle();

    expect(paywallPresenter.calls, 0);
    expect(exportCsvCalled, true);
  });

  testWidgets('free user batch export opens paywall and stops action', (
    tester,
  ) async {
    final paywallPresenter = FakePaywallPresenter();
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
    final controller = HistoryItemActionsController(
      dbKey: '2',
      data: data,
      exportCsv: (_, {required csvHeader, required shareText}) async {},
    );

    final harness = await pumpControllerHarness(tester, [
      paywallPresenterProvider.overrideWithValue(paywallPresenter),
      isPremiumProvider.overrideWithValue(false),
      csvUtilsProvider.overrideWith((ref) => _FakeCsvUtils(ref)),
    ]);

    await controller.exportEntry(harness.context, harness.ref, harness.logger);
    await tester.pumpAndSettle();

    expect(paywallPresenter.calls, 1);
    expect(paywallPresenter.lastTriggerFeature, 'batchExport');
  });

  testWidgets('delete action uses injected delete handler', (tester) async {
    var deleteCalls = 0;
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

    final controller = HistoryItemActionsController(
      dbKey: 'delete-1',
      data: data,
      deleteHistoryEntry: (ref, dbKey) async => deleteCalls += 1,
      exportCsv: (_, {required csvHeader, required shareText}) async {},
    );

    final harness = await pumpControllerHarness(tester, const []);

    unawaited(controller.deleteEntry(harness.context, harness.ref));
    await tester.pumpAndSettle();
    await tester.tap(
      find.text(lookupAppLocalizations(const Locale('en')).deleteButton).last,
    );
    await tester.pumpAndSettle();

    expect(deleteCalls, 1);
  });

  testWidgets('load action forwards history entry to calculator', (
    tester,
  ) async {
    final fakeCalculator = FakeCalculatorNotifier();
    var historyLoadedCalls = 0;
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
          dbKey: 'load-1',
          data: data,
          itemKeyPrefix: 'test.load',
          onHistoryLoaded: () async => historyLoadedCalls += 1,
          exportCsv: (_, {required csvHeader, required shareText}) async {},
        ),
      ),
      [calculatorProvider.overrideWith(() => fakeCalculator)],
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('test.load.menu')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.text(lookupAppLocalizations(const Locale('en')).historyLoadAction),
    );
    await tester.pumpAndSettle();

    expect(fakeCalculator.loadFromHistoryCalls, 1);
    expect(fakeCalculator.lastLoadedHistory?.key, 'load-1');
    expect(historyLoadedCalls, 1);
  });

  testWidgets('free user does not see export action for batch quote', (
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

    await tester.tap(
      find.byKey(const ValueKey<String>('test.batch.export.menu')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Export'), findsNothing);
    expect(paywallPresenter.calls, 0);
    expect(exportCsvCalled, false);
  });
}
