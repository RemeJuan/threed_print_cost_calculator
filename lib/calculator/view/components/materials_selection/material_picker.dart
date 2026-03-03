import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';
import 'package:threed_print_cost_calculator/settings/materials/material_form.dart';

/// Reusable material picker widget. Expects a function that loads materials
/// and a callback invoked when a material is selected.
class MaterialPicker extends HookWidget {
  const MaterialPicker({
    required this.materialsStream,
    required this.onSelected,
    this.excludedIds,
    super.key,
  });

  // Stream of material lists; picker is stream-driven for live updates.
  final Stream<List<MaterialModel>> materialsStream;
  final ValueChanged<MaterialModel> onSelected;

  // Optional set of material IDs that should be excluded from the list
  // (e.g. already-selected materials). IDs are compared after trimming.
  final Set<String>? excludedIds;

  @override
  Widget build(BuildContext context) {
    final query = useState('');
    final l10n = S.of(context);

    return StreamBuilder<List<MaterialModel>>(
      stream: materialsStream,
      builder: (context, snapshot) {
        final items = snapshot.data ?? const <MaterialModel>[];
        return _buildContent(context, items, query, l10n);
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<MaterialModel> items,
    ValueNotifier<String> query,
    S l10n,
  ) {
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: Text(l10n.addMaterialButton),
              onPressed: () async {
                final saved = await showDialog<bool>(
                  context: context,
                  useRootNavigator: true,
                  builder: (dialogContext) => const MaterialForm(),
                );

                // Only refresh if the user actually saved a material
                if (saved == true) {
                  // nothing needed here when using a live stream
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

        // Add material button at the bottom to open the add dialog
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: Text(l10n.addMaterialButton),
            onPressed: () async {
              final saved = await showDialog<bool>(
                context: context,
                useRootNavigator: true,
                builder: (dialogContext) => const MaterialForm(),
              );

              if (saved == true) {
                // stream-backed UI will update automatically
              }
            },
          ),
        ),
      ],
    );
  }
}
