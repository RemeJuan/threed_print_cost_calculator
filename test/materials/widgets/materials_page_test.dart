import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/materials/widgets/materials_page.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';

import '../../helpers/helpers.dart';
import '../../settings/settings_test_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupTest();
  });

  group('MaterialsPage', () {
    testWidgets('shows empty state when no materials', (tester) async {
      final repo = FakeMaterialsRepository();
      final db = await tester.pumpApp(
        const MaterialsPage(),
        [materialsRepositoryProvider.overrideWithValue(repo)],
      );
      await tester.pumpAndSettle();
      addTearDown(db.close);

      await tester.pumpAndSettle();

      expect(
        find.text(lookupAppLocalizations(const Locale('en')).materialsEmpty),
        findsOneWidget,
      );
    });

    testWidgets('shows material list', (tester) async {
      final materials = [
        MaterialModel(
          id: '1',
          name: 'PLA Pro',
          cost: '24.99',
          color: 'Black',
          weight: '1000',
          archived: false,
        ),
        MaterialModel(
          id: '2',
          name: 'PETG',
          cost: '29.99',
          color: 'White',
          weight: '1000',
          archived: false,
        ),
      ];
      final repo = FakeMaterialsRepository(watchResponses: [materials]);
      final db = await tester.pumpApp(
        const MaterialsPage(),
        [materialsRepositoryProvider.overrideWithValue(repo)],
      );
      await tester.pumpAndSettle();
      addTearDown(db.close);

      await tester.pumpAndSettle();

      expect(find.text('PLA Pro'), findsOneWidget);
      expect(find.text('PETG'), findsOneWidget);
    });

    testWidgets('add FAB opens material form dialog', (tester) async {
      final repo = FakeMaterialsRepository();
      final db = await tester.pumpApp(
        const MaterialsPage(),
        [materialsRepositoryProvider.overrideWithValue(repo)],
      );
      await tester.pumpAndSettle();
      addTearDown(db.close);

      await tester.pumpAndSettle();

      final fabButtons = find.byType(FloatingActionButton);
      expect(fabButtons, findsOneWidget);
      await tester.tap(fabButtons);
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);
      expect(
        find.text(
          lookupAppLocalizations(const Locale('en')).materialNameLabel,
        ),
        findsOneWidget,
      );
    });
  });
}
