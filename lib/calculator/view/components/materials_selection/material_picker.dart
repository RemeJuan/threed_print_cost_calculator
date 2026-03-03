import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';

/// Reusable material picker widget. Expects a function that loads materials
/// and a callback invoked when a material is selected.
class MaterialPicker extends HookWidget {
  const MaterialPicker({
    required this.loadMaterials,
    required this.onSelected,
    this.loadMaterialsFuture,
    this.excludedIds,
    super.key,
  });

  final Future<List<MaterialModel>> Function() loadMaterials;
  final Future<List<MaterialModel>>? loadMaterialsFuture;
  final ValueChanged<MaterialModel> onSelected;

  // Optional set of material IDs that should be excluded from the list
  // (e.g. already-selected materials). IDs are compared after trimming.
  final Set<String>? excludedIds;

  @override
  Widget build(BuildContext context) {
    final query = useState('');
    final l10n = S.of(context);

    final materialsFuture = useMemoized(
      () => loadMaterialsFuture ?? loadMaterials(),
      const [],
    );

    return FutureBuilder<List<MaterialModel>>(
      future: materialsFuture,
      builder: (context, snapshot) {
        final items = snapshot.data ?? const <MaterialModel>[];
        final filtered = items.where((item) {
          final q = query.value.toLowerCase();
          final matchesQuery =
              item.name.toLowerCase().contains(q) ||
              item.color.toLowerCase().contains(q);

          if (!matchesQuery) return false;

          if (excludedIds == null || excludedIds!.isEmpty) return true;

          final id = item.id.trim();
          return !excludedIds!.contains(id);
        }).toList();

        if (filtered.isEmpty) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: l10n.searchMaterialsHint,
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: (value) => query.value = value,
                ),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(l10n.addAtLeastOneMaterial),
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  labelText: l10n.searchMaterialsHint,
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: (value) => query.value = value,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final material = filtered[index];
                  final weight =
                      num.tryParse(material.weight.replaceAll(',', '.')) ?? 0;
                  final cost =
                      num.tryParse(material.cost.replaceAll(',', '.')) ?? 0;
                  final costPerKg = weight <= 0 ? 0 : (cost / weight) * 1000;

                  return ListTile(
                    title: Text(material.name),
                    subtitle: Text(
                      '${material.color} • ${costPerKg.toStringAsFixed(2)}/kg',
                    ),
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
