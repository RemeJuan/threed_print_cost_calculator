import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/settings/backup_restore/backup_restore_section.dart';
import 'package:threed_print_cost_calculator/settings/backup_restore/backup_restore_service.dart';

class _FakeL10n implements AppLocalizations {
  @override
  String get dataBackupJsonFileTypeLabel => 'JSON backup';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

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

  test('android restore accepts json backups', () {
    final groups = backupAcceptedTypeGroups(
      TargetPlatform.android,
      _FakeL10n(),
    );

    expect(groups, hasLength(1));
    expect(groups.single.extensions, ['json']);
    expect(groups.single.mimeTypes, [backupJsonMimeType]);
  });

  test('desktop restore keeps json-only filter', () {
    final groups = backupAcceptedTypeGroups(TargetPlatform.macOS, _FakeL10n());

    expect(groups, hasLength(1));
    expect(groups.single.extensions, ['json']);
    expect(groups.single.mimeTypes, isNull);
  });
}
