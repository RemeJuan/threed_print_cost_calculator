import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/settings/providers/materials_notifier.dart';

import '../settings_test_fakes.dart';

void main() {
  group('MaterialsProvider localized parsing', () {
    late ProviderContainer container;
    late MaterialsProvider notifier;

    setUp(() {
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
      expect(state.cost.value, 0);
      expect(state.weight.value, 0);
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
        seededNotifier.init('mat-1');
        await Future<void>.delayed(Duration.zero);
        seededNotifier.updateWeight('750');
        await seededNotifier.submit('mat-1');

        final disabledSaved = materialsRepository.savedMaterials.last;
        expect(disabledSaved.autoDeductEnabled, isFalse);
        expect(disabledSaved.remainingWeight, 750);

        seededNotifier.init('mat-1');
        await Future<void>.delayed(Duration.zero);
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
        final seededContainer = ProviderContainer(
          overrides: [
            materialsRepositoryProvider.overrideWithValue(materialsRepository),
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
        seededNotifier.init('mat-2');
        await Future<void>.delayed(Duration.zero);
        seededNotifier.updateWeight('750');
        seededNotifier.updateAutoDeductEnabled(true);
        await seededNotifier.submit('mat-2');

        final saved = materialsRepository.savedMaterials.last;
        expect(saved.autoDeductEnabled, isTrue);
        expect(saved.originalWeight, 750);
        expect(saved.remainingWeight, 750);
      },
    );
  });
}
