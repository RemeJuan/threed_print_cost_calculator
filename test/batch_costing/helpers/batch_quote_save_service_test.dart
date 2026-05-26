import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:threed_print_cost_calculator/batch_costing/batch_summary_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/helpers/batch_quote_save_service.dart';
import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_costing_state.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_pricing_state.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/database/repositories/history_repository.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';

import '../../helpers/helpers.dart';

class _CapturingLogSink extends AppLogSink {
  final List<AppLogEvent> events = [];

  @override
  void log(AppLogEvent event) {
    events.add(event);
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

    testWidgets('saves history and shows success dialog', (tester) async {
      final sink = _CapturingLogSink();
      await tester.pumpApp(const BatchSummaryPage(), [
        batchCostingProvider.overrideWith(() => _SaveBatchNotifier()),
        isPremiumProvider.overrideWithValue(true),
        appLogSinkProvider.overrideWithValue(sink),
        appLoggerConfigProvider.overrideWithValue(
          const AppLoggerConfig(minLevel: AppLogLevel.debug),
        ),
      ]);

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
    });
  });

  group('saveBatchQuote failure path', () {
    testWidgets('shows error toast when repository save fails', (tester) async {
      final sink = _CapturingLogSink();
      await tester.pumpApp(const BatchSummaryPage(), [
        batchCostingProvider.overrideWith(() => _SaveBatchNotifier()),
        isPremiumProvider.overrideWithValue(true),
        appLogSinkProvider.overrideWithValue(sink),
        appLoggerConfigProvider.overrideWithValue(
          const AppLoggerConfig(minLevel: AppLogLevel.debug),
        ),
        historyRepositoryProvider.overrideWith(
          (ref) => _ThrowingHistoryRepository(ref),
        ),
      ]);

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
      expect(
        sink.events.any((e) => e.message.contains('batch_quote_save_service')),
        isTrue,
      );
      expect(sink.events.any((e) => e.category == AppLogCategory.db), isTrue);
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
