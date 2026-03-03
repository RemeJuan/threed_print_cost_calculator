import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';
import 'package:threed_print_cost_calculator/settings/materials/material_form.dart';

/// Reusable material picker widget. Uses a Stream<List<MaterialModel>> so it
/// updates live when the DB changes. Calls `onSelected` when the user picks
/// or creates a material. The picker does not pop navigation itself; the
/// caller should handle closing the bottom sheet if desired.
class MaterialPicker extends HookWidget {
  const MaterialPicker({
    required this.materialsStream,
    required this.onSelected,
    this.excludedIds,
    super.key,
  });

  final Stream<List<MaterialModel>> materialsStream;
  final ValueChanged<MaterialModel> onSelected;
  final Set<String>? excludedIds;

  @override
  Widget build(BuildContext context) {
    final query = useState('');
    final l10n = S.of(context);

    return StreamBuilder<List<MaterialModel>>(
      stream: materialsStream,
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
              // Add button is intentionally here so users can create new materials
              // if none exist yet.
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addMaterialButton),
                  onPressed: () async {
                    final created = await showDialog<MaterialModel?>(
                      context: context,
                      useRootNavigator: true,
                      builder: (dialogContext) => const MaterialForm(),
                    );

                    if (created != null) {
                      // Notify parent; parent decides whether to close the sheet
                      onSelected(created);
                    }
                  },
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
            // Add material button at the bottom so the user can create a new
            // material even when the list already contains items.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: Text(l10n.addMaterialButton),
                onPressed: () async {
                  final created = await showDialog<MaterialModel?>(
                    context: context,
                    useRootNavigator: true,
                    builder: (dialogContext) => const MaterialForm(),
                  );

                  if (created != null) {
                    onSelected(created);
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
