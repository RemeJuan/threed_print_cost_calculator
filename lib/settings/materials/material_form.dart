import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/app/view/app.dart';
import 'package:threed_print_cost_calculator/settings/providers/materials_notifier.dart';

class MaterialForm extends HookConsumerWidget {
  final String? dbRef;

  const MaterialForm({this.dbRef, super.key});

  @override
  Widget build(context, ref) {
    final notifier = ref.read(materialsProvider.notifier)..init(dbRef);
    final state = ref.watch(materialsProvider);

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
                decoration: const InputDecoration(labelText: 'Name *'),
                onChanged: notifier.updateName,
              ),
              TextFormField(
                initialValue: state.color.value,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(labelText: 'Color *'),
                onChanged: notifier.updateColor,
              ),
              TextFormField(
                initialValue: state.weight.value != null
                    ? state.weight.value.toString()
                    : '',
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Weight *',
                  suffix: Text('g'),
                ),
                onChanged: notifier.updateWeight,
              ),
              TextFormField(
                initialValue: state.cost.value != null
                    ? state.cost.value.toString()
                    : '',
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Cost *'),
                onChanged: notifier.updateCost,
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
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
