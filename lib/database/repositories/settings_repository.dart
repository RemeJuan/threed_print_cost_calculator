import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/database/database_record_mapper.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>(
  SettingsRepository.new,
);

class SettingsRepository {
  SettingsRepository(this.ref);

  final Ref ref;

  Database get _db => ref.read(databaseProvider);

  StoreRef<String, Object?> get _store => StoreRef<String, Object?>.main();

  Future<GeneralSettingsModel> getSettings() async {
    final snapshot = await _store.record(DBName.settings.name).getSnapshot(_db);
    return _normalizeSettings(snapshot?.value, key: DBName.settings.name);
  }

  Stream<GeneralSettingsModel> watchSettings() async* {
    yield await getSettings();
    await for (final snapshot
        in _store.record(DBName.settings.name).onSnapshot(_db)) {
      yield await _normalizeSettings(
        snapshot?.value,
        key: DBName.settings.name,
      );
    }
  }

  Future<void> saveSettings(GeneralSettingsModel settings) async {
    await _store.record(DBName.settings.name).put(_db, settings.toMap());
  }

  Future<GeneralSettingsModel> _normalizeSettings(
    Object? raw, {
    required Object key,
  }) async {
    final map = castDatabaseRecord(
      raw,
      storeName: DBName.settings.name,
      key: key,
    );
    if (map == null) {
      return GeneralSettingsModel.initial();
    }

    GeneralSettingsModel settings;
    try {
      settings = GeneralSettingsModel.fromMap(map);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          'Falling back to default settings for key=$key: $error\n$stackTrace',
        );
      }
      return GeneralSettingsModel.initial();
    }

    final printersStore = stringMapStoreFactory.store(DBName.printers.name);
    final printerSnapshots = await printersStore.find(_db);
    final printerIds = printerSnapshots
        .map((snapshot) => snapshot.key.toString())
        .toList();

    if (printerIds.isEmpty) {
      return settings.copyWith(activePrinter: '');
    }

    if (!printerIds.contains(settings.activePrinter)) {
      return settings.copyWith(activePrinter: printerIds.first);
    }

    return settings;
  }
}

final settingsStreamProvider = StreamProvider<GeneralSettingsModel>((ref) {
  return ref.watch(settingsRepositoryProvider).watchSettings();
});
