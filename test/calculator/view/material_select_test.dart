import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/calculator/view/material_select.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';

import '../../helpers/helpers.dart';
import '../../helpers/lower_level_test_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupTest();
  });

  MaterialModel material(String id, String name, String color) {
    return MaterialModel(
      id: id,
      name: name,
      cost: '20',
      color: color,
      weight: '1000',
      archived: false,
    );
  }

  MaterialModel trackedMaterial(String id, String name, String color) {
    return MaterialModel(
      id: id,
      name: name,
      cost: '20',
      color: color,
      weight: '1000',
      archived: false,
      autoDeductEnabled: true,
      originalWeight: 1000,
      remainingWeight: 640,
    );
  }

  testWidgets('stale selected material is ignored when missing', (
    tester,
  ) async {
    final settingsRepo = FakeSettingsRepository(
      initialSettings: GeneralSettingsModel.initial().copyWith(
        selectedMaterial: 'old-material',
      ),
    );

    await tester.pumpApp(const MaterialSelect(), [
      settingsRepositoryProvider.overrideWithValue(settingsRepo),
      materialsStreamProvider.overrideWith(
        (ref) => Stream.value([material('new-material', 'PLA', '#FFFFFF')]),
      ),
    ]);

    await tester.pumpAndSettle();

    final dropdown = tester.widget<DropdownButton<String>>(
      find.byType(DropdownButton<String>),
    );
    expect(dropdown.value, isNull);
  });

  testWidgets('selecting a material saves settings and updates calculator', (
    tester,
  ) async {
    final settingsRepo = FakeSettingsRepository();
    final calculatorNotifier = FakeCalculatorNotifier();
    final materials = [
      material('mat-a', 'PLA', '#FFFFFF'),
      material('mat-b', 'ABS', '#000000'),
    ];

    await tester.pumpApp(const MaterialSelect(), [
      calculatorProvider.overrideWith(() => calculatorNotifier),
      settingsRepositoryProvider.overrideWithValue(settingsRepo),
      materialsStreamProvider.overrideWith((ref) => Stream.value(materials)),
    ]);

    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ABS').last);
    await tester.pumpAndSettle();

    expect(settingsRepo.lastSavedSettings?.selectedMaterial, 'mat-b');
    expect(calculatorNotifier.selectedMaterials.single.id, 'mat-b');
  });

  testWidgets('empty material data hides the select', (tester) async {
    await tester.pumpApp(const MaterialSelect(), [
      materialsStreamProvider.overrideWith(
        (ref) => Stream.value(const <MaterialModel>[]),
      ),
    ]);

    await tester.pumpAndSettle();

    expect(find.byType(DropdownButton<String>), findsNothing);
  });

  testWidgets('shows remaining stock only for tracked selected material', (
    tester,
  ) async {
    await tester.pumpApp(const MaterialSelect(), [
      settingsRepositoryProvider.overrideWithValue(
        FakeSettingsRepository(
          initialSettings: GeneralSettingsModel.initial().copyWith(
            selectedMaterial: 'mat-a',
          ),
        ),
      ),
      materialsStreamProvider.overrideWith(
        (ref) => Stream.value([
          trackedMaterial('mat-a', 'PLA', '#FFFFFF'),
          material('mat-b', 'ABS', '#000000'),
        ]),
      ),
    ]);

    await tester.pumpAndSettle();

    expect(find.text('Remaining: 640g'), findsOneWidget);
  });
}
