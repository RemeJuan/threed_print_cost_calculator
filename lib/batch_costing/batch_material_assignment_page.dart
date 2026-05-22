import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:threed_print_cost_calculator/batch_costing/batch_pricing_scope_page.dart';
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
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/materials/model/stock_status.dart';
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
                                  padding: const EdgeInsets.only(top: kAppSpace8),
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
  ) {
    final allocations = state.itemMaterialAllocations[item.id];
    if (allocations != null && allocations.isNotEmpty) return allocations;

    final materialId = item.materialId ?? state.batchMaterialId;
    if (materialId == null) {
      return [const BatchAssignmentAllocation(targetId: '', quantity: 1)];
    }

    return [
      BatchAssignmentAllocation(targetId: materialId, quantity: item.quantity),
    ];
  }

  bool _nextEnabled(
    BatchCostingState state,
    List<MaterialModel> sortedMaterials,
  ) {
    if (sortedMaterials.isEmpty) return false;
    if (state.materialAssignmentMode == BatchMaterialAssignmentMode.batchWide) {
      return state.batchMaterialId != null;
    }
    return state.items.isNotEmpty;
  }

  void _continue(BuildContext context, WidgetRef ref, BatchCostingState state) {
    final missing = state.items.where((item) {
      final allocations =
          state.itemMaterialAllocations[item.id] ??
          const <BatchAssignmentAllocation>[];
      return state.materialAssignmentMode ==
              BatchMaterialAssignmentMode.batchWide
          ? state.batchMaterialId == null
          : allocations.isEmpty ||
                allocations.any((allocation) => allocation.targetId.isEmpty);
    });
    if (missing.isNotEmpty) {
      BotToast.showText(
        text: AppLocalizations.of(
          context,
        )!.batchCostingMaterialAssignmentRequiredError,
      );
      return;
    }

    final mode =
        state.materialAssignmentMode == BatchMaterialAssignmentMode.batchWide
        ? 'batch'
        : 'split';
    final hasSplit =
        state.materialAssignmentMode == BatchMaterialAssignmentMode.perItem &&
        state.items.any((item) {
          final allocs = state.itemMaterialAllocations[item.id];
          if (allocs == null || allocs.length <= 1) return false;
          return allocs.map((a) => a.targetId).toSet().length > 1;
        });
    AppAnalytics.safeLog(
      () => AppAnalytics.batchAssignmentCompleted(
        type: 'material',
        mode: mode,
        hasSplitAllocations: hasSplit,
      ),
    );

    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const BatchPricingScopePage()),
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
