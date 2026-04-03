import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';
import 'package:threed_print_cost_calculator/settings/materials/material_form.dart';
import 'package:threed_print_cost_calculator/shared/theme.dart';

class Materials extends HookConsumerWidget {
  const Materials({super.key});

  @override
  Widget build(context, ref) {
    final materialsRepository = ref.read(materialsRepositoryProvider);
    final l10n = S.of(context);

    return ref
        .watch(materialsStreamProvider)
        .when(
          data: (materials) {
            return Column(
              children: [
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    itemCount: materials.length,
                    itemBuilder: (_, index) {
                      final data = materials[index];
                      final key = data.id;

                      return Slidable(
                        key: ValueKey<String>('settings.materials.item.$index'),
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (_) {
                                materialsRepository.deleteMaterial(key);
                              },
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                            ),
                            SlidableAction(
                              key: ValueKey<String>(
                                'settings.materials.item.$index.edit.button',
                              ),
                              onPressed: (_) {
                                showDialog<void>(
                                  context: context,
                                  builder: (_) => MaterialForm(dbRef: key),
                                );
                              },
                              backgroundColor: LIGHT_BLUE,
                              foregroundColor: Colors.white,
                              icon: Icons.edit,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  key: ValueKey<String>(
                                    'settings.materials.item.$index.name',
                                  ),
                                  data.name,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(color: Colors.white),
                                ),
                                Text(
                                  key: ValueKey<String>(
                                    'settings.materials.item.$index.color',
                                  ),
                                  data.color,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontSize: 12),
                                ),
                              ],
                            ),
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
                Text('Failed to load materials: $error'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => ref.invalidate(materialsStreamProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
  }
}
