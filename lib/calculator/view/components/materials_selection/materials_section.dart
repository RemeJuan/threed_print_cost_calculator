import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/calculator/view/components/materials_selection/materials_header.dart';
import 'package:threed_print_cost_calculator/calculator/view/components/materials_selection/materials_list.dart';
import 'package:threed_print_cost_calculator/calculator/view/components/materials_selection/materials_providers.dart';
import 'package:threed_print_cost_calculator/calculator/view/components/materials_selection/materials_section_helpers.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';

class MaterialsSection extends HookConsumerWidget {
  const MaterialsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorProvider);
    final notifier = ref.read(calculatorProvider.notifier);

    final totalWeight = state.materialUsages.fold<int>(
      0,
      (s, i) => s + i.weightGrams,
    );

    final materialsById = ref.watch(materialsByIdProvider);
    ref.watch(materialsStreamProvider);
    final currencyAsync = ref.watch(settingsStreamProvider);
    final currencySettings = currencyAsync is AsyncData<GeneralSettingsModel>
        ? currencyAsync.value
        : GeneralSettingsModel.initial();

    final expanded = useState<bool>(true);

    void onAddPressed() async {
      final selectedId = await showMaterialPicker(
        context,
        ref,
        editingIndex: null,
      );
      if (selectedId == null) return;
      expanded.value = true;
    }

    void onRowPick(int index) async {
      final usage = state.materialUsages[index];
      final selectedId = await showMaterialPicker(
        context,
        ref,
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
        ..submitDebounced(trackCompletedCosting: true);
    }

    void onRowSpoolWeightChanged(int index, num value) {
      notifier
        ..updateUnsavedMaterialSpool(index, spoolWeight: value)
        ..submitDebounced(trackCompletedCosting: true);
    }

    void onRowSpoolCostChanged(int index, num value) {
      notifier
        ..updateUnsavedMaterialSpool(index, spoolCost: value)
        ..submitDebounced(trackCompletedCosting: true);
    }

    void onRowRemove(int index) {
      notifier
        ..removeMaterialUsageAt(index)
        ..submitDebounced(trackCompletedCosting: true);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MaterialsHeader(
          count: state.materialUsages.length,
          totalWeight: totalWeight,
          expanded: expanded.value,
          onAdd: onAddPressed,
          onToggle: () => expanded.value = !expanded.value,
        ),
        if (!expanded.value) ...[
          const SizedBox(height: kAppSpace8),
          Divider(
            height: 1,
            thickness: 1,
            color: Theme.of(context).dividerColor.withAlpha(120),
          ),
        ],
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(bottom: kAppSpace4),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: kAppSpace12),
                  child: MaterialsList(
                    usages: state.materialUsages,
                    materialsById: materialsById,
                    onPick: onRowPick,
                    onWeightChanged: onRowWeightChanged,
                    onRemove: onRowRemove,
                    onSpoolWeightChanged: onRowSpoolWeightChanged,
                    onSpoolCostChanged: onRowSpoolCostChanged,
                    currencySymbol: currencySettings.currencySymbol,
                    currencyPosition: currencySettings.currencyPosition,
                    currencySpacing: currencySettings.currencySpacing,
                  ),
                ),
                if (expanded.value) ...[
                  const SizedBox(height: kAppSpace8),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Theme.of(context).dividerColor.withAlpha(120),
                  ),
                ],
              ],
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
    );
  }
}
