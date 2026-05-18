import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:threed_print_cost_calculator/batch_costing/batch_pricing_scope_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_costing_state.dart';
import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/materials/model/stock_status.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/shared/providers/batch_costing_visibility.dart';
import 'package:threed_print_cost_calculator/shared/utils/weight_formatting.dart';

class BatchMaterialAssignmentPage extends ConsumerStatefulWidget {
  const BatchMaterialAssignmentPage({super.key});

  @override
  ConsumerState<BatchMaterialAssignmentPage> createState() =>
      _BatchMaterialAssignmentPageState();
}

class _BatchMaterialAssignmentPageState
    extends ConsumerState<BatchMaterialAssignmentPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
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
              child: Form(
                key: _formKey,
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
                      child: materials.isEmpty
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
                          ? _BatchWideMaterialSection(
                              materials: sortedMaterials,
                              selectedMaterialId: state.batchMaterialId,
                              warningText: _buildStockWarning(
                                l10n,
                                _materialById(
                                  sortedMaterials,
                                  state.batchMaterialId,
                                ),
                                _totalRequiredWeight(state),
                              ),
                              onChanged: (value) {
                                ref
                                    .read(batchCostingProvider.notifier)
                                    .setBatchMaterialId(value);
                              },
                              labelText: l10n
                                  .batchCostingMaterialAssignmentMaterialLabel,
                              hintText: l10n
                                  .batchCostingMaterialAssignmentBatchWideHint,
                              validatorText: l10n
                                  .batchCostingMaterialAssignmentRequiredError,
                            )
                          : ListView.separated(
                              itemCount: state.items.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = state.items[index];
                                final selectedMaterial = _materialById(
                                  sortedMaterials,
                                  item.materialId,
                                );
                                return _PerItemMaterialSection(
                                  item: item,
                                  materials: sortedMaterials,
                                  selectedMaterialId: item.materialId,
                                  warningText: _buildStockWarning(
                                    l10n,
                                    selectedMaterial,
                                    _itemRequiredWeight(item),
                                  ),
                                  onChanged: (value) {
                                    ref
                                        .read(batchCostingProvider.notifier)
                                        .setItemMaterialId(item.id, value);
                                  },
                                  labelText: l10n
                                      .batchCostingMaterialAssignmentMaterialLabel,
                                  hintText: l10n
                                      .batchCostingMaterialAssignmentPerItemHint,
                                  validatorText: l10n
                                      .batchCostingMaterialAssignmentRequiredError,
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
                            MaterialLocalizations.of(context).backButtonTooltip,
                          ),
                        ),
                        const Spacer(),
                        FilledButton(
                          onPressed: materials.isEmpty
                              ? null
                              : () => _continue(context),
                          child: Text(
                            l10n.batchCostingMaterialAssignmentContinueButton,
                          ),
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

  void _continue(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

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

  double _itemRequiredWeight(BatchCostingItem item) {
    return item.printWeightG * item.quantity;
  }

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

class _BatchWideMaterialSection extends StatelessWidget {
  const _BatchWideMaterialSection({
    required this.materials,
    required this.selectedMaterialId,
    required this.warningText,
    required this.onChanged,
    required this.labelText,
    required this.hintText,
    required this.validatorText,
  });

  final List<MaterialModel> materials;
  final String? selectedMaterialId;
  final String? warningText;
  final ValueChanged<String?> onChanged;
  final String labelText;
  final String hintText;
  final String validatorText;

  @override
  Widget build(BuildContext context) {
    final selectedValue = materials.any((m) => m.id == selectedMaterialId)
        ? selectedMaterialId
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          initialValue: selectedValue,
          decoration: InputDecoration(
            labelText: labelText,
            border: const OutlineInputBorder(),
          ),
          hint: Text(hintText),
          items: materials
              .map(
                (material) => DropdownMenuItem<String>(
                  value: material.id,
                  child: Text(material.name),
                ),
              )
              .toList(),
          validator: (value) => value == null ? validatorText : null,
          onChanged: onChanged,
        ),
        if (warningText != null) ...[
          const SizedBox(height: 8),
          _warningBox(context, warningText!),
        ],
      ],
    );
  }
}

class _PerItemMaterialSection extends StatelessWidget {
  const _PerItemMaterialSection({
    required this.item,
    required this.materials,
    required this.selectedMaterialId,
    required this.warningText,
    required this.onChanged,
    required this.labelText,
    required this.hintText,
    required this.validatorText,
  });

  final BatchCostingItem item;
  final List<MaterialModel> materials;
  final String? selectedMaterialId;
  final String? warningText;
  final ValueChanged<String?> onChanged;
  final String labelText;
  final String hintText;
  final String validatorText;

  @override
  Widget build(BuildContext context) {
    final selectedValue = materials.any((m) => m.id == selectedMaterialId)
        ? selectedMaterialId
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              item.displayName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: selectedValue,
              decoration: InputDecoration(
                labelText: labelText,
                border: const OutlineInputBorder(),
              ),
              hint: Text(hintText),
              items: materials
                  .map(
                    (material) => DropdownMenuItem<String>(
                      value: material.id,
                      child: Text(material.name),
                    ),
                  )
                  .toList(),
              validator: (value) => value == null ? validatorText : null,
              onChanged: onChanged,
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
