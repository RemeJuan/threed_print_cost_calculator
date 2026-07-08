import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage_input.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/calculator/view/calculator_page.dart';
import 'package:threed_print_cost_calculator/calculator/view/components/materials_selection/material_row.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';

import '../../helpers/helpers.dart';
import '../../helpers/lower_level_test_fakes.dart';
import '../../../test_support/fake_purchases_gateway.dart';

class _MaterialRowSummaryHarness extends StatefulWidget {
  const _MaterialRowSummaryHarness();

  @override
  State<_MaterialRowSummaryHarness> createState() =>
      _MaterialRowSummaryHarnessState();
}

class _MaterialRowSummaryHarnessState extends State<_MaterialRowSummaryHarness> {
  static final MaterialModel _material = MaterialModel(
    id: 'mat_1',
    name: 'PLA Black',
    color: 'Black',
    cost: '20',
    weight: '1000',
    archived: false,
  );

  List<MaterialUsageInput> usages = const [
    MaterialUsageInput(
      materialId: 'mat_1',
      materialName: 'PLA Black',
      costPerKg: 20,
      weightGrams: 0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final totalWeight = usages.fold<int>(
      0,
      (sum, usage) => sum + usage.weightGrams,
    );
    final summary =
        '${usages.length} ${usages.length == 1 ? 'material' : 'materials'} · ${totalWeight}g';

    return SingleChildScrollView(
      child: Column(
        children: [
          Text(summary),
          if (usages.isNotEmpty)
            SizedBox(
              height: 96,
              child: MaterialRow(
                index: 0,
                usage: usages.first,
                material: _material,
                onPick: () {},
                onWeightChanged: (grams) {
                  setState(() {
                    usages = [usages.first.copyWith(weightGrams: grams)];
                  });
                },
                onRemove: () {
                  setState(() {
                    usages = const [];
                  });
                },
              ),
            ),
        ],
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final l10n = lookupAppLocalizations(const Locale('en'));

  late FakeCalculatorNotifier calculatorNotifier;

  setUpAll(() async {
    await setupTest();
  });

  setUp(() {
    calculatorNotifier = FakeCalculatorNotifier();
    SharedPreferences.setMockInitialValues({});
  });

  group('CalculatorPage', () {
    testWidgets('renders CalculatorView', (tester) async {
      final db = await tester.pumpApp(const CalculatorPage(), [
        calculatorProvider.overrideWith(() => calculatorNotifier),
      ]);
      addTearDown(() => db.close());
      await tester.pumpAndSettle();
      expect(find.byType(CalculatorPage), findsOneWidget);
    });

    testWidgets('shows batch costing entry for free users', (tester) async {
      final db = await tester.pumpApp(const CalculatorPage(), [
        calculatorProvider.overrideWith(() => calculatorNotifier),
      ]);
      addTearDown(() => db.close());

      await tester.pumpAndSettle();

      expect(
        find.byKey(
          const ValueKey<String>('calculator.batch_costing.open.button'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('opens batch costing shell when enabled', (tester) async {
      final db = await tester.pumpApp(const CalculatorPage(), [
        calculatorProvider.overrideWith(() => calculatorNotifier),
        purchasesGatewayProvider.overrideWithValue(
          FakePurchasesGateway.premium(),
        ),
      ]);
      addTearDown(() => db.close());

      await tester.pumpAndSettle();

      expect(find.text('Start Batch Costing'), findsOneWidget);

      await tester.tap(
        find.byKey(
          const ValueKey<String>('calculator.batch_costing.open.button'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Batch item review'), findsOneWidget);
      expect(
        find.text('Review batch items before printer assignment.'),
        findsOneWidget,
      );
    });

    testWidgets(
      'existing material row updates total and remove updates summary',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: _MaterialRowSummaryHarness()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('PLA Black'), findsWidgets);
        expect(find.text('1 material · 0g'), findsOneWidget);

        final weightField = find.byType(TextFormField).last;
        await tester.enterText(weightField, '120');
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('1 material · 120g'), findsOneWidget);

        await tester.drag(find.byType(Slidable).first, const Offset(-300, 0));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.delete));
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10n.deleteButton).last);
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('0 materials · 0g'), findsOneWidget);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
      },
    );
  });
}
