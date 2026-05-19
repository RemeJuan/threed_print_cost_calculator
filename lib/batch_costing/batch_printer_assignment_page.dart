import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:threed_print_cost_calculator/batch_costing/batch_material_assignment_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_costing_state.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/batch_anchor_selector.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/batch_split_copies_dialog.dart';
import 'package:threed_print_cost_calculator/database/repositories/printers_repository.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';
import 'package:threed_print_cost_calculator/shared/providers/batch_costing_visibility.dart';

class BatchPrinterAssignmentPage extends ConsumerWidget {
  const BatchPrinterAssignmentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(batchCostingEnabledProvider)) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(batchCostingProvider);
    final printersAsync = ref.watch(printersStreamProvider);

    return printersAsync.when(
      data: (printers) {
        if (printers.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.batchCostingPrinterAssignmentAppBarTitle),
              leading: BackButton(onPressed: () => Navigator.of(context).pop()),
            ),
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    l10n.batchCostingPrinterAssignmentNoPrintersMessage,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.batchCostingPrinterAssignmentAppBarTitle),
            leading: BackButton(onPressed: () => Navigator.of(context).pop()),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.batchCostingPrinterAssignmentSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<BatchPrinterAssignmentMode>(
                    segments: [
                      ButtonSegment(
                        value: BatchPrinterAssignmentMode.batchWide,
                        label: Text(
                          l10n.batchCostingPrinterAssignmentBatchWideMode,
                        ),
                      ),
                      ButtonSegment(
                        value: BatchPrinterAssignmentMode.perItem,
                        label: Text(
                          l10n.batchCostingPrinterAssignmentPerItemMode,
                        ),
                      ),
                    ],
                    selected: {state.printerAssignmentMode},
                    onSelectionChanged: (selected) {
                      ref
                          .read(batchCostingProvider.notifier)
                          .setPrinterAssignmentMode(selected.first);
                    },
                  ),
                  const SizedBox(height: 16),
                  if (state.printerAssignmentMode ==
                      BatchPrinterAssignmentMode.batchWide) ...[
                    BatchAnchorSelector(
                      labelText:
                          l10n.batchCostingPrinterAssignmentBatchWideMode,
                      hintText: l10n.batchCostingPrinterAssignmentBatchWideHint,
                      value:
                          printers.any(
                            (printer) => printer.id == state.batchPrinterId,
                          )
                          ? state.batchPrinterId
                          : null,
                      onChanged: (value) => ref
                          .read(batchCostingProvider.notifier)
                          .setBatchPrinterId(value),
                      entries: [
                        for (final printer in printers)
                          BatchAnchorSelectorEntry(
                            value: printer.id,
                            label: printer.name,
                          ),
                      ],
                    ),
                    const Spacer(),
                  ],
                  if (state.printerAssignmentMode ==
                      BatchPrinterAssignmentMode.perItem)
                    Expanded(
                      child: ListView.separated(
                        itemCount: state.items.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = state.items[index];
                          final allocations = _printerAllocationsFor(
                            state,
                            item,
                          );
                          return _PrinterAllocationCard(
                            item: item,
                            allocations: allocations,
                            printers: printers,
                            printerLabel:
                                l10n.batchCostingAssignmentPrinterLabel,
                            onSetAllocations: (updated) => ref
                                .read(batchCostingProvider.notifier)
                                .setItemPrinterAllocations(item.id, updated),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          l10n.batchCostingPrinterAssignmentPreviousButton,
                        ),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: () => _continue(context, ref, state),
                        child: Text(
                          l10n.batchCostingPrinterAssignmentNextButton,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(
          title: Text(l10n.batchCostingPrinterAssignmentAppBarTitle),
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(
          title: Text(l10n.batchCostingPrinterAssignmentAppBarTitle),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(error.toString(), textAlign: TextAlign.center),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.refresh(printersStreamProvider),
                child: Text(l10n.retryButton),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<BatchAssignmentAllocation> _printerAllocationsFor(
    BatchCostingState state,
    BatchCostingItem item,
  ) {
    final allocations = state.itemPrinterAllocations[item.id];
    if (allocations != null && allocations.isNotEmpty) return allocations;

    final printerId = state.itemPrinterIds[item.id] ?? state.batchPrinterId;
    if (printerId == null) {
      return [const BatchAssignmentAllocation(targetId: '', quantity: 1)];
    }

    return [
      BatchAssignmentAllocation(targetId: printerId, quantity: item.quantity),
    ];
  }

  void _continue(BuildContext context, WidgetRef ref, BatchCostingState state) {
    final missing = state.items.where((item) {
      final allocations =
          state.itemPrinterAllocations[item.id] ??
          const <BatchAssignmentAllocation>[];
      return state.printerAssignmentMode == BatchPrinterAssignmentMode.batchWide
          ? state.batchPrinterId == null
          : allocations.isEmpty ||
                allocations.any((allocation) => allocation.targetId.isEmpty);
    });
    if (missing.isNotEmpty) {
      BotToast.showText(
        text: AppLocalizations.of(
          context,
        )!.batchCostingPrinterAssignmentRequiredError,
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const BatchMaterialAssignmentPage(),
      ),
    );
  }
}

class _PrinterAllocationCard extends StatelessWidget {
  const _PrinterAllocationCard({
    required this.item,
    required this.allocations,
    required this.printers,
    required this.onSetAllocations,
    required this.printerLabel,
  });

  final BatchCostingItem item;
  final List<BatchAssignmentAllocation> allocations;
  final List<PrinterModel> printers;
  final void Function(List<BatchAssignmentAllocation>) onSetAllocations;
  final String printerLabel;

  Future<void> _openSplitCopiesDialog(BuildContext context) async {
    final result = await showDialog<List<BatchAssignmentAllocation>>(
      context: context,
      builder: (_) => BatchSplitCopiesDialog(
        itemName: item.displayName,
        itemQuantity: item.quantity,
        allocations: allocations,
        printers: printers,
      ),
    );
    if (result == null || !context.mounted) return;
    onSetAllocations(result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.displayName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  '${item.quantity} ${l10n.batchCostingAssignmentCopiesLabel}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(printerLabel),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _openSplitCopiesDialog(context),
              icon: const Icon(Icons.tune),
              label: Text(l10n.batchCostingAssignmentSplitCopiesButton),
            ),
          ],
        ),
      ),
    );
  }
}
