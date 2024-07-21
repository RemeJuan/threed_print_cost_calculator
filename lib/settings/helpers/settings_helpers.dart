import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/app/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';

class SettingsHelpers {
  final Ref ref;

  SettingsHelpers(this.ref);

  Future<void> saveMaterial(
    MaterialModel value,
  ) async {
    final db = ref.read(databaseProvider);
    final store = stringMapStoreFactory.store('materials');

    try {
      await store.add(db, value.toMap());
    } catch (e) {
      BotToast.showText(text: 'Error saving print');
    }
  }
}
