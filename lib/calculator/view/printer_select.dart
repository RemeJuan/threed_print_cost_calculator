import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/database/repositories/printers_repository.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';

class PrinterSelect extends ConsumerWidget {
  const PrinterSelect({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final printersAsync = ref.watch(printersStreamProvider);
    final calculatorState = ref.watch(calculatorProvider);

    return printersAsync.when(
      data: (data) {
        if (data.isEmpty) return const SizedBox.shrink();

        final selectedPrinterId = calculatorState.activePrinterId.isEmpty
            ? null
            : calculatorState.activePrinterId;

        return KeyedSubtree(
          key: const ValueKey<String>('calculator.printer.select'),
          child: DropdownButtonFormField<String>(
            key: ValueKey<String>(
              'calculator.printer.field.$selectedPrinterId',
            ),
            hint: Text(l10n.selectPrinterHint),
            alignment: AlignmentDirectional.centerStart,
            isExpanded: true,
            initialValue: data.any((printer) => printer.id == selectedPrinterId)
                ? selectedPrinterId
                : null,
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
                    if (v == null) return;
                    await ref
                        .read(calculatorProvider.notifier)
                        .selectPrinter(v);
                  },
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }
}
