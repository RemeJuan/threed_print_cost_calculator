import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/shared/utils/label_utils.dart';

void main() {
  group('formatCountLabel', () {
    test('replaces # with count when present', () {
      final raw = '# materials';
      final res = formatCountLabel(raw, 3);
      expect(res, '3 materials');
    });

    test('returns original string when no # present', () {
      final raw = 'No placeholder';
      final res = formatCountLabel(raw, 5);
      expect(res, raw);
    });

    test('works with multiple # occurrences', () {
      final raw = '# items and # more';
      final res = formatCountLabel(raw, 2);
      expect(res, '2 items and 2 more');
    });

    test('handles zero and negative counts', () {
      expect(formatCountLabel('#', 0), '0');
      expect(formatCountLabel('# items', -1), '-1 items');
    });
  });
}
