import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/settings/materials/material_form.dart';
import 'package:threed_print_cost_calculator/shared/utils/number_parsing.dart';

/// Reusable material picker widget. Uses the shared materials provider so it
/// updates live without creating duplicate listeners.
class MaterialPicker extends HookConsumerWidget {
  const MaterialPicker({required this.onSelected, this.excludedIds, super.key});

  final ValueChanged<MaterialModel> onSelected;
  final Set<String>? excludedIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = useState('');
    final l10n = AppLocalizations.of(context)!;
    final materialsAsync = ref.watch(materialsStreamProvider);

    return materialsAsync.when(
      data: (items) {
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
                  key: const ValueKey<String>(
                    'calculator.materialPicker.search.input',
                  ),
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
                  key: const ValueKey<String>(
                    'calculator.materialPicker.add.button',
                  ),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addMaterialButton),
                  onPressed: () async {
                    final created = await showDialog<MaterialModel?>(
                      context: context,
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
                key: const ValueKey<String>(
                  'calculator.materialPicker.search.input',
                ),
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
                  final weight = parseLocalizedNumOrFallback(material.weight);
                  final cost = parseLocalizedNumOrFallback(material.cost);
                  final costPerKg = weight <= 0 ? 0 : (cost / weight) * 1000;

                  return ListTile(
                    key: ValueKey<String>(
                      'calculator.materialPicker.item.${material.name}',
                    ),
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
                key: const ValueKey<String>(
                  'calculator.materialPicker.add.button',
                ),
                icon: const Icon(Icons.add),
                label: Text(l10n.addMaterialButton),
                onPressed: () async {
                  final created = await showDialog<MaterialModel?>(
                    context: context,
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
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(l10n.materialsLoadError(error.toString())),
        ),
      ),
    );
  }
}
