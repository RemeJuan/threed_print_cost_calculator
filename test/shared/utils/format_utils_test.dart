import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/shared/utils/format_utils.dart';

void main() {
  test('formatCurrencyValue formats symbol placement', () {
    expect(
      formatCurrencyValue(
        95.3,
        currencySymbol: '',
        currencyPosition: 'before',
        currencySpacing: false,
      ),
      '95.30',
    );
    expect(
      formatCurrencyValue(
        95.3,
        currencySymbol: '€',
        currencyPosition: 'after',
        currencySpacing: true,
      ),
      '95.30 €',
    );
    expect(
      formatCurrencyValue(
        95.3,
        currencySymbol: 'R',
        currencyPosition: 'before',
        currencySpacing: false,
      ),
      'R95.30',
    );
  });
}
