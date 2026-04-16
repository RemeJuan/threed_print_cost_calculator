import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/database/repositories/printers_repository.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/settings/printers/add_printer.dart';
import 'package:threed_print_cost_calculator/settings/settings_slidable_item.dart';

class Printers extends HookConsumerWidget {
  const Printers({super.key});

  @override
  Widget build(context, ref) {
    final printersRepository = ref.read(printersRepositoryProvider);
    final l10n = AppLocalizations.of(context)!;

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

                      return SettingsSlidableItem(
                        itemKey: ValueKey<String>(
                          'settings.printers.item.$index',
                        ),
                        editButtonKey: ValueKey<String>(
                          'settings.printers.item.$index.edit.button',
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        onDelete: () {
                          printersRepository.deletePrinter(key);
                        },
                        onEdit: () {
                          showDialog<void>(
                            context: context,
                            builder: (_) => AddPrinter(dbRef: key),
                          );
                        },
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                key: ValueKey<String>(
                                  'settings.printers.item.$index.name',
                                ),
                                data.name,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              key: ValueKey<String>(
                                'settings.printers.item.$index.summary',
                              ),
                              '${data.bedSize} (${data.wattage}${l10n.wattsSuffix})',
                              overflow: TextOverflow.ellipsis,
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
                Text(l10n.printersLoadError(error.toString())),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => ref.invalidate(printersStreamProvider),
                  child: Text(l10n.retryButton),
                ),
              ],
            ),
          ),
        );
  }
}
