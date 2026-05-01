import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/materials/widgets/material_filters.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';

import '../../helpers/helpers.dart';
import '../../settings/settings_test_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupTest();
  });

  group('MaterialFilters', () {
    testWidgets('shows stock chips when no types', (tester) async {
      final repo = FakeMaterialsRepository();
      final db = await tester.pumpApp(const MaterialFilters(), [
        materialsRepositoryProvider.overrideWithValue(repo),
      ]);
      await tester.pumpAndSettle();
      addTearDown(db.close);

      final l10n = lookupAppLocalizations(const Locale('en'));
      expect(find.text(l10n.materialsFilterInStock), findsOneWidget);
      expect(find.text(l10n.materialsFilterLowStock), findsOneWidget);
      expect(find.text(l10n.materialsFilterOutOfStock), findsOneWidget);
    });

    testWidgets('shows type chips from material data', (tester) async {
      final materials = [
        MaterialModel(
          id: '1',
          name: 'Test1',
          cost: '10',
          color: 'Red',
          weight: '1000',
          archived: false,
          materialType: 'PLA',
        ),
        MaterialModel(
          id: '2',
          name: 'Test2',
          cost: '10',
          color: 'Blue',
          weight: '1000',
          archived: false,
          materialType: 'PETG',
        ),
      ];
      final repo = FakeMaterialsRepository(watchResponses: [materials]);
      final db = await tester.pumpApp(
        const MaterialFilters(),
        [materialsRepositoryProvider.overrideWithValue(repo)],
      );
      await tester.pumpAndSettle();
      addTearDown(db.close);

      await tester.pumpAndSettle();

      expect(find.text('PLA'), findsOneWidget);
      expect(find.text('PETG'), findsOneWidget);
    });
  });
}
