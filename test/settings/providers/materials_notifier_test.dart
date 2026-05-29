import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/core/analytics/analytics_service.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/settings/providers/materials_notifier.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

import '../settings_test_fakes.dart';

class _FakeAnalytics implements AnalyticsService {
  String? lastName;
  Map<String, Object>? lastParams;

  @override
  Future<void> logEvent(String name, {Map<String, Object>? params}) async {
    lastName = name;
    lastParams = params;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('MaterialsProvider localized parsing', () {
    late ProviderContainer container;
    late MaterialsProvider notifier;
    late _FakeAnalytics analytics;

    setUp(() {
      analytics = _FakeAnalytics();
      AppAnalytics.service = analytics;
      container = ProviderContainer();
      notifier = container.read(materialsProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('parses comma-decimal settings values', () {
      notifier.updateCost(' 12,5 ');
      notifier.updateWeight('0,75');

      final state = container.read(materialsProvider);
      expect(state.cost.value, 12.5);
      expect(state.weight.value, 0.75);
    });

    test('invalid settings values keep numeric fallback behavior', () {
      notifier.updateCost('abc');
      notifier.updateWeight('');

      final state = container.read(materialsProvider);
      expect(state.cost.value, isNull);
      expect(state.weight.value, isNull);
      expect(state.costText, 'abc');
      expect(state.weightText, '');
    });

    test('init for create clears previous form state', () async {
      notifier
        ..updateName('PLA')
        ..updateColor('Blue')
        ..updateWeight('1000')
        ..updateCost('24.5')
        ..updateAutoDeductEnabled(true)
        ..updateRemainingWeight('850')
        ..updateBrand('Sunlu')
        ..updateMaterialType('PLA+')
        ..updateColorHex('#112233')
        ..updateNotes('Saved draft');

      await notifier.init(null);

      final state = container.read(materialsProvider);
      expect(state.name.value, isEmpty);
      expect(state.color.value, isEmpty);
      expect(state.weightText, isEmpty);
      expect(state.costText, isEmpty);
      expect(state.autoDeductEnabled, isFalse);
      expect(state.remainingWeightText, isEmpty);
      expect(state.brand.value, isEmpty);
      expect(state.materialType.value, isEmpty);
      expect(state.colorHex.value, isEmpty);
      expect(state.notes.value, isEmpty);
    });

    test('rejects invalid payloads before persistence', () async {
      final materialsRepository = FakeMaterialsRepository();
      final guardedContainer = ProviderContainer(
        overrides: [
          materialsRepositoryProvider.overrideWithValue(materialsRepository),
        ],
      );
      addTearDown(guardedContainer.dispose);

      final guardedNotifier = guardedContainer.read(materialsProvider.notifier);
      guardedNotifier.updateName('PLA');
      guardedNotifier.updateColor('Blue');
      guardedNotifier.updateWeight('0');
      guardedNotifier.updateCost('12,5');

      final result = await guardedNotifier.submit(null);

      expect(result, isNull);
      expect(materialsRepository.savedMaterials, isEmpty);
    });

    test(
      'enabling tracking later seeds remaining weight from current spool',
      () async {
        final materialsRepository = FakeMaterialsRepository();
        final seededContainer = ProviderContainer(
          overrides: [
            materialsRepositoryProvider.overrideWithValue(materialsRepository),
          ],
        );
        addTearDown(seededContainer.dispose);

        await materialsRepository.saveMaterial(
          const MaterialModel(
            id: 'mat-1',
            name: 'PLA',
            cost: '20',
            color: 'Red',
            weight: '1000',
            archived: false,
            originalWeight: 1000,
            remainingWeight: 1000,
          ),
          id: 'mat-1',
        );

        final seededNotifier = seededContainer.read(materialsProvider.notifier);
        await seededNotifier.init('mat-1');
        seededNotifier.updateWeight('750');
        await seededNotifier.submit('mat-1');

        final disabledSaved = materialsRepository.savedMaterials.last;
        expect(disabledSaved.autoDeductEnabled, isFalse);
        expect(disabledSaved.remainingWeight, 750);

        await seededNotifier.init('mat-1');
        seededNotifier.updateAutoDeductEnabled(true);
        await seededNotifier.submit('mat-1');

        final enabledSaved = materialsRepository.savedMaterials.last;
        expect(enabledSaved.autoDeductEnabled, isTrue);
        expect(enabledSaved.originalWeight, 750);
        expect(enabledSaved.remainingWeight, 750);
      },
    );

    test(
      'editing weight then enabling tracking in same session uses edited spool weight',
      () async {
        final materialsRepository = FakeMaterialsRepository();
        final seededPrefs = await SharedPreferences.getInstance();
        final seededContainer = ProviderContainer(
          overrides: [
            materialsRepositoryProvider.overrideWithValue(materialsRepository),
            sharedPreferencesProvider.overrideWithValue(seededPrefs),
            isPremiumProvider.overrideWithValue(true),
          ],
        );
        addTearDown(seededContainer.dispose);

        await materialsRepository.saveMaterial(
          const MaterialModel(
            id: 'mat-2',
            name: 'PETG',
            cost: '25',
            color: 'Blue',
            weight: '1000',
            archived: false,
            originalWeight: 1000,
            remainingWeight: 1000,
          ),
          id: 'mat-2',
        );

        final seededNotifier = seededContainer.read(materialsProvider.notifier);
        await seededNotifier.init('mat-2');
        seededNotifier.updateWeight('750');
        seededNotifier.updateAutoDeductEnabled(true);
        await seededNotifier.submit('mat-2');

        final saved = materialsRepository.savedMaterials.last;
        expect(saved.autoDeductEnabled, isTrue);
        expect(saved.originalWeight, 750);
        expect(saved.remainingWeight, 750);
      },
    );

    test(
      'submit logs create and edit analytics with material metadata',
      () async {
        final materialsRepository = FakeMaterialsRepository(
          useExplicitSaveResult: true,
          saveResult: 'material-1',
        );
        final analyticsPrefs = await SharedPreferences.getInstance();
        final analyticsContainer = ProviderContainer(
          overrides: [
            materialsRepositoryProvider.overrideWithValue(materialsRepository),
            sharedPreferencesProvider.overrideWithValue(analyticsPrefs),
            isPremiumProvider.overrideWithValue(true),
          ],
        );
        addTearDown(analyticsContainer.dispose);

        final analyticsNotifier = analyticsContainer.read(
          materialsProvider.notifier,
        );
        analyticsNotifier
          ..updateName('PLA')
          ..updateColor('Black')
          ..updateWeight('1000')
          ..updateCost('24.99')
          ..updateAutoDeductEnabled(true)
          ..updateBrand('Sunlu')
          ..updateMaterialType('PLA');

        final createdKey = await analyticsNotifier.submit(null);

        expect(createdKey, isNotNull);
        expect(analytics.lastName, 'material_created');
        expect(analytics.lastParams, {
          'has_tracking': 1,
          'material_type': 'PLA',
          'brand': 'Sunlu',
        });

        final savedId = createdKey.toString();
        await analyticsNotifier.init(savedId);
        analyticsNotifier
          ..updateBrand('Overture')
          ..updateAutoDeductEnabled(false);

        await analyticsNotifier.submit(savedId);

        expect(analytics.lastName, 'material_edited');
        expect(analytics.lastParams, {
          'has_tracking': 0,
          'material_type': 'PLA',
          'brand': 'Overture',
        });
      },
    );
  });
}
