import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/database/repositories/printers_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';

class PrinterSelect extends ConsumerWidget {
  const PrinterSelect({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final printersAsync = ref.watch(printersStreamProvider);
    final settingsAsync = ref.watch(settingsStreamProvider);

    return settingsAsync.when(
      data: (generalSettings) => printersAsync.when(
        data: (data) {
          if (data.isEmpty) return const SizedBox.shrink();

          return DropdownButtonFormField<String>(
            key: const ValueKey<String>('calculator.printer.select'),
            hint: Text(l10n.selectPrinterHint),
            alignment: AlignmentDirectional.centerStart,
            isExpanded: true,
            initialValue: generalSettings.activePrinter.isEmpty
                ? null
                : generalSettings.activePrinter,
            items: data.map((e) {
              return DropdownMenuItem(
                key: ValueKey<String>('calculator.printer.option.${e.name}'),
                value: e.id,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(e.name, overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 12),
                    Text('${e.wattage}${l10n.wattsSuffix}'),
                  ],
                ),
              );
            }).toList(),
            onChanged: data.length == 1
                ? null
                : (v) async {
                    final updated = generalSettings.copyWith(activePrinter: v!);
                    await ref
                        .read(settingsRepositoryProvider)
                        .saveSettings(updated);

                    final wattage = data.firstWhere((e) => e.id == v).wattage;

                    ref
                        .read(calculatorProvider.notifier)
                        .updateWatt(wattage.toString());
                  },
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (error, stackTrace) => const SizedBox.shrink(),
      ),
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }
}
