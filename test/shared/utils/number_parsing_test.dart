import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/shared/utils/number_parsing.dart';

void main() {
  group('number parsing', () {
    test('parses localized numbers predictably', () {
      expect(tryParseLocalizedNum('12'), 12);
      expect(tryParseLocalizedNum('12.5'), 12.5);
      expect(tryParseLocalizedNum('12,5'), 12.5);
      expect(tryParseLocalizedNum(' 12,5 '), 12.5);
      expect(tryParseLocalizedNum(''), isNull);
      expect(tryParseLocalizedNum('abc'), isNull);
    });

    test('uses fallback for invalid localized values', () {
      expect(parseLocalizedNum('', fallback: 7), 7);
      expect(parseLocalizedNum('abc', fallback: 7), 7);
    });
  });
}
