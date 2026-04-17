import 'package:riverpod/riverpod.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/database/database_record_mapper.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

class SettingsStoreReader {
  SettingsStoreReader(this.ref);

  final Ref ref;

  Database get _db => ref.read(databaseProvider);

  Future<GeneralSettingsModel> getSettings() async {
    final settings = await StoreRef<String, Object?>.main()
        .record(DBName.settings.name)
        .get(_db);
    if (settings == null) {
      return GeneralSettingsModel.initial();
    }

    final settingsMap = castDatabaseRecord(
      settings,
      storeName: DBName.settings.name,
      key: DBName.settings.name,
    );
    if (settingsMap == null) {
      return GeneralSettingsModel.initial();
    }

    final printerSnapshots = await stringMapStoreFactory
        .store(DBName.printers.name)
        .find(_db);
    final printerIds = printerSnapshots.map((record) => record.key).toList();

    final generalSettings = GeneralSettingsModel.fromMap(settingsMap);
    if (printerIds.isEmpty) {
      return generalSettings.copyWith(activePrinter: '');
    }

    if (!printerIds.contains(generalSettings.activePrinter)) {
      return generalSettings.copyWith(activePrinter: printerIds.first);
    }

    return generalSettings;
  }
}
