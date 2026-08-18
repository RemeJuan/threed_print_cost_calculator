import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:threed_print_cost_calculator/batch_costing/helpers/batch_quote_save_analytics.dart';
import 'package:threed_print_cost_calculator/batch_costing/helpers/batch_quote_save_dialogs.dart';
import 'package:threed_print_cost_calculator/batch_costing/helpers/batch_quote_save_mapper.dart';
import 'package:threed_print_cost_calculator/batch_costing/helpers/batch_quote_save_actions.dart';
import 'package:threed_print_cost_calculator/batch_costing/helpers/batch_summary_calculator.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_costing_state.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/database/repositories/history_repository.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/services/app_usage_service.dart';

class BatchQuoteSaveService {
  BatchQuoteSaveService(this._ref);

  final Ref _ref;

  AppLogger get _logger => _ref.read(appLoggerProvider);

  Future<void> saveBatchQuote(
    BuildContext context,
    BatchCostingState state,
    BatchSummaryResult summary,
  ) async {
    final quoteName = await showBatchQuoteNameDialog(context);
    if (quoteName == null || !context.mounted) return;

    final l10n = AppLocalizations.of(context)!;

    final model = mapBatchQuoteHistoryModel(
      name: quoteName,
      state: state,
      summary: summary,
    );
    final analytics = buildBatchQuoteSaveAnalytics(state);

    try {
      await _ref.read(historyRepositoryProvider).saveHistory(model);
    } catch (e, st) {
      _logger.warn(
        AppLogCategory.db,
        'batch_quote_save_service.saveBatchQuote failed',
        error: e,
        stackTrace: st,
      );
      recordBatchQuoteSaveOutcome(analytics.copyWith(outcome: 'failure'));
      if (context.mounted) {
        BotToast.showText(text: l10n.batchCostingSummarySaveErrorMessage);
      }
      return;
    }

    try {
      await _ref.read(appUsageServiceProvider).recordCompletedCosting();
    } catch (e, st) {
      _logger.warn(
        AppLogCategory.db,
        'batch_quote_save_service.recordCompletedCosting failed',
        error: e,
        stackTrace: st,
      );
    }

    recordBatchQuoteSaveOutcome(analytics.copyWith(outcome: 'success'));
    if (!context.mounted) return;
    final action = await showBatchQuoteSuccessDialog(context);
    if (action == null || !context.mounted) return;
    await handleBatchQuoteSuccessAction(_ref, context, action);
  }
}

final batchQuoteSaveServiceProvider = Provider<BatchQuoteSaveService>((ref) {
  return BatchQuoteSaveService(ref);
});
