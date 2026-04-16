import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/shared/utils/number_parsing.dart';

void main() {
  group('number parsing', () {
    test('parses localized numbers predictably', () {
      expect(parseLocalizedNum('12'), 12);
      expect(parseLocalizedNum('12.5'), 12.5);
      expect(parseLocalizedNum('12,5'), 12.5);
      expect(parseLocalizedNum(' 12,5 '), 12.5);
      expect(parseLocalizedNum(''), isNull);
      expect(parseLocalizedNum('abc'), isNull);
    });

    test('uses fallback for invalid localized values', () {
      expect(parseLocalizedNumOrFallback('', fallback: 7), 7);
      expect(parseLocalizedNumOrFallback('abc', fallback: 7), 7);
    });
  });
}
