import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/database/repositories/printers_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';

class PrinterSelect extends HookConsumerWidget {
  const PrinterSelect({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final loading = useState<bool>(true);
    final generalSettings = useState(GeneralSettingsModel.initial());
    final l10n = S.of(context);

    Future<void> getSettings() async {
      generalSettings.value = await ref
          .read(settingsRepositoryProvider)
          .getSettings();
      loading.value = false;
    }

    useEffect(() {
      // ignore: unnecessary_statements
      getSettings();

      return null;
    }, []);

    final printersAsync = ref.watch(printersStreamProvider);

    return printersAsync.when(
      data: (data) {
        if (data.isNotEmpty && !loading.value) {
          return DropdownButtonFormField<String>(
            key: const ValueKey<String>('calculator.printer.select'),
            hint: Text(l10n.selectPrinterHint),
            alignment: AlignmentDirectional.centerStart,
            isExpanded: true,
            initialValue: generalSettings.value.activePrinter.isEmpty
                ? null
                : generalSettings.value.activePrinter,
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
                    final updated = generalSettings.value.copyWith(
                      activePrinter: v!,
                    );
                    generalSettings.value = updated;
                    await ref
                        .read(settingsRepositoryProvider)
                        .saveSettings(updated);

                    final wattage = data.firstWhere((e) => e.id == v).wattage;

                    ref
                        .read(calculatorProvider.notifier)
                        .updateWatt(wattage.toString());
                  },
          );
        }
        return const SizedBox.shrink();
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }
}
