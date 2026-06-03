import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:threed_print_cost_calculator/batch_costing/batch_pricing_scope_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/batch_summary_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/helpers/batch_assignment_flow.dart';
import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_costing_state.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/batch_anchor_selector.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/batch_assignment_page_shell.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/batch_searchable_selector.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/material_allocation_card.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/warning_box.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/materials/model/stock_status.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/utils/weight_formatting.dart';

class BatchMaterialAssignmentPage extends ConsumerWidget {
  const BatchMaterialAssignmentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(batchCostingProvider);
    final materialsAsync = ref.watch(materialsStreamProvider);

    return materialsAsync.when(
      data: (materials) {
        final sortedMaterials = [...materials]
          ..sort((a, b) {
            final statusA = calculateStockStatus(a);
            final statusB = calculateStockStatus(b);
            final order = _stockSortOrder(
              statusA,
            ).compareTo(_stockSortOrder(statusB));
            if (order != 0) return order;
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          });

        return Scaffold(
          appBar: buildAssignmentPageAppBar(
            context,
            l10n.batchCostingMaterialAssignmentAppBarTitle,
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(kAppSpace16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AssignmentModeHeader(
                    subtitle: l10n.batchCostingMaterialAssignmentSubtitle,
                    segments: [
                      ButtonSegment(
                        value: BatchMaterialAssignmentMode.batchWide,
                        label: Text(
                          l10n.batchCostingMaterialAssignmentBatchWideMode,
                        ),
                      ),
                      ButtonSegment(
                        value: BatchMaterialAssignmentMode.perItem,
                        label: Text(
                          l10n.batchCostingMaterialAssignmentPerItemMode,
                        ),
                      ),
                    ],
                    selected: {state.materialAssignmentMode},
                    onSelectionChanged: (selected) {
                      ref
                          .read(batchCostingProvider.notifier)
                          .setMaterialAssignmentMode(selected.first);
                    },
                  ),
                  const SizedBox(height: kAppSpace16),
                  Expanded(
                    child: sortedMaterials.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(kAppSpace16),
                              child: Text(
                                l10n.batchCostingMaterialAssignmentNoMaterialsMessage,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : state.materialAssignmentMode ==
                              BatchMaterialAssignmentMode.batchWide
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: BatchSearchableSelector(
                                  searchHintText: l10n
                                      .batchCostingMaterialAssignmentBatchWideHint,
                                  value:
                                      sortedMaterials.any(
                                        (m) => m.id == state.batchMaterialId,
                                      )
                                      ? state.batchMaterialId
                                      : null,
                                  onChanged: (value) => ref
                                      .read(batchCostingProvider.notifier)
                                      .setBatchMaterialId(value),
                                  entries: [
                                    for (final material in sortedMaterials)
                                      BatchAnchorSelectorEntry(
                                        value: material.id,
                                        label: material.name,
                                      ),
                                  ],
                                ),
                              ),
                              if (_buildStockWarning(
                                    l10n,
                                    _materialById(
                                      sortedMaterials,
                                      state.batchMaterialId,
                                    ),
                                    _totalRequiredWeight(state),
                                  )
                                  case final warning?)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: kAppSpace8,
                                  ),
                                  child: WarningBox(text: warning),
                                ),
                            ],
                          )
                        : ListView.separated(
                            itemCount: state.items.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: kAppSpace12),
                            itemBuilder: (context, index) {
                              final item = state.items[index];
                              final allocations = _materialAllocationsFor(
                                state,
                                item,
                              );
                              return MaterialAllocationCard(
                                item: item,
                                allocations: allocations,
                                materials: sortedMaterials,
                                warningText: _buildStockWarning(
                                  l10n,
                                  _materialById(
                                    sortedMaterials,
                                    allocations.isEmpty
                                        ? null
                                        : allocations.first.targetId,
                                  ),
                                  _itemRequiredWeight(item),
                                ),
                                onSetAllocations: (updated) => ref
                                    .read(batchCostingProvider.notifier)
                                    .setItemMaterialAllocations(
                                      item.id,
                                      updated,
                                    ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: kAppSpace16),
                  AssignmentNavRow(
                    previousLabel:
                        l10n.batchCostingMaterialAssignmentPreviousButton,
                    nextLabel: l10n.batchCostingMaterialAssignmentNextButton,
                    nextEnabled: _nextEnabled(state, sortedMaterials),
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
        l10n.batchCostingMaterialAssignmentAppBarTitle,
      ),
      error: (error, stackTrace) => buildAssignmentErrorState(
        l10n.batchCostingMaterialAssignmentAppBarTitle,
        error.toString(),
        l10n.retryButton,
        () => ref.refresh(materialsStreamProvider),
      ),
    );
  }

  List<BatchAssignmentAllocation> _materialAllocationsFor(
    BatchCostingState state,
    BatchCostingItem item,
  ) => batchAllocationsFor(
    state: state,
    item: item,
    itemAllocations: (s) => s.itemMaterialAllocations,
    itemFallback: (i) => i.materialId,
    batchId: (s) => s.batchMaterialId,
  );

  bool _nextEnabled(
    BatchCostingState state,
    List<MaterialModel> sortedMaterials,
  ) => batchNextEnabled(
    state: state,
    hasData: sortedMaterials.isNotEmpty,
    isBatchWide: (s) =>
        s.materialAssignmentMode == BatchMaterialAssignmentMode.batchWide,
    batchId: (s) => s.batchMaterialId,
  );

  void _continue(
    BuildContext context,
    WidgetRef ref,
    BatchCostingState state,
  ) {
    final policy = ref.read(premiumAccessPolicyProvider);
    final nextPage = policy.advancedPricingConfig().allowed
        ? const BatchPricingScopePage()
        : const BatchSummaryPage();

    batchContinueFlow(
      context: context,
      state: state,
      isBatchWide: (s) =>
          s.materialAssignmentMode == BatchMaterialAssignmentMode.batchWide,
      itemAllocations: (s) => s.itemMaterialAllocations,
      batchId: (s) => s.batchMaterialId,
      errorText: (l) => l.batchCostingMaterialAssignmentRequiredError,
      analyticsType: 'material',
      nextPage: nextPage,
    );
  }

  double _totalRequiredWeight(BatchCostingState state) {
    return state.items.fold<double>(
      0,
      (total, item) => total + _itemRequiredWeight(item),
    );
  }

  double _itemRequiredWeight(BatchCostingItem item) =>
      (item.printWeightG ?? 0) * item.quantity;

  MaterialModel? _materialById(List<MaterialModel> materials, String? id) {
    if (id == null || id.isEmpty) return null;
    for (final material in materials) {
      if (material.id == id) return material;
    }
    return null;
  }

  String? _buildStockWarning(
    AppLocalizations l10n,
    MaterialModel? material,
    double requiredWeightG,
  ) {
    if (material == null) return null;
    if (!material.autoDeductEnabled) return null;
    if (requiredWeightG <= 0) return null;
    if (material.remainingWeight >= requiredWeightG) return null;

    return l10n.batchCostingMaterialAssignmentStockWarning(
      formatWeight(requiredWeightG),
      formatWeight(material.remainingWeight),
    );
  }

  int _stockSortOrder(StockStatus status) {
    return switch (status) {
      StockStatus.inStock => 0,
      StockStatus.lowStock => 1,
      StockStatus.noTracking => 2,
      StockStatus.outOfStock => 3,
    };
  }
}
