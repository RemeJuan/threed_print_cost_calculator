import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';

void main() {
  test('MaterialModel archived round trips through toMap/fromMap', () {
    const model = MaterialModel(
      id: 'material-1',
      name: 'PLA',
      cost: '12.50',
      color: 'Red',
      weight: '1000',
      archived: true,
    );

    final roundTrip = MaterialModel.fromMap(model.toMap(), model.id);

    expect(roundTrip.archived, isTrue);
  });

  test('MaterialModel.fromMap defaults archived to false when absent', () {
    final model = MaterialModel.fromMap({
      'name': 'PLA',
      'cost': '12.50',
      'color': 'Red',
      'weight': '1000',
    }, 'material-1');

    expect(model.archived, isFalse);
  });
}
