import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/settings/backup_restore/backup_restore_section.dart';

void main() {
  test('restore helper waits then refreshes targeted providers', () async {
    var endOfFrameWaited = false;
    final calls = <String>[];

    final result = await restoreBackupAndRefresh(
      restore: () async {
        calls.add('restore');
        return 'done';
      },
      resetCalculator: () async => calls.add('reset'),
      refreshHistory: () async => calls.add('history'),
      waitForEndOfFrame: () async {
        endOfFrameWaited = true;
        calls.add('frame');
      },
    );

    expect(endOfFrameWaited, isTrue);
    expect(result, 'done');
    expect(calls, ['frame', 'restore', 'reset', 'history']);
  });
}
