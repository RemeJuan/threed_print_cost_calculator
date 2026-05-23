import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:threed_print_cost_calculator/batch_costing/batch_material_assignment_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_costing_state.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/batch_anchor_selector.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/batch_assignment_page_shell.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/batch_searchable_selector.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/batch_split_copies_dialog.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/material_allocation_row.dart';
import 'package:threed_print_cost_calculator/database/repositories/printers_repository.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_screen_header.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_surface_card.dart';

class BatchPrinterAssignmentPage extends ConsumerWidget {
  const BatchPrinterAssignmentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(batchCostingProvider);
    final printersAsync = ref.watch(printersStreamProvider);

    return printersAsync.when(
      data: (printers) {
        if (printers.isEmpty) {
          return Scaffold(
            appBar: AppScreenHeader(
              title: l10n.batchCostingPrinterAssignmentAppBarTitle,
              leading: BackButton(onPressed: () => Navigator.of(context).pop()),
            ),
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(kAppSpace16),
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
          appBar: buildAssignmentPageAppBar(
            context,
            l10n.batchCostingPrinterAssignmentAppBarTitle,
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(kAppSpace16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AssignmentModeHeader(
                    subtitle: l10n.batchCostingPrinterAssignmentSubtitle,
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
                  const SizedBox(height: kAppSpace16),
                  if (state.printerAssignmentMode ==
                      BatchPrinterAssignmentMode.batchWide)
                    Expanded(
                      child: BatchSearchableSelector(
                        searchHintText:
                            l10n.batchCostingPrinterAssignmentBatchWideHint,
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
                    ),
                  if (state.printerAssignmentMode ==
                      BatchPrinterAssignmentMode.perItem)
                    Expanded(
                      child: ListView.separated(
                        itemCount: state.items.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: kAppSpace12),
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
                            onSetAllocations: (updated) => ref
                                .read(batchCostingProvider.notifier)
                                .setItemPrinterAllocations(item.id, updated),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: kAppSpace16),
                  AssignmentNavRow(
                    previousLabel:
                        l10n.batchCostingPrinterAssignmentPreviousButton,
                    nextLabel: l10n.batchCostingPrinterAssignmentNextButton,
                    nextEnabled: _nextEnabled(state),
                    onPrevious: () => Navigator.of(context).pop(),
                    onNext: () => _continue(context, ref, state),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => buildAssignmentLoadingState(
        l10n.batchCostingPrinterAssignmentAppBarTitle,
      ),
      error: (error, stackTrace) => buildAssignmentErrorState(
        l10n.batchCostingPrinterAssignmentAppBarTitle,
        error.toString(),
        l10n.retryButton,
        () => ref.refresh(printersStreamProvider),
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

  bool _nextEnabled(BatchCostingState state) {
    if (state.printerAssignmentMode == BatchPrinterAssignmentMode.batchWide) {
      return state.batchPrinterId != null;
    }
    return state.items.isNotEmpty;
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

    final mode =
        state.printerAssignmentMode == BatchPrinterAssignmentMode.batchWide
        ? 'batch'
        : 'split';
    final hasSplit =
        state.printerAssignmentMode == BatchPrinterAssignmentMode.perItem &&
        state.items.any((item) {
          final allocs = state.itemPrinterAllocations[item.id];
          if (allocs == null || allocs.length <= 1) return false;
          return allocs.map((a) => a.targetId).toSet().length > 1;
        });
    AppAnalytics.safeLog(
      () => AppAnalytics.batchAssignmentCompleted(
        type: 'printer',
        mode: mode,
        hasSplitAllocations: hasSplit,
      ),
    );

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
  });

  final BatchCostingItem item;
  final List<BatchAssignmentAllocation> allocations;
  final List<PrinterModel> printers;
  final void Function(List<BatchAssignmentAllocation>) onSetAllocations;

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
    final visibleIndices = <int>[
      for (var index = 0; index < allocations.length; index += 1)
        if (allocations[index].targetId.isNotEmpty) index,
    ];
    return AppSurfaceCard(
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
          if (visibleIndices.isNotEmpty) ...[
            const SizedBox(height: kAppSpace8),
            for (
              var visibleIndex = 0;
              visibleIndex < visibleIndices.length;
              visibleIndex += 1
            ) ...[
              MaterialAllocationRow(
                title: _printerName(
                  allocations[visibleIndices[visibleIndex]].targetId,
                ),
                subtitle: null,
                copies: allocations[visibleIndices[visibleIndex]].quantity,
                onRemove: visibleIndices.length > 1
                    ? () => onSetAllocations(
                        [...allocations]
                          ..removeAt(visibleIndices[visibleIndex]),
                      )
                    : null,
              ),
            ],
          ],
          AppSecondaryButton(
            onPressed: () => _openSplitCopiesDialog(context),
            icon: const Icon(Icons.tune),
            label: l10n.batchCostingAssignmentSplitCopiesButton,
          ),
        ],
      ),
    );
  }

  String _printerName(String targetId) {
    for (final printer in printers) {
      if (printer.id == targetId) return printer.name;
    }
    return targetId;
  }
}
