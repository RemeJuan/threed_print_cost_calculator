import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/history/components/history_item.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';

import '../../helpers/helpers.dart';

HistoryModel _model() {
  return HistoryModel(
    name: 'Multi Material Benchy',
    totalCost: 42.5,
    riskCost: 3.5,
    filamentCost: 25.0,
    electricityCost: 7.0,
    labourCost: 8.0,
    date: DateTime.utc(2024, 1, 3),
    printer: 'Prusa MK4',
    material: 'PLA',
    weight: 123,
    timeHours: '06:20',
    materialUsages: [
      {'materialId': 'pla-red', 'materialName': 'PLA Red', 'weightGrams': 75},
      {'materialName': 'Support', 'weightGrams': 48},
    ],
  );
}

HistoryModel _singleMaterialSnapshotModel() {
  return HistoryModel(
    name: 'Single Snapshot Benchy',
    totalCost: 14.11,
    riskCost: 1.41,
    filamentCost: 8.19,
    electricityCost: 1.23,
    labourCost: 3.28,
    date: DateTime.utc(2024, 1, 4),
    printer: 'Prusa MK4',
    material: 'PLA Black',
    weight: 123,
    timeHours: '01:45',
    materialUsages: const [
      {
        'materialId': 'pla-black',
        'materialName': 'PLA Black',
        'costPerKg': 0,
        'weightGrams': 123,
      },
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupTest();
  });

  testWidgets('renders costs, summary, and breakdown labels', (tester) async {
    await tester.pumpApp(HistoryItem(dbKey: 'history-1', data: _model()), [
      materialsStreamProvider.overrideWith(
        (ref) => Stream.value([
          const MaterialModel(
            id: 'pla-red',
            name: 'PLA',
            cost: '25',
            color: 'Red',
            weight: '1000',
            archived: false,
          ),
        ]),
      ),
    ]);

    await tester.pumpAndSettle();

    expect(find.text('Multi Material Benchy'), findsOneWidget);
    expect(find.text('03 Jan 2024'), findsOneWidget);
    expect(find.text('0.12 kg • 6h 20m • Prusa MK4 • PLA'), findsOneWidget);
    expect(find.text('42.50'), findsOneWidget);
    expect(find.text('3.50'), findsOneWidget);
    expect(find.text('25.00'), findsOneWidget);
    expect(find.text('7.00'), findsOneWidget);
    expect(find.text('8.00'), findsOneWidget);

    await tester.tap(find.text(S.current.materialBreakdownLabel));
    await tester.pumpAndSettle();

    expect(find.text('PLA (Red)'), findsOneWidget);
    expect(find.text('Support'), findsOneWidget);
    expect(find.text('75g'), findsOneWidget);
    expect(find.text('48g'), findsOneWidget);
  });

  testWidgets(
    'renders_single_material_filament_cost_from_stored_snapshot_not_material_usage',
    (tester) async {
      await tester.pumpApp(
        HistoryItem(
          dbKey: 'history-single',
          data: _singleMaterialSnapshotModel(),
        ),
        [
          materialsStreamProvider.overrideWith(
            (ref) => Stream.value([
              const MaterialModel(
                id: 'pla-black',
                name: 'PLA',
                cost: '99',
                color: 'Black',
                weight: '1000',
                archived: false,
              ),
            ]),
          ),
        ],
      );

      await tester.pumpAndSettle();

      expect(find.text('Single Snapshot Benchy'), findsOneWidget);
      expect(find.text('8.19'), findsOneWidget);

      await tester.tap(find.text(S.current.materialBreakdownLabel));
      await tester.pumpAndSettle();

      expect(find.text('PLA (Black)'), findsOneWidget);
      expect(find.text('123g'), findsOneWidget);
      expect(find.text('8.19'), findsOneWidget);
    },
  );
}
