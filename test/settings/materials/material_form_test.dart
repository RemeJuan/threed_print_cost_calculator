import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_policy.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
import 'package:threed_print_cost_calculator/settings/materials/material_form.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import '../settings_test_fakes.dart';

import '../../helpers/helpers.dart';

Finder _field(String key) {
  return find.descendant(
    of: find.byKey(ValueKey<String>(key)),
    matching: find.byType(TextFormField),
  );
}

Finder _decorator(String key) {
  return find.descendant(
    of: find.byKey(ValueKey<String>(key)),
    matching: find.byType(InputDecorator),
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

class _MaterialFlowHost extends StatelessWidget {
  const _MaterialFlowHost();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (_) => const MaterialForm(dbRef: 'material-1'),
              );
            },
            child: const Text('Open edit'),
          ),
          ElevatedButton(
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (_) => const MaterialForm(),
              );
            },
            child: const Text('Open create'),
          ),
        ],
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
      [
        materialsRepositoryProvider.overrideWithValue(repo),
        premiumAccessPolicyProvider.overrideWithValue(
          DefaultPremiumAccessPolicy(isPremium: true),
        ),
      ],
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

    await tester.ensureVisible(
      find.byKey(const ValueKey<String>('settings.materials.save.button')),
    );
    await tester.pumpAndSettle();
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

  testWidgets('cost input shows currency prefix when configured', (
    tester,
  ) async {
    final repo = FakeMaterialsRepository(
      useExplicitSaveResult: true,
      saveResult: 'material-1',
    );
    final db = await tester.pumpApp(
      _MaterialDialogHost(
        onResult: (_) {},
        builder: (_) => const MaterialForm(),
      ),
      [
        materialsRepositoryProvider.overrideWithValue(repo),
        settingsStreamProvider.overrideWith(
          (ref) => Stream.value(
            const GeneralSettingsModel(
              electricityCost: '',
              wattage: '',
              activePrinter: '',
              selectedMaterial: '',
              wearAndTear: '',
              failureRisk: '',
              labourRate: '',
              pricingMarkupPercent: '',
              pricingSetupFee: '',
              pricingRoundingMode: 'none',
              currencySymbol: 'R',
              currencyPosition: 'before',
              currencySpacing: false,
            ),
          ),
        ),
      ],
    );
    addTearDown(db.close);
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('R'), findsWidgets);
  });

  testWidgets('cost input shows spaced after-position suffix', (tester) async {
    final repo = FakeMaterialsRepository(
      useExplicitSaveResult: true,
      saveResult: 'material-1',
    );
    final db = await tester.pumpApp(
      _MaterialDialogHost(
        onResult: (_) {},
        builder: (_) => const MaterialForm(),
      ),
      [
        materialsRepositoryProvider.overrideWithValue(repo),
        settingsStreamProvider.overrideWith(
          (ref) => Stream.value(
            const GeneralSettingsModel(
              electricityCost: '',
              wattage: '',
              activePrinter: '',
              selectedMaterial: '',
              wearAndTear: '',
              failureRisk: '',
              labourRate: '',
              pricingMarkupPercent: '',
              pricingSetupFee: '',
              pricingRoundingMode: 'none',
              currencySymbol: 'R',
              currencyPosition: 'after',
              currencySpacing: true,
            ),
          ),
        ),
      ],
    );
    addTearDown(db.close);
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<InputDecorator>(_decorator('settings.materials.cost.input'))
          .decoration
          .suffixText,
      ' R',
    );
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
      [
        materialsRepositoryProvider.overrideWithValue(repo),
        premiumAccessPolicyProvider.overrideWithValue(
          DefaultPremiumAccessPolicy(isPremium: true),
        ),
      ],
    );
    addTearDown(db.close);

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.enterText(_field('settings.materials.name.input'), 'PLA');
    await tester.enterText(_field('settings.materials.color.input'), 'Blue');
    await tester.enterText(_field('settings.materials.weight.input'), '0');
    await tester.enterText(_field('settings.materials.cost.input'), '0');

    await tester.ensureVisible(
      find.byKey(const ValueKey<String>('settings.materials.save.button')),
    );
    await tester.pumpAndSettle();
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
      [
        materialsRepositoryProvider.overrideWithValue(repo),
        premiumAccessPolicyProvider.overrideWithValue(
          DefaultPremiumAccessPolicy(isPremium: true),
        ),
      ],
    );
    addTearDown(db.close);

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.enterText(_field('settings.materials.name.input'), 'PLA');
    await tester.enterText(_field('settings.materials.color.input'), 'Blue');
    await tester.enterText(_field('settings.materials.weight.input'), '1000,5');
    await tester.enterText(_field('settings.materials.cost.input'), '24,5');

    await tester.ensureVisible(
      find.byKey(const ValueKey<String>('settings.materials.save.button')),
    );
    await tester.pumpAndSettle();
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
      [
        materialsRepositoryProvider.overrideWithValue(repo),
        premiumAccessPolicyProvider.overrideWithValue(
          DefaultPremiumAccessPolicy(isPremium: true),
        ),
      ],
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

  testWidgets('free tier disables track remaining filament', (tester) async {
    final repo = FakeMaterialsRepository();
    final db = await tester.pumpApp(
      _MaterialDialogHost(
        onResult: (_) {},
        builder: (_) => const MaterialForm(),
      ),
      [
        materialsRepositoryProvider.overrideWithValue(repo),
        premiumAccessPolicyProvider.overrideWithValue(
          DefaultPremiumAccessPolicy(isPremium: false),
        ),
      ],
    );
    addTearDown(db.close);

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(
        const ValueKey<String>('settings.materials.track_remaining.toggle'),
      ),
      findsNothing,
    );
    expect(
      find.byKey(
        const ValueKey<String>('settings.materials.remaining_weight.input'),
      ),
      findsNothing,
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
      [
        materialsRepositoryProvider.overrideWithValue(repo),
        premiumAccessPolicyProvider.overrideWithValue(
          DefaultPremiumAccessPolicy(isPremium: true),
        ),
      ],
    );
    addTearDown(db.close);

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.enterText(_field('settings.materials.name.input'), 'PLA');
    await tester.enterText(_field('settings.materials.color.input'), 'Blue');
    await tester.enterText(_field('settings.materials.weight.input'), '1000');
    await tester.enterText(_field('settings.materials.cost.input'), '24.5');
    await tester.ensureVisible(
      find.byKey(const ValueKey<String>('settings.materials.save.button')),
    );
    await tester.pumpAndSettle();
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
      [
        materialsRepositoryProvider.overrideWithValue(repo),
        premiumAccessPolicyProvider.overrideWithValue(
          DefaultPremiumAccessPolicy(isPremium: true),
        ),
      ],
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

  testWidgets('create form resets after closing edited material dialog', (
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
      brand: 'Sunlu',
      materialType: 'PLA+',
      colorHex: '#112233',
      notes: 'Edited material',
    );
    final repo = FakeMaterialsRepository();
    repo.materialsById[material.id] = material;

    final db = await tester.pumpApp(const _MaterialFlowHost(), [
      materialsRepositoryProvider.overrideWithValue(repo),
      premiumAccessPolicyProvider.overrideWithValue(
        DefaultPremiumAccessPolicy(isPremium: true),
      ),
    ]);
    addTearDown(db.close);

    await tester.tap(find.text('Open edit'));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<TextFormField>(_field('settings.materials.name.input'))
          .controller!
          .text,
      'PLA',
    );

    await tester.ensureVisible(find.text('Cancel'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open create'));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<TextFormField>(_field('settings.materials.name.input'))
          .controller!
          .text,
      isEmpty,
    );
    expect(
      tester
          .widget<TextFormField>(_field('settings.materials.color.input'))
          .controller!
          .text,
      isEmpty,
    );
    expect(
      tester
          .widget<TextFormField>(_field('settings.materials.weight.input'))
          .controller!
          .text,
      isEmpty,
    );
    expect(
      tester
          .widget<TextFormField>(_field('settings.materials.cost.input'))
          .controller!
          .text,
      isEmpty,
    );
    expect(
      tester
          .widget<TextFormField>(_field('settings.materials.notes.input'))
          .controller!
          .text,
      isEmpty,
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
      isFalse,
    );
    expect(
      find.byKey(
        const ValueKey<String>('settings.materials.remaining_weight.input'),
      ),
      findsNothing,
    );
  });
}
