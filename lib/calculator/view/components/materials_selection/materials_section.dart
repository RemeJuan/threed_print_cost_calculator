import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/app/components/focus_safe_text_field.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage_input.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/calculator/view/components/materials_selection/materials_header.dart';
import 'package:threed_print_cost_calculator/calculator/view/components/materials_selection/materials_list.dart';
import 'package:threed_print_cost_calculator/calculator/view/components/materials_selection/material_picker.dart';
import 'package:threed_print_cost_calculator/calculator/view/components/materials_selection/materials_providers.dart';

class MaterialsSection extends HookConsumerWidget {
  const MaterialsSection({required this.premium, super.key});

  final bool premium;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorProvider);
    final notifier = ref.read(calculatorProvider.notifier);
    final l10n = S.of(context);

    // Quick non-premium fields (unchanged behavior)
    if (!premium) {
      final spoolWeightController = useTextEditingController(
        text: state.spoolWeight.value?.toString() ?? '',
      );
      final spoolCostController = useTextEditingController(
        text: state.spoolCostText.isNotEmpty
            ? state.spoolCostText
            : (state.spoolCost.value?.toString() ?? ''),
      );
      final spoolWeightFocus = useFocusNode();
      final spoolCostFocus = useFocusNode();
      final printWeightController = useTextEditingController(
        text: state.printWeight.value?.toString() ?? '',
      );
      final printWeightFocus = useFocusNode();

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: FocusSafeTextField(
                  controller: spoolWeightController,
                  externalText: state.spoolWeight.value?.toString() ?? '',
                  focusNode: spoolWeightFocus,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.spoolWeightLabel,
                    suffixText: l10n.gramsSuffix,
                  ),
                  onChanged: (value) {
                    final normalized = value.trim().replaceAll(',', '.');
                    notifier
                      ..updateSpoolWeight(num.tryParse(normalized) ?? 0)
                      ..submitDebounced();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FocusSafeTextField(
                  controller: spoolCostController,
                  externalText: state.spoolCostText.isNotEmpty
                      ? state.spoolCostText
                      : (state.spoolCost.value?.toString() ?? ''),
                  focusNode: spoolCostFocus,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(labelText: l10n.spoolCostLabel),
                  onChanged: (value) {
                    notifier
                      ..updateSpoolCost(value)
                      ..submitDebounced();
                  },
                ),
              ),
            ],
          ),
          FocusSafeTextField(
            controller: printWeightController,
            externalText: state.printWeight.value?.toString() ?? '',
            focusNode: printWeightFocus,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l10n.printWeightLabel),
            onChanged: (value) {
              notifier
                ..updatePrintWeight(value)
                ..submitDebounced();
            },
          ),
        ],
      );
    }

    // --- Premium UI: materials accordion ---

    final totalWeight = state.materialUsages.fold<int>(
      0,
      (s, i) => s + i.weightGrams,
    );

    // Read materials via Riverpod providers
    final materialsAsync = ref.watch(materialsListProvider);
    final materialsById = ref.watch(materialsByIdProvider);

    // Memoize the future so FutureBuilder won't re-query on every build
    final materialsFuture = useMemoized(() async {
      return materialsAsync.maybeWhen(
        data: (list) => Future.value(list),
        orElse: () async {
          final dbHelpers = ref.read(dbHelpersProvider(DBName.materials));
          final snapshots = await dbHelpers.getAllRecords();
          return snapshots
              .map(
                (e) => MaterialModel.fromMap(
                  e.value as Map<String, dynamic>,
                  e.key.toString(),
                ),
              )
              .toList();
        },
      );
    }, [materialsAsync.asData?.value]);

    // Accordion expanded state
    final expanded = useState<bool>(true);

    void onAddPressed() async {
      final selectedId = await _showMaterialPicker(
        context,
        ref,
        materialsFuture,
      );
      if (selectedId == null) return;
      expanded.value = true;
    }

    void onRowPick(int index) async {
      final usage = state.materialUsages[index];
      final selectedId = await _showMaterialPicker(
        context,
        ref,
        materialsFuture,
        editingIndex: index,
        focusAfterId: usage.materialId.trim().isNotEmpty
            ? usage.materialId.trim()
            : null,
      );
      if (selectedId == null) return;
      expanded.value = true;
    }

    void onRowWeightChanged(int index, int grams) {
      notifier
        ..updateMaterialUsageWeight(index, grams)
        ..submitDebounced();
    }

    void onRowRemove(int index) {
      notifier
        ..removeMaterialUsageAt(index)
        ..submitDebounced();
    }

    return Card(
      color: Theme.of(context).cardColor,
      margin: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MaterialsHeader(
            count: state.materialUsages.length,
            totalWeight: totalWeight,
            expanded: expanded.value,
            onAdd: onAddPressed,
            onToggle: () => expanded.value = !expanded.value,
          ),

          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: MaterialsList(
                usages: state.materialUsages,
                materialsById: materialsById,
                onPick: onRowPick,
                onWeightChanged: onRowWeightChanged,
                onRemove: onRowRemove,
              ),
            ),
            crossFadeState: expanded.value
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
            firstCurve: Curves.easeInOut,
            secondCurve: Curves.easeInOut,
            sizeCurve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }

  // Material picker modal. Returns selected material id or null.
  Future<String?> _showMaterialPicker(
    BuildContext context,
    WidgetRef ref,
    Future<List<MaterialModel>> materialsFuture, {
    int? editingIndex,
    String? focusAfterId,
  }) async {
    final state = ref.read(calculatorProvider);

    final selectedIds = state.materialUsages
        .map((u) => u.materialId)
        .where((id) => id.trim().isNotEmpty && id.toLowerCase() != 'none')
        .map((e) => e.trim())
        .toSet();
    if (focusAfterId != null && focusAfterId.trim().isNotEmpty) {
      selectedIds.remove(focusAfterId);
    }

    final selectedId = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.95,
          child: MaterialPicker(
            loadMaterials: () => materialsFuture,
            onSelected: (material) {
              final weight =
                  num.tryParse(material.weight.replaceAll(',', '.')) ?? 0;
              final cost =
                  num.tryParse(material.cost.replaceAll(',', '.')) ?? 0;
              final costPerKg = weight <= 0 ? 0 : (cost / weight) * 1000;

              final refRead = ref.read(calculatorProvider.notifier);
              if (editingIndex != null &&
                  editingIndex >= 0 &&
                  editingIndex < state.materialUsages.length) {
                refRead.updateMaterialUsage(
                  editingIndex,
                  MaterialUsageInput(
                    materialId: material.id,
                    materialName: material.name,
                    costPerKg: costPerKg,
                    weightGrams: state.materialUsages[editingIndex].weightGrams,
                  ),
                );
              } else {
                refRead.addMaterialUsage(
                  MaterialUsageInput(
                    materialId: material.id,
                    materialName: material.name,
                    costPerKg: costPerKg,
                    weightGrams: 0,
                  ),
                );
              }
              Navigator.of(context).pop(material.id);
            },
            loadMaterialsFuture: materialsFuture,
            excludedIds: selectedIds,
          ),
        );
      },
    );

    return selectedId;
  }
}
