import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';
import 'package:threed_print_cost_calculator/settings/providers/printers_notifier.dart';
import 'package:threed_print_cost_calculator/shared/theme.dart';

class AddPrinter extends HookConsumerWidget {
  const AddPrinter({this.dbRef, super.key});

  final String? dbRef;

  @override
  Widget build(context, ref) {
    final notifier = ref.read(printersProvider.notifier)..init(dbRef);
    final state = ref.watch(printersProvider);
    final l10n = S.of(context);

    return Dialog(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        physics: const ClampingScrollPhysics(),
        child: AutofillGroup(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                initialValue: state.name.value,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(labelText: l10n.printerNameLabel),
                onChanged: notifier.updateName,
              ),
              TextFormField(
                initialValue: state.bedSize.value,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(labelText: l10n.bedSizeLabel),
                onChanged: notifier.updateBedSize,
              ),
              TextFormField(
                initialValue: state.wattage.value,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.wattageLabel),
                onChanged: notifier.updateWattage,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: DEEP_BLUE,
                  textStyle: Theme.of(
                    context,
                  ).textTheme.displayMedium?.copyWith(fontSize: 16),
                ),
                onPressed: () => notifier.submit(dbRef),
                child: Text(l10n.saveButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
