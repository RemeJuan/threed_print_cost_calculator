import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/database/repositories/printers_repository.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';
import 'package:threed_print_cost_calculator/settings/printers/add_printer.dart';
import 'package:threed_print_cost_calculator/shared/theme.dart';

class Printers extends HookConsumerWidget {
  const Printers({super.key});

  @override
  Widget build(context, ref) {
    final printersRepository = ref.read(printersRepositoryProvider);
    final l10n = S.of(context);

    return ref
        .watch(printersStreamProvider)
        .when(
          data: (printers) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).height / 4,
                  child: ListView.builder(
                    itemCount: printers.length,
                    itemBuilder: (_, index) {
                      final data = printers[index];
                      final key = data.id;

                      return Slidable(
                        key: ValueKey<String>('settings.printers.item.$index'),
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (_) {
                                printersRepository.deletePrinter(key);
                              },
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                            ),
                            SlidableAction(
                              key: ValueKey<String>(
                                'settings.printers.item.$index.edit.button',
                              ),
                              onPressed: (_) {
                                showDialog<void>(
                                  context: context,
                                  builder: (_) => AddPrinter(dbRef: key),
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
                            Text(
                              key: ValueKey<String>(
                                'settings.printers.item.$index.name',
                              ),
                              data.name,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: Colors.white),
                            ),
                            Text(
                              key: ValueKey<String>(
                                'settings.printers.item.$index.summary',
                              ),
                              '${data.bedSize} (${data.wattage}${l10n.wattsSuffix})',
                              style: Theme.of(context).textTheme.titleSmall,
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
                Text('Failed to load printers: $error'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => ref.invalidate(printersStreamProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
  }
}
