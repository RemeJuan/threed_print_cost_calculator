import 'package:bot_toast/bot_toast.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/locator.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';

class SettingsHelpers {
  static Future<void> saveMaterial(
    MaterialModel value,
  ) async {
    final db = sl<Database>();
    final store = stringMapStoreFactory.store('materials');

    try {
      await store.add(db, value.toMap());
    } catch (e) {
      BotToast.showText(text: 'Error saving print');
    }
  }
}
