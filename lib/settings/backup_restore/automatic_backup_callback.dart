import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/database/database.dart';
import 'package:threed_print_cost_calculator/startup.dart';
import 'package:threed_print_cost_calculator/settings/backup_restore/automatic_backup_service.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void automaticBackupCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    final prefs = await SharedPreferences.getInstance();
    final db = await DatabaseStorageImpl().openDb();
    try {
      await startupMigration(db);
    } catch (_) {
      await db.close();
      rethrow;
    }
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        databaseProvider.overrideWithValue(db),
      ],
    );
    try {
      final result = await container
          .read(automaticBackupServiceProvider)
          .runOnce();
      return result != AutomaticBackupRunResult.failure;
    } finally {
      container.dispose();
      await db.close();
    }
  });
}
