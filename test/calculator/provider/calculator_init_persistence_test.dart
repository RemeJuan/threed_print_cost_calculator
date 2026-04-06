import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/database/repositories/calculator_preferences_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

class _NoopLogSink extends AppLogSink {
  const _NoopLogSink();

  @override
  void log(AppLogEvent event) {}
}

void main() {
  late Database db;
  late ProviderContainer container;

  setUp(() async {
    db = await databaseFactoryMemory.openDatabase(
      'calculator_init_${DateTime.now().microsecondsSinceEpoch}.db',
    );
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        appLogSinkProvider.overrideWithValue(const _NoopLogSink()),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test(
    'init hydrates persisted calculator state and settings writes back',
    () async {
      await StoreRef<String, Object?>.main()
          .record(DBName.settings.name)
          .put(
            db,
            GeneralSettingsModel(
              electricityCost: '0.32',
              wattage: '140',
              activePrinter: 'printer-1',
              selectedMaterial: 'material-1',
              wearAndTear: '1.5',
              failureRisk: '7.25',
              labourRate: '22',
            ).toMap(),
          );

      await StoreRef<String, Object?>.main().record('spoolWeight').put(db, {
        'value': '750',
      });
      await StoreRef<String, Object?>.main().record('spoolCost').put(db, {
        'value': '19.99',
      });

      await stringMapStoreFactory
          .store(DBName.printers.name)
          .record('printer-1')
          .put(
            db,
            const PrinterModel(
              id: 'printer-1',
              name: 'Prusa MK4',
              bedSize: '250x210',
              wattage: '180',
              archived: false,
            ).toMap(),
          );

      await stringMapStoreFactory
          .store(DBName.materials.name)
          .record('material-1')
          .put(
            db,
            const MaterialModel(
              id: 'material-1',
              name: 'PLA',
              cost: '25',
              color: 'Red',
              weight: '1000',
              archived: false,
            ).toMap(),
          );

      final notifier = container.read(calculatorProvider.notifier);
      await notifier.init();
      await notifier
          .updateWearAndTear(2.5)
          .then((_) => notifier.updateFailureRisk(11.5))
          .then((_) => notifier.updateLabourRate(30));

      final state = container.read(calculatorProvider);
      expect(state.watt.value, 180);
      expect(state.kwCost.value, 0.32);
      expect(state.spoolWeight.value, 750);
      expect(state.spoolCost.value, 19.99);
      expect(state.spoolCostText, '19.99');
      expect(state.wearAndTear.value, 2.5);
      expect(state.failureRisk.value, 11.5);
      expect(state.labourRate.value, 30);
      expect(state.materialUsages, hasLength(1));
      expect(state.materialUsages.first.materialId, 'material-1');
      expect(state.materialUsages.first.materialName, 'PLA');
      expect(state.materialUsages.first.costPerKg, 25);

      final savedSettings = await container
          .read(settingsRepositoryProvider)
          .getSettings();
      expect(savedSettings.wearAndTear, '2.5');
      expect(savedSettings.failureRisk, '11.50');
      expect(savedSettings.labourRate, '30');

      final savedPrefs = container.read(
        calculatorPreferencesRepositoryProvider,
      );
      expect(await savedPrefs.getStringValue('spoolWeight'), '750');
      expect(await savedPrefs.getStringValue('spoolCost'), '19.99');
    },
  );
}
