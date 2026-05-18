import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/batch_costing/helpers/batch_summary_calculator.dart';
import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_costing_state.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_pricing_state.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';

void main() {
  test('HistoryModel.fromMap parses localized numeric strings', () {
    final model = HistoryModel.fromMap({
      'name': 'Localized',
      'totalCost': '12,5',
      'riskCost': '1,5',
      'filamentCost': '7,25',
      'electricityCost': '2,5',
      'labourCost': '1,25',
      'date': DateTime.utc(2024, 1, 1).toIso8601String(),
      'printer': 'Printer',
      'material': 'PLA',
      'weight': ' 42,5 ',
      'timeHours': '01:00',
      'importedFromGcode': true,
    });

    expect(model.totalCost, 12.5);
    expect(model.riskCost, 1.5);
    expect(model.filamentCost, 7.25);
    expect(model.electricityCost, 2.5);
    expect(model.labourCost, 1.25);
    expect(model.weight, 42.5);
    expect(model.importedFromGcode, isTrue);
  });

  test('HistoryModel.batchQuote round-trips batch snapshot fields', () {
    final state = BatchCostingState(
      items: [
        BatchCostingItem.manual(
          id: 'item-1',
          displayName: 'Benchy',
          quantity: 2,
          printWeightG: 10,
          printDuration: const Duration(hours: 1),
          printerId: 'printer-1',
          materialId: 'material-1',
        ),
      ],
      batchPrinterId: 'printer-1',
      batchMaterialId: 'material-1',
      pricing: const BatchPricingState(
        labourRate: BatchPricingFieldState(value: '10'),
      ),
    );
    final summary = BatchSummaryCalculator.calculate(state);

    final model = HistoryModel.batchQuote(
      name: 'Batch quote',
      date: DateTime.utc(2024, 1, 1),
      state: state,
      summary: summary,
    );

    final roundTrip = HistoryModel.fromMap(model.toMap());

    expect(roundTrip.batchQuote, isTrue);
    expect(roundTrip.batchQuoteItems, hasLength(1));
    expect(roundTrip.batchQuoteSummary?['batchPrinterId'], 'printer-1');
    expect(roundTrip.totalCost, summary.finalTotal);
  });
}
