import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/settings/materials/material_form.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/utils/number_parsing.dart';
import 'package:threed_print_cost_calculator/shared/utils/format_utils.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';

/// Reusable material picker widget. Uses the shared materials provider so it
/// updates live without creating duplicate listeners.
class MaterialPicker extends HookConsumerWidget {
  const MaterialPicker({
    required this.onSelected,
    this.excludedIds,
    this.onUnsavedSelected,
    super.key,
  });

  final ValueChanged<MaterialModel> onSelected;
  final Set<String>? excludedIds;
  final VoidCallback? onUnsavedSelected;

  static const _unsavedSentinelId = '__unsaved_picker_option__';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = useState('');
    final l10n = AppLocalizations.of(context)!;
    final materialsAsync = ref.watch(materialsStreamProvider);
    final currencyAsync = ref.watch(settingsStreamProvider);
    final currencySettings = currencyAsync is AsyncData<GeneralSettingsModel>
        ? currencyAsync.value
        : GeneralSettingsModel.initial();

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

        if (onUnsavedSelected != null) {
          filtered.add(
            MaterialModel(
              id: _unsavedSentinelId,
              name: l10n.unsavedMaterialOptionLabel,
              cost: '0',
              color: 'Unknown',
              weight: '0',
              archived: false,
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(kAppSpace16),
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
              child: filtered.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(kAppSpace16),
                        child: Text(l10n.addAtLeastOneMaterial),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        final weight = parseLocalizedNumOrFallback(item.weight);
                        final cost = parseLocalizedNumOrFallback(item.cost);
                        final costPerKg = weight <= 0
                            ? 0
                            : (cost / weight) * 1000;
                        return ListTile(
                          key: ValueKey<String>(
                            'calculator.materialPicker.item.${item.name}',
                          ),
                          title: Text(item.name),
                          subtitle: Text(
                            '${item.color} \u2022 ${l10n.materialCostPerKilogramLabel(formatCurrencyValue(costPerKg, currencySymbol: currencySettings.currencySymbol, currencyPosition: currencySettings.currencyPosition, currencySpacing: currencySettings.currencySpacing))}',
                          ),
                          onTap: () {
                            if (item.id == _unsavedSentinelId) {
                              onUnsavedSelected!();
                            } else {
                              onSelected(item);
                            }
                          },
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: kAppSpace16,
                vertical: kAppSpace8,
              ),
              child: AppSecondaryButton(
                key: const ValueKey<String>(
                  'calculator.materialPicker.add.button',
                ),
                icon: const Icon(Icons.add),
                label: l10n.addMaterialButton,
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
          padding: const EdgeInsets.all(kAppSpace16),
          child: Text(l10n.materialsLoadError(error.toString())),
        ),
      ),
    );
  }
}
