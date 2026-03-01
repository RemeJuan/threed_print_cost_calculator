import 'package:bot_toast/bot_toast.dart';
import 'package:riverpod/riverpod.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';

final calculatorHelpersProvider = Provider<CalculatorHelpers>(
  CalculatorHelpers.new,
);

class CalculatorHelpers {
  final Ref ref;

  CalculatorHelpers(this.ref);

  Database get db => ref.read(databaseProvider);

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

  /// Calculates total filament cost for a multi-material print.
  ///
  /// Each [MaterialUsage] contributes `(weightGrams / spoolWeight) * spoolCost`.
  /// Usages with zero spool weight are skipped to avoid division by zero.
  /// Returns 0 if [usages] is empty.
  num multiFilamentCost(List<MaterialUsage> usages) {
    if (usages.isEmpty) return 0.0;
    num total = 0;
    for (final usage in usages) {
      if (usage.spoolWeight > 0) {
        total += filamentCost(usage.weightGrams, usage.spoolWeight, usage.spoolCost);
      }
    }
    return num.parse(total.toStringAsFixed(2));
  }

  /// Computes per-material filament costs and returns a new list with
  /// [MaterialUsage.filamentCost] populated on each entry.
  List<MaterialUsage> computeUsageCosts(List<MaterialUsage> usages) {
    return usages.map((usage) {
      num cost = 0;
      if (usage.spoolWeight > 0) {
        cost = filamentCost(usage.weightGrams, usage.spoolWeight, usage.spoolCost);
      }
      return usage.copyWith(filamentCost: cost);
    }).toList();
  }

  static num labourCost(num labourRate, num labourTime) {
    //Labour Rate * Labour Time = Labour Cost
    final totalFixed = (labourRate * labourTime).toStringAsFixed(2);
    return num.parse(totalFixed);
  }

  Future<void> addOrUpdateRecord(String key, String value) async {
    final store = stringMapStoreFactory.store();
    // Check if the record exists before adding or updating it.
    await db.transaction((txn) async {
      // Look of existing record
      final existing = await store.record(key).getSnapshot(txn);
      if (existing == null) {
        // code not found, add
        await store.record(key).add(txn, {'value': value});
      } else {
        // Update existing
        await existing.ref.update(txn, {'value': value});
      }
    });
  }

  Future<void> savePrint(HistoryModel value) async {
    try {
      final data = {...value.toMap(), 'date': value.date.toIso8601String()};
      final dbHelpers = ref.read(dbHelpersProvider(DBName.history));
      await dbHelpers.insertRecord(data);
      BotToast.showText(text: 'Print saved');
    } catch (e) {
      BotToast.showText(text: 'Error saving print');
    }
  }
}
