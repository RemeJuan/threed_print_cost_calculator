import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_file_validator.dart';

void main() {
  group('looksTextLike', () {
    test('returns false for empty string', () {
      expect(looksTextLike(''), false);
    });

    test('returns true for plain ASCII text', () {
      expect(looksTextLike('hello world'), true);
    });

    test('returns true for G-code text with newlines', () {
      expect(looksTextLike('G1 X10 Y10\nM104 S200\n'), true);
    });

    test('returns false for binary data with many control chars', () {
      final binary = Uint8List.fromList([0, 1, 2, 3, 4, 5, 6, 7, 8, 11]);
      expect(looksTextLike(String.fromCharCodes(binary)), false);
    });
  });

  group('looksLikeGCode', () {
    test('detects FLAVOR comment', () {
      expect(looksLikeGCode('; FLAVOR: Marlin\n'), true);
    });

    test('detects Generated with comment', () {
      expect(looksLikeGCode('; Generated with PrusaSlicer\n'), true);
    });

    test('detects TIME comment', () {
      expect(looksLikeGCode('; TIME: 100\n'), true);
    });

    test('detects filament used comment', () {
      expect(looksLikeGCode('; filament used = 1.2m\n'), true);
    });

    test('detects G0 moves', () {
      expect(looksLikeGCode('G0 X10 Y10 F3000\n'), true);
    });

    test('detects G1 moves', () {
      expect(looksLikeGCode('G1 X10 Y10 E0.1\n'), true);
    });

    test('detects M104', () {
      expect(looksLikeGCode('M104 S200\n'), true);
    });

    test('detects M109', () {
      expect(looksLikeGCode('M109 S200\n'), true);
    });

    test('detects M140', () {
      expect(looksLikeGCode('M140 S60\n'), true);
    });

    test('detects M190', () => expect(looksLikeGCode('M190 S60\n'), true));

    test('returns false for plain text without G-code markers', () {
      expect(looksLikeGCode('hello world'), false);
    });

    test('returns false for binary data', () {
      final binary = Uint8List.fromList([0, 1, 2, 3, 4, 5, 6, 7, 8, 11]);
      expect(looksLikeGCode(String.fromCharCodes(binary)), false);
    });
  });

  group('looksLikeTextualGCodeMimeType', () {
    test('matches text/plain', () {
      expect(looksLikeTextualGCodeMimeType('text/plain'), true);
    });

    test('matches text/x.gcode', () {
      expect(looksLikeTextualGCodeMimeType('text/x.gcode'), true);
    });

    test('matches application/x-gcode', () {
      expect(looksLikeTextualGCodeMimeType('application/x-gcode'), true);
    });

    test('matches application/gcode', () {
      expect(looksLikeTextualGCodeMimeType('application/gcode'), true);
    });

    test('rejects application/octet-stream', () {
      expect(looksLikeTextualGCodeMimeType('application/octet-stream'), false);
    });

    test('rejects image/png', () {
      expect(looksLikeTextualGCodeMimeType('image/png'), false);
    });
  });

  group('sniffText', () {
    test('decodes valid UTF-8 bytes', () {
      final bytes = Uint8List.fromList('hello'.codeUnits);
      expect(sniffText(bytes), 'hello');
    });

    test('handles bytes exceeding sniff limit', () {
      final bytes = Uint8List(100 * 1024);
      for (var i = 0; i < bytes.length; i++) {
        bytes[i] = 0x61;
      }
      final result = sniffText(bytes);
      expect(result.length, 64 * 1024);
      expect(result, startsWith('a' * 64 * 1024));
    });

    test('handles malformed UTF-8', () {
      final bytes = Uint8List.fromList([0xff, 0xfe, 0x00]);
      expect(() => sniffText(bytes), returnsNormally);
    });
  });
}
