import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/calculator/view/components/materials_selection/materials_header.dart';
import 'package:threed_print_cost_calculator/calculator/view/components/materials_selection/materials_list.dart';
import 'package:threed_print_cost_calculator/calculator/view/components/materials_selection/materials_providers.dart';
import 'package:threed_print_cost_calculator/calculator/view/components/materials_selection/materials_section_helpers.dart';

class MaterialsSectionPremium extends HookConsumerWidget {
  const MaterialsSectionPremium({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorProvider);
    final notifier = ref.read(calculatorProvider.notifier);

    final totalWeight = state.materialUsages.fold<int>(
      0,
      (s, i) => s + i.weightGrams,
    );

    final materialsById = ref.watch(materialsByIdProvider);

    final db = ref.read(databaseProvider);
    final materialsStore = stringMapStoreFactory.store(DBName.materials.name);
    final materialsStream = materialsStore
        .query()
        .onSnapshots(db)
        .map(
          (snapshots) => snapshots
              .map(
                (e) => MaterialModel.fromMap(
                  e.value as Map<String, dynamic>,
                  e.key.toString(),
                ),
              )
              .toList(),
        );

    final expanded = useState<bool>(true);

    void onAddPressed() async {
      final selectedId = await showMaterialPicker(
        context,
        ref,
        materialsStream,
      );
      if (selectedId == null) return;
      expanded.value = true;
    }

    void onRowPick(int index) async {
      final usage = state.materialUsages[index];
      final selectedId = await showMaterialPicker(
        context,
        ref,
        materialsStream,
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
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
          if (!expanded.value) ...[
            const SizedBox(height: 8),
            Divider(
              height: 1,
              thickness: 1,
              color: Theme.of(context).dividerColor.withAlpha(120),
            ),
          ],
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: MaterialsList(
                      usages: state.materialUsages,
                      materialsById: materialsById,
                      onPick: onRowPick,
                      onWeightChanged: onRowWeightChanged,
                      onRemove: onRowRemove,
                    ),
                  ),
                  if (expanded.value) ...[
                    const SizedBox(height: 8),
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
      ),
    );
  }
}
