import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/settings/materials/material_form.dart';
import 'package:threed_print_cost_calculator/settings/settings_slidable_item.dart';

class Materials extends HookConsumerWidget {
  const Materials({super.key});

  @override
  Widget build(context, ref) {
    final materialsRepository = ref.read(materialsRepositoryProvider);
    final l10n = AppLocalizations.of(context)!;

    String formatWeight(num value) {
      return value % 1 == 0
          ? value.toStringAsFixed(0)
          : value.toStringAsFixed(1);
    }

    return ref
        .watch(materialsStreamProvider)
        .when(
          data: (materials) {
            return Column(
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).height / 4,
                  child: ListView.builder(
                    itemCount: materials.length,
                    itemBuilder: (_, index) {
                      final data = materials[index];
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
                                        ?.copyWith(color: Colors.white),
                                  ),
                                  Text(
                                    key: ValueKey<String>(
                                      'settings.materials.item.$index.color',
                                    ),
                                    data.color,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontSize: 12),
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
                                          .titleSmall
                                          ?.copyWith(fontSize: 12),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  key: ValueKey<String>(
                                    'settings.materials.item.$index.cost',
                                  ),
                                  data.cost,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(color: Colors.white),
                                ),
                                Text(
                                  key: ValueKey<String>(
                                    'settings.materials.item.$index.weight',
                                  ),
                                  '${data.weight}${l10n.gramsSuffix}',
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontSize: 12),
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
                ElevatedButton(
                  onPressed: () => ref.invalidate(materialsStreamProvider),
                  child: Text(l10n.retryButton),
                ),
              ],
            ),
          ),
        );
  }
}
