import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage_input.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/core/analytics/analytics_service.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/database/repositories/calculator_preferences_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';

import '../../helpers/helpers.dart';
import '../../helpers/lower_level_test_fakes.dart';

class _FakeAnalytics implements AnalyticsService {
  final events = <String>[];
  final paramsByEvent = <String, Map<String, Object>?>{};
  String? lastName;
  Map<String, Object>? lastParams;

  @override
  Future<void> logEvent(String name, {Map<String, Object>? params}) async {
    events.add(name);
    paramsByEvent[name] = params;
    lastName = name;
    lastParams = params;
  }
}

MaterialModel _material({
  required String id,
  required String name,
  required String cost,
  String weight = '1000',
}) {
  return MaterialModel(
    id: id,
    name: name,
    cost: cost,
    color: '#FFFFFF',
    weight: weight,
    archived: false,
  );
}

void main() {
  group('Material selection recalculation', () {
    late ProviderContainer container;
    late CalculatorProvider notifier;
    late _FakeAnalytics analytics;

    setUpAll(setupTest);

    setUp(() {
      analytics = _FakeAnalytics();
      AppAnalytics.service = analytics;
      container = ProviderContainer(
        overrides: [
          calculatorPreferencesRepositoryProvider.overrideWith(
            _FakeCalculatorPreferencesRepository.new,
          ),
          settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository()),
        ],
      );
      notifier = container.read(calculatorProvider.notifier);

      notifier
        ..updatePrintWeight('100')
        ..addMaterialUsage(
          const MaterialUsageInput(
            materialId: 'mat-a',
            materialName: 'Material A',
            costPerKg: 60,
            weightGrams: 100,
          ),
        )
        ..submit();

      analytics.events.clear();
      analytics.paramsByEvent.clear();
      analytics.lastName = null;
      analytics.lastParams = null;
    });

    tearDown(() {
      container.dispose();
    });

    test('material change updates total for non-zero to non-zero cost', () async {
      final materialA = _material(
        id: 'mat-a',
        name: 'Material A',
        cost: '60',
      ).copyWith(brand: 'Sunlu', materialType: 'PLA', autoDeductEnabled: true);
      final materialB = _material(id: 'mat-b', name: 'Material B', cost: '30');

      await notifier.selectMaterial(materialA);
      expect(notifier.state.spoolCost.value, 60);
      expect(notifier.state.materialUsages.single.materialId, 'mat-a');
      expect(notifier.state.materialUsages.single.costPerKg, 60);
      expect(notifier.state.results.filament, 6.0);
      expect(notifier.state.results.total, 6.0);
      expect(analytics.events, contains('material_selected_in_calculator'));
      expect(analytics.events, contains('calculation_created'));
      expect(
        analytics.events.indexOf('material_selected_in_calculator'),
        lessThan(analytics.events.indexOf('calculation_created')),
      );
      expect(
        analytics.events
            .where((e) => e == 'material_selected_in_calculator')
            .length,
        1,
      );
      expect(analytics.paramsByEvent['material_selected_in_calculator'], {
        'has_tracking': 1,
        'material_type': 'PLA',
        'brand': 'Sunlu',
      });

      await notifier.selectMaterial(materialB);

      expect(notifier.state.spoolCost.value, 30);
      expect(notifier.state.materialUsages.single.materialId, 'mat-b');
      expect(notifier.state.materialUsages.single.costPerKg, 30);
      expect(notifier.state.results.filament, 3.0);
      expect(notifier.state.results.total, 3.0);
    });

    test('material change updates total for non-zero to zero cost', () async {
      final materialA = _material(id: 'mat-a', name: 'Material A', cost: '60');
      final materialC = _material(id: 'mat-c', name: 'Material C', cost: '0.0');

      await notifier.selectMaterial(materialA);
      expect(notifier.state.results.total, 6.0);

      await notifier.selectMaterial(materialC);

      expect(notifier.state.spoolCost.value, 0.0);
      expect(notifier.state.materialUsages.single.materialId, 'mat-c');
      expect(notifier.state.materialUsages.single.costPerKg, 0);
      expect(notifier.state.results.filament, 0.0);
      expect(notifier.state.results.total, 0.0);
    });

    test('material change updates total for zero to non-zero cost', () async {
      final materialC = _material(id: 'mat-c', name: 'Material C', cost: '0');
      final materialD = _material(id: 'mat-d', name: 'Material D', cost: '45');

      await notifier.selectMaterial(materialC);
      expect(notifier.state.results.total, 0.0);

      await notifier.selectMaterial(materialD);

      expect(notifier.state.spoolCost.value, 45);
      expect(notifier.state.materialUsages.single.materialId, 'mat-d');
      expect(notifier.state.materialUsages.single.costPerKg, 45);
      expect(notifier.state.results.filament, 4.5);
      expect(notifier.state.results.total, 4.5);
    });

    test('material usage row with zero cost overrides stale spool totals', () {
      notifier
        ..updateSpoolWeight(1000)
        ..updateSpoolCost('60')
        ..updateMaterialUsage(
          0,
          const MaterialUsageInput(
            materialId: 'mat-zero',
            materialName: 'Zero Cost Material',
            costPerKg: 0,
            weightGrams: 100,
          ),
        )
        ..submit();

      expect(notifier.state.spoolCost.value, 60);
      expect(notifier.state.materialUsages.single.costPerKg, 0);
      expect(notifier.state.results.filament, 0.0);
      expect(notifier.state.results.total, 0.0);
    });

    test('material usage mutations keep total weight synced', () {
      notifier.addMaterialUsage(
        const MaterialUsageInput(
          materialId: 'mat-a',
          materialName: 'Duplicate Material',
          costPerKg: 60,
          weightGrams: 5,
        ),
      );
      expect(notifier.state.materialUsages, hasLength(1));

      notifier.addMaterialUsage(
        const MaterialUsageInput(
          materialId: 'mat-b',
          materialName: 'Material B',
          costPerKg: 30,
          weightGrams: 40,
        ),
      );
      expect(notifier.state.materialUsages, hasLength(2));

      notifier.removeMaterialUsageAt(-1);
      expect(notifier.state.materialUsages, hasLength(2));

      notifier.removeMaterialUsageAt(1);
      expect(notifier.state.materialUsages, hasLength(1));
      expect(notifier.state.printWeight.value, 100);

      notifier.updateMaterialUsageWeight(0, -5);
      expect(notifier.state.materialUsages.single.weightGrams, 0);
      expect(notifier.state.printWeight.value, 0);

      notifier.updateMaterialUsage(
        0,
        const MaterialUsageInput(
          materialId: 'mat-c',
          materialName: 'Material C',
          costPerKg: 25,
          weightGrams: 25,
        ),
      );

      expect(notifier.state.materialUsages.single.materialId, 'mat-c');
      expect(notifier.state.printWeight.value, 25);
    });

    test('applySingleTotalWeightToFirstRow normalizes rows', () {
      notifier
        ..addMaterialUsage(
          const MaterialUsageInput(
            materialId: 'mat-b',
            materialName: 'Material B',
            costPerKg: 30,
            weightGrams: 40,
          ),
        )
        ..updatePrintWeight('140');

      notifier.applySingleTotalWeightToFirstRow();

      expect(notifier.state.printWeight.value, 140);
      expect(notifier.state.materialUsages.first.weightGrams, 140);
      expect(notifier.state.materialUsages.last.weightGrams, 0);
    });

    test('deleting selected material clears stale spool defaults', () async {
      final settingsRepo = FakeSettingsRepository(
        initialSettings: const GeneralSettingsModel(
          electricityCost: '',
          wattage: '',
          activePrinter: '',
          selectedMaterial: 'mat-a',
          wearAndTear: '',
          failureRisk: '',
          labourRate: '',
        ),
      );
      final scopedContainer = ProviderContainer(
        overrides: [
          calculatorPreferencesRepositoryProvider.overrideWith(
            _FakeCalculatorPreferencesRepository.new,
          ),
          settingsRepositoryProvider.overrideWithValue(settingsRepo),
        ],
      );
      addTearDown(scopedContainer.dispose);
      final scopedNotifier = scopedContainer.read(calculatorProvider.notifier);
      final prefsRepo = scopedContainer.read(
            calculatorPreferencesRepositoryProvider,
          )
          as _FakeCalculatorPreferencesRepository;
      final materialA = _material(id: 'mat-a', name: 'Material A', cost: '60');

      scopedNotifier
        ..updatePrintWeight('100')
        ..addMaterialUsage(
          const MaterialUsageInput(
            materialId: 'mat-a',
            materialName: 'Material A',
            costPerKg: 60,
            weightGrams: 100,
          ),
        )
        ..selectMaterial(materialA);

      await scopedNotifier.clearUsagesForDeletedMaterial('mat-a');

      expect(scopedNotifier.state.materialUsages, isEmpty);
      expect(scopedNotifier.state.printWeight.value, 0);
      expect(scopedNotifier.state.spoolWeight.value, isNull);
      expect(scopedNotifier.state.spoolCost.value, isNull);
      expect(scopedNotifier.state.spoolCostText, '');
      expect(scopedNotifier.state.results.filament, 0.0);
      expect(settingsRepo.lastSavedSettings?.selectedMaterial, '');
      expect(await prefsRepo.getStringValue('spoolWeight'), '');
      expect(await prefsRepo.getStringValue('spoolCost'), '');
    });

    test('deleting one material usage recomputes total weight', () async {
      notifier.addMaterialUsage(
        const MaterialUsageInput(
          materialId: 'mat-b',
          materialName: 'Material B',
          costPerKg: 30,
          weightGrams: 40,
        ),
      );

      await notifier.clearUsagesForDeletedMaterial('mat-b');

      expect(notifier.state.materialUsages, hasLength(1));
      expect(notifier.state.materialUsages.single.materialId, 'mat-a');
      expect(notifier.state.printWeight.value, 100);
    });
  });
}

class _FakeCalculatorPreferencesRepository
    extends CalculatorPreferencesRepository {
  _FakeCalculatorPreferencesRepository(super.ref);

  final Map<String, String> _values = {};

  @override
  Future<String> getStringValue(String key) async => _values[key] ?? '';

  @override
  Future<void> saveStringValue(String key, String value) async {
    _values[key] = value;
  }
}
