import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_android_file_picker.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_file_picker.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_file_validator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  test('supported extension helper accepts bin files', () {
    expect(hasSupportedGCodeExtension('benchy.gcode'), isTrue);
    expect(hasSupportedGCodeExtension('benchy.gco'), isTrue);
    expect(hasSupportedGCodeExtension('benchy.nc'), isTrue);
    expect(hasSupportedGCodeExtension('cache.bin'), isTrue);
  });

  test('android picker sends max size to native channel', () async {
    final picker = AndroidGCodeImportFilePicker();
    final channel = const MethodChannel('com.threed_print_calculator/gcode_import_picker');
    Object? capturedArgs;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      capturedArgs = call.arguments;
      return null;
    });

    final picked = await picker.pick();

    expect(picked, isNull);
    expect(capturedArgs, <String, Object>{'maxBytes': maxGCodeImportBytes});

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });
}
