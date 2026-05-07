import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_file_picker.dart';

void main() {
  test('iOS picker accepts generic data files', () {
    final groups = gCodeAcceptedTypeGroups(TargetPlatform.iOS);

    expect(groups, hasLength(1));
    expect(groups.single.label, 'G-code');
    expect(groups.single.uniformTypeIdentifiers, ['public.data']);
    expect(groups.single.extensions, isNull);
  });

  test('desktop picker filters by gcode extensions', () {
    final groups = gCodeAcceptedTypeGroups(TargetPlatform.macOS);

    expect(groups, hasLength(1));
    expect(groups.single.label, 'G-code');
    expect(groups.single.extensions, ['gcode', 'gco', 'nc', 'bin']);
    expect(groups.single.uniformTypeIdentifiers, isNull);
  });

  test('supported extension helper ignores bin files', () {
    expect(hasSupportedGCodeExtension('benchy.gcode'), isTrue);
    expect(hasSupportedGCodeExtension('benchy.gco'), isTrue);
    expect(hasSupportedGCodeExtension('benchy.nc'), isTrue);
    expect(hasSupportedGCodeExtension('cache.bin'), isFalse);
  });
}
