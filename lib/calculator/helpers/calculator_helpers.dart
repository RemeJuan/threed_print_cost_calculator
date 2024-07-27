import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/app/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';

final calculatorHelpersProvider = Provider<CalculatorHelpers>(
  CalculatorHelpers.new,
);

class CalculatorHelpers {
  final Ref ref;

  CalculatorHelpers(this.ref);

  Database get db => ref.read(databaseProvider);

  double electricityCost(
    int watts,
    int hours,
    int minutes,
    double cost,
  ) {
    //Wattage in Watts / 1,000 × Hours Used × Electricity Price per kWh = Cost of Electricity

    final w = watts / 1000;
    final m = hours + (minutes / 60);

    final totalFixed = (w * m * cost).toStringAsFixed(2);

    return double.parse(totalFixed);
  }

  double filamentCost(
    int itemWeight,
    int spoolWeight,
    int cost,
  ) {
    //Weight in grams / 1,000 × Cost per kg = Cost of filament
    final w = itemWeight / spoolWeight;

    final totalFixed = (w * cost).toStringAsFixed(2);

    return double.parse(totalFixed);
  }

  static double labourCost(
    double labourRate,
    double labourTime,
  ) {
    //Labour Rate * Labour Time = Labour Cost
    final totalFixed = (labourRate * labourTime).toStringAsFixed(2);
    return double.parse(totalFixed);
  }

  Future<void> addOrUpdateRecord(
    String key,
    String value,
  ) async {
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

  Future<void> savePrint(
    HistoryModel value,
  ) async {
    final store = stringMapStoreFactory.store('history');

    try {
      await store.add(db, value.toMap());
    } catch (e) {
      BotToast.showText(text: 'Error saving print');
    }
  }
}
