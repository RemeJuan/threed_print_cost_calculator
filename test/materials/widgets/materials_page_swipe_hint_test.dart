import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/materials/widgets/materials_page.dart';
import 'package:threed_print_cost_calculator/materials/widgets/materials_swipe_hint_controller.dart';

import '../../helpers/helpers.dart';
import '../../settings/settings_test_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupTest();
  });

  group('MaterialsPage', () {
    testWidgets('shows swipe hint on first frame when preference missing', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final repo = FakeMaterialsRepository();
      final db = await tester.pumpApp(const MaterialsPage(), [
        materialsRepositoryProvider.overrideWithValue(repo),
      ]);
      addTearDown(db.close);

      expect(
        find.text(
          lookupAppLocalizations(const Locale('en')).materialsSwipeHint,
        ),
        findsOneWidget,
      );
    });

    testWidgets('hides swipe hint on first frame when preference stored', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        materialsSwipeHintShownPreferenceKey: true,
      });
      final repo = FakeMaterialsRepository();
      final db = await tester.pumpApp(const MaterialsPage(), [
        materialsRepositoryProvider.overrideWithValue(repo),
      ]);
      addTearDown(db.close);

      expect(
        find.text(
          lookupAppLocalizations(const Locale('en')).materialsSwipeHint,
        ),
        findsNothing,
      );
    });

    testWidgets('dismisses and persists swipe hint via close', (tester) async {
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

    testWidgets('dismisses and persists swipe hint via swipe', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = FakeMaterialsRepository();
      final db = await tester.pumpApp(const MaterialsPage(), [
        materialsRepositoryProvider.overrideWithValue(repo),
      ]);
      addTearDown(db.close);

      await tester.pumpAndSettle();
      await tester.fling(
        find.byKey(const ValueKey<String>('materials.swipe_hint')),
        const Offset(-1000, 0),
        2000,
      );
      await tester.pumpAndSettle();

      expect(prefs.getBool(materialsSwipeHintShownPreferenceKey), isTrue);
      expect(
        find.text(
          lookupAppLocalizations(const Locale('en')).materialsSwipeHint,
        ),
        findsNothing,
      );
    });

    test('swipe hint dismissal is idempotent', () {
      final prefs = _CountingSwipeHintStore();
      final controller = MaterialsSwipeHintController(
        shown: false,
        store: prefs,
      );

      expect(controller.isVisible, isTrue);
      controller.dismiss();
      controller.dismiss();

      expect(prefs.markShownCalls, 1);
      expect(prefs.shown, isTrue);
      expect(controller.isVisible, isFalse);
    });
  });
}

class _CountingSwipeHintStore implements MaterialsSwipeHintStore {
  var markShownCalls = 0;
  var _shown = false;

  @override
  bool get shown => _shown;

  @override
  void markShown() {
    markShownCalls++;
    _shown = true;
  }
}
