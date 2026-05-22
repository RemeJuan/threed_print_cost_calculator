import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:threed_print_cost_calculator/batch_costing/helpers/batch_summary_calculator.dart';
import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_costing_state.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/batch_new_batch_dialog.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/database/repositories/history_repository.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/app/app_page_shell_config.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

Future<void> saveBatchQuote(
  BuildContext context,
  WidgetRef ref,
  BatchCostingState state,
  BatchSummaryResult summary,
) async {
  final l10n = AppLocalizations.of(context)!;

  final nameController = TextEditingController(
    text: l10n.batchCostingSummaryDefaultQuoteName,
  );
  final quoteName = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.batchCostingSummaryQuoteNameDialogTitle),
      content: TextField(
        controller: nameController,
        decoration: InputDecoration(
          hintText: l10n.batchCostingSummaryDefaultQuoteName,
          labelText: l10n.batchCostingSummaryQuoteNameHint,
          border: const OutlineInputBorder(),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(null),
          child: Text(l10n.cancelButton),
        ),
        FilledButton(
          onPressed: () {
            final name = nameController.text.trim();
            Navigator.of(dialogContext).pop(
              name.isEmpty ? l10n.batchCostingSummaryDefaultQuoteName : name,
            );
          },
          child: Text(l10n.saveButton),
        ),
      ],
    ),
  );
  nameController.dispose();

  if (quoteName == null || !context.mounted) return;

  final model = HistoryModel.batchQuote(
    name: quoteName,
    date: DateTime.now(),
    state: state,
    summary: summary,
  );

  final copyCount = state.items.fold<int>(
    0,
    (sum, item) => sum + item.quantity,
  );
  final hasGCode = state.items.any(
    (item) => item.sourceType == BatchCostingItemSourceType.gcode,
  );
  final hasManual = state.items.any(
    (item) => item.sourceType == BatchCostingItemSourceType.manual,
  );
  final hasSplitP = state.hasSplitPrinters;
  final hasSplitM = state.hasSplitMaterials;

  try {
    await ref.read(historyRepositoryProvider).saveHistory(model);
  } catch (e, st) {
    debugPrint('batch_quote_save_service._saveQuote error: $e\n$st');
    AppAnalytics.safeLog(
      () => AppAnalytics.batchQuoteSaved(
        outcome: 'failure',
        itemCount: state.items.length,
        copyCount: copyCount,
        hasGCodeItems: hasGCode,
        hasManualItems: hasManual,
        hasSplitPrinters: hasSplitP,
        hasSplitMaterials: hasSplitM,
      ),
    );
    if (!context.mounted) return;
    BotToast.showText(text: l10n.batchCostingSummarySaveErrorMessage);
    return;
  }

  AppAnalytics.safeLog(
    () => AppAnalytics.batchQuoteSaved(
      outcome: 'success',
      itemCount: state.items.length,
      copyCount: copyCount,
      hasGCodeItems: hasGCode,
      hasManualItems: hasManual,
      hasSplitPrinters: hasSplitP,
      hasSplitMaterials: hasSplitM,
    ),
  );

  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.batchCostingSummarySaveSuccessTitle),
      content: Text(l10n.batchCostingSummarySaveSuccessBody),
      actions: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                ref
                    .read(pendingTabNavigationProvider.notifier)
                    .navigate(AppPageTab.history);
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Text(l10n.batchCostingSummaryViewHistoryButton),
            ),
            OutlinedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Text(l10n.batchCostingSummaryReturnToCalculatorButton),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final confirmed = await showStartNewBatchDialog(context);
                if (confirmed && context.mounted) {
                  ref.read(batchCostingProvider.notifier).reset();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
              child: Text(l10n.batchCostingSummaryStartNewBatchButton),
            ),
          ],
        ),
      ],
    ),
  );
}
