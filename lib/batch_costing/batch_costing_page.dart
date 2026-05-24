import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:threed_print_cost_calculator/batch_costing/batch_gcode_import_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/batch_printer_assignment_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/helpers/batch_flow_reset.dart';
import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/batch_costing_item_card.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/batch_costing_item_editor_dialog.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/batch_new_batch_dialog.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_screen_header.dart';
import 'package:threed_print_cost_calculator/shared/widgets/home_button.dart';

class BatchCostingPage extends ConsumerStatefulWidget {
  const BatchCostingPage({super.key});

  @override
  ConsumerState<BatchCostingPage> createState() => _BatchCostingPageState();
}

class _BatchCostingPageState extends ConsumerState<BatchCostingPage> {
  final Map<String, TextEditingController> _quantityControllers =
      <String, TextEditingController>{};
  final Set<String> _expandedItemIds = <String>{};
  bool _initialSyncDone = false;

  @override
  void initState() {
    super.initState();
    ref.listenManual(batchCostingProvider, (prev, next) {
      _syncQuantityControllers(next.items);
    });
  }

  @override
  void dispose() {
    for (final controller in _quantityControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final batchState = ref.watch(batchCostingProvider);
    final items = batchState.items;

    _syncExpandedState(items);

    if (!_initialSyncDone) {
      _initialSyncDone = true;
      _syncQuantityControllers(items);
    }

    return Scaffold(
      appBar: AppScreenHeader(
        title: l10n.batchCostingReviewAppBarTitle,
        actions: [homeButton(context)],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(kAppSpace16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.batchCostingReviewSubtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: kAppSpace16),
              if (items.isNotEmpty) ...[
                Align(
                  alignment: AlignmentDirectional.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppTertiaryButton(
                        onPressed: () => _addManualItem(context),
                        label: l10n.batchCostingReviewAddManualItemButton,
                        icon: const Icon(Icons.add),
                      ),
                      const SizedBox(width: kAppSpace8),
                      AppTertiaryButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const BatchGCodeImportPage(),
                          ),
                        ),
                        label: l10n.batchCostingReviewImportGcodeButton,
                        icon: const Icon(Icons.upload_file),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: kAppSpace16),
              ],
              Expanded(
                child: items.isEmpty
                    ? _emptyState(context, l10n)
                    : ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (context, _) =>
                            const SizedBox(height: kAppSpace12),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return BatchCostingItemCard(
                            item: item,
                            quantityController:
                                _quantityControllers[item.id]!,
                            initiallyExpanded:
                                _expandedItemIds.contains(item.id),
                            onExpansionChanged: (expanded) {
                              setState(() {
                                if (expanded) {
                                  _expandedItemIds.add(item.id);
                                } else {
                                  _expandedItemIds.remove(item.id);
                                }
                              });
                            },
                            onEdit: () => _editItem(context, item),
                          );
                        },
                      ),
              ),
              if (items.isNotEmpty) ...[
                const SizedBox(height: kAppSpace16),
                SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppPrimaryButton(
                        onPressed: _hasMissingFields(items)
                            ? null
                            : () => _continueToPrinterAssignment(context),
                        icon: const Icon(Icons.arrow_forward),
                        label: l10n.batchCostingReviewContinueButton,
                      ),
                      const SizedBox(height: kAppSpace12),
                      AppSecondaryButton(
                        onPressed: () => _showStartNewBatchDialog(context),
                        label: l10n.batchCostingSummaryStartNewBatchButton,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _syncQuantityControllers(List<BatchCostingItem> items) {
    final activeIds = items.map((item) => item.id).toSet();

    _quantityControllers.removeWhere((id, controller) {
      if (!activeIds.contains(id)) {
        controller.dispose();
        return true;
      }
      return false;
    });

    for (final item in items) {
      final controller = _quantityControllers.putIfAbsent(
        item.id,
        () => TextEditingController(text: item.quantity.toString()),
      );
      if (controller.text != item.quantity.toString()) {
        controller.text = item.quantity.toString();
      }
    }
  }

  void _syncExpandedState(List<BatchCostingItem> items) {
    final activeIds = items.map((i) => i.id).toSet();
    _expandedItemIds.removeWhere((id) => !activeIds.contains(id));

    if (items.isNotEmpty && _expandedItemIds.isEmpty) {
      _expandedItemIds.add(items.first.id);
    }
  }

  Widget _emptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 56,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.batchCostingReviewEmptyTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.batchCostingReviewEmptyBody,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          AppPrimaryButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const BatchGCodeImportPage(),
              ),
            ),
            icon: const Icon(Icons.upload_file),
            label: l10n.batchCostingReviewImportGcodeButton,
          ),
          const SizedBox(height: 12),
          AppSecondaryButton(
            onPressed: () => _addManualItem(context),
            icon: const Icon(Icons.add),
            label: l10n.batchCostingReviewAddManualItemButton,
          ),
        ],
      ),
    );
  }

  bool _hasMissingFields(List<BatchCostingItem> items) {
    return items.any(
      (item) => item.printWeightG == null || item.printDuration == null,
    );
  }

  void _continueToPrinterAssignment(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const BatchPrinterAssignmentPage(),
      ),
    );
  }

  Future<void> _showStartNewBatchDialog(BuildContext context) async {
    final confirmed = await showStartNewBatchDialog(context);
    if (!confirmed) return;
    if (!context.mounted) return;
    await resetBatchFlow(context, ref);
  }

  Future<void> _addManualItem(BuildContext context) async {
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
    if (!mounted) return;

    final wasEmpty = ref.read(batchCostingProvider).items.isEmpty;

    final itemId = DateTime.now().microsecondsSinceEpoch.toString();
    ref
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

    if (wasEmpty) {
      AppAnalytics.safeLog(() => AppAnalytics.batchStarted(source: 'manual'));
    }

    AppAnalytics.safeLog(() => AppAnalytics.batchItemAdded(source: 'manual'));
  }

  Future<void> _editItem(BuildContext context, BatchCostingItem item) async {
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
