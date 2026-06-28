import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:threed_print_cost_calculator/batch_costing/batch_gcode_import_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/batch_printer_assignment_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/helpers/batch_flow_reset.dart'
    as batch_flow_reset;
import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/batch_new_batch_dialog.dart'
    as batch_new_batch_dialog;
import 'package:threed_print_cost_calculator/batch_costing/widgets/batch_costing_item_editor_dialog.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/paywall_presenter.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
import 'package:threed_print_cost_calculator/purchases/premium_upsell_helper.dart';

class BatchCostingPageActions {
  BatchCostingPageActions(this.ref);

  final WidgetRef ref;

  bool hasMissingFields(List<BatchCostingItem> items) => items.any(
    (item) => item.printWeightG == null || item.printDuration == null,
  );

  void continueToPrinterAssignment(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const BatchPrinterAssignmentPage(),
      ),
    );
  }

  Future<void> showStartNewBatchDialog(BuildContext context) async {
    final confirmed = await batch_new_batch_dialog.showStartNewBatchDialog(
      context,
    );
    if (!confirmed) return;
    if (!context.mounted) return;
    await batch_flow_reset.resetBatchFlow(context, ref);
  }

  Future<void> addManualItem(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<BatchCostingItemEditorResult>(
      context: context,
      builder: (_) => BatchCostingItemEditorDialog(
        title: l10n.batchCostingItemEditorAddTitle,
        initialDisplayName: '',
        initialQuantity: 0,
        initialPrintWeightG: 0,
        initialPrintDuration: Duration.zero,
      ),
    );

    if (result == null) return;
    if (!context.mounted) return;

    final wasEmpty = ref.read(batchCostingProvider).items.isEmpty;
    final itemId = DateTime.now().microsecondsSinceEpoch.toString();
    final added = ref
        .read(batchCostingProvider.notifier)
        .addItem(
          BatchCostingItem.manual(
            id: itemId,
            displayName: result.displayName,
            quantity: result.quantity,
            printWeightG: result.printWeightG,
            printDuration: result.printDuration,
          ),
        );

    if (!added) {
      BotToast.showText(text: l10n.batchItemLimitReachedMessage);
      return;
    }

    if (wasEmpty) {
      AppAnalytics.safeLog(() => AppAnalytics.batchStarted(source: 'manual'));
    }

    AppAnalytics.safeLog(() => AppAnalytics.batchItemAdded(source: 'manual'));
  }

  Future<void> openBatchGcodeImport(BuildContext context) async {
    final policy = ref.read(premiumAccessPolicyProvider);
    if (!policy.batchGcodeImport().allowed) {
      final upgraded = await requirePremium(
        ref.read(paywallPresenterProvider),
        policy.batchGcodeImport(),
        purchaseSource: 'batch_gcode_import',
        recheck: () => Future.value(
          ref.read(premiumAccessPolicyProvider).batchGcodeImport().allowed,
        ),
      );
      if (!upgraded) return;
    }

    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const BatchGCodeImportPage()),
    );
  }

  Future<void> editItem(BuildContext context, BatchCostingItem item) async {
    final l10n = AppLocalizations.of(context)!;
    if (!context.mounted) return;
    final result = await showDialog<BatchCostingItemEditorResult>(
      context: context,
      builder: (_) => BatchCostingItemEditorDialog(
        title: l10n.batchCostingItemEditorEditTitle,
        initialDisplayName: item.displayName,
        initialQuantity: item.quantity,
        initialPrintWeightG: item.printWeightG,
        initialPrintDuration: item.printDuration,
      ),
    );

    if (result == null) return;
    if (!context.mounted) return;

    final updatedItem = item.copyWith(
      displayName: result.displayName,
      quantity: result.quantity,
      printWeightG: result.printWeightG,
      printDuration: result.printDuration,
    );
    final cleared = ref
        .read(batchCostingProvider.notifier)
        .updateItem(updatedItem);
    if (cleared && context.mounted) {
      BotToast.showText(
        text: l10n.batchCostingAssignmentQuantityChangedMessage,
      );
    }

    final source = item.sourceType == BatchCostingItemSourceType.gcode
        ? 'gcode'
        : 'manual';
    final changedQuantity = item.quantity != updatedItem.quantity;
    final changedWeight = item.printWeightG != updatedItem.printWeightG;
    final changedDuration = item.printDuration != updatedItem.printDuration;

    AppAnalytics.safeLog(
      () => AppAnalytics.batchItemEdited(
        source: source,
        changedQuantity: changedQuantity,
        changedWeight: changedWeight,
        changedDuration: changedDuration,
      ),
    );
  }
}
