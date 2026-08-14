import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:threed_print_cost_calculator/batch_costing/batch_summary_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/helpers/batch_quote_save_service.dart';
import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_costing_state.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_pricing_state.dart';
import 'package:threed_print_cost_calculator/app/app_page_shell_config.dart';
import 'package:threed_print_cost_calculator/core/analytics/analytics_service.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/database/repositories/history_repository.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/premium_local_store.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/shared/services/app_usage_service.dart';

import '../../helpers/helpers.dart';

class _CapturingLogSink extends AppLogSink {
  final List<AppLogEvent> events = [];

  @override
  void log(AppLogEvent event) {
    events.add(event);
  }
}

class _CapturingAnalyticsService implements AnalyticsService {
  String? lastName;
  Map<String, Object>? lastParams;
  final events = <String>[];

  @override
  Future<void> logEvent(String name, {Map<String, Object>? params}) async {
    lastName = name;
    lastParams = params;
    events.add(name);
  }
}

class _CapturingUsageService extends AppUsageService {
  _CapturingUsageService(super.ref);

  @override
  var completedCostingCount = 0;

  @override
  Future<void> recordCompletedCosting() async {
    completedCostingCount += 1;
  }
}

class _ThrowingUsageService extends AppUsageService {
  _ThrowingUsageService(super.ref);

  @override
  Future<void> recordCompletedCosting() async {
    throw Exception('Simulated usage failure');
  }
}

class _DelayedHistoryRepository extends HistoryRepository {
  _DelayedHistoryRepository(super.ref);

  HistoryModel? savedModel;
  final completer = Completer<void>();

  @override
  Future<Object?> saveHistory(HistoryModel model) async {
    savedModel = model;
    await completer.future;
    return 1;
  }
}

class _CapturingHistoryRepository extends HistoryRepository {
  _CapturingHistoryRepository(super.ref);

  HistoryModel? savedModel;

  @override
  Future<Object?> saveHistory(HistoryModel model) async {
    savedModel = model;
    return 1;
  }
}

class _ThrowingHistoryRepository extends HistoryRepository {
  _ThrowingHistoryRepository(super.ref);

  @override
  Future<Object?> saveHistory(HistoryModel model) {
    throw Exception('Simulated save failure');
  }
}

class _SaveBatchNotifier extends BatchCostingNotifier {
  @override
  BatchCostingState build() {
    return BatchCostingState(
      items: [
        BatchCostingItem.manual(
          id: 'item-1',
          displayName: 'Test Item',
          quantity: 2,
          printWeightG: 10,
          printDuration: const Duration(hours: 1),
        ),
      ],
      pricing: const BatchPricingState(
        labourRate: BatchPricingFieldState(
          value: '10',
          scope: BatchPricingScope.item,
        ),
        additionalCostAmount: BatchPricingFieldState(
          value: '5',
          scope: BatchPricingScope.batch,
        ),
        markupPercent: BatchPricingFieldState(
          value: '10',
          scope: BatchPricingScope.item,
        ),
      ),
    );
  }
}

void main() {
  setUpAll(setupTest);
  late AnalyticsService originalAnalytics;
  late _CapturingAnalyticsService analytics;

  setUp(() {
    originalAnalytics = AppAnalytics.service;
  });

  group('BatchQuoteSaveService provider wiring', () {
    test('batchQuoteSaveServiceProvider resolves', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final service = container.read(batchQuoteSaveServiceProvider);

      expect(service, isA<BatchQuoteSaveService>());
    });
  });

  group('saveBatchQuote success path', () {
    testWidgets('shows save button with items', (tester) async {
      await tester.pumpApp(const BatchSummaryPage(), [
        batchCostingProvider.overrideWith(() => _SaveBatchNotifier()),
        isPremiumProvider.overrideWithValue(true),
      ]);

      final l10n = AppLocalizations.of(
        tester.element(find.byType(BatchSummaryPage)),
      )!;

      await tester.scrollUntilVisible(
        find.text(l10n.batchCostingSummarySaveButton),
        200,
      );
      await tester.pumpAndSettle();

      expect(find.text(l10n.batchCostingSummarySaveButton), findsOneWidget);
    });

    testWidgets('cancelling quote dialog blocks save flow', (tester) async {
      final sink = _CapturingLogSink();
      final premiumLocalStore = InMemoryPremiumLocalStore();
      analytics = _CapturingAnalyticsService();
      AppAnalytics.service = analytics;
      addTearDown(() => AppAnalytics.service = originalAnalytics);
      final container = await tester.pumpAppWithContainer(
        const BatchSummaryPage(),
        overrides: [
          batchCostingProvider.overrideWith(() => _SaveBatchNotifier()),
          isPremiumProvider.overrideWithValue(true),
          appLogSinkProvider.overrideWithValue(sink),
          appLoggerConfigProvider.overrideWithValue(
            const AppLoggerConfig(minLevel: AppLogLevel.debug),
          ),
          appUsageServiceProvider.overrideWith(
            (ref) => _CapturingUsageService(ref),
          ),
        ],
        premiumLocalStore: premiumLocalStore,
      );
      final usage =
          container.read(appUsageServiceProvider) as _CapturingUsageService;
      final l10n = AppLocalizations.of(
        tester.element(find.byType(BatchSummaryPage)),
      )!;

      await tester.scrollUntilVisible(
        find.text(l10n.batchCostingSummarySaveButton),
        200,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.batchCostingSummarySaveButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.cancelButton));
      await tester.pumpAndSettle();

      expect(usage.completedCostingCount, 0);
      expect(
        analytics.events.where((event) => event == 'batch_quote_saved'),
        isEmpty,
      );
      expect(find.text(l10n.batchCostingSummarySaveSuccessTitle), findsNothing);
      expect(container.read(pendingTabNavigationProvider), isNull);
      expect(sink.events, isEmpty);
    });

    testWidgets('saves history and shows success dialog', (tester) async {
      final sink = _CapturingLogSink();
      final premiumLocalStore = InMemoryPremiumLocalStore();
      analytics = _CapturingAnalyticsService();
      AppAnalytics.service = analytics;
      addTearDown(() => AppAnalytics.service = originalAnalytics);
      final container = await tester.pumpAppWithContainer(
        const BatchSummaryPage(),
        overrides: [
          batchCostingProvider.overrideWith(() => _SaveBatchNotifier()),
          isPremiumProvider.overrideWithValue(true),
          appLogSinkProvider.overrideWithValue(sink),
          appLoggerConfigProvider.overrideWithValue(
            const AppLoggerConfig(minLevel: AppLogLevel.debug),
          ),
          appUsageServiceProvider.overrideWith(
            (ref) => _CapturingUsageService(ref),
          ),
          historyRepositoryProvider.overrideWith(
            (ref) => _CapturingHistoryRepository(ref),
          ),
        ],
        premiumLocalStore: premiumLocalStore,
      );
      final usage =
          container.read(appUsageServiceProvider) as _CapturingUsageService;
      final repo =
          container.read(historyRepositoryProvider)
              as _CapturingHistoryRepository;

      final l10n = AppLocalizations.of(
        tester.element(find.byType(BatchSummaryPage)),
      )!;

      await tester.scrollUntilVisible(
        find.text(l10n.batchCostingSummarySaveButton),
        200,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.batchCostingSummarySaveButton));
      await tester.pumpAndSettle();

      expect(
        find.text(l10n.batchCostingSummaryQuoteNameDialogTitle),
        findsOneWidget,
      );

      final textField = find.widgetWithText(
        TextField,
        l10n.batchCostingSummaryDefaultQuoteName,
      );
      await tester.enterText(textField, 'My Batch Quote');
      await tester.tap(find.text(l10n.saveButton));
      await tester.pumpAndSettle();

      expect(
        find.text(l10n.batchCostingSummarySaveSuccessTitle),
        findsOneWidget,
      );
      expect(usage.completedCostingCount, 1);
      expect(analytics.lastName, 'batch_quote_saved');
      expect(analytics.lastParams?['outcome'], 'success');
      expect(repo.savedModel, isNotNull);
      expect(repo.savedModel!.name, 'My Batch Quote');
      expect(repo.savedModel!.batchQuoteItems.length, 1);
      expect(repo.savedModel!.batchQuoteSummary?['itemCount'], 1);
      expect(repo.savedModel!.batchQuoteSummary?['totalQuantity'], 2);
      expect(repo.savedModel!.batchQuoteSummary?['finalTotal'], greaterThan(0));
      await tester.tap(find.text(l10n.batchCostingSummaryViewHistoryButton));
      await tester.pumpAndSettle();

      expect(container.read(pendingTabNavigationProvider), AppPageTab.history);
    });

    testWidgets('return to calculator closes success dialog', (tester) async {
      final sink = _CapturingLogSink();
      final premiumLocalStore = InMemoryPremiumLocalStore();
      analytics = _CapturingAnalyticsService();
      AppAnalytics.service = analytics;
      addTearDown(() => AppAnalytics.service = originalAnalytics);
      await tester.pumpAppWithContainer(
        const BatchSummaryPage(),
        overrides: [
          batchCostingProvider.overrideWith(() => _SaveBatchNotifier()),
          isPremiumProvider.overrideWithValue(true),
          appLogSinkProvider.overrideWithValue(sink),
          appLoggerConfigProvider.overrideWithValue(
            const AppLoggerConfig(minLevel: AppLogLevel.debug),
          ),
          appUsageServiceProvider.overrideWith(
            (ref) => _CapturingUsageService(ref),
          ),
        ],
        premiumLocalStore: premiumLocalStore,
      );
      final l10n = AppLocalizations.of(
        tester.element(find.byType(BatchSummaryPage)),
      )!;

      await tester.scrollUntilVisible(
        find.text(l10n.batchCostingSummarySaveButton),
        200,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.batchCostingSummarySaveButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.saveButton));
      await tester.pumpAndSettle();
      await tester.tap(
        find.text(l10n.batchCostingSummaryReturnToCalculatorButton).last,
      );
      await tester.pumpAndSettle();

      expect(find.text(l10n.batchCostingSummarySaveSuccessTitle), findsNothing);
    });

    testWidgets(
      'keeps save effects when unmounted before async save completes',
      (tester) async {
        final sink = _CapturingLogSink();
        final premiumLocalStore = InMemoryPremiumLocalStore();
        analytics = _CapturingAnalyticsService();
        AppAnalytics.service = analytics;
        addTearDown(() => AppAnalytics.service = originalAnalytics);
        final container = await tester.pumpAppWithContainer(
          const BatchSummaryPage(),
          overrides: [
            batchCostingProvider.overrideWith(() => _SaveBatchNotifier()),
            isPremiumProvider.overrideWithValue(true),
            appLogSinkProvider.overrideWithValue(sink),
            appLoggerConfigProvider.overrideWithValue(
              const AppLoggerConfig(minLevel: AppLogLevel.debug),
            ),
            appUsageServiceProvider.overrideWith(
              (ref) => _CapturingUsageService(ref),
            ),
            historyRepositoryProvider.overrideWith(
              (ref) => _DelayedHistoryRepository(ref),
            ),
          ],
          premiumLocalStore: premiumLocalStore,
        );
        final usage =
            container.read(appUsageServiceProvider) as _CapturingUsageService;
        final repo =
            container.read(historyRepositoryProvider)
                as _DelayedHistoryRepository;

        final l10n = AppLocalizations.of(
          tester.element(find.byType(BatchSummaryPage)),
        )!;

        await tester.scrollUntilVisible(
          find.text(l10n.batchCostingSummarySaveButton),
          200,
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text(l10n.batchCostingSummarySaveButton));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.widgetWithText(
            TextField,
            l10n.batchCostingSummaryDefaultQuoteName,
          ),
          'My Batch Quote',
        );
        await tester.tap(find.text(l10n.saveButton));
        await tester.pump();

        await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
        repo.completer.complete();
        await tester.pumpAndSettle();

        expect(repo.savedModel, isNotNull);
        expect(usage.completedCostingCount, 1);
        expect(analytics.lastName, 'batch_quote_saved');
        expect(
          find.text(l10n.batchCostingSummarySaveSuccessTitle),
          findsNothing,
        );
        expect(
          sink.events.any((e) => e.category == AppLogCategory.db),
          isFalse,
        );
      },
    );

    testWidgets('resets batch on start new batch confirmation', (tester) async {
      final sink = _CapturingLogSink();
      final container = await tester.pumpAppWithContainer(
        const BatchSummaryPage(),
        overrides: [
          batchCostingProvider.overrideWith(() => _SaveBatchNotifier()),
          isPremiumProvider.overrideWithValue(true),
          appLogSinkProvider.overrideWithValue(sink),
          appLoggerConfigProvider.overrideWithValue(
            const AppLoggerConfig(minLevel: AppLogLevel.debug),
          ),
        ],
      );

      final l10n = AppLocalizations.of(
        tester.element(find.byType(BatchSummaryPage)),
      )!;

      await tester.scrollUntilVisible(
        find.text(l10n.batchCostingSummarySaveButton),
        200,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.batchCostingSummarySaveButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.saveButton));
      await tester.pumpAndSettle();
      await tester.tap(
        find.text(l10n.batchCostingSummaryStartNewBatchButton).at(1),
      );
      await tester.pumpAndSettle();

      expect(find.text(l10n.batchCostingNewBatchDialogTitle), findsWidgets);
      expect(container.read(batchCostingProvider).items, isNotEmpty);

      await tester.tap(
        find
            .text(
              l10n.batchCostingSummaryStartNewBatchButton,
              skipOffstage: false,
            )
            .last,
      );
      await tester.pumpAndSettle();

      expect(container.read(batchCostingProvider).items, isEmpty);
    });
  });

  group('saveBatchQuote failure path', () {
    testWidgets('shows error toast when repository save fails', (tester) async {
      final sink = _CapturingLogSink();
      final premiumLocalStore = InMemoryPremiumLocalStore();
      analytics = _CapturingAnalyticsService();
      AppAnalytics.service = analytics;
      addTearDown(() => AppAnalytics.service = originalAnalytics);
      final container = await tester.pumpAppWithContainer(
        const BatchSummaryPage(),
        overrides: [
          batchCostingProvider.overrideWith(() => _SaveBatchNotifier()),
          isPremiumProvider.overrideWithValue(true),
          appLogSinkProvider.overrideWithValue(sink),
          appLoggerConfigProvider.overrideWithValue(
            const AppLoggerConfig(minLevel: AppLogLevel.debug),
          ),
          appUsageServiceProvider.overrideWith(
            (ref) => _CapturingUsageService(ref),
          ),
          historyRepositoryProvider.overrideWith(
            (ref) => _ThrowingHistoryRepository(ref),
          ),
        ],
        premiumLocalStore: premiumLocalStore,
      );
      final usage =
          container.read(appUsageServiceProvider) as _CapturingUsageService;

      final l10n = AppLocalizations.of(
        tester.element(find.byType(BatchSummaryPage)),
      )!;

      await tester.scrollUntilVisible(
        find.text(l10n.batchCostingSummarySaveButton),
        200,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.batchCostingSummarySaveButton));
      await tester.pumpAndSettle();
      // Name dialog should appear for default name
      await tester.tap(find.text(l10n.saveButton));
      await tester.pumpAndSettle();

      // Verify error toast: name dialog should close + error message visible
      expect(
        find.text(l10n.batchCostingSummarySaveErrorMessage),
        findsOneWidget,
      );
      expect(find.text(l10n.batchCostingSummarySaveSuccessTitle), findsNothing);
      expect(analytics.lastName, 'batch_quote_saved');
      expect(analytics.lastParams?['outcome'], 'failure');
      expect(usage.completedCostingCount, 0);
      expect(
        sink.events.any((e) => e.message.contains('batch_quote_save_service')),
        isTrue,
      );
      expect(sink.events.any((e) => e.category == AppLogCategory.db), isTrue);
    });

    testWidgets('still saves when usage tracking fails after repository save', (
      tester,
    ) async {
      final sink = _CapturingLogSink();
      final premiumLocalStore = InMemoryPremiumLocalStore();
      analytics = _CapturingAnalyticsService();
      AppAnalytics.service = analytics;
      addTearDown(() => AppAnalytics.service = originalAnalytics);
      final container = await tester.pumpAppWithContainer(
        const BatchSummaryPage(),
        overrides: [
          batchCostingProvider.overrideWith(() => _SaveBatchNotifier()),
          isPremiumProvider.overrideWithValue(true),
          appLogSinkProvider.overrideWithValue(sink),
          appLoggerConfigProvider.overrideWithValue(
            const AppLoggerConfig(minLevel: AppLogLevel.debug),
          ),
          appUsageServiceProvider.overrideWith(
            (ref) => _ThrowingUsageService(ref),
          ),
          historyRepositoryProvider.overrideWith(
            (ref) => _CapturingHistoryRepository(ref),
          ),
        ],
        premiumLocalStore: premiumLocalStore,
      );

      final l10n = AppLocalizations.of(
        tester.element(find.byType(BatchSummaryPage)),
      )!;

      await tester.scrollUntilVisible(
        find.text(l10n.batchCostingSummarySaveButton),
        200,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.batchCostingSummarySaveButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.saveButton));
      await tester.pumpAndSettle();

      expect(
        find.text(l10n.batchCostingSummarySaveSuccessTitle),
        findsOneWidget,
      );
      expect(analytics.lastName, 'batch_quote_saved');
      expect(analytics.lastParams?['outcome'], 'success');
      expect(find.text(l10n.batchCostingSummarySaveErrorMessage), findsNothing);
      expect(
        sink.events.any((e) => e.message.contains('recordCompletedCosting')),
        isTrue,
      );
      expect(container.read(pendingTabNavigationProvider), isNull);
    });
  });

  group('service provider wiring', () {
    test('batchQuoteSaveServiceProvider resolves', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(
        container.read(batchQuoteSaveServiceProvider),
        isA<BatchQuoteSaveService>(),
      );
    });

    test('CapturingLogSink stores events', () {
      final sink = _CapturingLogSink();
      sink.log(
        const AppLogEvent(
          level: AppLogLevel.warn,
          category: AppLogCategory.db,
          message: 'batch_quote_save_service.saveBatchQuote failed',
          error: 'fail',
        ),
      );
      expect(sink.events.length, 1);
      expect(sink.events.first.message, contains('batch_quote_save_service'));
    });
  });
}
