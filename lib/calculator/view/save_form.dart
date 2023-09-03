import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:threed_print_cost_calculator/calculator/helpers/calculator_helpers.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';

class SaveForm extends HookWidget {
  const SaveForm({required this.data, required this.showSave, super.key});

  final Map<dynamic, dynamic> data;
  final ValueNotifier<bool> showSave;

  @override
  Widget build(BuildContext context) {
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
                    final model = HistoryModel.fromMap({
                      'name': name.value,
                      'totalCost': data['total'] ?? '0',
                      'riskCost': data['risk'] ?? '0',
                      'filamentCost': data['filament'] ?? '0',
                      'electricityCost': data['electricity'] ?? '0',
                      'labourCost': data['labour'] ?? '0',
                      'date': DateTime.now().toString(),
                    });
                    await CalculatorHelpers.savePrint(model);
                    showSave.value = false;
                    BotToast.showText(text: 'Print saved');
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
