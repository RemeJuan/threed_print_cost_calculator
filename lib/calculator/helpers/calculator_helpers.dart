import 'package:bot_toast/bot_toast.dart';
import 'package:riverpod/riverpod.dart';
import 'package:threed_print_cost_calculator/database/repositories/calculator_preferences_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/history_repository.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage_input.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';

final calculatorHelpersProvider = Provider<CalculatorHelpers>(
  CalculatorHelpers.new,
);

class CalculatorHelpers {
  final Ref ref;

  CalculatorHelpers(this.ref);

  num electricityCost(num watts, num hours, num minutes, num cost) {
    //Wattage in Watts / 1,000 × Hours Used × Electricity Price per kWh = Cost of Electricity
    final w = watts / 1000;
    final m = hours + (minutes / 60);

    final totalFixed = (w * m * cost).toStringAsFixed(2);

    return num.parse(totalFixed);
  }

  num filamentCost(num itemWeight, num spoolWeight, num cost) {
    //Weight in grams / 1,000 × Cost per kg = Cost of filament
    if (spoolWeight == 0 && itemWeight == 0) {
      return 0.0;
    }

    final w = itemWeight / spoolWeight;

    final totalFixed = (w * cost).toStringAsFixed(2);

    return num.parse(totalFixed);
  }

  num multiMaterialFilamentCost(List<MaterialUsageInput> usages) {
    // Compute each usage cost and round to cents before summing to avoid
    // accumulation rounding drift.
    final total = usages.fold<num>(0, (sum, usage) {
      final raw = (usage.weightGrams * usage.costPerKg) / 1000;
      // Round per-item cost to two decimals (cents) before adding.
      final perItem = num.parse(raw.toStringAsFixed(2));
      return sum + perItem;
    });

    return num.parse(total.toStringAsFixed(2));
  }

  static num labourCost(num labourRate, num labourTime) {
    //Labour Rate * Labour Time = Labour Cost
    final totalFixed = (labourRate * labourTime).toStringAsFixed(2);
    return num.parse(totalFixed);
  }

  Future<void> addOrUpdateRecord(String key, String value) async {
    await ref
        .read(calculatorPreferencesRepositoryProvider)
        .saveStringValue(key, value);
  }

  Future<void> savePrint(HistoryModel value) async {
    try {
      await ref.read(historyRepositoryProvider).saveHistory(value);
      BotToast.showText(text: 'Print saved');
    } catch (e) {
      BotToast.showText(text: 'Error saving print');
    }
  }
}
