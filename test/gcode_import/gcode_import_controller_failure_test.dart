import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_controller.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_file_picker.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_service.dart';

import 'gcode_import_controller_test_support.dart';

void main() {
  test('handles service read failure as readFailed', () async {
    final container = makeContainer(
      file: makeFile('part.gcode', gcodeBytes()),
      serviceResult: result,
      failure: GCodeImportFailure.read(
        Exception('read error'),
        StackTrace.current,
      ),
    );

    await container.read(gcodeImportControllerProvider.notifier).pickAndParse();

    final state = container.read(gcodeImportControllerProvider);
    expect(state.status, GCodeImportStatus.failure);
    expect(state.error, GCodeImportError.readFailed);
  });

  test('handles service parse failure as unsupportedFile', () async {
    final container = makeContainer(
      file: makeFile('part.gcode', gcodeBytes()),
      serviceResult: result,
      failure: GCodeImportFailure.parse(
        FormatException('bad parse'),
        StackTrace.current,
      ),
    );

    await container.read(gcodeImportControllerProvider.notifier).pickAndParse();

    final state = container.read(gcodeImportControllerProvider);
    expect(state.status, GCodeImportStatus.failure);
    expect(state.error, GCodeImportError.unsupportedFile);
  });

  test('picker exception emits pickerException parse failure', () async {
    final container = ProviderContainer(
      overrides: [
        gcodeImportFilePickerProvider.overrideWithValue(ThrowingPicker()),
      ],
    );
    final events = <Map<String, Object?>>[];
    final originalService = AppAnalytics.service;
    AppAnalytics.service = CaptureAnalytics(events);
    addTearDown(() => AppAnalytics.service = originalService);

    await container.read(gcodeImportControllerProvider.notifier).pickAndParse();

    expect(events.single['failure_reason'], GCodeFailureReason.pickerException);
  });

  test('service exception emits readFailed parse failure', () async {
    final container = makeContainer(
      file: makeFile('part.gcode', gcodeBytes()),
      serviceResult: result,
      failure: GCodeImportFailure.read(
        Exception('read error'),
        StackTrace.current,
      ),
    );
    final events = <Map<String, Object?>>[];
    final originalService = AppAnalytics.service;
    AppAnalytics.service = CaptureAnalytics(events);
    addTearDown(() => AppAnalytics.service = originalService);

    await container.read(gcodeImportControllerProvider.notifier).pickAndParse();

    expect(events.single['failure_reason'], GCodeFailureReason.readFailed);
  });

  test('service parse failure emits parseException parse failure', () async {
    final container = makeContainer(
      file: makeFile('part.gcode', gcodeBytes()),
      serviceResult: result,
      failure: GCodeImportFailure.parse(
        FormatException('bad parse'),
        StackTrace.current,
      ),
    );
    final events = <Map<String, Object?>>[];
    final originalService = AppAnalytics.service;
    AppAnalytics.service = CaptureAnalytics(events);
    addTearDown(() => AppAnalytics.service = originalService);

    await container.read(gcodeImportControllerProvider.notifier).pickAndParse();

    expect(events.single['failure_reason'], GCodeFailureReason.parseException);
  });

  test('metadata-empty result emits noMetadata analytics', () async {
    final container = makeContainer(
      file: makeFile('part.gcode', gcodeBytes()),
      serviceResult: emptyResult,
    );
    final events = <Map<String, Object?>>[];
    final originalService = AppAnalytics.service;
    AppAnalytics.service = CaptureAnalytics(events);
    addTearDown(() => AppAnalytics.service = originalService);

    await container.read(gcodeImportControllerProvider.notifier).pickAndParse();

    expect(events.single['failure_reason'], GCodeFailureReason.noMetadata);
  });

  test('typed service failure does not duplicate capture', () async {
    final container = makeContainer(
      file: makeFile('part.gcode', gcodeBytes()),
      serviceResult: result,
      failure: GCodeImportFailure.read(
        Exception('read error'),
        StackTrace.current,
      ),
    );
    final events = <Map<String, Object?>>[];
    final originalService = AppAnalytics.service;
    AppAnalytics.service = CaptureAnalytics(events);
    addTearDown(() => AppAnalytics.service = originalService);

    await container.read(gcodeImportControllerProvider.notifier).pickAndParse();

    expect(events.length, 1);
    expect(events.single['failure_reason'], GCodeFailureReason.readFailed);
  });

  test('handles metadata-empty result as unsupportedFile', () async {
    final container = makeContainer(
      file: makeFile('part.gcode', gcodeBytes()),
      serviceResult: emptyResult,
    );

    await container.read(gcodeImportControllerProvider.notifier).pickAndParse();

    final state = container.read(gcodeImportControllerProvider);
    expect(state.status, GCodeImportStatus.failure);
    expect(state.error, GCodeImportError.unsupportedFile);
  });
}
