import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:threed_print_cost_calculator/batch_costing/batch_gcode_import_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/batch_printer_assignment_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/batch_costing_item_editor_dialog.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/batch_new_batch_dialog.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/providers/batch_costing_visibility.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/shared/utils/format_utils.dart';
import 'package:threed_print_cost_calculator/shared/utils/weight_formatting.dart';
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
  Timer? _quantityChangeTimer;

  @override
  void dispose() {
    _quantityChangeTimer?.cancel();
    for (final controller in _quantityControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(batchCostingEnabledProvider)) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    final batchState = ref.watch(batchCostingProvider);
    final items = batchState.items;

    _syncExpandedState(items);

    if (!_initialSyncDone) {
      _initialSyncDone = true;
      _syncQuantityControllers(items);
    }

    ref.listen(batchCostingProvider, (prev, next) {
      _syncQuantityControllers(next.items);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.batchCostingReviewAppBarTitle),
        actions: [homeButton(context)],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.batchCostingReviewSubtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              if (items.isNotEmpty) ...[
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton.icon(
                        onPressed: () => _addManualItem(context),
                        icon: const Icon(Icons.add),
                        label: Text(l10n.batchCostingReviewAddManualItemButton),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const BatchGCodeImportPage(),
                          ),
                        ),
                        icon: const Icon(Icons.upload_file),
                        label: Text(l10n.batchCostingReviewImportGcodeButton),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Expanded(
                child: items.isEmpty
                    ? _emptyState(context, l10n)
                    : ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (context, _) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _batchItemCard(context, l10n, item);
                        },
                      ),
              ),
              if (items.isNotEmpty) ...[
                const SizedBox(height: 16),
                SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FilledButton.icon(
                        onPressed: _hasMissingFields(items)
                            ? null
                            : () => _continueToPrinterAssignment(context),
                        icon: const Icon(Icons.arrow_forward),
                        label: Text(l10n.batchCostingReviewContinueButton),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () => _showStartNewBatchDialog(context),
                        child: Text(l10n.batchCostingSummaryStartNewBatchButton),
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
          FilledButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const BatchGCodeImportPage(),
              ),
            ),
            icon: const Icon(Icons.upload_file),
            label: Text(l10n.batchCostingReviewImportGcodeButton),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _addManualItem(context),
            icon: const Icon(Icons.add),
            label: Text(l10n.batchCostingReviewAddManualItemButton),
          ),
        ],
      ),
    );
  }

  Widget _batchItemCard(
    BuildContext context,
    AppLocalizations l10n,
    BatchCostingItem item,
  ) {
    final quantityController = _quantityControllers[item.id];

    return Card(
      child: ExpansionTile(
        key: ValueKey<String>('batch-item-${item.id}'),
        initiallyExpanded: _expandedItemIds.contains(item.id),
        onExpansionChanged: (expanded) {
          setState(() {
            if (expanded) {
              _expandedItemIds.add(item.id);
            } else {
              _expandedItemIds.remove(item.id);
            }
          });
        },
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        title: Row(
          children: [
            Expanded(
              child: Text(
                item.displayName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(width: 8),
            _sourceChip(l10n, item),
          ],
        ),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _itemDetailRow(
                      context,
                      l10n.batchCostingReviewWeightLabel,
                      item.printWeightG != null
                          ? Text(
                              '${formatWeight(item.printWeightG!)}${l10n.gramsSuffix}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            )
                          : Text(
                              l10n.batchCostingReviewWeightRequired,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                            ),
                    ),
                    _itemDetailRow(
                      context,
                      l10n.batchCostingReviewDurationLabel,
                      item.printDuration != null
                          ? Text(
                              formatDuration(item.printDuration!),
                              style: Theme.of(context).textTheme.bodyMedium,
                            )
                          : Text(
                              l10n.batchCostingReviewDurationRequired,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: TextField(
                  controller: quantityController,
                  decoration: InputDecoration(
                    labelText: l10n.batchCostingReviewQuantityLabel,
                    border: const OutlineInputBorder(),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    final parsed = int.tryParse(value);
                    if (parsed == null || parsed < 1) return;
                    if (!context.mounted) return;
                    final cleared = ref
                        .read(batchCostingProvider.notifier)
                        .updateItem(item.copyWith(quantity: parsed));
                    _quantityChangeTimer?.cancel();
                    if (cleared) {
                      _quantityChangeTimer = Timer(
                        const Duration(milliseconds: 1000),
                        () {
                          if (!context.mounted) return;
                          BotToast.showText(
                            text: l10n
                                .batchCostingAssignmentQuantityChangedMessage,
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                onPressed: () {
                  final src =
                      item.sourceType == BatchCostingItemSourceType.gcode
                          ? 'gcode'
                          : 'manual';
                  AppAnalytics.safeLog(
                    () => AppAnalytics.batchItemRemoved(source: src),
                  );
                  ref
                      .read(batchCostingProvider.notifier)
                      .removeItem(item.id);
                },
                icon: const Icon(Icons.delete_outline),
                label: Text(l10n.batchCostingReviewRemoveButton),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _editItem(context, item),
                icon: const Icon(Icons.edit_outlined),
                label: Text(l10n.editButton),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _itemDetailRow(BuildContext context, String label, Widget child) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 92,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: child),
      ],
    );
  }

  Widget _sourceChip(AppLocalizations l10n, BatchCostingItem item) {
    final label = switch (item.sourceType) {
      BatchCostingItemSourceType.manual => l10n.batchCostingReviewSourceManual,
      BatchCostingItemSourceType.gcode => l10n.batchCostingReviewSourceGcode,
      null => l10n.batchCostingReviewSourceUnknown,
    };
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.symmetric(horizontal: 6),
    );
  }



  bool _hasMissingFields(List<BatchCostingItem> items) {
    return items.any(
      (item) => item.printWeightG == null || item.printDuration == null,
    );
  }

  void _continueToPrinterAssignment(BuildContext context) {
    _quantityChangeTimer?.cancel();
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
    ref.read(batchCostingProvider.notifier).reset();
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
      AppAnalytics.safeLog(
        () => AppAnalytics.batchStarted(source: 'manual'),
      );
    }

    AppAnalytics.safeLog(
      () => AppAnalytics.batchItemAdded(source: 'manual'),
    );
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
