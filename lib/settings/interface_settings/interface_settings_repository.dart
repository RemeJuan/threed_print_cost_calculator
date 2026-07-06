import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/database/database_record_mapper.dart';
import 'package:threed_print_cost_calculator/settings/interface_settings/interface_settings_model.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

final interfaceSettingsRepositoryProvider =
    Provider<InterfaceSettingsRepository>(InterfaceSettingsRepository.new);

class InterfaceSettingsRepository {
  InterfaceSettingsRepository(this.ref);
  final Ref ref;
  AppLogger get _logger => ref.read(appLoggerProvider);
  Database get _db => ref.read(databaseProvider);
  StoreRef<String, Object?> get _store => StoreRef<String, Object?>.main();

  Future<InterfaceSettingsModel> getSettings() async {
    final snapshot = await _store
        .record(DBName.interfaceSettings.name)
        .getSnapshot(_db);
    return _normalize(snapshot?.value, key: DBName.interfaceSettings.name);
  }

  Stream<InterfaceSettingsModel> watchSettings() async* {
    InterfaceSettingsModel? last;
    await for (final snapshot
        in _store.record(DBName.interfaceSettings.name).onSnapshot(_db)) {
      final settings = await _normalize(
        snapshot?.value,
        key: DBName.interfaceSettings.name,
      );
      if (settings != last) {
        last = settings;
        yield settings;
      }
    }
  }

  Future<void> saveSettings(InterfaceSettingsModel settings) async {
    await _store
        .record(DBName.interfaceSettings.name)
        .put(_db, settings.toMap());
  }

  Future<void> updateSettings(
    InterfaceSettingsModel Function(InterfaceSettingsModel current) updater,
  ) async {
    await _db.transaction((txn) async {
      final raw = await _store.record(DBName.interfaceSettings.name).get(txn);
      final current = await _normalize(raw, key: DBName.interfaceSettings.name);
      await _store
          .record(DBName.interfaceSettings.name)
          .put(txn, updater(current).toMap());
    });
  }

  Future<InterfaceSettingsModel> _normalize(
    Object? raw, {
    required Object key,
  }) async {
    if (raw == null) return InterfaceSettingsModel.initial();
    final map = castDatabaseRecord(
      raw,
      storeName: DBName.interfaceSettings.name,
      key: key,
      logger: _logger,
    );
    if (map == null) return InterfaceSettingsModel.initial();
    try {
      return InterfaceSettingsModel.fromMap(map);
    } catch (error, stackTrace) {
      _logger.warn(
        AppLogCategory.migration,
        'Falling back to default interface settings',
        context: {'store': DBName.interfaceSettings.name, 'key': key},
        error: error,
        stackTrace: stackTrace,
      );
      return InterfaceSettingsModel.initial();
    }
  }
}

final interfaceSettingsFutureProvider = FutureProvider<InterfaceSettingsModel>((
  ref,
) async {
  ref.watch(appRefreshProvider);
  return ref.watch(interfaceSettingsRepositoryProvider).getSettings();
});

final interfaceSettingsProvider = Provider<InterfaceSettingsModel>((ref) {
  final async = ref.watch(interfaceSettingsFutureProvider);
  return async.maybeWhen(
    data: (value) => value,
    orElse: InterfaceSettingsModel.initial,
  );
});
