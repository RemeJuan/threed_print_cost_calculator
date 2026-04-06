import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';
import 'package:threed_print_cost_calculator/settings/materials/material_form.dart';
import 'package:threed_print_cost_calculator/settings/materials/materials.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import '../settings_test_fakes.dart';

import '../../helpers/helpers.dart';

Finder _field(String key) {
  return find.descendant(
    of: find.byKey(ValueKey<String>(key)),
    matching: find.byType(TextFormField),
  );
}

MaterialModel _material() {
  return const MaterialModel(
    id: 'material-1',
    name: 'PLA',
    cost: '24.5',
    color: 'Red',
    weight: '1000',
    archived: false,
  );
}

class _MaterialDialogHost extends StatelessWidget {
  const _MaterialDialogHost({required this.onResult, required this.builder});

  final ValueChanged<Object?> onResult;
  final WidgetBuilder builder;

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

  testWidgets('renders material rows from stream state', (tester) async {
    final material = _material();
    final repo = FakeMaterialsRepository(
      watchResponses: [
        <MaterialModel>[material],
      ],
    );
    final db = await tester.pumpApp(const Materials(), [
      materialsRepositoryProvider.overrideWithValue(repo),
    ]);
    addTearDown(db.close);

    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('settings.materials.item.0.name')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('settings.materials.item.0.color')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('settings.materials.item.0.cost')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('settings.materials.item.0.weight')),
      findsOneWidget,
    );
    expect(find.text('PLA'), findsOneWidget);
    expect(find.text('Red'), findsOneWidget);
    expect(find.text('24.5'), findsOneWidget);
    expect(find.text('1000${S.current.gramsSuffix}'), findsOneWidget);
  });

  testWidgets('retries after a stream error', (tester) async {
    final repo = FakeMaterialsRepository(
      watchResponses: [
        StateError('boom'),
        <MaterialModel>[_material()],
      ],
    );
    final db = await tester.pumpApp(const Materials(), [
      materialsRepositoryProvider.overrideWithValue(repo),
    ]);
    addTearDown(db.close);

    await tester.pumpAndSettle();

    expect(find.textContaining('Failed to load materials'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('PLA'), findsOneWidget);
  });

  testWidgets('delete action calls repository delete', (tester) async {
    final material = _material();
    final repo = FakeMaterialsRepository(
      watchResponses: [
        <MaterialModel>[material],
      ],
    );
    repo.materialsById[material.id] = material;

    final db = await tester.pumpApp(const Materials(), [
      materialsRepositoryProvider.overrideWithValue(repo),
    ]);
    addTearDown(db.close);

    await tester.pumpAndSettle();

    await tester.drag(
      find.byKey(const ValueKey<String>('settings.materials.item.0')),
      const Offset(-300, 0),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey<String>('settings.materials.item.0')),
        matching: find.byIcon(Icons.delete),
      ),
    );
    await tester.pumpAndSettle();

    expect(repo.deleteCalls, ['material-1']);
  });

  testWidgets('edit action opens MaterialForm with the material id', (
    tester,
  ) async {
    final material = _material();
    final repo = FakeMaterialsRepository(
      watchResponses: [
        <MaterialModel>[material],
      ],
    );
    repo.materialsById[material.id] = material;

    final db = await tester.pumpApp(const Materials(), [
      materialsRepositoryProvider.overrideWithValue(repo),
    ]);
    addTearDown(db.close);

    await tester.pumpAndSettle();

    await tester.drag(
      find.byKey(const ValueKey<String>('settings.materials.item.0')),
      const Offset(-300, 0),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(
        const ValueKey<String>('settings.materials.item.0.edit.button'),
      ),
    );
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
  });

  testWidgets('save returns the saved material and closes the dialog', (
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
      find.byKey(const ValueKey<String>('settings.materials.save.button')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    expect(repo.savedMaterials, hasLength(1));
    expect(repo.savedMaterials.single.name, 'PLA');
    expect(repo.savedMaterials.single.color, 'Blue');
    expect(repo.savedMaterials.single.weight, '1000');
    expect(repo.savedMaterials.single.cost, '24.5');
    expect(repo.getMaterialByIdCalls, ['material-1']);
    expect(savedResult.single, isA<MaterialModel>());
    expect((savedResult.single as MaterialModel).id, 'material-1');
  });

  testWidgets('null save results close the dialog safely', (tester) async {
    final repo = FakeMaterialsRepository(
      useExplicitSaveResult: true,
      saveResult: null,
    );
    Object? savedResult;
    final db = await tester.pumpApp(
      _MaterialDialogHost(
        onResult: (value) => savedResult = value,
        builder: (_) => const MaterialForm(),
      ),
      [materialsRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(db.close);

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.enterText(_field('settings.materials.name.input'), 'PLA');
    await tester.tap(
      find.byKey(const ValueKey<String>('settings.materials.save.button')),
    );
    await tester.pumpAndSettle();

    expect(savedResult, isNull);
    expect(find.byType(Dialog), findsNothing);
  });
}
