import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/core/integrity/play_integrity_models.dart';

void main() {
  test('parses snapshot values and decision', () {
    final snapshot = PlayIntegritySnapshot.fromJson({
      'license': 'LICENSED',
      'appIntegrity': 'PLAY_RECOGNIZED',
      'deviceIntegrity': 'MEETS_DEVICE_INTEGRITY',
      'virtualIntegrity': 'UNEVALUATED',
      'recentDeviceActivity': 'LEVEL_1',
      'playProtect': 'NO_ISSUES',
      'appAccessRisk': ['OVERLAY'],
      'decision': 'allow_logged_risk',
    });

    expect(snapshot.license, 'LICENSED');
    expect(snapshot.decision, PlayIntegrityDecisionLabel.allowLoggedRisk);
    expect(snapshot.appAccessRisk, ['OVERLAY']);
  });

  test('falls back for missing and unknown values', () {
    final snapshot = PlayIntegritySnapshot.fromJson({'decision': 'nope'});

    expect(snapshot.license, 'UNEVALUATED');
    expect(snapshot.decision, PlayIntegrityDecisionLabel.allow);
  });
}
