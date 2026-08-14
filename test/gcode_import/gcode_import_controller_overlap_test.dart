import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_controller.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_result.dart';

import 'gcode_import_controller_test_support.dart';

void main() {
  test('ignores stale overlapping attempt completion', () async {
    final aBytes = Completer<Uint8List>();
    final bService = Completer<GCodeImportResult>();
    final states = <GCodeImportState>[];
    final container = makeContainer(
      file: makeFileAsync('part-a.gcode', aBytes.future),
      serviceResult: result,
      onImportAsync: () => bService.future,
    );
    container.listen(
      gcodeImportControllerProvider,
      (_, next) => states.add(next),
    );

    final controller = container.read(gcodeImportControllerProvider.notifier);
    final attemptA = controller.parsePickedFile(
      makeFileAsync('part-a.gcode', aBytes.future),
      attemptId: 'attempt-a',
    );

    await Future<void>.delayed(Duration.zero);

    final attemptB = controller.parsePickedFile(
      makeFile('part-b.gcode', gcodeBytes()),
      attemptId: 'attempt-b',
    );

    bService.complete(result);
    await attemptB;

    expect(
      container.read(gcodeImportControllerProvider).activeAttemptId,
      'attempt-b',
    );
    expect(
      container.read(gcodeImportControllerProvider).status,
      GCodeImportStatus.success,
    );

    aBytes.complete(gcodeBytes());
    await attemptA;

    final state = container.read(gcodeImportControllerProvider);
    expect(state.status, GCodeImportStatus.success);
    expect(state.activeAttemptId, 'attempt-b');
    expect(states.last.activeAttemptId, 'attempt-b');
  });
}
