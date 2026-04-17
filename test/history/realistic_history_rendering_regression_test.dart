import 'package:flutter_test/flutter_test.dart';

import '../helpers/helpers.dart';
import 'history_regression_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(setupTest);

  group('Rendered values', () {
    testWidgets('save form builds fallback single-material payload', (
      tester,
    ) async {
      final savedModel = await captureSavedModel(
        tester,
        state: HistoryRegressionFixtures.fallbackState,
        results: HistoryRegressionFixtures.fallbackResults,
        name: 'Fallback 0.33',
        settings: HistoryRegressionFixtures.fallbackSettings,
        printers: HistoryRegressionFixtures.fallbackPrinters(),
        materials: HistoryRegressionFixtures.fallbackMaterials(),
      );
      expect(savedModel.material, 'PLA Marble');
      expect(savedModel.materialUsages.single['weightGrams'], 14);
    });

    testWidgets('save form keeps initialized single-row payload', (
      tester,
    ) async {
      final savedModel = await captureSavedModel(
        tester,
        state: HistoryRegressionFixtures.initializedState,
        results: HistoryRegressionFixtures.initializedResults,
        name: 'Single 1.77',
        settings: HistoryRegressionFixtures.initializedSettings,
        printers: HistoryRegressionFixtures.initializedPrinters(),
        materials: HistoryRegressionFixtures.initializedMaterials(),
      );
      expect(savedModel.material, 'PETG Black');
      expect(savedModel.materialUsages.length, 1);
    });

    testWidgets('save form keeps multi-material payload', (tester) async {
      final savedModel = await captureSavedModel(
        tester,
        state: HistoryRegressionFixtures.multiMaterialState,
        results: HistoryRegressionFixtures.multiMaterialResults,
        name: 'Multi 0.33',
        settings: HistoryRegressionFixtures.multiMaterialSettings,
        printers: HistoryRegressionFixtures.multiMaterialPrinters(),
      );
      expect(savedModel.material, 'PLA Black +1');
      expect(savedModel.materialUsages.length, 2);
    });

    testWidgets('calculator results shows 0.33-style values', (tester) async {
      final view = await pumpCalculatorResultsView(
        tester,
        HistoryRegressionFixtures.fallbackResults,
      );
      expect(view['electricity'], '0.04');
      expect(view['total'], '0.33');
    });

    testWidgets('history item shows stored single-material values', (
      tester,
    ) async {
      final view = await pumpHistoryItemView(
        tester,
        HistoryRegressionFixtures.fallbackHistoryModel(),
        materials: HistoryRegressionFixtures.fallbackMaterials(),
      );
      expect(view['filament'], '0.29');
      expect(view['total'], '0.33');
    });

    testWidgets('history item keeps stored legacy zero-cost snapshot', (
      tester,
    ) async {
      final view = await pumpHistoryItemView(
        tester,
        HistoryRegressionFixtures.initializedHistoryModel(),
      );
      expect(view['filament'], '1.35');
      expect(view['total'], '1.77');
    });
  });
}
