import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:threed_print_cost_calculator/batch_costing/batch_material_assignment_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_costing_state.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/batch_anchor_selector.dart';
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
                        label: Text(l10n.batchCostingPrinterAssignmentBatchWideMode),
                      ),
                      ButtonSegment(
                        value: BatchPrinterAssignmentMode.perItem,
                        label: Text(l10n.batchCostingPrinterAssignmentPerItemMode),
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
                  Expanded(
                    child: state.printerAssignmentMode == BatchPrinterAssignmentMode.batchWide
                        ? _BatchWidePrinterSection(
                            printers: printers,
                            selectedPrinterId: state.batchPrinterId,
                            hintText: l10n.batchCostingPrinterAssignmentBatchWideHint,
                            onChanged: (value) => ref
                                .read(batchCostingProvider.notifier)
                                .setBatchPrinterId(value),
                          )
                        : ListView.separated(
                            itemCount: state.items.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final item = state.items[index];
                              final allocations = _printerAllocationsFor(state, item);
                              return _PrinterAllocationCard(
                                item: item,
                                allocations: allocations,
                                printers: printers,
                                onAllocationChanged: (allocationIndex, printerId) {
                                  final updated = [...allocations];
                                  updated[allocationIndex] = updated[allocationIndex].copyWith(
                                    targetId: printerId ?? '',
                                  );
                                  ref
                                      .read(batchCostingProvider.notifier)
                                      .setItemPrinterAllocations(item.id, updated);
                                },
                                onAddAllocation: () => ref
                                    .read(batchCostingProvider.notifier)
                                    .addItemPrinterAllocation(item.id),
                                onRemoveAllocation: (allocationIndex) => ref
                                    .read(batchCostingProvider.notifier)
                                    .removeItemPrinterAllocation(item.id, allocationIndex),
                                hintText: l10n.batchCostingPrinterAssignmentPerItemHint,
                                addButtonLabel: l10n.batchCostingAssignmentSplitCopiesButton,
                                copiesLabel: l10n.batchCostingAssignmentCopiesLabel,
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(MaterialLocalizations.of(context).backButtonTooltip),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: () => _continue(context, ref, state),
                        child: Text(l10n.batchCostingPrinterAssignmentContinueButton),
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

  List<BatchAssignmentAllocation> _printerAllocationsFor(BatchCostingState state, BatchCostingItem item) {
    final allocations = state.itemPrinterAllocations[item.id];
    if (allocations != null && allocations.isNotEmpty) return allocations;

    final printerId = state.itemPrinterIds[item.id] ?? state.batchPrinterId;
    if (printerId == null) {
      return [const BatchAssignmentAllocation(targetId: '', quantity: 1)];
    }

    return [BatchAssignmentAllocation(targetId: printerId, quantity: item.quantity)];
  }

  void _continue(BuildContext context, WidgetRef ref, BatchCostingState state) {
    final missing = state.items.where((item) {
      final allocations = state.itemPrinterAllocations[item.id] ?? const <BatchAssignmentAllocation>[];
      return state.printerAssignmentMode == BatchPrinterAssignmentMode.batchWide
          ? state.batchPrinterId == null
          : allocations.isEmpty || allocations.any((allocation) => allocation.targetId.isEmpty);
    });
    if (missing.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.batchCostingPrinterAssignmentRequiredError)),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const BatchMaterialAssignmentPage()),
    );
  }
}

class _BatchWidePrinterSection extends StatelessWidget {
  const _BatchWidePrinterSection({
    required this.printers,
    required this.selectedPrinterId,
    required this.onChanged,
    required this.hintText,
  });

  final List<PrinterModel> printers;
  final String? selectedPrinterId;
  final ValueChanged<String?> onChanged;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return BatchAnchorSelector(
      labelText: AppLocalizations.of(context)!.batchCostingPrinterAssignmentBatchWideMode,
      hintText: hintText,
      value: printers.any((printer) => printer.id == selectedPrinterId) ? selectedPrinterId : null,
      onChanged: onChanged,
      entries: [for (final printer in printers) BatchAnchorSelectorEntry(value: printer.id, label: printer.name)],
    );
  }
}

class _PrinterAllocationCard extends StatelessWidget {
  const _PrinterAllocationCard({
    required this.item,
    required this.allocations,
    required this.printers,
    required this.onAllocationChanged,
    required this.onAddAllocation,
    required this.onRemoveAllocation,
    required this.hintText,
    required this.addButtonLabel,
    required this.copiesLabel,
  });

  final BatchCostingItem item;
  final List<BatchAssignmentAllocation> allocations;
  final List<PrinterModel> printers;
  final void Function(int allocationIndex, String? printerId) onAllocationChanged;
  final VoidCallback onAddAllocation;
  final void Function(int allocationIndex) onRemoveAllocation;
  final String hintText;
  final String addButtonLabel;
  final String copiesLabel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(item.displayName, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (var index = 0; index < allocations.length; index += 1) ...[
              _PrinterAllocationRow(
                copiesLabel: copiesLabel,
                copies: allocations[index].quantity,
                printers: printers,
                selectedPrinterId: allocations[index].targetId.isEmpty ? null : allocations[index].targetId,
                hintText: hintText,
                onChanged: (value) => onAllocationChanged(index, value),
                onRemove: allocations.length > 1 ? () => onRemoveAllocation(index) : null,
              ),
              if (index != allocations.length - 1) const SizedBox(height: 12),
            ],
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onAddAllocation,
              icon: const Icon(Icons.add),
              label: Text(addButtonLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrinterAllocationRow extends StatelessWidget {
  const _PrinterAllocationRow({
    required this.copiesLabel,
    required this.copies,
    required this.printers,
    required this.selectedPrinterId,
    required this.hintText,
    required this.onChanged,
    required this.onRemove,
  });

  final String copiesLabel;
  final int copies;
  final List<PrinterModel> printers;
  final String? selectedPrinterId;
  final String hintText;
  final ValueChanged<String?> onChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: BatchAnchorSelector(
            labelText: '$copiesLabel · $copies',
            hintText: hintText,
            value: printers.any((printer) => printer.id == selectedPrinterId) ? selectedPrinterId : null,
            onChanged: onChanged,
            entries: [for (final printer in printers) BatchAnchorSelectorEntry(value: printer.id, label: printer.name)],
          ),
        ),
        if (onRemove != null) ...[
          const SizedBox(width: 8),
          IconButton(onPressed: onRemove, icon: const Icon(Icons.remove_circle_outline)),
        ],
      ],
    );
  }
}
