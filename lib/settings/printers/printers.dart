import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/database/repositories/printers_repository.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/settings/printers/add_printer.dart';
import 'package:threed_print_cost_calculator/settings/printers/printer_list_item.dart';

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
                for (final entry in printers.asMap().entries)
                  PrinterListItem(
                    key: ValueKey(entry.value.id),
                    index: entry.key,
                    name: entry.value.name,
                    bedSize: entry.value.bedSize,
                    wattage: entry.value.wattage,
                    wattsSuffix: l10n.wattsSuffix,
                    onDelete: () {
                      printersRepository.deletePrinter(entry.value.id);
                    },
                    onEdit: () {
                      showDialog<void>(
                        context: context,
                        builder: (_) => AddPrinter(dbRef: entry.value.id),
                      );
                    },
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
