import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/materials/color_utils.dart';

void main() {
  group('colorFromMaterial', () {
    test('parses 6-char hex', () {
      final c = colorFromMaterial(const MaterialColorInput(colorHex: '#FF0000'));
      expect((c.r * 255).round(), 255);
      expect((c.g * 255).round(), 0);
      expect((c.b * 255).round(), 0);
    });

    test('parses hex without hash prefix', () {
      final c = colorFromMaterial(const MaterialColorInput(colorHex: '00FF00'));
      expect((c.r * 255).round(), 0);
      expect((c.g * 255).round(), 255);
      expect((c.b * 255).round(), 0);
    });

    test('parses 8-char hex (with alpha)', () {
      final c = colorFromMaterial(
        const MaterialColorInput(colorHex: '800000FF'),
      );
      expect((c.a * 255).round(), 128);
      expect((c.r * 255).round(), 0);
      expect((c.g * 255).round(), 0);
      expect((c.b * 255).round(), 255);
    });

    test('parses 8-char hex with hash', () {
      final c = colorFromMaterial(
        const MaterialColorInput(colorHex: '#FF0000FF'),
      );
      expect((c.a * 255).round(), 255);
      expect((c.r * 255).round(), 0);
      expect((c.g * 255).round(), 0);
      expect((c.b * 255).round(), 255);
    });

    test('matches named color', () {
      final c = colorFromMaterial(const MaterialColorInput(colorName: 'Red'));
      expect((c.r * 255).round(), 255);
      expect((c.g * 255).round(), 0);
      expect((c.b * 255).round(), 0);
    });

    test('matches named color case-insensitive', () {
      final c = colorFromMaterial(const MaterialColorInput(colorName: 'DARK RED'));
      expect((c.r * 255).round(), 139);
      expect((c.g * 255).round(), 0);
      expect((c.b * 255).round(), 0);
    });

    test('partial name match falls through to substring lookup', () {
      final c = colorFromMaterial(
        const MaterialColorInput(colorName: 'Dark Blueish'),
      );
      expect((c.r * 255).round(), 0);
      expect((c.g * 255).round(), 0);
      expect((c.b * 255).round(), 255);
    });

    test('hex takes priority over color name', () {
      final c = colorFromMaterial(
        const MaterialColorInput(
          colorName: 'Red',
          colorHex: '#0000FF',
        ),
      );
      expect((c.r * 255).round(), 0);
      expect((c.g * 255).round(), 0);
      expect((c.b * 255).round(), 255);
    });

    test('returns deterministic fallback for unknown name', () {
      final c1 = colorFromMaterial(
        const MaterialColorInput(colorName: 'ZzzNotAColor'),
      );
      final c2 = colorFromMaterial(
        const MaterialColorInput(colorName: 'ZzzNotAColor'),
      );
      expect((c1.r * 255).round(), (c2.r * 255).round());
      expect((c1.g * 255).round(), (c2.g * 255).round());
      expect((c1.b * 255).round(), (c2.b * 255).round());
    });

    test('different unknown names produce different colors', () {
      final c1 = colorFromMaterial(
        const MaterialColorInput(colorName: 'FooBar'),
      );
      final c2 = colorFromMaterial(
        const MaterialColorInput(colorName: 'BazQux'),
      );
      final same = (c1.r * 255).round() == (c2.r * 255).round() &&
          (c1.g * 255).round() == (c2.g * 255).round() &&
          (c1.b * 255).round() == (c2.b * 255).round();
      expect(same, isFalse);
    });

    test('returns non-transparent for default empty input', () {
      final c = colorFromMaterial(const MaterialColorInput());
      expect((c.a * 255).round(), 255);
    });

    test('handles transparent named color', () {
      final c = colorFromMaterial(const MaterialColorInput(colorName: 'transparent'));
      expect((c.a * 255).round(), 0);
    });
  });
}
