import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/helpers/calculator_helpers.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculation_results_state.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';

class SaveForm extends HookConsumerWidget {
  final CalculationResult data;
  final ValueNotifier<bool> showSave;

  const SaveForm({required this.data, required this.showSave, super.key});

  @override
  Widget build(context, ref) {
    final name = useState<String>('');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Print Name',
              ),
              onChanged: (value) {
                name.value = value;
              },
            ),
          ),
          IconButton(
            onPressed: name.value.isEmpty
                ? null
                : () async {
                    final model = HistoryModel(
                      name: name.value,
                      electricityCost: data.electricity,
                      filamentCost: data.filament,
                      totalCost: data.total,
                      riskCost: data.risk,
                      labourCost: data.labour,
                      date: DateTime.now(),
                    );
                    await ref.read(calculatorHelpersProvider).savePrint(model);
                    showSave.value = false;
                  },
            icon: const Icon(Icons.save),
          ),
          IconButton(
            onPressed: () {
              showSave.value = false;
            },
            icon: const Icon(Icons.cancel),
          ),
        ],
      ),
    );
  }
}
