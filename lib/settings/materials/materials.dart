import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/settings/materials/material_form.dart';
import 'package:threed_print_cost_calculator/settings/settings_slidable_item.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/utils/weight_formatting.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_search_bar.dart';

class Materials extends HookConsumerWidget {
  const Materials({super.key});

  @override
  Widget build(context, ref) {
    final materialsRepository = ref.read(materialsRepositoryProvider);
    final l10n = AppLocalizations.of(context)!;
    final searchController = useTextEditingController();

    return ref
        .watch(materialsStreamProvider)
        .when(
          data: (materials) {
            final q = searchController.text.toLowerCase();
            final filtered = materials.where((m) {
              if (q.isEmpty) return true;
              return m.name.toLowerCase().contains(q) ||
                  m.color.toLowerCase().contains(q);
            }).toList();

            return Column(
              children: [
                Padding(
                  padding: kAppSearchSectionPadding,
                  child: AppSearchBar(
                    controller: searchController,
                    hintText: l10n.searchMaterialsHint,
                    showClearButton: true,
                    onChanged: (_) {},
                  ),
                ),
                SizedBox(
                  height: MediaQuery.sizeOf(context).height / 4,
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, index) {
                      final data = filtered[index];
                      final key = data.id;

                      return SettingsSlidableItem(
                        itemKey: ValueKey<String>(
                          'settings.materials.item.$index',
                        ),
                        editButtonKey: ValueKey<String>(
                          'settings.materials.item.$index.edit.button',
                        ),
                        onDelete: () {
                          materialsRepository.deleteMaterial(key);
                        },
                        onEdit: () {
                          showDialog<void>(
                            context: context,
                            builder: (_) => MaterialForm(dbRef: key),
                          );
                        },
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    key: ValueKey<String>(
                                      'settings.materials.item.$index.name',
                                    ),
                                    data.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(color: TEXT_PRIMARY),
                                  ),
                                  Text(
                                    key: ValueKey<String>(
                                      'settings.materials.item.$index.color',
                                    ),
                                    data.color,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall,
                                  ),
                                  if (data.autoDeductEnabled)
                                    Text(
                                      key: ValueKey<String>(
                                        'settings.materials.item.$index.remaining',
                                      ),
                                      '${l10n.remainingLabel} ${formatWeight(data.remainingWeight)}${l10n.gramsSuffix}',
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: kAppSpace12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  key: ValueKey<String>(
                                    'settings.materials.item.$index.cost',
                                  ),
                                  data.cost,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(color: TEXT_PRIMARY),
                                ),
                                Text(
                                  key: ValueKey<String>(
                                    'settings.materials.item.$index.weight',
                                  ),
                                  '${data.weight}${l10n.gramsSuffix}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: TEXT_SECONDARY),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.materialsLoadError(error.toString())),
                const SizedBox(height: 8),
                AppPrimaryButton(
                  onPressed: () => ref.invalidate(materialsStreamProvider),
                  label: l10n.retryButton,
                ),
              ],
            ),
          ),
        );
  }
}
