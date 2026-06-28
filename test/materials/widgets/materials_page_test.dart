import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculator_state.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/materials/materials_page_actions.dart';
import 'package:threed_print_cost_calculator/materials/widgets/materials_page.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_policy.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
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
      final db = await tester.pumpApp(const MaterialsPage(), [
        materialsRepositoryProvider.overrideWithValue(repo),
      ]);
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
      final db = await tester.pumpApp(const MaterialsPage(), [
        materialsRepositoryProvider.overrideWithValue(repo),
      ]);
      await tester.pumpAndSettle();
      addTearDown(db.close);

      await tester.pumpAndSettle();

      expect(find.text('PLA Pro'), findsOneWidget);
      expect(find.text('PETG'), findsOneWidget);
    });

    testWidgets('dismisses and persists swipe hint', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = FakeMaterialsRepository();
      final db = await tester.pumpApp(const MaterialsPage(), [
        materialsRepositoryProvider.overrideWithValue(repo),
      ]);
      addTearDown(db.close);

      await tester.pumpAndSettle();

      expect(
        find.text(
          lookupAppLocalizations(const Locale('en')).materialsSwipeHint,
        ),
        findsOneWidget,
      );

      await tester.tap(find.byIcon(Icons.close).last);
      await tester.pumpAndSettle();

      expect(
        find.text(
          lookupAppLocalizations(const Locale('en')).materialsSwipeHint,
        ),
        findsNothing,
      );
      expect(prefs.getBool(materialsSwipeHintShownPreferenceKey), isTrue);

      await tester.pumpWidget(const SizedBox.shrink());

      final reopenedDb = await tester.pumpApp(const MaterialsPage(), [
        materialsRepositoryProvider.overrideWithValue(repo),
      ]);
      addTearDown(reopenedDb.close);

      await tester.pumpAndSettle();

      expect(
        find.text(
          lookupAppLocalizations(const Locale('en')).materialsSwipeHint,
        ),
        findsNothing,
      );
    });

    testWidgets('add FAB opens material form dialog', (tester) async {
      final repo = FakeMaterialsRepository();
      final db = await tester.pumpApp(const MaterialsPage(), [
        materialsRepositoryProvider.overrideWithValue(repo),
      ]);
      await tester.pumpAndSettle();
      addTearDown(db.close);

      await tester.pumpAndSettle();

      final fabButtons = find.byType(FloatingActionButton);
      expect(fabButtons, findsOneWidget);
      await tester.tap(fabButtons);
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);
      expect(
        find.text(lookupAppLocalizations(const Locale('en')).materialNameLabel),
        findsOneWidget,
      );
    });

    testWidgets('free users at material cap see upsell and disabled add', (
      tester,
    ) async {
      final materials = List.generate(
        5,
        (i) => MaterialModel(
          id: '${i + 1}',
          name: 'Material ${i + 1}',
          cost: '20.00',
          color: 'Black',
          weight: '1000',
          archived: false,
        ),
      );
      final repo = FakeMaterialsRepository(watchResponses: [materials]);
      final db = await tester.pumpApp(const MaterialsPage(), [
        materialsRepositoryProvider.overrideWithValue(repo),
        premiumAccessPolicyProvider.overrideWithValue(
          DefaultPremiumAccessPolicy(isPremium: false),
        ),
      ]);
      addTearDown(db.close);

      await tester.pumpAndSettle();

      expect(
        find.text(
          lookupAppLocalizations(
            const Locale('en'),
          ).materialLimitReachedMessage,
        ),
        findsOneWidget,
      );

      final fab = tester.widget<FloatingActionButton>(
        find.byType(FloatingActionButton),
      );
      expect(fab.onPressed, isNull);
    });

    testWidgets('duplicate action loads source material from repository', (
      tester,
    ) async {
      final material = MaterialModel(
        id: '1',
        name: 'PLA Pro',
        cost: '24.99',
        color: 'Black',
        weight: '1000',
        archived: false,
      );
      final repo = _ThrowingDuplicateMaterialsRepository(material);
      final db = await tester.pumpApp(const MaterialsPage(), [
        materialsRepositoryProvider.overrideWithValue(repo),
      ]);
      addTearDown(db.close);

      await tester.pumpAndSettle();
      await tester.drag(find.byType(Slidable).first, const Offset(-300, 0));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.content_copy), findsOneWidget);
      await tester.tap(find.byIcon(Icons.content_copy));
      await tester.pump();

      expect(repo.getMaterialByIdCalls, ['1']);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('delete action removes material and clears calculator usage', (
      tester,
    ) async {
      final material = MaterialModel(
        id: '1',
        name: 'PLA Pro',
        cost: '24.99',
        color: 'Black',
        weight: '1000',
        archived: false,
      );
      final repo = FakeMaterialsRepository(
        watchResponses: [
          <MaterialModel>[material],
        ],
      );
      final calculator = _TrackingCalculatorProvider();
      final db = await tester.pumpApp(const MaterialsPage(), [
        materialsRepositoryProvider.overrideWithValue(repo),
        calculatorProvider.overrideWith(() => calculator),
      ]);
      addTearDown(db.close);

      await tester.pumpAndSettle();
      await tester.drag(find.byType(Slidable).first, const Offset(-300, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      await tester.tap(
        find.text(lookupAppLocalizations(const Locale('en')).deleteButton).last,
      );
      await tester.pumpAndSettle();

      expect(repo.deleteCalls, ['1']);
      expect(calculator.clearedMaterialIds, ['1']);
      expect(
        find.text(
          lookupAppLocalizations(
            const Locale('en'),
          ).deleteMaterialSuccessMessage,
        ),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('delete failure does not clear calculator usage', (
      tester,
    ) async {
      final material = MaterialModel(
        id: '1',
        name: 'PLA Pro',
        cost: '24.99',
        color: 'Black',
        weight: '1000',
        archived: false,
      );
      final repo = _ThrowingDeleteMaterialsRepository(material);
      final calculator = _TrackingCalculatorProvider();
      final db = await tester.pumpApp(const MaterialsPage(), [
        materialsRepositoryProvider.overrideWithValue(repo),
        calculatorProvider.overrideWith(() => calculator),
      ]);
      addTearDown(db.close);

      await tester.pumpAndSettle();
      await tester.drag(find.byType(Slidable).first, const Offset(-300, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      await tester.tap(
        find.text(lookupAppLocalizations(const Locale('en')).deleteButton).last,
      );
      await tester.pumpAndSettle();

      expect(repo.deleteCalls, ['1']);
      expect(calculator.clearedMaterialIds, isEmpty);
      expect(
        find.text(
          lookupAppLocalizations(const Locale('en')).deleteRecordErrorMessage,
        ),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('free users at material cap cannot duplicate materials', (
      tester,
    ) async {
      final material = MaterialModel(
        id: '1',
        name: 'PLA Pro',
        cost: '24.99',
        color: 'Black',
        weight: '1000',
        archived: false,
      );
      final materials = [
        material,
        for (var i = 2; i <= 5; i++)
          MaterialModel(
            id: '$i',
            name: 'Material $i',
            cost: '20.00',
            color: 'Black',
            weight: '1000',
            archived: false,
          ),
      ];
      final repo = FakeMaterialsRepository(watchResponses: [materials]);
      for (final entry in materials) {
        repo.materialsById[entry.id] = entry;
      }
      final db = await tester.pumpApp(const MaterialsPage(), [
        materialsRepositoryProvider.overrideWithValue(repo),
        premiumAccessPolicyProvider.overrideWithValue(
          DefaultPremiumAccessPolicy(isPremium: false),
        ),
      ]);
      addTearDown(db.close);

      await tester.pumpAndSettle();
      await tester.drag(find.byType(Slidable).first, const Offset(-300, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.content_copy));
      await tester.pump();

      expect(repo.savedMaterials, isEmpty);
      expect(
        find.text(
          lookupAppLocalizations(
            const Locale('en'),
          ).materialLimitReachedMessage,
        ),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 3));
    });
  });
}

class _TrackingCalculatorProvider extends CalculatorProvider {
  final List<String> clearedMaterialIds = [];

  @override
  CalculatorState build() => CalculatorState();

  @override
  Future<void> clearUsagesForDeletedMaterial(String materialId) async {
    clearedMaterialIds.add(materialId);
  }
}

class _ThrowingDuplicateMaterialsRepository extends FakeMaterialsRepository {
  _ThrowingDuplicateMaterialsRepository(MaterialModel material)
    : super(
        watchResponses: [
          <MaterialModel>[material],
        ],
      ) {
    materialsById[material.id] = material;
  }

  @override
  Future<Object?> saveMaterial(MaterialModel material, {String? id}) {
    throw StateError('save failed');
  }
}

class _ThrowingDeleteMaterialsRepository extends FakeMaterialsRepository {
  _ThrowingDeleteMaterialsRepository(MaterialModel material)
    : super(
        watchResponses: [
          <MaterialModel>[material],
        ],
      );

  @override
  Future<void> deleteMaterial(String id) async {
    deleteCalls.add(id);
    throw StateError('delete failed');
  }
}
