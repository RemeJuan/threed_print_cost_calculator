import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/app/app.dart';
import 'package:threed_print_cost_calculator/settings/providers/printers_notifier.dart';

class AddPrinter extends HookConsumerWidget {
  const AddPrinter({this.dbRef, super.key});

  final String? dbRef;

  @override
  Widget build(context, ref) {
    final notifier = ref.read(printersProvider.notifier)..init(dbRef);
    final state = ref.watch(printersProvider);

    return Dialog(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 16,
        ),
        physics: const ClampingScrollPhysics(),
        child: AutofillGroup(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                initialValue: state.name.value,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  prefixIcon: Icon(Icons.text_fields),
                ),
                onChanged: notifier.updateName,
              ),
              TextFormField(
                initialValue: state.bedSize.value != null
                    ? state.bedSize.value.toString()
                    : '',
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: 'Bed Size *',
                  prefixIcon: Icon(Icons.fullscreen),
                ),
                onChanged: notifier.updateBedSize,
              ),
              TextFormField(
                initialValue: state.wattage.value.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Wattage *',
                  prefixIcon: Icon(Icons.power),
                ),
                onChanged: notifier.updateWattage,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: DEEP_BLUE,
                  textStyle:
                      Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontSize: 16,
                          ),
                ),
                onPressed: () => notifier.submit(dbRef),
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
