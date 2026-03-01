import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/app/components/focus_safe_text_field.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage_input.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

class MaterialsSection extends HookConsumerWidget {
  const MaterialsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorProvider);
    final notifier = ref.read(calculatorProvider.notifier);
    final l10n = S.of(context);

    final totalWeight = state.materialUsages.fold<int>(
      0,
      (sum, item) => sum + item.weightGrams,
    );

    final printWeightController = useTextEditingController(
      text: state.printWeight.value?.toString() ?? '',
    );
    final printWeightFocus = useFocusNode();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FocusSafeTextField(
          controller: printWeightController,
          externalText: state.printWeight.value?.toString() ?? '',
          focusNode: printWeightFocus,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Print weight (g)'),
          onChanged: (value) {
            notifier
              ..updatePrintWeight(value)
              ..submitDebounced();
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              state.materialUsages.length == 1 ? 'Material' : 'Materials',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _showMaterialPicker(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Add material'),
            ),
          ],
        ),
        if (state.materialUsages.length == 1)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () {
                notifier
                  ..applySingleTotalWeightToFirstRow()
                  ..submitDebounced();
              },
              child: const Text('Use single total weight'),
            ),
          ),
        if (state.materialUsages.isEmpty)
          const Text('Add at least one material.')
        else
          ...state.materialUsages.asMap().entries.map((entry) {
            final index = entry.key;
            final usage = entry.value;

            return Row(
              children: [
                Expanded(flex: 3, child: Text(usage.materialName)),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    initialValue: usage.weightGrams.toString(),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(suffixText: l10n.gramsSuffix),
                    onChanged: (value) {
                      notifier
                        ..updateMaterialUsageWeight(
                          index,
                          int.tryParse(value) ?? 0,
                        )
                        ..submitDebounced();
                    },
                  ),
                ),
                IconButton(
                  onPressed: state.materialUsages.length == 1
                      ? null
                      : () {
                          notifier
                            ..removeMaterialUsageAt(index)
                            ..submitDebounced();
                        },
                  icon: const Icon(Icons.remove_circle_outline),
                ),
              ],
            );
          }),
        const SizedBox(height: 8),
        Text('Total material weight: ${totalWeight}g'),
      ],
    );
  }

  Future<void> _showMaterialPicker(BuildContext context, WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    final store = stringMapStoreFactory.store(DBName.materials.name);

    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.95,
          child: _MaterialPicker(
            onSelected: (material) {
              final weight = num.tryParse(material.weight) ?? 0;
              final cost = num.tryParse(material.cost) ?? 0;
              final costPerKg = weight <= 0 ? 0 : (cost / weight) * 1000;

              ref
                  .read(calculatorProvider.notifier)
                  .addMaterialUsage(
                    MaterialUsageInput(
                      materialId: material.id,
                      materialName: material.name,
                      costPerKg: costPerKg,
                      weightGrams: 0,
                    ),
                  );

              Navigator.of(context).pop();
            },
            loadMaterials: () async {
              final snapshots = await store.find(db);
              return snapshots
                  .map(
                    (e) => MaterialModel.fromMap(
                      e.value as Map<String, dynamic>,
                      e.key.toString(),
                    ),
                  )
                  .toList();
            },
          ),
        );
      },
    );
  }
}

class _MaterialPicker extends HookWidget {
  const _MaterialPicker({
    required this.loadMaterials,
    required this.onSelected,
  });

  final Future<List<MaterialModel>> Function() loadMaterials;
  final ValueChanged<MaterialModel> onSelected;

  @override
  Widget build(BuildContext context) {
    final query = useState('');

    return FutureBuilder<List<MaterialModel>>(
      future: loadMaterials(),
      builder: (context, snapshot) {
        final items = snapshot.data ?? const <MaterialModel>[];
        final filtered = items.where((item) {
          final q = query.value.toLowerCase();
          return item.name.toLowerCase().contains(q) ||
              item.color.toLowerCase().contains(q);
        }).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Search materials',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) => query.value = value,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final material = filtered[index];
                  final weight = num.tryParse(material.weight) ?? 0;
                  final cost = num.tryParse(material.cost) ?? 0;
                  final costPerKg = weight <= 0 ? 0 : (cost / weight) * 1000;

                  return ListTile(
                    title: Text(material.name),
                    subtitle: Text('${material.color} • ${costPerKg.toStringAsFixed(2)}/kg'),
                    onTap: () => onSelected(material),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
