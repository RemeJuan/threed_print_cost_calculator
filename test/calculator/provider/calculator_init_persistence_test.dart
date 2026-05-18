import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:threed_print_cost_calculator/calculator/model/pricing_models.dart';
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
      expect(state.activePrinterId, 'printer-1');
      expect(state.selectedMaterialId, 'material-1');
      expect(state.markupPercentOverridden, isFalse);
      expect(state.hasHydratedDefaults, isTrue);
      expect(state.materialUsages, isEmpty);

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

  group('local-only override persistence', () {
    Future<void> seedCalculatorData() async {
      await StoreRef<String, Object?>.main()
          .record(DBName.settings.name)
          .put(
            db,
            GeneralSettingsModel(
              electricityCost: '0.50',
              wattage: '100',
              activePrinter: 'printer-1',
              selectedMaterial: 'material-1',
              wearAndTear: '1.50',
              failureRisk: '5.00',
              labourRate: '20',
              pricingMarkupPercent: '10',
              pricingSetupFee: '5',
              pricingRoundingMode: 'none',
            ).toMap(),
          );

      await StoreRef<String, Object?>.main().record('spoolWeight').put(db, {
        'value': '1000',
      });
      await StoreRef<String, Object?>.main().record('spoolCost').put(db, {
        'value': '25.00',
      });

      await stringMapStoreFactory
          .store(DBName.printers.name)
          .record('printer-1')
          .put(
            db,
            const PrinterModel(
              id: 'printer-1',
              name: 'Test Printer',
              bedSize: '250x210',
              wattage: '100',
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
    }

    test(
      'edited overrides survive re-init simulating navigate away and back',
      () async {
        await seedCalculatorData();
        final notifier = container.read(calculatorProvider.notifier);
        await notifier.init();

        final initial = container.read(calculatorProvider);
        expect(initial.wearAndTear.value, 1.5);
        expect(initial.markupPercent.value, 10);
        expect(initial.markupPercentOverridden, isFalse);

        notifier.setWearAndTear(5);
        notifier.setMarkupPercent(20);

        var state = container.read(calculatorProvider);
        expect(state.wearAndTear.value, 5);
        expect(state.markupPercent.value, 20);
        expect(state.markupPercentOverridden, isTrue);

        await notifier.init();

        state = container.read(calculatorProvider);
        expect(state.wearAndTear.value, 5);
        expect(state.markupPercent.value, 20);
        expect(state.setupFee.value, 5);
        expect(state.roundingMode, PricingRoundingMode.none);
      },
    );

    test('cleared field stays cleared across re-init', () async {
      await seedCalculatorData();
      final notifier = container.read(calculatorProvider.notifier);
      await notifier.init();

      notifier.updateKwCost('');
      var state = container.read(calculatorProvider);
      expect(state.kwCost.value, isNull);

      await notifier.init();

      state = container.read(calculatorProvider);
      expect(
        state.kwCost.value,
        isNull,
        reason: 'blank active value must not silently reload settings default',
      );
    });

    test('zero override survives re-init', () async {
      await seedCalculatorData();
      final notifier = container.read(calculatorProvider.notifier);
      await notifier.init();

      var state = container.read(calculatorProvider);
      expect(state.wearAndTear.value, 1.5);

      notifier.setWearAndTear(0);

      state = container.read(calculatorProvider);
      expect(state.wearAndTear.value, 0);

      await notifier.init();

      state = container.read(calculatorProvider);
      expect(
        state.wearAndTear.value,
        0,
        reason: '0 must persist, not be reloaded from settings (1.5)',
      );
    });

    test('override cleared to zero does not reload settings default', () async {
      await seedCalculatorData();
      final notifier = container.read(calculatorProvider.notifier);
      await notifier.init();

      var state = container.read(calculatorProvider);
      expect(state.markupPercent.value, 10);
      expect(state.markupPercentOverridden, isFalse);

      notifier.setMarkupPercent(20);
      state = container.read(calculatorProvider);
      expect(state.markupPercent.value, 20);
      expect(state.markupPercentOverridden, isTrue);

      notifier.setMarkupPercent(0);
      state = container.read(calculatorProvider);
      expect(state.markupPercent.value, 0);
      expect(state.markupPercentOverridden, isTrue);

      await notifier.init();

      state = container.read(calculatorProvider);
      expect(
        state.markupPercent.value,
        0,
        reason: 'cleared value must stay 0, not reload settings default 10',
      );
    });

    test('submit uses current overrides, not settings defaults', () async {
      await seedCalculatorData();
      final notifier = container.read(calculatorProvider.notifier);
      await notifier.init();

      notifier.setMarkupPercent(25);

      await notifier.init();

      var state = container.read(calculatorProvider);
      expect(state.markupPercent.value, 25);
      expect(state.markupPercentOverridden, isTrue);

      notifier.updateHours(2);
      notifier.submit();
      state = container.read(calculatorProvider);
      expect(state.pricing.markupPercent, 25);
      expect(state.pricing.markupAmount, greaterThan(0));
    });

    test(
      'settings markup changes sync live until markup is overridden',
      () async {
        await seedCalculatorData();
        final notifier = container.read(calculatorProvider.notifier);
        await notifier.init();

        notifier.updateKwCost('0.77');

        var state = container.read(calculatorProvider);
        expect(state.markupPercent.value, 10);
        expect(state.markupPercentOverridden, isFalse);
        expect(state.baselineMarkupPercent, 10);
        expect(state.kwCost.value, 0.77);

        await container
            .read(settingsRepositoryProvider)
            .saveSettings(
              GeneralSettingsModel(
                electricityCost: '0.99',
                wattage: '100',
                activePrinter: 'printer-1',
                selectedMaterial: 'material-1',
                wearAndTear: '1.50',
                failureRisk: '5.00',
                labourRate: '20',
                pricingMarkupPercent: '40',
                pricingSetupFee: '8',
                pricingRoundingMode: '.00',
              ),
            );
        await Future<void>.delayed(Duration.zero);

        state = container.read(calculatorProvider);
        expect(state.markupPercent.value, 40);
        expect(state.markupPercentOverridden, isFalse);
        expect(state.baselineMarkupPercent, 40);
        expect(
          state.kwCost.value,
          0.77,
          reason: 'unrelated in-progress fields must stay untouched',
        );

        notifier.setMarkupPercent(25);

        await container
            .read(settingsRepositoryProvider)
            .saveSettings(
              GeneralSettingsModel(
                electricityCost: '1.25',
                wattage: '100',
                activePrinter: 'printer-1',
                selectedMaterial: 'material-1',
                wearAndTear: '1.50',
                failureRisk: '5.00',
                labourRate: '20',
                pricingMarkupPercent: '55',
                pricingSetupFee: '9',
                pricingRoundingMode: '.00',
              ),
            );
        await Future<void>.delayed(Duration.zero);

        state = container.read(calculatorProvider);
        expect(state.markupPercent.value, 25);
        expect(state.markupPercentOverridden, isTrue);
        expect(state.baselineMarkupPercent, 55);
        expect(
          state.kwCost.value,
          0.77,
          reason: 'settings markup updates must not clobber local fields',
        );
      },
    );

    test(
      'changing settings does not mutate in-progress form until reset',
      () async {
        await seedCalculatorData();
        final notifier = container.read(calculatorProvider.notifier);
        await notifier.init();

        notifier.setMarkupPercent(25);
        notifier.updateKwCost('0.77');

        await container
            .read(settingsRepositoryProvider)
            .saveSettings(
              GeneralSettingsModel(
                electricityCost: '0.99',
                wattage: '100',
                activePrinter: 'printer-1',
                selectedMaterial: 'material-1',
                wearAndTear: '1.50',
                failureRisk: '5.00',
                labourRate: '20',
                pricingMarkupPercent: '40',
                pricingSetupFee: '8',
                pricingRoundingMode: '.00',
              ),
            );

        await notifier.init();

        var state = container.read(calculatorProvider);
        expect(state.markupPercent.value, 25);
        expect(state.kwCost.value, 0.77);
        expect(state.setupFee.value, 5);
        expect(state.roundingMode, PricingRoundingMode.none);

        await notifier.resetToDefaults();

        state = container.read(calculatorProvider);
        expect(state.markupPercent.value, 40);
        expect(state.kwCost.value, 0.99);
        expect(state.setupFee.value, 8);
        expect(state.roundingMode, PricingRoundingMode.wholeDollar);
        expect(state.materialUsages, isEmpty);
      },
    );
  });
}
