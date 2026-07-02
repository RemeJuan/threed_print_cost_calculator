import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/core/integrity/play_integrity_decision.dart';
import 'package:threed_print_cost_calculator/core/integrity/play_integrity_models.dart';

void main() {
  test('decision helpers map hard and soft gates', () {
    expect(
      isPlayIntegrityHardBlocked(
        const PlayIntegritySnapshot(
          license: 'UNLICENSED',
          appIntegrity: 'UNEVALUATED',
          deviceIntegrity: 'UNEVALUATED',
          virtualIntegrity: 'UNEVALUATED',
          recentDeviceActivity: 'UNEVALUATED',
          playProtect: 'UNEVALUATED',
          appAccessRisk: <String>[],
          decision: PlayIntegrityDecisionLabel.blockUnlicensed,
        ),
      ),
      isTrue,
    );

    expect(
      isPlayIntegritySoftGated(
        const PlayIntegritySnapshot(
          license: 'LICENSED',
          appIntegrity: 'UNEVALUATED',
          deviceIntegrity: 'UNEVALUATED',
          virtualIntegrity: 'UNEVALUATED',
          recentDeviceActivity: 'UNEVALUATED',
          playProtect: 'UNEVALUATED',
          appAccessRisk: <String>[],
          decision: PlayIntegrityDecisionLabel.softGatePremium,
        ),
      ),
      isTrue,
    );
  });
}
