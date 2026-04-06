import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

class _NoopLogSink extends AppLogSink {
  const _NoopLogSink();

  @override
  void log(AppLogEvent event) {}
}

GeneralSettingsModel _settings({
  String electricityCost = '',
  String wattage = '',
  String activePrinter = '',
  String selectedMaterial = '',
  String wearAndTear = '',
  String failureRisk = '',
  String labourRate = '',
}) {
  return GeneralSettingsModel(
    electricityCost: electricityCost,
    wattage: wattage,
    activePrinter: activePrinter,
    selectedMaterial: selectedMaterial,
    wearAndTear: wearAndTear,
    failureRisk: failureRisk,
    labourRate: labourRate,
  );
}

void main() {
  late Database db;
  late ProviderContainer container;

  setUp(() async {
    db = await databaseFactoryMemory.openDatabase(
      'settings_repository_${DateTime.now().microsecondsSinceEpoch}.db',
    );
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        appLogSinkProvider.overrideWithValue(const _NoopLogSink()),
        appLoggerConfigProvider.overrideWithValue(
          const AppLoggerConfig(minLevel: AppLogLevel.debug),
        ),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('getSettings returns initial defaults when no record exists', () async {
    final settings = await container
        .read(settingsRepositoryProvider)
        .getSettings();

    expect(settings, GeneralSettingsModel.initial());
  });

  test('getSettings preserves activePrinter when it still exists', () async {
    final printersStore = stringMapStoreFactory.store(DBName.printers.name);
    await printersStore.record('printer-1').put(db, {'name': 'Printer 1'});
    await printersStore.record('printer-2').put(db, {'name': 'Printer 2'});
    await StoreRef<String, Object?>.main().record(DBName.settings.name).put(
      db,
      {
        ..._settings(
          activePrinter: 'printer-2',
          electricityCost: '0.2',
        ).toMap(),
      },
    );

    final settings = await container
        .read(settingsRepositoryProvider)
        .getSettings();

    expect(settings.activePrinter, 'printer-2');
  });

  test('getSettings clears activePrinter when no printers exist', () async {
    await StoreRef<String, Object?>.main().record(DBName.settings.name).put(
      db,
      {
        ..._settings(
          activePrinter: 'printer-2',
          electricityCost: '0.2',
        ).toMap(),
      },
    );

    final settings = await container
        .read(settingsRepositoryProvider)
        .getSettings();

    expect(settings.activePrinter, '');
  });

  test('getSettings falls back to the first printer when needed', () async {
    final printersStore = stringMapStoreFactory.store(DBName.printers.name);
    await printersStore.record('printer-1').put(db, {'name': 'Printer 1'});
    await printersStore.record('printer-2').put(db, {'name': 'Printer 2'});
    await StoreRef<String, Object?>.main().record(DBName.settings.name).put(
      db,
      {
        ..._settings(
          activePrinter: 'missing-printer',
          failureRisk: '0.1',
        ).toMap(),
      },
    );

    final settings = await container
        .read(settingsRepositoryProvider)
        .getSettings();

    expect(settings.activePrinter, 'printer-1');
  });

  test('watchSettings emits the initial value and later updates', () async {
    final repository = container.read(settingsRepositoryProvider);
    final expectation = expectLater(
      repository.watchSettings(),
      emitsInOrder([
        predicate<GeneralSettingsModel>(
          (settings) => settings == GeneralSettingsModel.initial(),
        ),
        predicate<GeneralSettingsModel>(
          (settings) =>
              settings.electricityCost == '0.3' &&
              settings.activePrinter == 'printer-1' &&
              settings.labourRate == '18',
        ),
      ]),
    );

    final printersStore = stringMapStoreFactory.store(DBName.printers.name);
    await printersStore.record('printer-1').put(db, {'name': 'Printer 1'});
    await StoreRef<String, Object?>.main()
        .record(DBName.settings.name)
        .put(db, {
          ..._settings(
            electricityCost: '0.3',
            activePrinter: 'printer-1',
            labourRate: '18',
          ).toMap(),
        });

    await expectation;
  });
}
