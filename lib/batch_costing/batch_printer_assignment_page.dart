import 'package:material_ui/material_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:threed_print_cost_calculator/batch_costing/batch_material_assignment_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/helpers/batch_assignment_flow.dart';
import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_costing_state.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/batch_anchor_selector.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/batch_assignment_page_shell.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/batch_searchable_selector.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/printer_allocation_card.dart';
import 'package:threed_print_cost_calculator/database/repositories/printers_repository.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
import 'package:threed_print_cost_calculator/settings/printers/add_printer.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';

class BatchPrinterAssignmentPage extends ConsumerWidget {
  const BatchPrinterAssignmentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(batchCostingProvider);
    final printersAsync = ref.watch(printersStreamProvider);

    return printersAsync.when(
      data: (printers) {
        final canCreate = ref
            .watch(premiumAccessPolicyProvider)
            .canCreatePrinter(printers.length)
            .allowed;

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
                  if (printers.isEmpty)
                    Text(l10n.batchCostingPrinterAssignmentNoPrintersMessage),
                  Row(
                    children: [
                      Text(l10n.printersHeader),
                      const Spacer(),
                      AppSecondaryButton(
                        key: const ValueKey<String>('batch-create-printer'),
                        onPressed: canCreate
                            ? () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => AddPrinter(
                                    onCreated: (id) {
                                      final batch = ref.read(
                                        batchCostingProvider,
                                      );
                                      final notifier = ref.read(
                                        batchCostingProvider.notifier,
                                      );
                                      if (batch.printerAssignmentMode ==
                                          BatchPrinterAssignmentMode
                                              .batchWide) {
                                        notifier.setBatchPrinterId(id);
                                      } else {
                                        for (final item in batch.items) {
                                          if (batch
                                                  .itemPrinterAllocations[item
                                                      .id]
                                                  ?.isNotEmpty ==
                                              true) {
                                            continue;
                                          }
                                          notifier.setItemPrinterAllocations(
                                            item.id,
                                            [
                                              BatchAssignmentAllocation(
                                                targetId: id,
                                                quantity: item.quantity,
                                              ),
                                            ],
                                          );
                                          break;
                                        }
                                      }
                                    },
                                  ),
                                ),
                              )
                            : null,
                        label: l10n.batchCostingAllocationPickerAddButton,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  if (!canCreate)
                    Text(
                      l10n.printerLimitReachedMessage,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: TEXT_TERTIARY),
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
                          return PrinterAllocationCard(
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
                    nextEnabled: printers.isNotEmpty && _nextEnabled(state),
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
  ) => batchAllocationsFor(
    state: state,
    item: item,
    itemAllocations: (s) => s.itemPrinterAllocations,
    itemFallback: (i) => state.itemPrinterIds[i.id],
    batchId: (s) => s.batchPrinterId,
  );

  bool _nextEnabled(BatchCostingState state) => batchNextEnabled(
    state: state,
    hasData: true,
    isBatchWide: (s) =>
        s.printerAssignmentMode == BatchPrinterAssignmentMode.batchWide,
    batchId: (s) => s.batchPrinterId,
  );

  void _continue(
    BuildContext context,
    WidgetRef ref,
    BatchCostingState state,
  ) => batchContinueFlow(
    context: context,
    state: state,
    isBatchWide: (s) =>
        s.printerAssignmentMode == BatchPrinterAssignmentMode.batchWide,
    itemAllocations: (s) => s.itemPrinterAllocations,
    batchId: (s) => s.batchPrinterId,
    errorText: (l) => l.batchCostingPrinterAssignmentRequiredError,
    analyticsType: 'printer',
    nextPage: const BatchMaterialAssignmentPage(),
  );
}
