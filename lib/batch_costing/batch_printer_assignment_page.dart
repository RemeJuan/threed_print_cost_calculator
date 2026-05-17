import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:threed_print_cost_calculator/batch_costing/batch_material_assignment_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/batch_wide_printer_section.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/per_item_printer_field.dart';
import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_costing_state.dart';
import 'package:threed_print_cost_calculator/database/repositories/printers_repository.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/providers/batch_costing_visibility.dart';

class BatchPrinterAssignmentPage extends ConsumerStatefulWidget {
  const BatchPrinterAssignmentPage({super.key});

  @override
  ConsumerState<BatchPrinterAssignmentPage> createState() =>
      _BatchPrinterAssignmentPageState();
}

class _BatchPrinterAssignmentPageState extends ConsumerState<BatchPrinterAssignmentPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(batchCostingEnabledProvider)) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(batchCostingProvider);
    final items = state.items;
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
              child: Form(
                key: _formKey,
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
                          ? BatchWidePrinterSection(
                              printers: printers,
                              selectedPrinterId: state.batchPrinterId,
                              onChanged: (value) {
                                ref.read(batchCostingProvider.notifier).setBatchPrinterId(value);
                              },
                              validatorText: l10n.batchCostingPrinterAssignmentRequiredError,
                              hintText: l10n.batchCostingPrinterAssignmentBatchWideHint,
                            )
                          : ListView.separated(
                              itemCount: items.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = items[index];
                                return PerItemPrinterField(
                                  itemName: item.displayName,
                                  printers: printers,
                                  selectedPrinterId: state.itemPrinterIds[item.id],
                                  onChanged: (value) {
                                    ref
                                        .read(batchCostingProvider.notifier)
                                        .setItemPrinterId(item.id, value);
                                  },
                                  hintText: l10n.batchCostingPrinterAssignmentPerItemHint,
                                  validatorText: l10n.batchCostingPrinterAssignmentRequiredError,
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
                          onPressed: () => _continue(context, state),
                          child: Text(l10n.batchCostingPrinterAssignmentContinueButton),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.batchCostingPrinterAssignmentAppBarTitle)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: Text(l10n.batchCostingPrinterAssignmentAppBarTitle)),
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
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _continue(BuildContext context, BatchCostingState state) {
    if (state.printerAssignmentMode == BatchPrinterAssignmentMode.batchWide) {
      if (!_formKey.currentState!.validate()) return;
    } else {
      _formKey.currentState!.validate();
      final missing = state.items.any((item) => state.itemPrinterIds[item.id] == null);
      if (missing) return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const BatchMaterialAssignmentPage()),
    );
  }
}
