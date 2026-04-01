import 'package:flutter_test/flutter_test.dart';
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
    });

    expect(model.totalCost, 12.5);
    expect(model.riskCost, 1.5);
    expect(model.filamentCost, 7.25);
    expect(model.electricityCost, 2.5);
    expect(model.labourCost, 1.25);
    expect(model.weight, 42.5);
  });
}
