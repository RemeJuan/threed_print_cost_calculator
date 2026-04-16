import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/settings/materials/material_form.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import '../settings_test_fakes.dart';

import '../../helpers/helpers.dart';

Finder _field(String key) {
  return find.descendant(
    of: find.byKey(ValueKey<String>(key)),
    matching: find.byType(TextFormField),
  );
}

class _MaterialDialogHost extends StatelessWidget {
  const _MaterialDialogHost({required this.builder, required this.onResult});

  final WidgetBuilder builder;
  final ValueChanged<Object?> onResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final result = await showDialog<Object?>(
              context: context,
              builder: builder,
            );
            onResult(result);
          },
          child: const Text('Open'),
        ),
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupTest();
  });

  testWidgets('typing updates notifier state and save closes the dialog', (
    tester,
  ) async {
    final repo = FakeMaterialsRepository(
      useExplicitSaveResult: true,
      saveResult: 'material-1',
    );
    final savedResult = <Object?>[];
    final db = await tester.pumpApp(
      _MaterialDialogHost(
        onResult: savedResult.add,
        builder: (_) => const MaterialForm(),
      ),
      [materialsRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(db.close);

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.enterText(_field('settings.materials.name.input'), 'PLA');
    await tester.enterText(_field('settings.materials.color.input'), 'Blue');
    await tester.enterText(_field('settings.materials.weight.input'), '1000');
    await tester.enterText(_field('settings.materials.cost.input'), '24.5');
    await tester.tap(
      find.byKey(
        const ValueKey<String>('settings.materials.track_remaining.toggle'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      _field('settings.materials.remaining_weight.input'),
      '850',
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('settings.materials.save.button')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    expect(repo.savedMaterials, hasLength(1));
    expect(repo.savedMaterials.single.name, 'PLA');
    expect(repo.savedMaterials.single.color, 'Blue');
    expect(repo.savedMaterials.single.weight, '1000.0');
    expect(repo.savedMaterials.single.cost, '24.5');
    expect(repo.savedMaterials.single.autoDeductEnabled, isTrue);
    expect(repo.savedMaterials.single.originalWeight, 1000);
    expect(repo.savedMaterials.single.remainingWeight, 850);
    expect(repo.getMaterialByIdCalls, ['material-1']);
    expect(savedResult.single, isA<MaterialModel>());
    expect((savedResult.single as MaterialModel).id, 'material-1');
  });

  testWidgets('invalid values block save and show validation errors', (
    tester,
  ) async {
    final repo = FakeMaterialsRepository();
    final db = await tester.pumpApp(
      _MaterialDialogHost(
        onResult: (_) {},
        builder: (_) => const MaterialForm(),
      ),
      [materialsRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(db.close);

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.enterText(_field('settings.materials.name.input'), 'PLA');
    await tester.enterText(_field('settings.materials.color.input'), 'Blue');
    await tester.enterText(_field('settings.materials.weight.input'), '0');
    await tester.enterText(_field('settings.materials.cost.input'), '0');

    await tester.tap(
      find.byKey(const ValueKey<String>('settings.materials.save.button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Must be greater than 0'), findsWidgets);
    expect(repo.savedMaterials, isEmpty);
    expect(find.byType(Dialog), findsOneWidget);
  });

  testWidgets('comma decimals save successfully', (tester) async {
    final repo = FakeMaterialsRepository(
      useExplicitSaveResult: true,
      saveResult: 'material-1',
    );
    final db = await tester.pumpApp(
      _MaterialDialogHost(
        onResult: (_) {},
        builder: (_) => const MaterialForm(),
      ),
      [materialsRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(db.close);

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.enterText(_field('settings.materials.name.input'), 'PLA');
    await tester.enterText(_field('settings.materials.color.input'), 'Blue');
    await tester.enterText(_field('settings.materials.weight.input'), '1000,5');
    await tester.enterText(_field('settings.materials.cost.input'), '24,5');

    await tester.tap(
      find.byKey(const ValueKey<String>('settings.materials.save.button')),
    );
    await tester.pumpAndSettle();

    expect(repo.savedMaterials.single.weight, '1000.5');
    expect(repo.savedMaterials.single.cost, '24.5');
  });

  testWidgets('remaining filament input strips leading zeros', (tester) async {
    final repo = FakeMaterialsRepository();
    final db = await tester.pumpApp(
      _MaterialDialogHost(
        onResult: (_) {},
        builder: (_) => const MaterialForm(),
      ),
      [materialsRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(db.close);

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(
        const ValueKey<String>('settings.materials.track_remaining.toggle'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      _field('settings.materials.remaining_weight.input'),
      '01000',
    );
    await tester.pump();

    expect(
      tester
          .widget<TextFormField>(
            _field('settings.materials.remaining_weight.input'),
          )
          .controller!
          .text,
      '1000',
    );
  });

  testWidgets('null save results keep the dialog open', (tester) async {
    final repo = FakeMaterialsRepository(
      useExplicitSaveResult: true,
      saveResult: null,
    );
    Object? dialogResult;
    final db = await tester.pumpApp(
      _MaterialDialogHost(
        onResult: (value) => dialogResult = value,
        builder: (_) => const MaterialForm(),
      ),
      [materialsRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(db.close);

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.enterText(_field('settings.materials.name.input'), 'PLA');
    await tester.enterText(_field('settings.materials.color.input'), 'Blue');
    await tester.enterText(_field('settings.materials.weight.input'), '1000');
    await tester.enterText(_field('settings.materials.cost.input'), '24.5');
    await tester.tap(
      find.byKey(const ValueKey<String>('settings.materials.save.button')),
    );
    await tester.pumpAndSettle();

    expect(dialogResult, isNull);
    expect(repo.savedMaterials, hasLength(1));
    expect(find.byType(Dialog), findsOneWidget);
  });

  testWidgets('edit mode preloads once and rebuilds preserve edits', (
    tester,
  ) async {
    final material = const MaterialModel(
      id: 'material-1',
      name: 'PLA',
      cost: '24.5',
      color: 'Red',
      weight: '1000',
      archived: false,
      autoDeductEnabled: true,
      originalWeight: 1000,
      remainingWeight: 725,
    );
    final repo = FakeMaterialsRepository();
    repo.materialsById[material.id] = material;

    final db = await tester.pumpApp(
      _MaterialDialogHost(
        onResult: (_) {},
        builder: (_) => const MaterialForm(dbRef: 'material-1'),
      ),
      [materialsRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(db.close);

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(repo.getMaterialByIdCalls, ['material-1']);
    expect(
      tester
          .widget<TextFormField>(_field('settings.materials.name.input'))
          .controller!
          .text,
      'PLA',
    );
    expect(
      tester
          .widget<TextFormField>(_field('settings.materials.color.input'))
          .controller!
          .text,
      'Red',
    );
    expect(
      tester
          .widget<TextFormField>(_field('settings.materials.weight.input'))
          .controller!
          .text,
      '1000',
    );
    expect(
      tester
          .widget<TextFormField>(_field('settings.materials.cost.input'))
          .controller!
          .text,
      '24.5',
    );
    expect(
      tester
          .widget<SwitchListTile>(
            find.byKey(
              const ValueKey<String>(
                'settings.materials.track_remaining.toggle',
              ),
            ),
          )
          .value,
      isTrue,
    );
    expect(
      tester
          .widget<TextFormField>(
            _field('settings.materials.remaining_weight.input'),
          )
          .controller!
          .text,
      '725.0',
    );

    await tester.enterText(
      _field('settings.materials.name.input'),
      'PLA Edited',
    );
    await tester.pumpAndSettle();

    expect(repo.getMaterialByIdCalls, ['material-1']);
    expect(
      tester
          .widget<TextFormField>(_field('settings.materials.name.input'))
          .controller!
          .text,
      'PLA Edited',
    );
  });
}
