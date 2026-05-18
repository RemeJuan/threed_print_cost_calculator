import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:threed_print_cost_calculator/batch_costing/batch_pricing_scope_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_costing_state.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/batch_anchor_selector.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/materials/model/stock_status.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/shared/providers/batch_costing_visibility.dart';
import 'package:threed_print_cost_calculator/shared/utils/weight_formatting.dart';

class BatchMaterialAssignmentPage extends ConsumerWidget {
  const BatchMaterialAssignmentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(batchCostingEnabledProvider)) return const SizedBox.shrink();

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
          appBar: AppBar(
            title: Text(l10n.batchCostingMaterialAssignmentAppBarTitle),
            leading: BackButton(onPressed: () => Navigator.of(context).pop()),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.batchCostingMaterialAssignmentSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<BatchMaterialAssignmentMode>(
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
                  const SizedBox(height: 16),
                  Expanded(
                    child: sortedMaterials.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
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
                              BatchAnchorSelector(
                                labelText: l10n
                                    .batchCostingMaterialAssignmentMaterialLabel,
                                hintText: l10n
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
                                  padding: const EdgeInsets.only(top: 8),
                                  child: _warningBox(context, warning),
                                ),
                            ],
                          )
                        : ListView.separated(
                            itemCount: state.items.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final item = state.items[index];
                              final allocations = _materialAllocationsFor(
                                state,
                                item,
                              );
                              return _MaterialAllocationCard(
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
                                onAllocationChanged:
                                    (allocationIndex, materialId) {
                                      final updated = [...allocations];
                                      updated[allocationIndex] =
                                          updated[allocationIndex].copyWith(
                                            targetId: materialId ?? '',
                                          );
                                      ref
                                          .read(batchCostingProvider.notifier)
                                          .setItemMaterialAllocations(
                                            item.id,
                                            updated,
                                          );
                                    },
                                onAddAllocation: () => ref
                                    .read(batchCostingProvider.notifier)
                                    .addItemMaterialAllocation(item.id),
                                onRemoveAllocation: (allocationIndex) => ref
                                    .read(batchCostingProvider.notifier)
                                    .removeItemMaterialAllocation(
                                      item.id,
                                      allocationIndex,
                                    ),
                                hintText: l10n
                                    .batchCostingMaterialAssignmentPerItemHint,
                                addButtonLabel: l10n
                                    .batchCostingAssignmentSplitCopiesButton,
                                copiesLabel:
                                    l10n.batchCostingAssignmentCopiesLabel,
                                labelText: l10n
                                    .batchCostingMaterialAssignmentMaterialLabel,
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
                          l10n.batchCostingMaterialAssignmentPreviousButton,
                        ),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: sortedMaterials.isEmpty
                            ? null
                            : () => _continue(context, ref, state),
                        child: Text(
                          l10n.batchCostingMaterialAssignmentNextButton,
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
          title: Text(l10n.batchCostingMaterialAssignmentAppBarTitle),
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(
          title: Text(l10n.batchCostingMaterialAssignmentAppBarTitle),
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
                onPressed: () => ref.refresh(materialsStreamProvider),
                child: Text(l10n.retryButton),
              ),
            ],
          ),
        ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(
              context,
            )!.batchCostingMaterialAssignmentRequiredError,
          ),
        ),
      );
      return;
    }

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
      item.printWeightG * item.quantity;

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

class _MaterialAllocationCard extends StatelessWidget {
  const _MaterialAllocationCard({
    required this.item,
    required this.allocations,
    required this.materials,
    required this.warningText,
    required this.onAllocationChanged,
    required this.onAddAllocation,
    required this.onRemoveAllocation,
    required this.hintText,
    required this.addButtonLabel,
    required this.copiesLabel,
    required this.labelText,
  });

  final BatchCostingItem item;
  final List<BatchAssignmentAllocation> allocations;
  final List<MaterialModel> materials;
  final String? warningText;
  final void Function(int allocationIndex, String? materialId)
  onAllocationChanged;
  final VoidCallback onAddAllocation;
  final void Function(int allocationIndex) onRemoveAllocation;
  final String hintText;
  final String addButtonLabel;
  final String copiesLabel;
  final String labelText;

  @override
  Widget build(BuildContext context) {
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
                  '${item.quantity} $copiesLabel',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (var index = 0; index < allocations.length; index += 1) ...[
              _MaterialAllocationRow(
                copies: allocations[index].quantity,
                materials: materials,
                selectedMaterialId: allocations[index].targetId.isEmpty
                    ? null
                    : allocations[index].targetId,
                hintText: hintText,
                labelText: labelText,
                onChanged: (value) => onAllocationChanged(index, value),
                onRemove: allocations.length > 1
                    ? () => onRemoveAllocation(index)
                    : null,
              ),
              if (index != allocations.length - 1) const SizedBox(height: 12),
            ],
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onAddAllocation,
              icon: const Icon(Icons.add),
              label: Text(addButtonLabel),
            ),
            if (warningText != null) ...[
              const SizedBox(height: 8),
              _warningBox(context, warningText!),
            ],
          ],
        ),
      ),
    );
  }
}

class _MaterialAllocationRow extends StatelessWidget {
  const _MaterialAllocationRow({
    required this.copies,
    required this.materials,
    required this.selectedMaterialId,
    required this.hintText,
    required this.labelText,
    required this.onChanged,
    required this.onRemove,
  });

  final int copies;
  final List<MaterialModel> materials;
  final String? selectedMaterialId;
  final String hintText;
  final String labelText;
  final ValueChanged<String?> onChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: BatchAnchorSelector(
            labelText: labelText,
            hintText: hintText,
            value:
                materials.any((material) => material.id == selectedMaterialId)
                ? selectedMaterialId
                : null,
            onChanged: onChanged,
            entries: [
              for (final material in materials)
                BatchAnchorSelectorEntry(
                  value: material.id,
                  label: material.name,
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4, right: 4, top: 12),
          child: Text(
            '×$copies',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        if (onRemove != null) ...[
          const SizedBox(width: 4),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.remove_circle_outline),
          ),
        ],
      ],
    );
  }
}

Widget _warningBox(BuildContext context, String text) {
  final colors = Theme.of(context).colorScheme;
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: colors.errorContainer,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.bodySmall?.copyWith(color: colors.onErrorContainer),
    ),
  );
}
